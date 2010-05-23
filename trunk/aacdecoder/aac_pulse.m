function y = aac_pulse( x, data )
%Add pulses to quantized spectral coefficients
%See: 4.6.3.3 Decoding process

%Init
y = x;

if data.pulse.pulse_data_present

    %Init
    swb_offset = data.ics_info.swb_offset;
    number_pulse = data.pulse.number;
    pulse_start_sfb = data.pulse.start_sfb;
    pulse_offset = data.pulse.offset;
    pulse_amp = data.pulse.amp;

    %Add pulses
    k = swb_offset(pulse_start_sfb+1);
    for j=1:number_pulse+1
        k = k + pulse_offset(j);
        if y{1}(k)>0
            y{1}(k) = y{1}(k) + pulse_amp(j);
        else
            y{1}(k) = y{1}(k) - pulse_amp(j);
        end
    end
end