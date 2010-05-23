function sbr = sbr_hf_generation( sbr )
%HF generation
%See 4.6.18.6

%Input
numTimeSlots = sbr.fixed.numTimeSlots;
RATE = sbr.fixed.RATE;
tHFadj = sbr.fixed.tHFadj;
kx = sbr.freq_tables.kx;
N_Q = sbr.freq_tables.N_Q;
f_TableNoise = sbr.freq_tables.f_TableNoise+1;
t_E = sbr.grid.t_E;
Xlow = sbr.qmfa.Xlow;
bs_invf_mode = sbr.data.bs_invf_mode;
bs_invf_mode_prev = sbr.prev.bs_invf_mode;
bwArray_prev = sbr.prev.bwArray;
numPatches = sbr.freq_tables.numPatches;
patchNumSubbands = sbr.freq_tables.patchNumSubbands;
patchStartSubband = sbr.freq_tables.patchStartSubband;

%Inverse filtering parameters (4.6.18.6.2)
%Prediction filter coefficients
alpha0 = zeros(1,kx);
alpha1 = zeros(1,kx);
for k=1:kx
    phi = zeros(3,2);
    n = 1:numTimeSlots*RATE+6;
    for i=0:2
        for j=1:2
            phi(i+1,j+1) = sum( Xlow(k,n-i+tHFadj) .* conj( Xlow(k,n-j+tHFadj) ) );
        end
    end
    d = phi(3,3)*phi(2,2) - abs(phi(2,3)).^2/(1+1e-6);
    if d==0
        alpha1(k) = 0;
    else
        alpha1(k) = (phi(1,2)*phi(2,3)-phi(1,3)*phi(2,2))/d;
    end
    if phi(2,2)==0
        alpha0(k) = 0;
    else
        alpha0(k) = -(phi(1,2)+alpha1(k)*conj(phi(2,3)))/phi(2,2);
    end
    if abs(alpha0(k))>=4||abs(alpha1(k))>=4
        alpha0(k) = 0;
        alpha1(k) = 0;
    end
end
%Chirp factors
table = [0.00 0.60 0.90 0.98;
         0.60 0.75 0.90 0.98;
         0.00 0.75 0.90 0.98;
         0.00 0.75 0.90 0.98];
bwArray = zeros(1,N_Q);
for i=1:N_Q
    newBw = table(bs_invf_mode_prev(i)+1,bs_invf_mode(i)+1);
    if newBw<bwArray_prev(i)
        tempBw = 0.75000*newBw + 0.25000*bwArray_prev(i);
    else
        tempBw = 0.90625*newBw + 0.09375*bwArray_prev(i);
    end
    if tempBw<0.015625
        bwArray(i) = 0;
    else
        bwArray(i) = tempBw;
    end
end

%HF generator (4.6.18.6.3)
Xhigh = zeros(64,40);
l = RATE*t_E(1)+1:RATE*t_E(end);
for i=1:numPatches
    for x=1:patchNumSubbands(i)
        k = kx + x + sum(patchNumSubbands(1:i-1));
        p = patchStartSubband(i) + x;
        g = find(f_TableNoise(1:end-1)<=k&k<f_TableNoise(2:end));
        Xhigh( k, l+tHFadj ) = Xlow( p, l+tHFadj ) +...
            bwArray(g)*alpha0(p)*Xlow( p, l-1+tHFadj ) +...
            (bwArray(g)^2)*alpha1(p)*Xlow( p, l-2+tHFadj );
    end
end

%Output
sbr.prev.bs_invf_mode = bs_invf_mode;
sbr.prev.bwArray = bwArray;
sbr.qmfa.Xhigh = Xhigh;