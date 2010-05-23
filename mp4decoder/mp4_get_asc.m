function asc = mp4_get_asc( data, track )

asc = data.tracks(track).stsd.audioSpecificConfig;