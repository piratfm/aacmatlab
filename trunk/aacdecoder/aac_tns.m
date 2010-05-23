function y = aac_tns( x, data )
%Temporal Noise Shaping
%See: 4.6.9 Temporal noise shaping

if data.tns.tns_data_present

    %Init
    num_windows = data.ics_info.num_windows;
    window_length = data.ics_info.window_length;
    num_swb = data.ics_info.num_swb;
    swb_offset = data.ics_info.swb_offset;
    max_sfb = data.ics_info.max_sfb;
    tns_max_order = data.tns.tns_max_order;
    tns_max_bands = data.tns.tns_max_bands;
    y = x;
    
    %Loop over the windows
    for w=1:num_windows
        
        bottom = num_swb;
        
        %Loop over the filters
        for f=1:data.tns.n_filt{w}
            
            top = bottom;
            bottom = max( top-data.tns.length{w}(f), 0 );
            tns_order = min( data.tns.order{w}(f), tns_max_order);
            
            if tns_order
                
                %LPC
                lpcoef = tns_decode_coef( tns_order, data.tns.coef_res{w}+3,...
                    data.tns.coef_compress{w}(f), data.tns.coef{w}(f,:) );
                
                %Filter start and end
                filtstart = swb_offset( min( [bottom, tns_max_bands, max_sfb] )+1 );
                filtend = swb_offset( min( [top, tns_max_bands, max_sfb] )+1 ) - 1;
                filtsize = filtend-filtstart+1;
                
                if filtsize>0
                    
                    %Filter direction
                    if data.tns.direction{w}(f)
                        inc = -1;
                        tmp = filtend;
                        filtend = filtstart;
                        filtstart = tmp;
                    else
                        inc = 1;
                    end
                    
                    %Filtering
                    filtin = x((w-1)*window_length+filtstart:inc:(w-1)*window_length+filtend);
                    filtout = filter(1,lpcoef,filtin);
                    y((w-1)*window_length+filtstart:inc:(w-1)*window_length+filtend) = filtout;
                end
            end
        end
    end
else
    
    %No TNS
    y = x;
    
end

function a = tns_decode_coef( order, coef_res_bits, coef_compress, coef )

%Tables
tns_coef_0_3 = [0.0 0.4338837391 0.7818314825 0.9749279122 -0.9848077530...
    -0.8660254038 -0.6427876097 -0.3420201433 -0.4338837391 -0.7818314825...
    -0.9749279122 -0.9749279122 -0.9848077530 -0.8660254038 -0.6427876097...
    -0.3420201433];
tns_coef_0_4 = [0.0 0.2079116908 0.4067366431 0.5877852523 0.7431448255...
    0.8660254038 0.9510565163 0.9945218954 -0.9957341763 -0.9618256432...
    -0.8951632914 -0.7980172273 -0.6736956436 -0.5264321629 -0.3612416662...
    -0.1837495178];
tns_coef_1_3 = [0.0 0.4338837391 -0.6427876097 -0.3420201433 0.9749279122...
    0.7818314825 -0.6427876097 -0.3420201433 -0.4338837391 -0.7818314825...
    -0.6427876097 -0.3420201433 -0.7818314825 -0.4338837391 -0.6427876097...
    -0.3420201433];
 tns_coef_1_4 = [0.0 0.2079116908 0.4067366431 0.5877852523 -0.6736956436...
     -0.5264321629 -0.3612416662 -0.1837495178 0.9945218954 0.9510565163...
     0.8660254038 0.7431448255 -0.6736956436 -0.5264321629 -0.3612416662...
     -0.1837495178];
 
 %Unquantize
 if coef_compress==0
     if coef_res_bits==3
         tmp2 = tns_coef_0_3( coef+1 );
     else
         tmp2 = tns_coef_0_4( coef+1 );
     end
 else
     if coef_res_bits==3
         tmp2 = tns_coef_1_3( coef+1 );
     else
         tmp2 = tns_coef_1_4( coef+1 );
     end
 end
 
 %Convert to LPC coefficients
 a = zeros(1,order+1);
 b = zeros(1,order+1);
 a(0+1) = 1;
 for m=1:order
     i = 1:m-1;
     b(i+1) = a(i+1) + tmp2(m-1+1)*a(m-i+1);
     a(i+1) = b(i+1);
     a(m+1) = tmp2(m-1+1);
 end