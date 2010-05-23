function sample = mp4_get_sample( mp4, track, idx )

fseek(mp4.fid,mp4.tracks(track).sample_offset(idx),'bof');
sample = fread(mp4.fid,mp4.tracks(track).stsz_table(idx),'uchar');