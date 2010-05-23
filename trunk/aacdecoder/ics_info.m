function [data,c] = ics_info( bits, aac )
%Table 4.6 – Syntax of ics_info()

c = 0;

data.ics_reserved_bit = bits(c+1);
c = c + 1;

data.window_sequence = bits2int( bits(c+1:c+2) );
c = c + 2;

data.window_shape = bits(c+1);
c = c + 1;

if data.window_sequence==2
    
    data.max_sfb = bits2int( bits(c+1:c+4) );
    c = c + 4;
    
    data.scale_factor_grouping = bits(c+1:c+7);
    c = c + 7;
    
    data.predictor_data_present = 0;
    
    data.num_windows = aac.sfb_tns_info.sfb_short.num_windows;
    data.window_length = aac.sfb_tns_info.sfb_short.window_length;
    data.swb_offset = aac.sfb_tns_info.sfb_short.swb_offset;
    data.num_swb = aac.sfb_tns_info.sfb_short.num_swb;
	data.num_window_groups = 1;
	data.window_group_length = 1;
    for n=1:7
        if data.scale_factor_grouping(n)==0
            data.num_window_groups = data.num_window_groups + 1;
            data.window_group_length(data.num_window_groups) = 1;
        else
            data.window_group_length(data.num_window_groups) =...
                data.window_group_length(data.num_window_groups) + 1;
        end
    end
    for g=1:data.num_window_groups
        sect_sfb = 1;
        offset = 1;
        for n=1:data.max_sfb
            width = data.swb_offset(n+1) - data.swb_offset(n);
            width = width * data.window_group_length(g);
            data.sect_sfb_offset(g,sect_sfb) = offset;
            sect_sfb = sect_sfb+1;
            offset  = offset + width;
        end
        data.sect_sfb_offset(g,sect_sfb) = offset;
    end
    
else
    
    data.max_sfb = bits2int( bits(c+1:c+6) );
    c = c + 6;
    
    data.scale_factor_grouping = [];
    
    data.predictor_data_present = bits(c+1);
    c = c + 1;
    
    if data.predictor_data_present
        error 'ics_info: prediction not supported';
    end
    
    data.num_windows = aac.sfb_tns_info.sfb_long.num_windows;
    data.window_length = aac.sfb_tns_info.sfb_long.window_length;
    data.swb_offset = aac.sfb_tns_info.sfb_long.swb_offset;
    data.num_swb = aac.sfb_tns_info.sfb_long.num_swb;
	data.num_window_groups = 1;
	data.window_group_length = 1;
    data.sect_sfb_offset = data.swb_offset(1:data.max_sfb+1);
end