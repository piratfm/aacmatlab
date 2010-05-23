function sbr = sbr_hf_assembly( sbr )
%4.6.18.7.6 Assembling HF signals

%Input
RATE = sbr.fixed.RATE;
tHFadj = sbr.fixed.tHFadj;
bs_smoothing_mode = sbr.header.bs_smoothing_mode;
L_E = sbr.data.bs_num_env;
t_E = sbr.grid.t_E;
M = sbr.freq_tables.M;
kx = sbr.freq_tables.kx;
l_A = sbr.env.l_A;
l_A_prev = sbr.prev.l_A_prev;
G_LimBoost = sbr.env.G_LimBoost;
Q_M_LimBoost = sbr.env.Q_M_LimBoost;
S_M_Boost = sbr.env.S_M_Boost;
Gtemp_prev = sbr.prev.Gtemp;
Qtemp_prev = sbr.prev.Qtemp;
Xhigh = sbr.qmfa.Xhigh;
V = sbr.fixed.V;
indexNoise_prev = sbr.prev.indexNoise;
indexSine_prev = sbr.prev.indexSine;

%Smoothed gain values
if bs_smoothing_mode==0
    h_SL = 4;
else
    h_SL = 0;
end
h_Smooth = [0.33333333333333;
            0.30150283239582;
            0.21816949906249;
            0.11516383427084;
            0.03183050093751]';
Gtemp = zeros(M,40);
Qtemp = zeros(M,40);
if sbr.header.reset
    for l=1:4
        Gtemp(:,RATE*t_E(1)+l) = G_LimBoost(:,1);
        Qtemp(:,RATE*t_E(1)+l) = Q_M_LimBoost(:,1);
    end
else
    for l=1:4
        Gtemp(:,RATE*t_E(1)+l) = Gtemp_prev(:,l);
        Qtemp(:,RATE*t_E(1)+l) = Qtemp_prev(:,l);
    end
end
for l=1:L_E
    for i=RATE*t_E(l)+1:RATE*t_E(l+1)
        for m=1:M
            Gtemp(m,i+4) = G_LimBoost(m,l);
            Qtemp(m,i+4) = Q_M_LimBoost(m,l);
        end
    end
end
Gfilt = zeros(M,40);
Qfilt = zeros(M,40);
for l=1:L_E
    for i=RATE*t_E(l)+1:RATE*t_E(l+1)
        for m=1:M
            if l~=l_A+1 && l~=l_A_prev+1 && h_SL~=0
                j = 0:h_SL;
                Gfilt(m,i) = sum( Gtemp(m,i-j+4).*h_Smooth );
            else
                Gfilt(m,i) = Gtemp(m,i+4);
            end
            if l~=l_A+1 && l~=l_A_prev+1 && h_SL~=0 && S_M_Boost(m,l)==0 
                j = 0:h_SL;
                Qfilt(m,i) = sum( Qtemp(m,i-j+4).*h_Smooth );
            elseif l~=l_A+1 && l~=l_A_prev+1 && h_SL==0 && S_M_Boost(m,l)==0 
                Qfilt(m,i) = Qtemp(m,i+4);
            else
                Qfilt(m,i) = 0;
            end
        end
    end
end

%Init
W1 = zeros(64,40);
W2 = zeros(64,40);
Y = zeros(64,40);

%Apply gain to input subband matrix
for i = RATE*t_E(1)+1:RATE*t_E(L_E+1)
    for m = 1:M
        W1(m,i) = Gfilt(m,i) * Xhigh( m+kx, i+tHFadj );
    end
end

%Add pseudo-random noise
if sbr.header.reset
    indexNoise = 0;
else
    indexNoise = indexNoise_prev;
end
for i = RATE*t_E(1)+1:RATE*t_E(L_E+1)
    for m = 1:M
        f_IndexNoise = mod( indexNoise + (i-(RATE*t_E(1)+1))*M+m, 512 );
        W2(m,i) = W1(m,i) + Qfilt(m,i)*(V(1,f_IndexNoise+1)+1i*V(2,f_IndexNoise+1));
    end
end

%Add sinusoids
indexSine = mod(indexSine_prev+1,4);
phi = [[1,0,-1,0];[0,1,0,-1]];
for l=1:L_E
    for i=RATE*t_E(l)+1:RATE*t_E(l+1)
        for m = 1:M
            f_IndexSine = mod( indexSine + i-(RATE*t_E(1)+1), 4 );
            Y( m+kx, i+tHFadj ) = W2(m,i) + S_M_Boost(m,l)*(phi(1,f_IndexSine+1)+1i*(-1)^(m+kx-1)*phi(2,f_IndexSine+1));
        end
    end
end

%Output
sbr.prev.Gtemp = Gtemp(:,RATE*t_E(L_E+1)+4-3:RATE*t_E(L_E+1)+4);
sbr.prev.Qtemp = Qtemp(:,RATE*t_E(L_E+1)+4-3:RATE*t_E(L_E+1)+4);
sbr.prev.indexNoise = f_IndexNoise;
sbr.prev.indexSine = f_IndexSine;
if sbr.env.l_A==sbr.env.L_E
    sbr.prev.l_A_prev = 0;
else
    sbr.prev.l_A_prev = -1;
end
sbr.qmfs.Y = Y;