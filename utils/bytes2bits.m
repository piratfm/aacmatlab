function bits = bytes2bits( bytes )

bits = zeros(8,length(bytes));
for n=1:8
    bits(n,:) = bitget(bytes,8-n+1);
end
bits = bits(:);