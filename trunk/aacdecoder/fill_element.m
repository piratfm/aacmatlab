function [aac,c] = fill_element( aac, bits )
%Table 4.11 – Syntax of fill_element()

c = 0;

count = bits2int( bits(c+1:c+4) );
c = c + 4;

cnt = count;
if cnt==15
    esc_count = bits2int( bits(c+1:c+8) );
    c = c + 8;
    cnt = cnt + esc_count-1;
end

aac.elements{aac.num_elements}.data = bits(c+1:c+8*cnt);
c = c + 8*cnt;