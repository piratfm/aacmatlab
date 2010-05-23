function [index,c] = sbr_huff_dec(bits, t_huff)

index = 0;
c = 0;

while index >= 0
    bit = bits(c+1);
    c = c + 1;
    index = t_huff(index+1,bit+1);
end

index = index + 64;