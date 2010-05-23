function out = aac_pns( in, data )
%Perceptual Noise Substitution
%See: 4.6.13 Perceptual noise substitution (PNS)

%Init
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
swb_offset = data.ics_info.swb_offset;
window_length = data.ics_info.window_length;
window_group_length = data.ics_info.window_group_length;
scalefactors = data.scalefactors;
codebooks = data.codebooks;
group = 0;
out = in;

%Loop
for g=1:num_window_groups
    
    for b=1:window_group_length(g)
    
        for sfb=1:max_sfb

            if codebooks(g,sfb)==13

                k = swb_offset(sfb):swb_offset(sfb+1)-1;
                size = swb_offset(sfb+1)-swb_offset(sfb);

                spec = rand(1,size)-0.5;
                spec = spec / sqrt( sum( spec.^2 ) );

                scale = 2^(0.25*scalefactors(g,sfb));

                out((group*window_length)+k) = scale*spec;
            end
        end
        
        group = group + 1;
    end
end