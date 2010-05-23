function num_samples = mp4_get_num_samples( mp4, track )

num_samples = mp4.tracks(track).stsz_sample_count;