function [ext_m, vertex3] = meshRecovery(m, vertex, face,file_name,vertexora,Vertemb_Wrong)
%% Convert vertexes into bitstream
magnify = 10^m;
[vertex1, bit_len] = meshPrepro(m, vertex);
[meshlen, ver_bin] = meshLength(vertex1, bit_len);
% ver_bin
%% Separate vertexes into 2 sets
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
    if(v1==0 && v2==0 && v3==0) %no adjacent vertexes
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
    Vertnoemb = unique(Vertnoemb);
end
Vertemb=[setdiff(Vertemb,Vertemb_Wrong)];
%% Use MSB to extract the messages 
[~, num_vertemb] = size(Vertemb);
num_vertemb1=3*num_vertemb;
ext_m = [];
ext_m_temp=[];
extractdata=1;
for i = 1:num_vertemb%message_bin：embeding data
    if extractdata ==num_vertemb1+1;
        break;
    end
    index = int32(Vertemb(i));
    for j=1:3
        % Extract data
        operated_bits = ver_bin(3*(index-1)*bit_len + ...
            (j-1)*bit_len + 1: 3*(index-1)*bit_len + (j-1)*bit_len + bit_len);
        ext_m_temp= operated_bits(1);%Extract MSB
        extractdata=extractdata+1;
        ext_m= [ext_m;ext_m_temp];
        %             ext_m
        
    end
end
%% Recover the mesh，Recovery the MSB
k_enc = 12345;
sec_bin = logical(pseudoGenerate(meshlen, k_enc));
ver_bin= xor(ver_bin,sec_bin);%解密操作，除了最高位，其他的都是正确序列
% 找到与嵌入顶点相邻的顶点，Index此时存储的是嵌入顶点的编号
for i = 1:num_vertemb
    index = int32(Vertemb(i));
%     index
    [row, ~, ~] = find(face==index);%在face数组中找到与嵌入顶点的编号Index相同的顶点数编号，按照行返回
    %     row
    f_len = length(row);
    %     f_len
    face_d = [];
    face_c1 = [];
    face_c2 = [];
    for j = 1:f_len
        face_d = [face_d; setdiff(face(row(j), :), index)];
        %           face_d = [face_d; face(row(j), :)];
        face_c1 = [face_c1; [vertexora(face_d(j, 1), 1) vertexora(face_d(j, 1), 2) vertexora(face_d(j, 1), 3)]];
        face_c2 = [face_c2; [vertexora(face_d(j, 2), 1) vertexora(face_d(j, 2), 2) vertexora(face_d(j, 2), 3)]];
        face_cc=[face_c1;face_c2];
    end
    face_cc = unique(face_cc, 'rows');
%     face_cc
    for j=1:3
        face_cc_temp=face_cc(:,j);
        num1=length(find(face_cc_temp(:,1)>=0));
        num2=length(find(face_cc_temp(:,1)<0));
        if num1>=num2  %符号位为正数
            operated_bits = ver_bin(3*(index-1)*bit_len + ...
                (j-1)*bit_len + 1: 3*(index-1)*bit_len + (j-1)*bit_len + bit_len);
            %             operated_bits
            operated_bits(1)=0;
            ver_bin(3*(index-1)*bit_len + (j-1)*bit_len + 1: ...
                3*(index-1)*bit_len + (j-1)*bit_len + bit_len) = operated_bits;
            %             operated_bits1 = ver_bin(3*(index-1)*bit_len + ...%增加
            %                 (j-1)*bit_len + 1: 3*(index-1)*bit_len + (j-1)*bit_len + bit_len);
            %             operated_bits1
            %             fprintf('***');
        else  %符号位为负数
            operated_bits = ver_bin(3*(index-1)*bit_len + ...
                (j-1)*bit_len + 1: 3*(index-1)*bit_len + (j-1)*bit_len + bit_len);
            %             operated_bits
            operated_bits(1)=1;
            ver_bin(3*(index-1)*bit_len + (j-1)*bit_len + 1: ...
                3*(index-1)*bit_len + (j-1)*bit_len + bit_len) = operated_bits;
        end
        
    end
    
    
    
    
end
%% Convert into the recovered
encrypt_name = 'recovered';
vertex3= meshGenerate(ver_bin, magnify, face, bit_len, file_name, encrypt_name);


end

