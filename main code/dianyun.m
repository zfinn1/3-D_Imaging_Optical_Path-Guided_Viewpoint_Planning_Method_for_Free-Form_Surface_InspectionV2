% 读取 STL 文件
clear;
close all;
clc;
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
model = stlread(stlFile);

% 提取顶点并转换为点云
vertices = model.Points;
ptCloud = pointCloud(vertices);

% 可视化点云
figure;
pcshow(ptCloud, 'MarkerSize', 50);
title('原始点云');
xlabel('X'); ylabel('Y'); zlabel('Z');

gridSize = 0.1; % 网格大小，用于下采样
cleanPtCloud = pcdownsample(ptCloud, 'gridAverage', gridSize);

% 可视化降噪后的点云
figure;
pcshow(cleanPtCloud, 'MarkerSize', 50);
title('降噪后的点云');
xlabel('X'); ylabel('Y'); zlabel('Z');

% 提取点云的坐标
points = cleanPtCloud.Location;

% 使用 DBSCAN 聚类
epsilon = 0.5; % 邻域距离
minPts = 10;   % 最小点数
labels = dbscan(points, epsilon, minPts);

% 可视化分割结果
figure;
scatter3(points(:,1), points(:,2), points(:,3), 10, labels, 'filled');
title('DBSCAN 分割结果');
xlabel('X'); ylabel('Y'); zlabel('Z');
colorbar;



% 计算点云法向量
normals = pcnormals(cleanPtCloud);

% 根据法向量的角度进行分割
threshold = 0.9; % 法向量相似性阈值
mainSurfaceIdx = abs(normals(:,3)) > threshold;

% 分割点云
mainSurface = select(cleanPtCloud, mainSurfaceIdx);
otherSurface = select(cleanPtCloud, ~mainSurfaceIdx);

% 可视化分割结果
figure;
subplot(1, 2, 1);
pcshow(mainSurface, 'MarkerSize', 50);
title('主要表面');
subplot(1, 2, 2);
pcshow(otherSurface, 'MarkerSize', 50);
title('其他表面');
