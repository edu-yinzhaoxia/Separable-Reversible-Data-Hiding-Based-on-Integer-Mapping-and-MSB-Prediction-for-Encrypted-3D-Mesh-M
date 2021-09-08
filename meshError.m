function[Vertemb_Wrong]=meshError(m,face,vertex)%此时传入原始矩阵
magnify = 10^m;
[vertex, bit_len] = meshPrepro(m, vertex);
[~, ver_bin] = meshLength(vertex, bit_len);
[num_face, ~] = size(face);
face = int32(face);
Vertemb = int32([]);
Vertnoemb = int32([]);
Vertemb_Wrong=int32([]);
 Vertemb_Right=int32([]);
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
end
%% Vertemb:矩阵里面是所有的嵌入顶点，现在需要进一步去除掉具有误差的顶点
[~, num_vertemb] = size(Vertemb);
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
        face_c1 = [face_c1; [vertex(face_d(j, 1), 1) vertex(face_d(j, 1), 2) vertex(face_d(j, 1), 3)]];
        face_c2 = [face_c2; [vertex(face_d(j, 2), 1) vertex(face_d(j, 2), 2) vertex(face_d(j, 2), 3)]];
        face_cc=[face_c1;face_c2];
    end
    face_cc = unique(face_cc, 'rows');%每个嵌入顶点的邻接顶点矩阵
    %% 比较最高位是否预测准确
    for j=1:3 
        operated_bits = ver_bin(3*(index-1)*bit_len + ...
            (j-1)*bit_len + 1: 3*(index-1)*bit_len + (j-1)*bit_len + bit_len);
        operated_bits_hight=operated_bits(1);%取出最高位,81=(0 1 0)
        face_cc_temp=face_cc(:,j);
        num1=length(find(face_cc_temp(:,1)>=0));
        num2=length(find(face_cc_temp(:,1)<0));
        if num1>=num2  %符号位为正数
            operated_bits=0;
        else  %符号位为负数
            operated_bits=1;
        end
        %         operated_bits
        %         operated_bits_hight
        if operated_bits~=operated_bits_hight
            Vertemb_Wrong(i)=index;
            break;
        end
        
    end
    Vertemb_Wrong=[setdiff(Vertemb_Wrong,0)];
%      Vertemb_Right=[setdiff(Vertemb,Vertemb_Wrong)];
    
    
    
    
    
    
    
    
    
    
end





















% vertex= meshGenerate(ver_bin, magnify, face, bit_len, file_name, encrypt_name);
end
