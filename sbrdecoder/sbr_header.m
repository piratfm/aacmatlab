function [sbr,c] = sbr_header( sbr, bits )
%Table 4.63 – Syntax of sbr_header()

c = 0;
sbr.header.reset = 0;

sbr.header.bs_amp_res = bits(c+1);
c = c + 1;

bs_start_freq = bits2int( bits(c+1:c+4) );
c = c + 4;
if ~isfield(sbr.header,'bs_start_freq')||bs_start_freq~=sbr.header.bs_start_freq
    sbr.header.reset = 1;
end
sbr.header.bs_start_freq = bs_start_freq;

bs_stop_freq = bits2int( bits(c+1:c+4) );
c = c + 4;
if ~isfield(sbr.header,'bs_stop_freq')||bs_stop_freq~=sbr.header.bs_stop_freq
    sbr.header.reset = 1;
end
sbr.header.bs_stop_freq = bs_stop_freq;

bs_xover_band = bits2int( bits(c+1:c+3) );
c = c + 3;
if ~isfield(sbr.header,'bs_xover_band')||bs_xover_band~=sbr.header.bs_xover_band
    sbr.header.reset = 1;
end
sbr.header.bs_xover_band = bs_xover_band;

%Reserved
c = c + 2;

header_extra_1 = bits(c+1);
c = c + 1;
header_extra_2 = bits(c+1);
c = c + 1;

if header_extra_1
    bs_freq_scale = bits2int( bits(c+1:c+2) );
    c = c + 2;
    bs_alter_scale = bits(c+1);
    c = c + 1;
    bs_noise_bands = bits2int( bits(c+1:c+2) );
    c = c + 2;
else
    bs_freq_scale = 2;
    bs_alter_scale = 1;
    bs_noise_bands = 2;
end

if ~isfield(sbr.header,'bs_freq_scale')||bs_freq_scale~=sbr.header.bs_freq_scale
    sbr.header.reset = 1;
end
sbr.header.bs_freq_scale = bs_freq_scale;
if ~isfield(sbr.header,'bs_alter_scale')||bs_alter_scale~=sbr.header.bs_alter_scale
    sbr.header.reset = 1;
end
sbr.header.bs_alter_scale = bs_alter_scale;
if ~isfield(sbr.header,'bs_noise_bands')||bs_noise_bands~=sbr.header.bs_noise_bands
    sbr.header.reset = 1;
end
sbr.header.bs_noise_bands = bs_noise_bands;

if header_extra_2
    sbr.header.bs_limiter_bands = bits2int( bits(c+1:c+2) );
    c = c + 2;
    sbr.header.bs_limiter_gains = bits2int( bits(c+1:c+2) );
    c = c + 2;
    sbr.header.bs_interpol_freq = bits(c+1);
    c = c + 1;
    sbr.header.bs_smoothing_mode = bits(c+1);
    c = c + 1;
else
    sbr.header.bs_limiter_bands = 2;
    sbr.header.bs_limiter_gains = 2;
    sbr.header.bs_interpol_freq = 1;
    sbr.header.bs_smoothing_mode = 1;
end