function sbr = sbr_frequency_band_tables( sbr )
%4.6.18.3.2 Frequency band tables

%Input
Fs = sbr.samplingFrequency;
bs_start_freq = sbr.header.bs_start_freq;
bs_stop_freq = sbr.header.bs_stop_freq;
bs_xover_band = sbr.header.bs_xover_band;
bs_freq_scale = sbr.header.bs_freq_scale;
bs_alter_scale = sbr.header.bs_alter_scale;
bs_noise_bands = sbr.header.bs_noise_bands;
bs_limiter_bands = sbr.header.bs_limiter_bands;

%Master frequency band table (4.6.18.3.2.1)
if Fs==16000
    offset = [ -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2,  3,  4,  5,  6,  7 ];
elseif Fs==22050
    offset = [ -5, -4, -3, -2, -1,  0,  1,  2, 3, 4, 5,  6,  7,  9, 11, 13 ];
elseif Fs==24000
    offset = [ -5, -3, -2, -1,  0,  1,  2,  3, 4, 5, 6,  7,  9, 11, 13, 16 ];
elseif Fs==32000
    offset = [ -6, -4, -2, -1,  0,  1,  2,  3, 4, 5, 6,  7,  9, 11, 13, 16 ];
elseif Fs>=44100 && Fs<=64000
    offset = [ -4, -2, -1,  0,  1,  2,  3,  4, 5, 6, 7,  9, 11, 13, 16, 20 ];
elseif Fs>64000
    offset = [ -2, -1,  0,  1,  2,  3,  4,  5, 6, 7, 9, 11, 13, 16, 20, 24 ];
else
    error 'Unsupported Sampling Frequency';
end
if Fs<32000
    startMin = round( 3000*128/Fs );
    stopMin  = round( 6000*128/Fs );
elseif Fs>=32000 && Fs<64000
    startMin = round( 4000*128/Fs );
    stopMin  = round( 8000*128/Fs );
elseif Fs>=64000
    startMin = round(  5000*128/Fs );
    stopMin  = round( 10000*128/Fs );
else
    error 'Unsupported Sampling Frequency';
end
p = 0:12;
stopDk = round( stopMin*(64/stopMin).^((p+1)/13) ) - round( stopMin*(64/stopMin).^(p/13) );
stopDkSort = sort( stopDk );
k0 = startMin + offset( bs_start_freq+1 );
if 0<=bs_stop_freq && bs_stop_freq<14
    k2 = min( 64, stopMin+sum(stopDkSort(1:bs_stop_freq)) );
elseif bs_stop_freq==14
    k2 = min( 64, 2*k0 );
elseif bs_stop_freq==15
    k2 = min( 64, 3*k0 );
end
if bs_freq_scale==0
    if bs_alter_scale==0
        dk = 1;
        numBands = 2*floor( (k2-k0)/(dk*2) );
    else
        dk = 2;
        numBands = 2*round( (k2-k0)/(dk*2) );
    end
    k2Achieved = k0 + numBands * dk;
    k2Diff = k2 - k2Achieved;
    for k=0:numBands-1
        vDk(k+1) = dk;
    end
    if k2Diff~=0
        if k2Diff > 0
            incr = -1;
            k = numBands-1;
        else
            incr = 1;
            k = 0;
        end
        while k2Diff ~= 0
            vDk(k+1) = vDk(k+1)-incr;
            k  = k + incr;
            k2Diff = k2Diff + incr;
        end
    end
    f_master(1) = k0;
    for k=1:numBands
        f_master(k+1) = f_master(k) + vDk(k);
    end
    N_master = numBands;
else
    temp1 = [12 10 8];
    bands = temp1( bs_freq_scale );
    temp2 = [1.0 1.3];
    warp = temp2( bs_alter_scale+1 );
    if k2/k0>2.2449
        twoRegions = 1;
        k1 = 2 * k0;
    else
        twoRegions = 0;
        k1 = k2;
    end
    numBands0 = 2*round( bands * log(k1/k0) / (2*log(2)) );
    k = 0:numBands0-1;
    vDk0 = round( k0*(k1/k0).^((k+1)/numBands0) ) - round( k0*(k1/k0).^(k/numBands0) );
    vDk0 = sort( vDk0 );
    vk0(1) = k0;
    for k=1:numBands0
        vk0(k+1) = vk0(k) + vDk0(k);
    end
    if twoRegions==1
        numBands1 = 2*round( bands * log(k2/k1) / (2*log(2)*warp) );
        k = 0:numBands1-1;
        vDk1 = round( k1*(k2/k1).^((k+1)/numBands1) ) - round( k1*(k2/k1).^(k/numBands1) );
        if min(vDk1)<max(vDk0)
            vDk1 = sort( vDk1 );
            change = max(vDk0)-vDk1(1);
            if change>floor((vDk1(end)-vDk1(1))/2)
                change = floor((vDk1(end)-vDk1(1))/2);
            end
            vDk1(1) = vDk1(1) + change;
            vDk1(end) = vDk1(end) - change;
        end
        vDk1 = sort( vDk1 );
        vk1(1) = k1;
        for k=1:numBands1
            vk1(k+1) = vk1(k) + vDk1(k);
        end
        N_master = numBands0+numBands1;
        f_master = vk0;
        for k=0:numBands0
            f_master(k+1) = vk0(k+1);
        end
        for k=numBands0+1:N_master
            f_master(k+1) = vk1(k+1-numBands0);
        end
    else
        N_master = numBands0;
        f_master = vk0;
    end
