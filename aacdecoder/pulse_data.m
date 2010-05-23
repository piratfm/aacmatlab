function [pulse,c] = pulse_data( bits )
%Table 4.7 – Syntax of pulse_data()

%Init
c = 0;

%Pulse flag
pulse.pulse_data_present = bits(c+1);
c = c + 1;

if pulse.pulse_data_present

    %Decode pulses
    pulse.number = bits2int( bits(c+1:c+2) );
    c = c + 2;
    pulse.start_sfb = bits2int( bits(c+1:c+6) );
    c = c + 6;
    for i=1:pulse.number+1
        pulse.offset(i) = bits2int( bits(c+1:c+5) );
        c = c + 5;
        pulse.amp(i) = bits2int( bits(c+1:c+4) );
        c = c + 4;
    end
end