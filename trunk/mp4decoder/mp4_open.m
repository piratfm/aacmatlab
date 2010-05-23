function mp4 = mp4_open( filename )

%Open MP4 file
mp4.fid = fopen(filename,'rb');

%Parse MP4 atoms
mp4 = parse_atoms( mp4 );

%Compute sample offsets
for track=1:mp4.total_tracks
    firstChunk = mp4.tracks(track).stsc_first_chunk;
    samplesPerChunk = mp4.tracks(track).stsc_samples_per_chunk;
    chunkOffset = mp4.tracks(track).stco_chunk_offset;
    numChunks = length(chunkOffset);
    sampleCount = mp4.tracks(track).stsz_sample_count;
    sampleSize = mp4.tracks(track).stsz_table;
    mp4.tracks(track).sample_offset = zeros(1,sampleCount);
    c = 0;
    for n=1:numChunks
        idx = find(firstChunk-n<=0,1,'last');
        numSamples = samplesPerChunk(idx);
        offsetFirst = chunkOffset( n );
        offsetNext = [0 cumsum(sampleSize(c+1:c+numSamples-1))];
        mp4.tracks(track).sample_offset(c+1:c+numSamples) = offsetFirst + offsetNext;
        c = c + numSamples;
    end
end