end

%Derived frequency band tables (4.6.18.3.2.2)
N_high = N_master - bs_xover_band;
N_low = floor(N_high/2) + (N_high-2*floor(N_high/2));
n = [N_low N_high];
f_TableHigh = f_master( (1:N_high+1) + bs_xover_band );
M = f_TableHigh(N_high+1) - f_TableHigh(1);
kx = f_TableHigh(1);
i = [0 2*(1:N_low)-(1-(-1)^N_high)/2];
f_TableLow = f_TableHigh(i+1);
N_Q = max(1,round( bs_noise_bands*log(k2/kx)/log(2) ));
i = zeros(1,N_Q+1);
for k=1:N_Q
    i(k+1) = i(k) + floor( (N_low-i(k))/(N_Q+1-k) );
end
f_TableNoise = f_TableLow(i+1);

%Patch construction (Figure 4.47)
msb = k0;
usb = kx;
numPatches = 0;
goalSb = round( 2.048e6 / Fs );
if goalSb<kx+M
    i = 0;
    k = 0;
    while f_master(i+1)<goalSb
        k = i+1;
        i = i+1;
    end
else
    k = N_master;
end
while 1
    j = k;
    while 1
        sb = f_master(j+1);
        odd = mod( (sb - 2 + k0), 2);
        if sb <= (k0 - 1 + msb - odd)
            break;
        end
        j = j - 1;
    end
    patchNumSubbands(numPatches+1) = max(sb - usb, 0);
    patchStartSubband(numPatches+1) = k0 - odd - patchNumSubbands(numPatches+1);
    if patchNumSubbands(numPatches+1) > 0
        usb = sb;
        msb = sb;
        numPatches = numPatches+1;
    else
        msb = kx;
    end
    if f_master(k+1) - sb < 3
        k = N_master;
    end
    if sb == (kx + M)
        break;
    end
end
if patchNumSubbands(numPatches) < 3 && numPatches > 1
    numPatches = numPatches -1;
end

%Limiter frequency band table (4.6.18.3.2.3)
if bs_limiter_bands==0
    f_TableLim = [f_TableLow(1) f_TableLow(end)];
    N_L = 1;
else
    limiterBandsPerOctave = [ 1.2, 2, 3 ];
    limBands = limiterBandsPerOctave(bs_limiter_bands);
    patchBorders(1) = kx;
    for k=1:numPatches
        patchBorders(k+1) = patchBorders(k) + patchNumSubbands(k);
    end
    for k=0:N_low
        limTable(k+1) = f_TableLow(k+1);
    end
    for k=1:numPatches-1
      limTable(k+1+N_low) = patchBorders(k+1);
    end
    limTable = sort(limTable);
    k = 1;
    nrLim = N_low + numPatches - 1;
    while 1
        if k>nrLim
            N_L = nrLim;
            f_TableLim = limTable;
            break;
        else
            nOctaves = log2( limTable(k+1) / limTable(k) );
            if ( nOctaves * limBands ) < 0.49
                if limTable(k+1) == limTable(k)
                    limTable(k+1) = [];
                    nrLim = nrLim - 1;
                else
                    if ~isempty(find(patchBorders==limTable(k+1), 1))
                        if ~isempty(find(patchBorders==limTable(k), 1))
                            k = k+1;
                        else
                            limTable(k) = [];
                            nrLim = nrLim - 1;
                        end
                    else
                        limTable(k+1) = [];
                        nrLim = nrLim - 1;
                    end
                end
            else
                k = k+1;
            end
        end
    end
end

%Output
sbr.freq_tables.k0 = k0;
sbr.freq_tables.kx = kx;
sbr.freq_tables.k2 = k2;
sbr.freq_tables.M = M;
sbr.freq_tables.n = n;
sbr.freq_tables.N_low = N_low;
sbr.freq_tables.f_TableLow = f_TableLow;
sbr.freq_tables.N_high = N_high;
sbr.freq_tables.f_TableHigh = f_TableHigh;
sbr.freq_tables.N_Q = N_Q;
sbr.freq_tables.f_TableNoise = f_TableNoise;
sbr.freq_tables.N_L = N_L;
sbr.freq_tables.f_TableLim = f_TableLim;
sbr.freq_tables.numPatches = numPatches;
sbr.freq_tables.patchNumSubbands = patchNumSubbands;
sbr.freq_tables.patchStartSubband = patchStartSubband;