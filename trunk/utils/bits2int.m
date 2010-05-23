function out = bits2int( bits )

out = sum( bits .* 2.^(length(bits)-1:-1:0)' );