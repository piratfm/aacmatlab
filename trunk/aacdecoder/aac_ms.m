function out = aac_ms( in, data )
%M/S joint channel decoding
%See: 4.6.8.1 M/S stereo

%Init
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
sect_sfb_offset = data.ics_info.sect_sfb_offset;
ms_used = data.ms_info.ms_used;
codebooks_right = data.channels(2).codebooks;
out = in;

%Loop
for g=1:num_window_groups
    
    for sfb=1:max_sfb
        
        if ms_used(g,sfb)&&codebooks_right(g,sfb)~=14&&codebooks_right(g,sfb)~=15
        
            k = sect_sfb_offset(g,sfb):sect_sfb_offset(g,sfb+1)-1;
            
            out{1}{g}(k) = in{1}{g}(k) + in{2}{g}(k);
            out{2}{g}(k) = in{1}{g}(k) - in{2}{g}(k);
            
        end
    end
end