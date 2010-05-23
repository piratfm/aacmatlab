function [sbr,c] = sbr_grid( sbr, bits )
%Table 4.69 – Syntax of sbr_grid()

%Init
c = 0;

%Default values
bs_amp_res = sbr.header.bs_amp_res;
bs_num_env = [];
bs_freq_res = [];
bs_var_bord_0 = [];
bs_num_rel_0 = [];
bs_rel_bord_0 = [];
bs_var_bord_1 = [];
bs_num_rel_1 = [];
bs_rel_bord_1 = [];
bs_pointer = [];

%Frame class
bs_frame_class = bits2int( bits(c+1:c+2) );
c = c + 2;

%Decode time segments parameters
switch bs_frame_class
    
    case 0 %FIXFIX
        
        tmp = bits2int( bits(c+1:c+2) );
        c = c + 2;
        bs_num_env = 2^tmp;
        
        if bs_num_env==1
            bs_amp_res = 0;
        end
        
        tmp = bits(c+1);
        c = c + 1;
        bs_freq_res = tmp*ones(1,bs_num_env);
        
    case 1 %FIXVAR
        
        bs_var_bord_1 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        
        bs_num_rel_1 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        
        bs_num_env = bs_num_rel_1+1;
        
        for n=1:bs_num_env-1
            tmp = bits2int( bits(c+1:c+2) );
            c = c + 2;
            bs_rel_bord_1(n) = 2*tmp + 2;
        end
        
        ptr_bits = ceil (log ( bs_num_env + 1) / log (2));
        bs_pointer = bits2int( bits(c+1:c+ptr_bits) );
        c = c + ptr_bits;
        
        for n=1:bs_num_env
            tmp = bits(c+1);
            c = c + 1;
            bs_freq_res(bs_num_env-n+1) = tmp;
        end
        
    case 2 %VARFIX
        
        bs_var_bord_0 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        
        bs_num_rel_0 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        
        bs_num_env = bs_num_rel_0+1;
        
        for n=1:bs_num_env-1
            tmp = bits2int( bits(c+1:c+2) );
            c = c + 2;
            bs_rel_bord_0(n) = 2*tmp + 2;
        end
        
        ptr_bits = ceil (log ( bs_num_env + 1) / log (2));
        bs_pointer = bits2int( bits(c+1:c+ptr_bits) );
        c = c + ptr_bits;
        
        for n=1:bs_num_env
            tmp = bits(c+1);
            c = c + 1;
            bs_freq_res(n) = tmp;
        end
        
    case 3 %VARVAR

        bs_var_bord_0 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        bs_var_bord_1 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        
        bs_num_rel_0 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        bs_num_rel_1 = bits2int( bits(c+1:c+2) );
        c = c + 2;
        
        bs_num_env = bs_num_rel_0+bs_num_rel_1+1;
        
        for n=1:bs_num_rel_0
            tmp = bits2int( bits(c+1:c+2) );
            c = c + 2;
            bs_rel_bord_0(n) = 2*tmp + 2;
        end
        for n=1:bs_num_rel_1
            tmp = bits2int( bits(c+1:c+2) );
            c = c + 2;
            bs_rel_bord_1(n) = 2*tmp + 2;
        end
        
        ptr_bits = ceil (log ( bs_num_env + 1) / log (2));
        bs_pointer = bits2int( bits(c+1:c+ptr_bits) );
        c = c + ptr_bits;
        
        for n=1:bs_num_env
            tmp = bits(c+1);
            c = c + 1;
            bs_freq_res(n) = tmp;
        end
end

%Number of sbr envelopes and noise floors
if bs_frame_class == 3
    bs_num_env = min( bs_num_env, 5 );
else
    bs_num_env = min( bs_num_env, 4 );
end
if bs_num_env > 1
    bs_num_noise = 2;
else
    bs_num_noise = 1;
end

%Output
sbr.data.bs_amp_res = bs_amp_res;
sbr.data.bs_frame_class = bs_frame_class;
sbr.data.bs_num_env = bs_num_env;
sbr.data.bs_num_noise = bs_num_noise;
sbr.data.bs_freq_res = bs_freq_res;
sbr.data.bs_var_bord_0 = bs_var_bord_0;
sbr.data.bs_num_rel_0 = bs_num_rel_0;
sbr.data.bs_rel_bord_0 = bs_rel_bord_0;
sbr.data.bs_var_bord_1 = bs_var_bord_1;
sbr.data.bs_num_rel_1 = bs_num_rel_1;
sbr.data.bs_rel_bord_1 = bs_rel_bord_1;
sbr.data.bs_pointer = bs_pointer;