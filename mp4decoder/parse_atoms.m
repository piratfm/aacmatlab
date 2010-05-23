function data = parse_atoms( data )

%Init
data.eof = 0;
data.total_tracks = 0;

%Read first atom header
[headerSize,atomSize,typeTxt,typeIdx,data] = read_atom_header( data );

%Loop
while ~data.eof
    
    %MOOV atom
    if typeIdx==1
        data.moov.offset = ftell(data.fid) - headerSize;
        data.moov.size = atomSize;
    end
    
    %MDAT atom
    if typeIdx==130
        data.mdat.offset = ftell(data.fid) - headerSize;
        data.mdat.size = atomSize;
    end
    
    if typeIdx<128
        
        %Parse subatoms
        data = parse_subatoms( data, atomSize-headerSize );
        
    else
        
        %Go to next atom header
        status = fseek( data.fid, atomSize-headerSize, 'cof' );
        if status~=0
            error 'fseek failed';
        end
        
    end

    %Read next atom header
    [headerSize,atomSize,typeTxt,typeIdx,data] = read_atom_header( data );
end

%End
data = rmfield(data,'eof');