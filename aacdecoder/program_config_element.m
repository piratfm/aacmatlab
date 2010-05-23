function [pce,c] = program_config_element( bits, bit_counter )
%Table 4.2 – Syntax of program_config_element()

%Init
c = 0;

%Decode PCE data
pce.element_instance_tag = bits2int( bits(c+1:c+4) );
c = c + 4;
pce.object_type = bits2int( bits(c+1:c+2) );
c = c + 2;
pce.sampling_frequency_index = bits2int( bits(c+1:c+4) );
c = c + 4;
pce.num_front_channel_elements = bits2int( bits(c+1:c+4) );
c = c + 4;
pce.num_side_channel_elements = bits2int( bits(c+1:c+4) );
c = c + 4;
pce.num_back_channel_elements = bits2int( bits(c+1:c+4) );
c = c + 4;
pce.num_lfe_channel_elements = bits2int( bits(c+1:c+2) );
c = c + 2;
pce.num_assoc_data_elements = bits2int( bits(c+1:c+3) );
c = c + 3;
pce.num_valid_cc_elements = bits2int( bits(c+1:c+4) );
c = c + 4;
pce.mono_mixdown_present = bits2int( bits(c+1:c+1) );
c = c + 1;
if pce.mono_mixdown_present == 1
    pce.mono_mixdown_element_number = bits2int( bits(c+1:c+4) );
    c = c + 4;
else
    pce.mono_mixdown_element_number = 0;
end
pce.stereo_mixdown_present = bits2int( bits(c+1:c+1) );
c = c + 1;
if pce.stereo_mixdown_present == 1
    pce.stereo_mixdown_element_number = bits2int( bits(c+1:c+4) );
    c = c + 4;
else
    pce.stereo_mixdown_element_number = 0;
end
pce.matrix_mixdown_idx_present = bits2int( bits(c+1:c+1) );
c = c + 1;
if pce.matrix_mixdown_idx_present == 1
    pce.matrix_mixdown_idx = bits2int( bits(c+1:c+2) );
    c = c + 2;
    pce.pseudo_surround_enable = bits2int( bits(c+1:c+1) );
    c = c + 1;
else
    pce.matrix_mixdown_idx = 0;
    pce.pseudo_surround_enable = 0;
end
pce.front_element_is_cpe = [];
pce.front_element_tag_select = [];
for i=1:pce.num_front_channel_elements
    pce.front_element_is_cpe(i) = bits2int( bits(c+1:c+1) );
    c = c + 1;
    pce.front_element_tag_select(i) = bits2int( bits(c+1:c+4) );
    c = c + 4;
end
pce.side_element_is_cpe = [];
pce.side_element_tag_select = [];
for i=1:pce.num_side_channel_elements
    pce.side_element_is_cpe(i) = bits2int( bits(c+1:c+1) );
    c = c + 1;
    pce.side_element_tag_select(i) = bits2int( bits(c+1:c+4) );
    c = c + 4;
end
pce.back_element_is_cpe = [];
pce.back_element_tag_select = [];
for i=1:pce.num_back_channel_elements
    pce.back_element_is_cpe(i) = bits2int( bits(c+1:c+1) );
    c = c + 1;
    pce.back_element_tag_select(i) = bits2int( bits(c+1:c+4) );
    c = c + 4;
end
pce.lfe_element_tag_select = [];
for i=1:pce.num_lfe_channel_elements
    pce.lfe_element_tag_select(i) = bits2int( bits(c+1:c+4) );
    c = c + 4;
end
pce.assoc_data_element_tag_select = [];
for i=1:pce.num_assoc_data_elements
    pce.assoc_data_element_tag_select(i) = bits2int( bits(c+1:c+4) );
    c = c + 4;
end
pce.cc_element_is_ind_sw = [];
pce.valid_cc_element_tag_select = [];
for i=1:pce.num_valid_cc_elements
    pce.cc_element_is_ind_sw(i) = bits2int( bits(c+1:c+1) );
    c = c + 1;
    pce.valid_cc_element_tag_select(i) = bits2int( bits(c+1:c+4) );
    c = c + 4;
end

%Byte align
total = bit_counter + c;
remaining = ceil(total/8)*8 - total;
c = c + remaining;

%Decode comment field
comment_field_bytes = bits2int( bits(c+1:c+8) );
c = c + 8;
pce.comment_field_data = [];
for i=1:comment_field_bytes
    pce.comment_field_data(i) = bits2int( bits(c+1:c+8) );
    c = c + 8;
end