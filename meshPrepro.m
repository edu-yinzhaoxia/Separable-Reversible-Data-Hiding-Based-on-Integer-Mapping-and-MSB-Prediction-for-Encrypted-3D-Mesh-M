function [vertex, bit_len] = meshPrepro(m, vertex)
%mesh preporcessing

magnify = 10^m;
vertex = vertex*magnify;
if(m>=10)
    vertex = int64(vertex); bit_len = 64;
elseif(m<=2)
    vertex = int8(vertex); bit_len = 8;
elseif(m<=4)
    vertex = int16(vertex); bit_len = 16;
else
    vertex = int32(vertex); bit_len = 32;
end

end