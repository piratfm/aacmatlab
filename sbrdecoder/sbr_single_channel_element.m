function [sbr,c] = sbr_single_channel_element( sbr, bits )

%Init
c = 0;

%Data extra
data_extra = bits(c+1);
c = c + 1;
if data_extra
    c = c + 4;
end

%SBR grid
[sbr,decoded_bits] = sbr_grid( sbr, bits(c+1:end) );
c = c + decoded_bits;

%SBR dtdf
[sbr,decoded_bits] = sbr_dtdf( sbr, bits(c+1:end) );
c = c + decoded_bits;

%SBR invf
[sbr,decoded_bits] = sbr_invf( sbr, bits(c+1:end) );
c = c + decoded_bits;

%SBR envelope
[sbr,decoded_bits] = sbr_envelope( sbr, bits(c+1:end) );
c = c + decoded_bits;

%SBR noise floor
[sbr,decoded_bits] = sbr_noise( sbr, bits(c+1:end) );
c = c + decoded_bits;

%Harmonic data
[sbr,decoded_bits] = sbr_sinusoidal_coding( sbr, bits(c+1:end) );
c = c + decoded_bits;

%Extended data
extended_data = bits(c+1);
c = c + 1;
if extended_data
    error 'extended data present';
end