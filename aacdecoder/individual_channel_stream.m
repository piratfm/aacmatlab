function [aac,c] = individual_channel_stream( aac, bits, common_window )
%Table 4.50 – Syntax of individual_channel_stream()

% Init
c = 0;

% Decode global gain
data.global_gain = bits2int( bits(c+1:c+8) );
c = c + 8;

% Decode ICS info
if common_window==0
    [data.ics_info,decoded_bits] = ics_info( bits(c+1:end), aac );
    c = c + decoded_bits;
else
    data.ics_info = aac.elements{aac.num_elements}.ics_info;
end

% Section data
[data.codebooks,decoded_bits] = section_data( bits(c+1:end), data );
c = c + decoded_bits;

% Scalefactor data
[data.scalefactors,decoded_bits] = scale_factor_data( bits(c+1:end), data );
c = c + decoded_bits;

% Pulse data
[data.pulse,decoded_bits] = pulse_data( bits(c+1:end) );
c = c + decoded_bits;

% TNS data
[data.tns,decoded_bits] = tns_data( bits(c+1:end), data, aac );
c = c + decoded_bits;

% Gain control data
gain_control_data_present = bits(c+1);
c = c + 1;
if gain_control_data_present
    error 'gain control data not supported';
end

% Spectral data
[data.spectral_data,decoded_bits] = spectral_data( bits(c+1:end), data );
c = c + decoded_bits;

% Output
aac.elements{aac.num_elements}.channels(aac.elements{aac.num_elements}.numChannels) = data;