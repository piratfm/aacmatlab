function data = read_atom( data , size, type )

destination = ftell(data.fid) + size;

switch type
    
    case 'mvhd'
        fread(data.fid,3,'int32');
        data.moov.time_scale = read_int( data.fid, 4 );
        data.moov.duration = read_int( data.fid, 4 );
        
    case 'mdhd'
        version = read_int( data.fid, 4 );
        if version==1
            fread(data.fid,2,'int64');
            data.tracks(data.total_tracks).time_scale = read_int( data.fid, 4 );
            data.tracks(data.total_tracks).duration = read_int( data.fid, 8 );
        else
            fread(data.fid,2,'int32');
            data.tracks(data.total_tracks).time_scale = read_int( data.fid, 4 );
            data.tracks(data.total_tracks).duration = read_int( data.fid, 4 );
        end
        
    case 'stsd'
        fread(data.fid,1,'uchar');
        fread(data.fid,3,'uchar');
        data.tracks(data.total_tracks).stsd_entry_count = read_int( data.fid, 4 );
        [headerSize,atomSize,typeTxt,typeIdx,data] = read_atom_header( data );
        data.tracks(data.total_tracks).stsd_type = typeTxt;
        data.tracks(data.total_tracks).stsd = struct;
        switch typeTxt
            case 'mp4a'
                fread(data.fid,16,'uchar');
                data.tracks(data.total_tracks).stsd.channelCount = read_int( data.fid, 2 );
                data.tracks(data.total_tracks).stsd.sampleSize = read_int( data.fid, 2 );
                fread(data.fid,4,'uchar');
                data.tracks(data.total_tracks).stsd.sampleRate = read_int( data.fid, 2 );
                fread(data.fid,2,'uchar');
                [headerSize,atomSize,typeTxt,typeIdx,data] = read_atom_header( data );
                if strcmp(typeTxt,'esds')
                    fread(data.fid,4,'uchar');
                    tag = fread(data.fid,1,'uchar');
                    if tag==3
                        length = read_descr_length( data.fid );
                        if length<20
                            error 'wrong esds';
                        end
                        fread(data.fid,3,'uchar');
                    else
                        fread(data.fid,2,'uchar');
                    end
                    tag = fread(data.fid,1,'uchar');
                    if tag~=4
                        error 'wrong esds';
                    end
                    length = read_descr_length( data.fid );
                    if length<13
                        error 'wrong esds';
                    end
                    data.tracks(data.total_tracks).stsd.audioType = read_int( data.fid, 1 );
                    fread(data.fid,4,'uchar');
                    data.tracks(data.total_tracks).stsd.maxBitrate = read_int( data.fid, 4 );
                    data.tracks(data.total_tracks).stsd.avgBitrate = read_int( data.fid, 4 );
                    tag = fread(data.fid,1,'uchar');
                    if tag~=5
                        error 'wrong esds';
                    end
                    length = read_descr_length( data.fid );
                    data.tracks(data.total_tracks).stsd.audioSpecificConfig = fread(data.fid,length,'uchar');
                end
        end
        
    case 'stts'
        fread(data.fid,1,'uchar');
        fread(data.fid,3,'uchar');
        stts_entry_count = read_int( data.fid, 4 );
        data.tracks(data.total_tracks).stts_sample_count = zeros(1,stts_entry_count);
        data.tracks(data.total_tracks).stts_sample_delta = zeros(1,stts_entry_count);
        temp = read_int( data.fid, 4, stts_entry_count*2 );
        data.tracks(data.total_tracks).stts_sample_count = temp(1:2:end);
        data.tracks(data.total_tracks).stts_sample_delta = temp(2:2:end);
        
    case 'stsc'
        fread(data.fid,1,'uchar');
        fread(data.fid,3,'uchar');
        stsc_entry_count = read_int( data.fid, 4 );
        temp = read_int( data.fid, 4, stsc_entry_count*3 );
        data.tracks(data.total_tracks).stsc_first_chunk = temp(1:3:end);
        data.tracks(data.total_tracks).stsc_samples_per_chunk = temp(2:3:end);
        data.tracks(data.total_tracks).stsc_sample_desc_index = temp(3:3:end);
        
    case 'stsz'
        fread(data.fid,1,'uchar');
        fread(data.fid,3,'uchar');
        data.tracks(data.total_tracks).stsz_sample_size = read_int( data.fid, 4 );
        data.tracks(data.total_tracks).stsz_sample_count = read_int( data.fid, 4 );
        if data.tracks(data.total_tracks).stsz_sample_size==0
            data.tracks(data.total_tracks).stsz_table = read_int( data.fid, 4, data.tracks(data.total_tracks).stsz_sample_count );
        else
            data.tracks(data.total_tracks).stsz_table = data.tracks(data.total_tracks).stsz_sample_size*ones(1,data.tracks(data.total_tracks).stsz_sample_count);
        end
        
    case 'stco'
        fread(data.fid,1,'uchar');
        fread(data.fid,3,'uchar');
        stco_entry_count = read_int( data.fid, 4 );
        data.tracks(data.total_tracks).stco_chunk_offset = read_int( data.fid, 4, stco_entry_count );
end

current_position = ftell(data.fid);
skip = destination - current_position;
if skip>0
    status = fseek( data.fid, skip, 'cof' );
    if status~=0
        error 'fseek failed';
    end
end

function length = read_descr_length( fid )

numbytes = 0;
length = 0;
b = 128;
while bitget(b,8) && numbytes<4
    b = fread(fid,1,'uchar');
    numbytes = numbytes + 1;
    length = bitshift( length, 7 ) + mod( b,128);
end

function out = read_int( fid, n, m )

if nargin==2
    m = 1;
end
temp = fread(fid, n*m,'uchar');
temp = reshape(temp, n, m );
p = repmat( fliplr( cumprod( [1 2^8*ones(1,n-1)] ) )', 1, m );
out = sum( temp .* p );