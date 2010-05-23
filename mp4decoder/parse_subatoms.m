function data = parse_subatoms( data, totalsize )

%Init
counted_size = 0;

while counted_size < totalsize
    
    %Read atom header
    [headerSize,atomSize,typeTxt,typeIdx,data] = read_atom_header( data );
    counted_size = counted_size + atomSize;
    
    %Track atom
    if typeIdx==2
        data.total_tracks = data.total_tracks + 1;
    end
    
    if typeIdx<128
        
        %Parse subatoms
        data = parse_subatoms( data, atomSize-headerSize );
        
    else
        
        %Read atom
        data = read_atom( data, atomSize-headerSize, typeTxt );
        
    end

end