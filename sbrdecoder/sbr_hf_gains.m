function sbr = sbr_hf_gains( sbr )
%HF adjustment
%See 4.6.18.7

%Input
RATE = sbr.fixed.RATE;
tHFadj = sbr.fixed.tHFadj;
epsilon = sbr.fixed.epsilon;
bs_interpol_freq = sbr.header.bs_interpol_freq;
bs_limiter_gains = sbr.header.bs_limiter_gains;
kx = sbr.freq_tables.kx;
M = sbr.freq_tables.M;
L_E = sbr.data.bs_num_env;
N_Q = sbr.freq_tables.N_Q;
t_E = sbr.grid.t_E;
t_Q = sbr.grid.t_Q;
n = sbr.grid.n;
F = sbr.grid.F;
Xhigh = sbr.qmfa.Xhigh;
E_orig = sbr.env.E_orig;
Q_orig = sbr.env.Q_orig;
N_high = sbr.freq_tables.N_high;
f_TableHigh = sbr.freq_tables.f_TableHigh;
f_TableNoise = sbr.freq_tables.f_TableNoise;
N_L = sbr.freq_tables.N_L;
f_TableLim = sbr.freq_tables.f_TableLim;
bs_frame_class = sbr.data.bs_frame_class;
bs_pointer = sbr.data.bs_pointer;
S_IndexMapped_prev = sbr.prev.S_IndexMapped;
bs_add_harmonic_flag = sbr.data.bs_add_harmonic_flag;
bs_add_harmonic = sbr.data.bs_add_harmonic;
l_A_prev = sbr.prev.l_A_prev;

%Mapping (4.6.18.7.2)
E_origmapped = zeros(M,L_E);
for l=1:L_E
    for i=1:n(l)
        for m=F(i,l)+1:F(i+1,l)
            E_origmapped(m-kx,l) = E_orig(i,l);
        end
    end
end
Q_mapped = zeros(M,L_E);
for l=1:L_E
    for i=1:N_Q
        for m=f_TableNoise(i)+1:f_TableNoise(i+1)
            k = find(RATE*t_E(l)>=RATE*t_Q(1:end-1)&RATE*t_E(l+1)<=RATE*t_Q(2:end));
            Q_mapped(m-kx,l) = Q_orig(i,k);
        end
    end
end
if bs_frame_class==0
    l_A = -1;
elseif bs_frame_class==2
    if bs_pointer > 1
        l_A = bs_pointer - 1;
    else
        l_A = -1;
    end
else
    if bs_pointer == 0
        l_A = -1;
    else
        l_A = L_E + 1 - bs_pointer;
    end
end
if bs_add_harmonic_flag
    S_Index = bs_add_harmonic;
else
    S_Index = zeros(1,N_high);
end
S_IndexMapped = zeros(M,L_E);
for l=1:L_E
    for i=1:N_high
        for m=f_TableHigh(i)+1:f_TableHigh(i+1)
            if m==floor((f_TableHigh(i+1)+f_TableHigh(i))/2)+1
                if l>=l_A+1 || S_IndexMapped_prev(m-kx)==1
                    d_step = 1;
                else
                    d_step = 0;
                end
                S_IndexMapped(m-kx,l) = S_Index(i)*d_step;
            end
        end
    end
end
S_mapped = zeros(M,L_E);
for l=1:L_E
    for i=1:n(l)
        for m=F(i,l)+1:F(i+1,l)
            j = F(i,l)+1:F(i+1,l);
            if ~isempty(find(S_IndexMapped(j-kx,l)==1, 1))
                delta_S = 1;
            else
                delta_S = 0;
            end
            S_mapped(m-kx,l) = delta_S;
        end
    end
end

%Estimation of current envelope (4.6.18.7.3)
E_curr = zeros(M,L_E);
if bs_interpol_freq==1
    for l=1:L_E
        for m=1:M
            i = RATE*t_E(l)+tHFadj+1 : RATE*t_E(l+1)+tHFadj;
            E_curr(m,l) = sum( abs( Xhigh( m+kx, i ) ).^2 ) / (  RATE*t_E(l+1)-RATE*t_E(l) );
        end
    end
