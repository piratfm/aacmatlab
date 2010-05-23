function y = aac_reorder( x, data )
%Coefficients reordering for short blocks
%See: 4.6.3.3 Decoding process

%Init
num_windows = data.ics_info.num_windows;
num_window_groups = data.ics_info.num_window_groups;
max_sfb = data.ics_info.max_sfb;
window_group_length = data.ics_info.window_group_length;
window_length = data.ics_info.window_length;
swb_offset = data.ics_info.swb_offset;
y = zeros(num_windows,window_length);

%No reordering if long block
if num_windows==1
    
    y = x{1};

%Do reordering for short block
else
    
    k = 0;
    for g=1:num_window_groups
        j = 0;
        l = 0;
        for sfb=1:max_sfb
            width = swb_offset(sfb+1) - swb_offset(sfb);
            for win=1:window_group_length(g)
                bin = 1:width;
                y(win+k,bin+j) = x{g}(bin+l);
                l = l + width;
            end
            j = j + width;
        end
        k = k + window_group_length(g);
    end
    
    y = reshape( y', 1, num_windows*window_length );
end