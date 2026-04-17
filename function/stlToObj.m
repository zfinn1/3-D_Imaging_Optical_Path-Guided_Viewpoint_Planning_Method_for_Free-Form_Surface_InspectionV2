
clear;
close all;
clc;

stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl';  % 替换为实际的 STL 文件路径
objFile = 'C:\Users\86132\Desktop\本科毕设\model.obj';  % 输出 OBJ 文件路径
% 读取 STL 文件
model = stlread(stlFile);

% 提取顶点和面数据
vertices = model.Points;  % 顶点
faces = model.ConnectivityList;  % 面片

% 打开 OBJ 文件进行写入
fid = fopen(objFile, 'w');

if fid == -1
    error('无法打开文件: %s', objFile);
end

% 写入顶点数据
for i = 1:size(vertices, 1)
    fprintf(fid, 'v %.6f %.6f %.6f\n', vertices(i, 1), vertices(i, 2), vertices(i, 3));
end

% 写入面数据
for i = 1:size(faces, 1)
    % 注意：OBJ 中的面索引从 1 开始，而 STL 文件的面索引从 1 开始，因此无需调整索引
    fprintf(fid, 'f %d %d %d\n', faces(i, 1), faces(i, 2), faces(i, 3));
end

% 关闭文件
fclose(fid);

disp(['转换完成，OBJ 文件已保存为: ', objFile]);

% 加载 OBJ 文件并可视化
% 打开 OBJ 文件进行读取
fid = fopen(objFile, 'r');

if fid == -1
    error('无法打开文件: %s', objFile);
end

% 初始化顶点和面数组
objVertices = [];
objFaces = [];

% 逐行读取 OBJ 文件内容
while ~feof(fid)
    line = fgetl(fid);
    
    % 如果是顶点数据
    if strncmp(line, 'v ', 2)
        data = sscanf(line, 'v %f %f %f');
        objVertices = [objVertices; data'];
        
    % 如果是面数据
    elseif strncmp(line, 'f ', 2)
        data = sscanf(line, 'f %d %d %d');
        objFaces = [objFaces; data'];
    end
end

% 关闭文件
fclose(fid);

% 可视化 OBJ 模型
figure;
trisurf(objFaces, objVertices(:,1), objVertices(:,2), objVertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k');
hold on;
axis equal;
camlight;
lighting phong;
title('Visualizing OBJ Model');

