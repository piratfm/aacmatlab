function [aac,c] = channel_pair_element( aac, bits )
%Table 4.5 – Syntax of channel_pair_element()

% Init bit counter
c = 0;

% Decode element instance tag
aac.elements{aac.num_elements}.instance_tag = bits2int( bits(c+1:c+4) );
c = c + 4;

% Decode common window
aac.elements{aac.num_elements}.common_window = bits(c+1);
c = c + 1;

if aac.elements{aac.num_elements}.common_window
    
    % Decode ICS info
    [aac.elements{aac.num_elements}.ics_info,decoded_bits] = ics_info( bits(c+1:end), aac );
    c = c + decoded_bits;
    
    %Decode MS info
    aac.elements{aac.num_elements}.ms_info.ms_mask_present = bits2int( bits(c+1:c+2) );
    c = c + 2;
    nwg = aac.elements{aac.num_elements}.ics_info.num_window_groups;
    msb = aac.elements{aac.num_elements}.ics_info.max_sfb;
    switch aac.elements{aac.num_elements}.ms_info.ms_mask_present
        case 0
            aac.elements{aac.num_elements}.ms_info.ms_used = zeros(nwg,msb);
        case 1
            aac.elements{aac.num_elements}.ms_info.ms_used = zeros(nwg,msb);
            for g=1:nwg
                for sfb=1:msb
                    aac.elements{aac.num_elements}.ms_info.ms_used(g,sfb) = bits(c+1);
                    c = c + 1;
                end
            end
        case 2
            aac.elements{aac.num_elements}.ms_info.ms_used = ones(nwg,msb);
        otherwise
            error 'ms_mask_present not supported';
    end
end

% Decode 2 individual channel streams
aac.elements{aac.num_elements}.numChannels = 1;
[aac,decoded_bits] = individual_channel_stream( aac, bits(c+1:end), aac.elements{aac.num_elements}.common_window );
c = c + decoded_bits;
aac.elements{aac.num_elements}.numChannels = 2;
[aac,decoded_bits] = individual_channel_stream( aac, bits(c+1:end), aac.elements{aac.num_elements}.common_window );
c = c + decoded_bits;