else
    for l=1:L_E
        for p=1:n(l)
            kl = F(p,l)+1;
            kh = F(p+1,l);
            for k=kl:kh
                i = RATE*t_E(l)+tHFadj+1 : RATE*t_E(l+1)+tHFadj;
                j = kl:kh;
                E_curr(k-kx,l) = sum( sum( abs( Xhigh( j, i ) ).^2 )) / (  (RATE*t_E(l+1)-RATE*t_E(l))*(kh-kl+1) );
            end
        end
    end
end

%Calculation of levels of additional HF signal components (4.6.18.7.4)
Q_M = sqrt( E_origmapped.*Q_mapped./(1+Q_mapped) );
S_M = sqrt( E_origmapped.*S_IndexMapped./(1+Q_mapped) );

%Calculation of gain (4.6.18.7.5)
G = zeros(M,L_E);
for l=1:L_E
    if l==l_A+1 || l==l_A_prev+1
        delta = 0;
    else
        delta = 1;
    end
    for m=1:M
        if S_mapped(m,l)==0
            G(m,l) = sqrt( E_origmapped(m,l)/((epsilon+E_curr(m,l))*(1+delta*Q_mapped(m,l))) );
        else
            G(m,l) = sqrt( E_origmapped(m,l)*Q_mapped(m,l)/((epsilon+E_curr(m,l))*(1+Q_mapped(m,l))) );
        end
    end
end
limGain = [0.70795, 1.0, 1.41254, 1e10];
Gmaxtemp = zeros(N_L,L_E);
for l=1:L_E
    for k=1:N_L
        i = f_TableLim(k)-kx+1:f_TableLim(k+1)-kx;
        Gmaxtemp(k,l) = sqrt((1e-12+sum(E_origmapped(i,l)))/(1e-12+sum(E_curr(i,l))))*limGain(bs_limiter_gains+1);
    end
end
Gmax = zeros(M,L_E);
for l=1:L_E
    for m=1:M
        k = find( f_TableLim(1:end-1)<m+kx & m+kx<=f_TableLim(2:end) );
        Gmax(m,l) = min( Gmaxtemp(k,l), 1e5 );
    end
end
QMlim = zeros(M,L_E);
Glim = zeros(M,L_E);
for l=1:L_E
    for m=1:M
        QMlim(m,l) = min( Q_M(m,l), Q_M(m,l)*Gmax(m,l)/G(m,l) );
        Glim(m,l) = min( G(m,l), Gmax(m,l) );
    end
end
Gboosttemp = zeros(N_L,L_E);
for l=1:L_E
    for k=1:N_L
        i = f_TableLim(k)-kx+1:f_TableLim(k+1)-kx;
        if l==l_A+1 || l==l_A_prev+1
            delta = zeros(length(i),1);
        else
            delta = S_M(i,l)==0;
        end
        Gboosttemp(k,l) = sqrt((1e-12+sum(E_origmapped(i,l)))/(1e-12+sum(E_curr(i,l).*Glim(i,l).^2+S_M(i,l).^2+delta.*QMlim(i,l).^2)));
    end
end
Gboost = zeros(M,L_E);
for l=1:L_E
    for m=1:M
        k = find( f_TableLim(1:end-1)<m+kx & m+kx<=f_TableLim(2:end) );
        Gboost(m,l) = min( Gboosttemp(k,l), 1.584893192 );
    end
end
G_LimBoost = Glim.*Gboost;
Q_M_LimBoost = QMlim.*Gboost;
S_M_Boost = S_M.*Gboost;

%Output
sbr.prev.S_IndexMapped = S_IndexMapped(:,L_E);
sbr.env.l_A = l_A;
sbr.env.G_LimBoost = G_LimBoost;
sbr.env.Q_M_LimBoost = Q_M_LimBoost;
sbr.env.S_M_Boost = S_M_Boost;