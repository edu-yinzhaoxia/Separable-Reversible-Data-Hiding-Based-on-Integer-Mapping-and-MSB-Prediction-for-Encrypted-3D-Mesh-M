function [meshlen, ver_bin] = meshLength(vertex, bit_len)
%把取整后的整数顶点值，和位长传给meshLength函数
%Convert vertex into binary stream

[v_h, ~] = size(vertex);%v_h保存顶点的个数,size返回的的是行列数
ver_int = [];%ver_int保存所有顶点信息
for i = 1:v_h
    ver_int = [ver_int; vertex(i, 1); vertex(i, 2); vertex(i, 3);];
%     ver_int
end
ver_bin = logical([]);
for i = 1:length(ver_int)
    temp = dec2binPN(ver_int(i), bit_len);
    ver_bin = [ver_bin; temp];%ver_bin顶点的二进制信息
  
end

meshlen = length(ver_bin);

end