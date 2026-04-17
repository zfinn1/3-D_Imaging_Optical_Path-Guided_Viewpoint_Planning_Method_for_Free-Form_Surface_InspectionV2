

clear;
close all;
clc;
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; 
% 读取 STL 文件
model= stlread(stlFile);
vertices = model.Points; % 提取模型的顶点坐标（点云数据）
faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成


[simplifiedFaces, simplifiedVertices] = reducepatch(faces, vertices, 0.1);
% 可视化叶片模型的三角形面片
figure;
trisurf(simplifiedFaces,  simplifiedVertices(:,1),  simplifiedVertices(:,2),  simplifiedVertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k'); % 'FaceColor' 为面片的颜色，'EdgeColor' 为边缘的颜色
axis equal; % 设置坐标轴比例，使各轴单位长度相等
title('飞机叶片三角形面片分布');
xlabel('X'); ylabel('Y'); zlabel('Z');

% 可视化叶片模型的三角形面片
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k'); % 'FaceColor' 为面片的颜色，'EdgeColor' 为边缘的颜色
axis equal; % 设置坐标轴比例，使各轴单位长度相等
title('飞机叶片三角形面片分布');
xlabel('X'); ylabel('Y'); zlabel('Z');