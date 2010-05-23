function [aac,c] = data_stream_element( aac, bits, bit_counter )
%Table 4.10 – Syntax of data_stream_element()

% Init bit counter
c = 0;

% Decode element instance tag
aac.elements{aac.num_elements}.instance_tag = bits2int( bits(c+1:c+4) );
c = c + 4;

% Decode data byte align flag
data_byte_align_flag = bits2int( bits(c+1:c+1) );
c = c + 1;

%Decode count
count = bits2int( bits(c+1:c+8) );
c = c + 8;
cnt = count;
if cnt==255
    esc_count = bits2int( bits(c+1:c+8) );
    c = c + 8;
    cnt = cnt + esc_count;
end

%Byte align
if data_byte_align_flag
    total = bit_counter + c;
    remaining = ceil(total/8)*8 - total;
    c = c + remaining;
end

%Decode data
aac.elements{aac.num_elements}.data = zeros(1,cnt);
for n=1:cnt
    aac.elements{aac.num_elements}.data(n) = bits2int( bits(c+1:c+8) );
    c = c + 8;
end