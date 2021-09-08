function [vertex2, message_bin] = meshEmbed(m, vertex, face, file_name,Vertemb_Wrong)%传入加密后的vertex1
%% Convert Vertexes into Bitstream
magnify = 10^m;
[vertex, bit_len] = meshPrepro(m, vertex);
[~, ver_bin] = meshLength(vertex, bit_len);
% Vertemb_Wrong=int32([]);
%% Separate Vertexes into 2 Sets：Se，Sn
[num_face, ~] = size(face);
face = int32(face);
Vertemb = int32([]);
Vertnoemb = int32([]);

for i = 1:num_face
    v1 = isempty(find(face(i, 1)==Vertemb))==0;
    v2 = isempty(find(face(i, 2)==Vertemb))==0;
    v3 = isempty(find(face(i, 3)==Vertemb))==0;
    v4 = isempty(find(face(i, 1)==Vertnoemb))==0;
    v5 = isempty(find(face(i, 2)==Vertnoemb))==0;
    v6 = isempty(find(face(i, 3)==Vertnoemb))==0;
    if(v1==0 && v2==0 && v3==0) % no adjacent vertexes
        if(v4==0 && v5==0 & v6==0)
            Vertemb = [Vertemb face(i, 1)];
            Vertnoemb = [Vertnoemb face(i, 2) face(i, 3)];
        elseif(v4==0 && v5==0 & v6==1)
            Vertemb = [Vertemb face(i, 1)];
            Vertnoemb = [Vertnoemb face(i, 2)];
        elseif(v4==0 && v5==1 & v6==0)
            Vertemb = [Vertemb face(i, 1)];
            Vertnoemb = [Vertnoemb face(i, 3)];
        elseif(v4==1 && v5==0 & v6==0)
            Vertemb = [Vertemb face(i, 2)];
            Vertnoemb = [Vertnoemb face(i, 3)];
        elseif(v4==0 && v5==1 & v6==1)
            Vertemb = [Vertemb face(i, 1)];
        elseif(v4==1 && v5==0 & v6==1)
            Vertemb = [Vertemb face(i, 2)];
        elseif(v4==1 && v5==1 & v6==0)
            Vertemb = [Vertemb face(i, 3)];
        elseif(v4==1 && v5==1 & v6==1)
        end
    else %some adjacent vertexes
        if(v1==0)
            Vertnoemb = [Vertnoemb face(i, 1)];
        end
        if(v2==0)
            Vertnoemb = [Vertnoemb face(i, 2)];
        end
        if(v3==0)
            Vertnoemb = [Vertnoemb face(i, 3)];
        end
    end
    Vertnoemb = unique(Vertnoemb);%b = unique(A) 没有重复元素。
end
%% Embed messages into selected vertexes
%% 在此引入去除误差的函数，把vertexemb里的个别噪声去掉，达到更好的恢复结果
Vertemb=[setdiff(Vertemb,Vertemb_Wrong)];
%Generate the embedded message
[~, num_vertemb] = size(Vertemb);
k_emb = 54321;
num_vertemb1=num_vertemb*3;
message_bin = logical(pseudoGenerate(num_vertemb1, k_emb));
%% MSB
mes=1;
for i = 1:num_vertemb         %message_bin：embeding data
    if mes ==num_vertemb1+1;
        break;
    end
    index = int32(Vertemb(i));
    for j=1:3                
        operated_bits = ver_bin(3*(index-1)*bit_len + ...
            (j-1)*bit_len + 1: 3*(index-1)*bit_len + (j-1)*bit_len + bit_len);
        operated_bits(1)=message_bin(mes);   %MSB
        ver_bin(3*(index-1)*bit_len + (j-1)*bit_len + 1: ...
            3*(index-1)*bit_len + (j-1)*bit_len + bit_len) = operated_bits;
        mes=mes+1;
        
    end
end

%Reset into vertexes
encrypt_name = 'embedded';
vertex2 = meshGenerate(ver_bin, magnify, face, bit_len, file_name, encrypt_name);

end