function [aac,c] = single_channel_element( aac, bits )
%Table 4.4 – Syntax of single_channel_element()

% Init bit counter
c = 0;

% Decode element instance tag
aac.elements{aac.num_elements}.instance_tag = bits2int( bits(c+1:c+4) );
c = c + 4;

% Decode individual channel stream
aac.elements{aac.num_elements}.numChannels = 1;
[aac,decoded_bits] = individual_channel_stream( aac, bits(c+1:end), 0 );
c = c + decoded_bits;