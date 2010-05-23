function [pcm,aac] = aac_synth_frame( aac, ele )

%Init
element = aac.elements{ele};
nc = element.numChannels;
spec = cell(1,nc);
pcm = zeros(aac.frameLength,nc);

%Quantized spectrum
for c=1:nc
    spec{c} = element.channels(c).spectral_data;
end

%Add pulses
for c=1:nc
    spec{c} = aac_pulse( spec{c}, element.channels(c) );
end

%Inverse quantization
for c=1:nc
    spec{c} = aac_invquant( spec{c}, element.channels(c) );
end

%Mid-Side
if nc==2&&element.common_window
    spec = aac_ms( spec, element );
end

%Intensity stereo
if nc==2&&element.common_window
    spec = aac_is( spec, element );
end

%Coefficients reordering
for c=1:nc
    spec{c} = aac_reorder( spec{c}, element.channels(c) );
end

%PNS
for c=1:nc
    spec{c} = aac_pns( spec{c}, element.channels(c) );
end

%TNS
for c=1:nc
    spec{c} = aac_tns( spec{c}, element.channels(c) );
end

%Filter bank
for c=1:nc
    [pcm(:,c),aac.filter_bank_memory(ele,c).prev_winshape,aac.filter_bank_memory(ele,c).overlap] =...
        aac_filterbank( spec{c}, element.channels(c), aac.filter_bank_memory(ele,c).prev_winshape, aac.filter_bank_memory(ele,c).overlap );
end