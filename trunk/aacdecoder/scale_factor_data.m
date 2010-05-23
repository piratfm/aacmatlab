function [scalefactors,c] = scale_factor_data( bits, data )
%Table 4.53 – Syntax of scale_factor_data()

%Init
c = 0;
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
codebooks = data.codebooks;
scalefactors = zeros(data.ics_info.num_window_groups,data.ics_info.max_sfb);
last_sf = data.global_gain;
last_nrg = data.global_gain - 90;
last_is = 0;
hcb_sf = hcb_sf_table;
noise_pcm_flag = 1;

%Loop over window groups
for g=1:num_window_groups
    
    %Loop over scale factor bands
    for sfb=1:max_sfb
        
        %Scalefactor for spectral data
        if 0<codebooks(g,sfb)&&codebooks(g,sfb)<=11
            
            offset = 1;
            while hcb_sf(offset,2)
                bit = bits(c+1);
                c = c + 1;
                offset = offset + hcb_sf(offset,bit+1);
            end
            dpcm_offset = hcb_sf(offset,1) - 60;
            
            scalefactors(g,sfb) = last_sf + dpcm_offset;
            last_sf = scalefactors(g,sfb);
            
        %Scalefactor for PNS
        elseif codebooks(g,sfb)==13
            
            if  noise_pcm_flag
                noise_pcm_flag = 0;
                dpcm_offset = bits2int( bits(c+1:c+9) ) - 256;
                c = c + 9;
            else
                offset = 1;
                while hcb_sf(offset,2)
                    bit = bits(c+1);
                    c = c + 1;
                    offset = offset + hcb_sf(offset,bit+1);
                end
                dpcm_offset = hcb_sf(offset,1) - 60;
            end
            scalefactors(g,sfb) = last_nrg + dpcm_offset;
            last_nrg = scalefactors(g,sfb);
            
        %Scalefactor for Intensity Stereo
        elseif codebooks(g,sfb)==14||codebooks(g,sfb)==15
            
            offset = 1;
            while hcb_sf(offset,2)
                bit = bits(c+1);
                c = c + 1;
                offset = offset + hcb_sf(offset,bit+1);
            end
            dpcm_offset = hcb_sf(offset,1) - 60;
            
            scalefactors(g,sfb) = last_is + dpcm_offset;
            last_is = scalefactors(g,sfb);
            
        end
    end
end