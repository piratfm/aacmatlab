function [info_long,info_short] = tns_info( fsIdx )

%Long window
info_long.tns_max_order = 12;
tns_max_bands = [31 31 34 40 42 51 46 46 42 42 42 39];
info_long.tns_max_bands = tns_max_bands(fsIdx+1);

%Short window
info_short.tns_max_order = 7;
tns_max_bands = [9 9 10 14 14 14 14 14 14 14 14 14];
info_short.tns_max_bands = tns_max_bands(fsIdx+1);