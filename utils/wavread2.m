function [y,fs] = wavread2( file )

%Open file
fid = fopen( file, 'rb' );

%RIFF chunk
ckID = fread(fid,4,'*char');
if strcmp(ckID','RIFF')==0
    error 'ckID not RIFF';
end
fread(fid,1,'uint32',0,'l');
WAVEID = fread(fid,4,'*char');
if strcmp(WAVEID','WAVE')==0
    error 'WAVEID not WAVE';
end

%Format Chunk
ckID = fread(fid,4,'*char');
if strcmp(ckID','fmt ')==0
    error 'ckID not fmt ';
end
fread(fid,1,'uint32',0,'l');
fread(fid,1,'uint16',0,'l');
nChannels = fread(fid,1,'uint16',0,'l');
nSamplesPerSec = fread(fid,1,'uint32',0,'l');
fread(fid,1,'uint32',0,'l');
fread(fid,1,'uint16',0,'l');
wBitsPerSample = fread(fid,1,'uint16',0,'l');
fread(fid,1,'uint16',0,'l');
fread(fid,1,'uint16',0,'l');
fread(fid,1,'uint32',0,'l');
fread(fid,16,'uchar');

%Fact Chunk
ckID = fread(fid,4,'*char');
if strcmp(ckID','fact')
    fread(fid,1,'uint32',0,'l');
    fread(fid,1,'uint32',0,'l');
    %Data Chunk
    ckID = fread(fid,4,'*char');
    if strcmp(ckID','data')==0
        error 'ckID not data';
    end
    cksize = fread(fid,1,'uint32',0,'l');
    data = fread(fid,cksize*8/wBitsPerSample,['bit' num2str(wBitsPerSample)],0,'l');
elseif strcmp(ckID','data')
    %Data Chunk (no fact chunk)
    cksize = fread(fid,1,'uint32',0,'l');
    data = fread(fid,cksize*8/wBitsPerSample,['bit' num2str(wBitsPerSample)],0,'l');
else
    error 'ckID unknown';
end

%Close file
fclose(fid);

%Output
y = reshape(data,nChannels,length(data)/nChannels)';
fs = nSamplesPerSec;