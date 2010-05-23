function [tns,c] = tns_data( bits, data, aac )
%Table 4.54 – Syntax of tns_data()

%Init
c = 0;

%TNS flag
tns.tns_data_present = bits(c+1);
c = c + 1;

if tns.tns_data_present
    
    %Init
    if data.ics_info.window_sequence==2
        n_filt_bits = 1;
        length_bits = 4;
        order_bits = 3;
        tns.tns_max_order = aac.sfb_tns_info.tns_short.tns_max_order;
        tns.tns_max_bands = aac.sfb_tns_info.tns_short.tns_max_bands;
    else
        n_filt_bits = 2;
        length_bits = 6;
        order_bits = 5;
        tns.tns_max_order = aac.sfb_tns_info.tns_long.tns_max_order;
        tns.tns_max_bands = aac.sfb_tns_info.tns_long.tns_max_bands;
    end

    %Loop over window
    for w=1:data.ics_info.num_windows

        %Init output
        tns.n_filt{w} = [];
        tns.coef_res{w} = [];
        tns.length{w} = [];
        tns.order{w} = [];
        tns.direction{w} = [];
        tns.coef_compress{w} = [];
        tns.coef{w} = [];

        %Number of filter for the current window
        tns.n_filt{w} = bits2int( bits(c+1:c+n_filt_bits) );
        c = c + n_filt_bits;

        %Coefficients resolution ( 0: 3 bits, 1: 4 bits )
        if tns.n_filt{w}
            tns.coef_res{w} = bits(c+1);
            c = c + 1;
        end

        %Loop over the filters
        for filt=1:tns.n_filt{w}

            %Filter length
            tns.length{w}(filt) = bits2int( bits(c+1:c+length_bits) );
            c = c + length_bits;

            %Filter order
            tns.order{w}(filt) = bits2int( bits(c+1:c+order_bits) );
            c = c + order_bits;

            if tns.order{w}(filt)

                %Filter direction ( 0: upward, 1: downward )
                tns.direction{w}(filt) = bits(c+1);
                c = c + 1;

                %Omit most significant bit or not
                tns.coef_compress{w}(filt) = bits(c+1);
                c = c + 1;

                %Resulting coefficient resolution in bits
                coef_bits = tns.coef_res{w}+3-tns.coef_compress{w}(filt);

                %Decode coefficients
                for i=1:tns.order{w}(filt)
                    tns.coef{w}(filt,i) = bits2int( bits(c+1:c+coef_bits) );
                    c = c + coef_bits;
                end
            end
        end
    end
end