function y = aac_invquant( x, data )
%Inverse non uniform quantization
%See: 4.6.1 Quantization , 4.6.2 Scalefactors

%Init
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
window_group_length = data.ics_info.window_group_length;
window_length = data.ics_info.window_length;
sect_sfb_offset = data.ics_info.sect_sfb_offset;
SF_OFFSET = 100;
y = cell(1,num_window_groups);

%Loop
for g=1:num_window_groups
    
    y{g} = zeros(1,window_group_length(g)*window_length);
    
    for sfb=1:max_sfb
        
        k=sect_sfb_offset(g,sfb):sect_sfb_offset(g,sfb+1)-1;
        
        sig = sign(x{g}(k));
        amp = abs(x{g}(k)).^(4/3);
        gain = 2^( 0.25 * ( data.scalefactors(g,sfb) - SF_OFFSET ) );
        
        y{g}(k) = sig .* amp .* gain;
        
    end
end