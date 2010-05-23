function [x,fs] = decode_mp4_aac_lc( filename )

%Init MP4
mp4 = mp4_open( filename );
track = mp4_get_mp4a_tracks( mp4 );
if isempty(track)
    error 'no mp4a tracks in mp4 file';
end
if length(track)>1
    disp('Warning: more than 1 mp4a tracks, decode first');
    track = track(1);
end
asc = mp4_get_asc( mp4, track );
num_samples = mp4_get_num_samples( mp4, track );

%Init AAC
aac = aac_open( asc );
fs = aac.samplingFrequency;

%Init output signal
x = [];

%Decoding loop
for n=1:num_samples
    sample = mp4_get_sample( mp4, track, n );
    aac = aac_decode_frame( aac, sample );
    temp = [];
    for el=1:aac.num_elements
        if aac.elements{el}.id==0||aac.elements{el}.id==1||aac.elements{el}.id==3
            [pcm,aac] = aac_synth_frame( aac, el );
            temp = [temp pcm];
        end
    end
    x = [x;temp];
end

%Scale output
x = x / 32768;

%Close MP4
mp4_close( mp4 );
