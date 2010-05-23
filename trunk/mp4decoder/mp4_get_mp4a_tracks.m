function tracks = mp4_get_mp4a_tracks( mp4 )

tracks = [];
for n=1:mp4.total_tracks
    if strcmp( mp4.tracks(n).stsd_type , 'mp4a' )
        tracks = [tracks n];
    end
end