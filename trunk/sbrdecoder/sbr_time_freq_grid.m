function sbr = sbr_time_freq_grid( sbr )
%4.6.18.3.3 Time / frequency grid

%Input
bs_frame_class = sbr.data.bs_frame_class;
bs_freq_res = sbr.data.bs_freq_res;
bs_var_bord_0 = sbr.data.bs_var_bord_0;
bs_var_bord_1 = sbr.data.bs_var_bord_1;
bs_num_rel_0 = sbr.data.bs_num_rel_0;
bs_num_rel_1 = sbr.data.bs_num_rel_1;
bs_rel_bord_0 = sbr.data.bs_rel_bord_0;
bs_rel_bord_1 = sbr.data.bs_rel_bord_1;
bs_pointer = sbr.data.bs_pointer;
L_E = sbr.data.bs_num_env;
L_Q = sbr.data.bs_num_noise;
numTimeSlots = sbr.fixed.numTimeSlots;
N_low = sbr.freq_tables.N_low;
N_high = sbr.freq_tables.N_high;
f_TableLow = sbr.freq_tables.f_TableLow;
f_TableHigh = sbr.freq_tables.f_TableHigh;

%Relative borders
switch bs_frame_class
    case 0 %FIXFIX
        absBordLead = 0;
        absBordTrail = numTimeSlots;
        n_RelLead = L_E - 1;
        n_RelTrail = 0;
        relBordLead(1:n_RelLead) = round(numTimeSlots/L_E);
        relBordTrail(1:n_RelTrail) = [];
    case 1 %FIXVAR
        absBordLead = 0;
        absBordTrail = bs_var_bord_1 + numTimeSlots;
        n_RelLead = 0;
        n_RelTrail = bs_num_rel_1;
        relBordLead(1:n_RelLead) = [];
        relBordTrail(1:n_RelTrail) = bs_rel_bord_1;
    case 2 %VARFIX
        absBordLead = bs_var_bord_0;
        absBordTrail = numTimeSlots;
        n_RelLead = bs_num_rel_0;
        n_RelTrail = 0;
        relBordLead(1:n_RelLead) = bs_rel_bord_0;
        relBordTrail(1:n_RelTrail) = [];
    case 3 %VARVAR
        absBordLead = bs_var_bord_0;
        absBordTrail = bs_var_bord_1 + numTimeSlots;
        n_RelLead = bs_num_rel_0;
        n_RelTrail = bs_num_rel_1;
        relBordLead(1:n_RelLead) = bs_rel_bord_0;
        relBordTrail(1:n_RelTrail) = bs_rel_bord_1;
end

%Envelope time border vector
t_E(1) = absBordLead;
t_E(L_E+1) = absBordTrail;
for l=1:n_RelLead
    t_E(l+1) = absBordLead + sum( relBordLead(1:l) );
end
for l=n_RelLead+1:L_E-1
    t_E(l+1) = absBordTrail - sum( relBordTrail(1:L_E-l) );
end

%Noise floor time border vector
if L_E==1
    t_Q = t_E;
else
    if bs_frame_class==0
        middleBorder = L_E/2;
    elseif bs_frame_class==2
        if bs_pointer==0
            middleBorder = 1;
        elseif bs_pointer==1
            middleBorder = L_E - 1;
        else
            middleBorder = bs_pointer - 1;
        end
    else
        if bs_pointer>1
            middleBorder = L_E + 1 - bs_pointer;
        else
            middleBorder = L_E - 1;
        end
    end
    t_Q = [t_E(1) t_E(middleBorder+1) t_E(L_E+1)];
end

%Frequency grid
r = bs_freq_res;
for l=1:L_E
    if r(l)==0
        n(l) = N_low;
        F(1:N_low+1,l) = f_TableLow;
    else
        n(l) = N_high;
        F(1:N_high+1,l) = f_TableHigh;
    end
end

%Output
sbr.grid.t_E = t_E;
sbr.grid.t_Q = t_Q;
sbr.grid.r = r;
sbr.grid.n = n;
sbr.grid.F = F;