function [headerSize,atomSize,typeTxt,typeIdx,data] = read_atom_header( data )

[bytes,count] = fread( data.fid, 8, 'uchar' );

if count<8
    
    %End of file
    data.eof = 1;
    headerSize = 0;
    atomSize = 0;
    typeTxt = 0;
    typeIdx = 0;

else

    %Header and atom size
    headerSize = 8;
    atomSize = bytes(1)*2^24 + bytes(2)*2^16 + bytes(3)*2^8 + bytes(4);

    %Long atom: size coded on 64 bits instead of 32 bits
    if atomSize==1
        headerSize = 16;
        atomSize = fread(data.fid,1,'int64');
    end

    %Atom type (text)
    typeTxt = char(bytes(5:8))';
    
    %Atom type (integer index)
    switch typeTxt
        case 'moov'
            typeIdx = 1;
        case 'trak'
            typeIdx = 2;
        case 'edts'
            typeIdx = 3;
        case 'mdia'
            typeIdx = 4;
        case 'minf'
            typeIdx = 5;
        case 'stbl'
            typeIdx = 6;
        case 'udta'
            typeIdx = 7;
        case 'ilst'
            typeIdx = 8;
        case 'ftyp'
            typeIdx = 129;
        case 'mdat'
            typeIdx = 130;
        otherwise
            typeIdx = 255;
    end
end