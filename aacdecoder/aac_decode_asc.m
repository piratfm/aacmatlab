function conf = aac_decode_asc( asc )

% Bytes to bits
bits = bytes2bits( asc );

% Init bit counter
c = 0;

% Audio Object Type (AOT)
conf.audioObjectType = bits2int( bits(c+1:c+5) );
c = c + 5;
if conf.audioObjectType~=2
    error('Unsupported AOT')
end

% Sampling Frequency
conf.samplingFrequencyIndex = bits2int( bits(c+1:c+4) );
c = c + 4;
if conf.samplingFrequencyIndex>12
    error('Unsupported Sampling Frequency Index')
end
sftab = [96000,88200,64000,48000,44100,32000,24000,22050,16000,12000,...
            11025,8000,7350];
conf.samplingFrequency = sftab(conf.samplingFrequencyIndex+1);

% Channel Configuration
conf.channelConfiguration = bits2int( bits(c+1:c+4) );
c = c + 4;

% Frame length
conf.frameLengthFlag = bits(c+1);
c = c + 1;

% Depends on core coder
conf.dependsOnCoreCoder = bits(c+1);
c = c + 1;
if conf.dependsOnCoreCoder
    error 'dependsOnCoreCoder==1'
end

% Extension Flag
conf.extensionFlag = bits(c+1);
c = c + 1;
if conf.extensionFlag
    error 'extensionFlag==1'
end

% Program Config Element
if conf.channelConfiguration==0
    [conf.pce,decoded_bits] = program_config_element( bits(c+1:end), c );
    c = c + decoded_bits;
else
    conf.pce = [];
end

% SBR + PS
conf.sbrPresentFlag = 0;
conf.psPresentFlag = 0;
bits_to_decode = length(bits)-c;
if bits_to_decode>=16
    syncExtensionType = bits2int( bits(c+1:c+11) );
    c = c + 11;
    if syncExtensionType==695
        conf.extensionAudioObjectType = bits2int( bits(c+1:c+5) );
        c = c + 5;
        if conf.extensionAudioObjectType==5
            conf.sbrPresentFlag = bits(c+1);
            c = c + 1;
            if conf.sbrPresentFlag
                conf.extensionSamplingFrequencyIndex = bits2int( bits(c+1:c+4) );
                c = c + 4;
                if conf.extensionSamplingFrequencyIndex>12
                    error('Unsupported Sampling Frequency Index')
                end
                conf.extensionSamplingFrequency = sftab(conf.extensionSamplingFrequencyIndex+1);
                bits_to_decode = length(bits)-c;
                if bits_to_decode>=16
                    syncExtensionType = bits2int( bits(c+1:c+11) );
                    c = c + 11;
                    if syncExtensionType==1352
                        conf.psPresentFlag = bits(c+1);
                        c = c + 1;
                    end
                end
            end
        else
            error('Unsupported extension AOT')
        end
    end
end