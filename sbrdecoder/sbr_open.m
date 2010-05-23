function sbr = sbr_open( aac )

%Copy useful data
sbr.samplingFrequencyIndex = aac.samplingFrequencyIndex-3;
sbr.samplingFrequency = aac.samplingFrequency*2;

%Init
sbr.fixed.numTimeSlots = 16;
sbr.fixed.RATE = 2;
sbr.fixed.tHFgen = 8;
sbr.fixed.tHFadj = 2;
sbr.fixed.NOISE_FLOOR_OFFSET = 6;
sbr.fixed.epsilon = 1;
sbr.fixed.V = sbr_noise_table();
sbr.header_flag = 0;
sbr.header_present = 0;
sbr.header = [];
sbr.freq_tables = [];
sbr.data = [];
sbr.grid = [];
sbr.env = [];
sbr.prev.kx = 0;
sbr.prev.M = 0;
sbr.prev.r = 0;
sbr.prev.E = zeros(1,49);
sbr.prev.Q = zeros(1,49);
sbr.prev.bs_invf_mode = zeros(1,4);
sbr.prev.bwArray = zeros(1,4);
sbr.prev.S_IndexMapped = zeros(1,49);
sbr.prev.l_A_prev = -1;
sbr.prev.Gtemp = zeros(49,4);
sbr.prev.Qtemp = zeros(49,4);
sbr.prev.indexNoise = 0;
sbr.prev.indexSine = -1;
sbr.qmfa.x = zeros(320,1);
sbr.qmfa.c = qmf_c()';
sbr.qmfa.M = zeros(32,64);
for k=1:32
    for n=1:64
        sbr.qmfa.M(k,n) = 2*exp( (1i*pi*(k-0.5)*(2*n-2.5))/64 );
    end
end
sbr.qmfa.Xlow = zeros(32,40);
sbr.qmfa.Xhigh = zeros(64,40);
sbr.qmfs.Y = zeros(64,40);
sbr.qmfs.X = zeros(64,40);
sbr.qmfs.v = zeros(1280,1);
sbr.qmfs.N = zeros(128,64);
for k=1:64
    for n=1:128
        sbr.qmfs.N(n,k) = (1/64)*exp( (1i*pi*((k-1)+0.5)*(2*(n-1)-255))/128 );
    end
end