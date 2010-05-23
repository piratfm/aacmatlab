function [sbr,c] = sbr_invf( sbr, bits )
%Table 4.71 – Syntax of sbr_invf()

%Input
num_noise_bands = sbr.freq_tables.N_Q;

%Init
c = 0;

%Decode
for n=1:num_noise_bands
    bs_invf_mode(n) = bits2int( bits(c+1:c+2) );
    c = c + 2;
end

%Ouput
sbr.data.bs_invf_mode = bs_invf_mode;