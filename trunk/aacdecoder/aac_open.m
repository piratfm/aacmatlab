function aac = aac_open( asc )

%Decode ASC
conf = aac_decode_asc( asc );

%Copy useful data
aac.samplingFrequencyIndex = conf.samplingFrequencyIndex;
aac.samplingFrequency = conf.samplingFrequency;
aac.channelConfiguration = conf.channelConfiguration;
aac.programConfigElement = conf.pce;
if conf.frameLengthFlag
    aac.frameLength = 960;
else
    aac.frameLength = 1024;
end

%Get SFB info
[aac.sfb_tns_info.sfb_long,aac.sfb_tns_info.sfb_short] = sfb_info( aac.samplingFrequency, aac.frameLength );

%Get TNS info
[aac.sfb_tns_info.tns_long,aac.sfb_tns_info.tns_short] = tns_info( aac.samplingFrequencyIndex );


%Init filterbank memory
for ele=1:48
    for c=1:2
        aac.filter_bank_memory(ele,c).prev_winshape = 0;
        aac.filter_bank_memory(ele,c).overlap = zeros(1,aac.frameLength);
    end
end

%Init elements
aac.num_elements = 0;
aac.elements = {};