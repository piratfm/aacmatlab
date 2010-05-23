function [aac,c] = coupling_channel_element( aac, bits )
%Table 4.8 – Syntax of coupling_channel_element()

% Init
c = 0;
hcb_sf = hcb_sf_table;

% Decode element instance tag
aac.elements{aac.num_elements}.instance_tag = bits2int( bits(c+1:c+4) );
c = c + 4;

%Decode CCE info
cce_info.ind_sw_cce_flag = bits2int( bits(c+1:c+1) );
c = c + 1;
cce_info.num_coupled_elements = bits2int( bits(c+1:c+3) );
c = c + 3;
cce_info.num_gain_element_lists = 0;
for n=1:cce_info.num_coupled_elements+1
    cce_info.num_gain_element_lists = cce_info.num_gain_element_lists + 1;
    cce_info.cc_target_is_cpe(n) = bits2int( bits(c+1:c+1) );
    c = c + 1;
    cce_info.cc_target_tag_select(n) = bits2int( bits(c+1:c+4) );
    c = c + 4;
    cce_info.cc_l = [];
    cce_info.cc_r = [];
    if cce_info.cc_target_is_cpe(n)
        cce_info.cc_l(n) = bits2int( bits(c+1:c+1) );
        c = c + 1;
        cce_info.cc_r(n) = bits2int( bits(c+1:c+1) );
        c = c + 1;
        if cce_info.cc_l(n) && cce_info.cc_r(n)
            cce_info.num_gain_element_lists = cce_info.num_gain_element_lists + 1;
        end
    end
end
cce_info.cc_domain = bits2int( bits(c+1:c+1) );
c = c + 1;
cce_info.gain_element_sign = bits2int( bits(c+1:c+1) );
c = c + 1;
cce_info.gain_element_scale = bits2int( bits(c+1:c+2) );
c = c + 2;
aac.elements{aac.num_elements}.cce_info = cce_info;

% Decode 1 individual channel stream
aac.elements{aac.num_elements}.numChannels = 1;
[aac,decoded_bits] = individual_channel_stream( aac, bits(c+1:end), 0 );
c = c + decoded_bits;

%Decode gain data
num_window_groups = aac.elements{aac.num_elements}.channels(1).ics_info.num_window_groups;
max_sfb = aac.elements{aac.num_elements}.channels(1).ics_info.max_sfb;
codebooks = aac.elements{aac.num_elements}.channels(1).codebooks;
gain_data.common_gain_element_present = [];
gain_data.common_gain_element = [];
gain_data.dpcm_gain_element = {};
for n=1:cce_info.num_gain_element_lists-1
    if cce_info.ind_sw_cce_flag
        cge = 1;
    else
        gain_data.common_gain_element_present(n) = bits2int( bits(c+1:c+1) );
        c = c + 1;
        cge = gain_data.common_gain_element_present(n);
    end
    if cge
        offset = 1;
        while hcb_sf(offset,2)
            bit = bits(c+1);
            c = c + 1;
            offset = offset + hcb_sf(offset,bit+1);
        end
        gain_data.common_gain_element(n) = hcb_sf(offset,1) - 60;
    else
        for g=1:num_window_groups
            for sfb=1:max_sfb
                if codebooks(g,sfb)~=0
                    offset = 1;
                    while hcb_sf(offset,2)
                        bit = bits(c+1);
                        c = c + 1;
                        offset = offset + hcb_sf(offset,bit+1);
                    end
                    gain_data.dpcm_gain_element{n}(g,sfb) = hcb_sf(offset,1) - 60;
                end
            end
        end
    end
end
aac.elements{aac.num_elements}.gain_data = gain_data;