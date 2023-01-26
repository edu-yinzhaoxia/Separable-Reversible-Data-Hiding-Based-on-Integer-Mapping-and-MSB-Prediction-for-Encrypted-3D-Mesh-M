clear; clc; close all;
addpath(genpath(pwd));

fprintf('Conduct RDH-ED in 3D meshes:\n');
tic
Capacity = [];
HD = [];
SNR = [];
for m=4:6
%徐娜
% name = 'beetle.off'; 
name = 'mushroom.off';
% name = 'mannequin.off';
% name ='happy_vrip.ply';
% name = 'Ramesses.off';
% name = 'elephant.off'; 
% name = 'cube.off';
% name = 'tre_twist.off';                   
source_dir = 'data/source';
source_dir = [source_dir,'/',name];
%% Read 3d mesh 
[~, file_name, suffix] = fileparts(source_dir);
if(strcmp(suffix,'.obj')==0) %off
    [vertex, face] = read_mesh(source_dir);                                                                                              
    vertex = vertex'; face = face'; 
else    %obj
    Obj = readObj(source_dir);
    vertex = Obj.v; face = Obj.f.v;%
end
vertex0 = vertex;
%% Preprocess
magnify = 10^m;
[vertex, bit_len] = meshPrepro(m, vertex);
fprintf('2');
%% Compute mesh length
[meshlen, ver_bin] = meshLength(vertex, bit_len);
%% 误差处理
Vertemb_Wrong=meshError(m,face,vertex0);%在顶点矩阵不做任何处理的情况下，选取出具有误差的顶点编号
% plot_mesh(vertex,face);
% meshlen
% ver_bin
% Generate a psudorandom stream
k_enc = 12345;
sec_bin = logical(pseudoGenerate(meshlen, k_enc));
fprintf('3');
%% XOR  Encrypt
enc_bin = xor(ver_bin, sec_bin);
%% Generate encrypted mesh
encrypt_name = 'encrypted';
vertex1= meshGenerate(enc_bin, magnify, face, bit_len, file_name, encrypt_name);
fprintf('4');
%% Message embedding
[vertex2, message_bin] = meshEmbed(m, vertex1, face, file_name,Vertemb_Wrong); 
% plot_mesh(vertex2,face);
fprintf('5');
%% Message extraction & mesh recovery
[ext_m, vertex3] = meshRecovery(m,vertex2, face,file_name,vertex0,Vertemb_Wrong);
% plot_mesh(vertex3,face);%recovery mesh
fprintf('6');
toc

%% Test
[hd] = HausdorffDist(vertex0,vertex3,1,0);
snr = meshSNR(vertex0,vertex3);
[v_n, ~] = size(vertex);
capacity = length(ext_m)/v_n;
err_dist = message_bin - ext_m;
err_len = length(find(err_dist(:)~=0));
data_err_percent = err_len/length(ext_m);
Capacity = [Capacity capacity];
HD = [HD hd];
SNR = [SNR snr];
end






