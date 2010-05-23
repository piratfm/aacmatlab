function sbr = sbr_env_noise_dec( sbr )
%4.6.18.3.4 SBR envelope and noise floor decoding
%4.6.18.3.5 Dequantization

%Input
L_E = sbr.data.bs_num_env;
L_Q = sbr.data.bs_num_noise;
N_Q = sbr.freq_tables.N_Q;
bs_amp_res = sbr.data.bs_amp_res;
bs_data_env = sbr.data.bs_data_env;
bs_data_noise = sbr.data.bs_data_noise;
bs_def_env = sbr.data.bs_df_env;
bs_def_noise = sbr.data.bs_df_noise;
r = sbr.grid.r;
n = sbr.grid.n;
r_prev = sbr.prev.r;
E_prev = sbr.prev.E;
Q_prev = sbr.prev.Q;
f_TableLow = sbr.freq_tables.f_TableLow;
f_TableHigh = sbr.freq_tables.f_TableHigh;
NOISE_FLOOR_OFFSET = sbr.fixed.NOISE_FLOOR_OFFSET;

%Envelope differential decoding
E = zeros(max(n),L_E);
E_delta = zeros(max(n),L_E);
for l=1:L_E
    for k=1:n(l)
        E_delta(k,l) = bs_data_env{l}(k);
    end
end
for l=1:L_E
    if l==1
        g = r_prev;
        g_E = E_prev;
    else
        g = r(l-1);
        g_E = E(:,l-1);
    end
    if bs_def_env(l)==0
        for k=1:n(l)
            i = 1:k;
            E(k,l) = sum( E_delta(i,l) );
        end
    elseif r(l)==g
        for k=1:n(l)
            E(k,l) = g_E(k) + E_delta(k,l);
        end
    elseif r(l)==0&&g==1
        for k=1:n(l)
            i = find(f_TableLow(k)==f_TableHigh);
            E(k,l) = g_E(i) + E_delta(k,l);
        end
    elseif r(l)==1&&g==0
        for k=1:n(l)
            i = find(f_TableLow(1:end-1)<=f_TableHigh(k)&f_TableHigh(k)<f_TableLow(2:end));
            E(k,l) = g_E(i) + E_delta(k,l);
        end
    end
end

%Noise floor differential decoding
Q = zeros(N_Q,L_Q);
Q_delta = zeros(N_Q,L_Q);
for l=1:L_Q
    for k=1:N_Q
        Q_delta(k,l) = bs_data_noise{l}(k);
    end
end
for l=1:L_Q
    for k=1:N_Q
        if bs_def_noise(l)==0
            i = 1:k;
            Q(k,l) = sum( Q_delta(i,l) );
        elseif l==1
            Q(k,l) = Q_prev(k) + Q_delta(k,1);
        else
            Q(k,l) = Q(k,l-1) + Q_delta(k,l);
        end
    end
end

%Dequantization
if bs_amp_res==0
    a = 2;
else
    a = 1;
end
E_orig = 64 * 2.^( E/a );
Q_orig = 2.^( NOISE_FLOOR_OFFSET - Q );

%Output
sbr.prev.r = r(L_E);
sbr.prev.E = E(:,L_E);
sbr.prev.Q = Q(:,L_Q);
sbr.env.L_E = L_E;
sbr.env.n = n;
sbr.env.E = E;
sbr.env.E_orig = E_orig;
sbr.env.L_Q = L_Q;
sbr.env.N_Q = N_Q;
sbr.env.Q = Q;
sbr.env.Q_orig = Q_orig;