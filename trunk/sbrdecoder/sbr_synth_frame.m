function [pcm,sbr] = sbr_synth_frame( sbr, pcm_aac )

%QMF analysis of AAC core samples
sbr = sbr_qmf_analysis( sbr, pcm_aac );

if sbr.header_present

    %Compute time/frequency grid
    sbr = sbr_time_freq_grid( sbr );

    %Generate high frequency subbands
    sbr = sbr_hf_generation( sbr );

    %Dequantize envelope and noise floor
    sbr = sbr_env_noise_dec( sbr );

    %Compute gains
    sbr = sbr_hf_gains( sbr );

    %Apply gains + Add noise + Add sinusoids
    sbr = sbr_hf_assembly( sbr );
    
end

%QMF synthesis
[sbr,pcm] = sbr_qmf_synthesis( sbr );