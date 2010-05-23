function out = aac_is( in, data )
%Intensity Stereo decoding
%See: 4.6.8.2 Intensity Stereo (IS)

%Init
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
sect_sfb_offset = data.ics_info.sect_sfb_offset;
ms_used = data.ms_info.ms_used;
scalefactors_right = data.channels(2).scalefactors;
codebooks_right = data.channels(2).codebooks;
out = in;

%Loop
for g=1:num_window_groups
    
    for sfb=1:max_sfb
        
        if codebooks_right(g,sfb)==14||codebooks_right(g,sfb)==15
            
            scale = 0.5^(0.25*scalefactors_right(g,sfb));
            if codebooks_right(g,sfb)==14
                scale  = -scale;
            end
            if ms_used(g,sfb)==1
                scale  = -scale;
            end
            
            k = sect_sfb_offset(g,sfb):sect_sfb_offset(g,sfb+1)-1;
            
            out{2}{g}(k) = scale*in{1}{g}(k);
            
        end
    end
end