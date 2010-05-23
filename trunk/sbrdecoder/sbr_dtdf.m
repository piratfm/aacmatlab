function [sbr,c] = sbr_dtdf( sbr, bits )
%Table 4.70 – Syntax of sbr_dtdf()

%Input
bs_num_env = sbr.data.bs_num_env;
bs_num_noise = sbr.data.bs_num_noise;

%Init
c = 0;

%Decode
for n=1:bs_num_env
    bs_df_env(n) = bits(c+1);
    c = c + 1;
end
for n=1:bs_num_noise
    bs_df_noise(n) = bits(c+1);
    c = c + 1;
end

%Ouput
sbr.data.bs_df_env = bs_df_env;
sbr.data.bs_df_noise = bs_df_noise;