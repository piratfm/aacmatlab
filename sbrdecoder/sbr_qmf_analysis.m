function sbr = sbr_qmf_analysis( sbr, pcm )
%QMF analysis filterbank
%See 4.6.18.4.1, 4.6.18.5 and Figure 4.41

%Input
numTimeSlots = sbr.fixed.numTimeSlots;
RATE = sbr.fixed.RATE;
tHFgen = sbr.fixed.tHFgen;
Xlow = sbr.qmfa.Xlow;
x = sbr.qmfa.x;
c = sbr.qmfa.c;
M = sbr.qmfa.M;
if sbr.header_present
    kx = sbr.freq_tables.kx;
else
    kx = 32;
end

%Init
l_f = numTimeSlots*RATE;
W = zeros(32,l_f);

%Loop over time slots
for l=1:l_f
    
    %Shift samples
    n = 320:-1:33;
    x(n) = x(n-32);
    
    %Add new samples
    x(32:-1:1) = pcm((l-1)*32+1:l*32);
    
    %Windowing
    z = x .* c(1:2:end);
    
    %Create u
    u = zeros(64,1);
    for n=1:64
        u(n) = sum( z(n+(0:4)*64) );
    end
    
    %Transform
    W(:,l) = M*u;
end

%Filter and Delay
l = 1:tHFgen;
Xlow(:,l) = Xlow(:,32+l);
l = tHFgen+1:tHFgen+l_f;
Xlow(1:kx,l) = W(1:kx,:);
Xlow(kx+1:32,l) = 0;

%Output
sbr.qmfa.Xlow = Xlow;
sbr.qmfa.x = x;