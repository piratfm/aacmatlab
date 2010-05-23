function aac = aac_decode_frame( aac, bytes )
%Table 4.3 – Syntax of top level payload for
%audio object types AAC Main, SSR, LC, and LTP (raw_data_block())

% Element ID
ID_SCE = 0;
ID_CPE = 1;
ID_CCE = 2;
ID_LFE = 3;
ID_DSE = 4;
ID_PCE = 5;
ID_FIL = 6;
ID_END = 7;

% Bytes to bits
bits = bytes2bits( bytes );

% Init
c = 0;
aac.num_elements = 0;
aac.elements = {};

% Decoding Loop
while 1

    % Decode element ID
    ele_id = bits2int( bits(c+1:c+3) );
    c = c + 3;
    
    %Test end of bitstream
    if ele_id==ID_END
        break;
    end
    
    %New Element
    aac.num_elements = aac.num_elements + 1;
    aac.elements{aac.num_elements}.id = ele_id;

    %Decode element
    switch ele_id
        case ID_SCE
            [aac,decoded_bits] = single_channel_element( aac, bits(c+1:end) );
            c = c + decoded_bits;
        case ID_CPE
            [aac,decoded_bits] = channel_pair_element( aac, bits(c+1:end) );
            c = c + decoded_bits;
        case ID_CCE
            [aac,decoded_bits] = coupling_channel_element( aac, bits(c+1:end) );
            c = c + decoded_bits;
        case ID_LFE
            [aac,decoded_bits] = lfe_channel_element( aac, bits(c+1:end) );
            c = c + decoded_bits;
        case ID_DSE
            [aac,decoded_bits] = data_stream_element( aac, bits(c+1:end), c );
            c = c + decoded_bits;
        case ID_PCE
            [aac.programConfigElement,decoded_bits] = program_config_element( bits(c+1:end), 0 );
            c = c + decoded_bits;
        case ID_FIL
            [aac,decoded_bits] = fill_element( aac, bits(c+1:end) );
            c = c + decoded_bits;
        otherwise
            error 'unsupported element ID';
    end
end

%Byte align
c = ceil(c/8)*8;

%Check number of decoded bits
if length(bits)~=c
    error 'bits remaining'
end