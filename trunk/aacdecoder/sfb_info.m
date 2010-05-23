function [info_long,info_short] = sfb_info( fs, frameLength )

%Tables
swb_offset_1024_96 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56,...
    64, 72, 80, 88, 96, 108, 120, 132, 144, 156, 172, 188, 212, 240,...
    276, 320, 384, 448, 512, 576, 640, 704, 768, 832, 896, 960, 1024
];
swb_offset_128_96 =...
[
    0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 92, 128
];
swb_offset_1024_64 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56,...
    64, 72, 80, 88, 100, 112, 124, 140, 156, 172, 192, 216, 240, 268,...
    304, 344, 384, 424, 464, 504, 544, 584, 624, 664, 704, 744, 784, 824,...
    864, 904, 944, 984, 1024
];
swb_offset_128_64 =...
[
    0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 92, 128
];
swb_offset_1024_48 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72,...
    80, 88, 96, 108, 120, 132, 144, 160, 176, 196, 216, 240, 264, 292,...
    320, 352, 384, 416, 448, 480, 512, 544, 576, 608, 640, 672, 704, 736,...
    768, 800, 832, 864, 896, 928, 1024
];
swb_offset_128_48 =...
[
    0, 4, 8, 12, 16, 20, 28, 36, 44, 56, 68, 80, 96, 112, 128
];
swb_offset_1024_32 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72,...
    80, 88, 96, 108, 120, 132, 144, 160, 176, 196, 216, 240, 264, 292,...
    320, 352, 384, 416, 448, 480, 512, 544, 576, 608, 640, 672, 704, 736,...
    768, 800, 832, 864, 896, 928, 960, 992, 1024
];
swb_offset_1024_24 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 52, 60, 68,...
    76, 84, 92, 100, 108, 116, 124, 136, 148, 160, 172, 188, 204, 220,...
    240, 260, 284, 308, 336, 364, 396, 432, 468, 508, 552, 600, 652, 704,...
    768, 832, 896, 960, 1024
];
swb_offset_128_24 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 36, 44, 52, 64, 76, 92, 108, 128
];
swb_offset_1024_16 =...
[
    0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 100, 112, 124,...
    136, 148, 160, 172, 184, 196, 212, 228, 244, 260, 280, 300, 320, 344,...
    368, 396, 424, 456, 492, 532, 572, 616, 664, 716, 772, 832, 896, 960, 1024
];
swb_offset_128_16 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 60, 72, 88, 108, 128
];
swb_offset_1024_8 =...
[
    0, 12, 24, 36, 48, 60, 72, 84, 96, 108, 120, 132, 144, 156, 172,...
    188, 204, 220, 236, 252, 268, 288, 308, 328, 348, 372, 396, 420, 448,...
    476, 508, 544, 580, 620, 664, 712, 764, 820, 880, 944, 1024
];
swb_offset_128_8 =...
[
    0, 4, 8, 12, 16, 20, 24, 28, 36, 44, 52, 60, 72, 88, 108, 128
];

%Long window
info_long.num_windows = 1;
info_long.window_length = frameLength;
switch fs
    case {96000,88200}
        info_long.swb_offset = swb_offset_1024_96+1;
        if frameLength==960
            info_long.swb_offset(end) = [];
        end
    case 64000
        info_long.swb_offset = swb_offset_1024_64+1;
        if frameLength==960
            info_long.swb_offset(end) = [];
        end
    case {48000,44100}
        info_long.swb_offset = swb_offset_1024_48+1;
    case 32000
        info_long.swb_offset = swb_offset_1024_32+1;
        if frameLength==960
            info_long.swb_offset(end-1:end) = [];
        end
    case {24000,22050}
        info_long.swb_offset = swb_offset_1024_24+1;
        if frameLength==960
            info_long.swb_offset(end) = [];
        end
    case {16000,12000,11025}
        info_long.swb_offset = swb_offset_1024_16+1;
        if frameLength==960
            info_long.swb_offset(end) = [];
        end
    case 8000
        info_long.swb_offset = swb_offset_1024_8+1;
    otherwise
        error 'SFB data: unsupported sampling frequency';
end
info_long.swb_offset(end) = frameLength + 1;
info_long.num_swb = length(info_long.swb_offset) - 1;
    
%Short window
info_short.num_windows = 8;
info_short.window_length = frameLength/8;
switch fs
    case {96000,88200}
        info_short.swb_offset = swb_offset_128_96+1;
    case 64000
        info_short.swb_offset = swb_offset_128_64+1;
    case {48000,44100,32000}
        info_short.swb_offset = swb_offset_128_48+1;
    case {24000,22050}
        info_short.swb_offset = swb_offset_128_24+1;
    case {16000,12000,11025}
        info_short.swb_offset = swb_offset_128_16+1;
    case 8000
        info_short.swb_offset = swb_offset_128_8+1;
    otherwise
        error 'SFB data: unsupported sampling frequency';
end
info_short.swb_offset(end) = frameLength/8 + 1;
info_short.num_swb = length(info_short.swb_offset) - 1;