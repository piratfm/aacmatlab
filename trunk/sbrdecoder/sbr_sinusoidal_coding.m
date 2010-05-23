function [sbr,c] = sbr_sinusoidal_coding( sbr, bits )
%Table 4.74 – Syntax of sbr_sinusoidal_coding()

%Input
num_high_res = sbr.freq_tables.N_high;

%Init
c = 0;

%Decode
bs_add_harmonic_flag = bits(c+1);
c = c + 1;
if bs_add_harmonic_flag
    for n=1:num_high_res
        bs_add_harmonic(n) = bits(c+1);
        c = c + 1;
    end
else
    bs_add_harmonic = [];
end

%Output
sbr.data.bs_add_harmonic_flag = bs_add_harmonic_flag;
sbr.data.bs_add_harmonic = bs_add_harmonic;