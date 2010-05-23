function [codebooks,c] = section_data( bits, data )
%Table 4.52 – Syntax of section_data()

%Init
c = 0;
if data.ics_info.window_sequence==2
    sect_esc_val = 7;
    sect_len_bits = 3;
else
    sect_esc_val = 31;
    sect_len_bits = 5;
end
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
codebooks = zeros(data.ics_info.num_window_groups,data.ics_info.max_sfb);

%Loop over window groups
for g=1:num_window_groups
    
    %Init
    k = 0;
    i = 1;
    
    %Loop over sections
    while k<max_sfb
        
        %Codebook index of the current section
        sect_gb = bits2int( bits(c+1:c+4) );
        c = c + 4;
        
        %Length of the current section
        sect_len = 0;
        sect_len_incr = bits2int( bits(c+1:c+sect_len_bits) );
        c = c + sect_len_bits;
        while sect_len_incr==sect_esc_val
            sect_len = sect_len + sect_esc_val;
            sect_len_incr = bits2int( bits(c+1:c+sect_len_bits) );
            c = c + sect_len_bits;
        end
        sect_len = sect_len + sect_len_incr;
        
        %Copy to output
        codebooks(g,k+1:k+sect_len) = sect_gb;
        
        %Iterate
        k = k + sect_len;
        i = i + 1;
        
    end
end