function sbr = sbr_decode_frame( sbr, aac, ele_aac, ele_sbr )

%Init
c = 0;
id_aac = aac.elements{ele_aac}.id;
bits = aac.elements{ele_sbr}.data;

%Extension type
extension_type = bits2int( bits(c+1:c+4) );
c = c + 4;
if extension_type~=13
    error 'Extension data not SBR';
end

%SBR header
sbr.header_flag = bits(c+1);
c = c + 1;
sbr.header.reset = 0;
if sbr.header_flag
    [sbr,decoded_bits] = sbr_header( sbr, bits(c+1:end) );
    c = c + decoded_bits;
    sbr = sbr_frequency_band_tables( sbr );
    sbr.header_present = 1;
end

if sbr.header_present

    %SBR data
    if id_aac==0
        [sbr,decoded_bits] = sbr_single_channel_element( sbr, bits(c+1:end) );
        c = c + decoded_bits;
    else
        error 'SBR for CPE not supported';
    end

    %Byte align
    c = ceil(c/8)*8;

    %Check number of decoded bits
    if length(bits)~=c
        error 'bits remaining'
    end
    
end