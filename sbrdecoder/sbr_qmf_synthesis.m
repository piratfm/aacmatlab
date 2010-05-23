function [sbr,pcm] = sbr_qmf_synthesis( sbr )
%4.6.18.4.2 Synthesis filterbank

%Input
numTimeSlots = sbr.fixed.numTimeSlots;
RATE = sbr.fixed.RATE;
tHFadj = sbr.fixed.tHFadj;
if sbr.header_present
    t_E = sbr.grid.t_E;
    M = sbr.freq_tables.M;
    kx = sbr.freq_tables.kx;
else
    t_E = 0;
    M = 0;
    kx = 32;
end
Xlow = sbr.qmfa.Xlow;
c = sbr.qmfa.c;
Y = sbr.qmfs.Y;
X = sbr.qmfs.X;
v = sbr.qmfs.v;
N = sbr.qmfs.N;

%Init
pcm = zeros(2048,1);

%Construct input matrix X
l_Temp = RATE*t_E(1)+1;
l_f = RATE*numTimeSlots;
X(:,1:l_Temp-1) = X(:,l_f+1:l_f+l_Temp-1);
X(1:kx,l_Temp:40-tHFadj) = Xlow(1:kx,l_Temp+tHFadj:40);
X(kx+1:kx+M,l_Temp:40-tHFadj) = Y(kx+1:kx+M,l_Temp+tHFadj:40);
X(kx+M+1:64,l_Temp:40-tHFadj) = 0;

%Loop over time slots
for l=1:l_f
    
    %Shift the samples in the array v by 128 positions
    n = 1280:-1:129;
    v(n) = v(n-128);
    
    %Transform
    v(1:128) = real( N*X(:,l) );
    
    %Extract samples from v
    g = zeros(640,1);
    for n=0:4
        k = 0:63;
        g( 128*n+k+1 ) =  v( 256*n+k+1 );
        g( 128*n+64+k+1 ) =  v( 256*n+192+k+1 );
    end
    
    %Windowing
    w = g .* c;
    
    %Output samples
    for k=0:63
        n=0:9;
        pcm( (l-1)*64+k+1 ) = sum( w(64*n+k+1) );
    end
end

%Output
sbr.qmfs.X = X;
sbr.qmfs.v = v;