%% Skeleton Extraction from STL Model (Method 2: 基于骨架提取)
clear; clc; close all;

%% 1. 读取 STL 模型
stl_file = 'C:\Users\86132\Desktop\c\111.stl'; % 请替换为你的STL文件路径
model = stlread(stl_file);
faces = model.ConnectivityList;
vertices = model.Points;

%% 2. 构造体素化网格
% 计算模型包围盒，并适当扩展一点
margin = 50;  % 可以根据模型大小调整
xmin = min(vertices(:,1)) - margin;
xmax = max(vertices(:,1)) + margin;
ymin = min(vertices(:,2)) - margin;
ymax = max(vertices(:,2)) + margin;
zmin = min(vertices(:,3)) - margin;
zmax = max(vertices(:,3)) + margin;

% 定义体素大小（分辨率）
voxelSize = 1;  % 单位与模型一致（例如毫米或其他单位），可以调整
x = xmin:voxelSize:xmax;
y = ymin:voxelSize:ymax;
z = zmin:voxelSize:zmax;
[X, Y, Z] = meshgrid(x, y, z);

%% 3. 体素化：判断每个网格点是否在模型内部
% 这里用 inpolyhedron 判断点是否在模型内部（inpolyhedron 可从 MATLAB File Exchange 下载）
points = [X(:), Y(:), Z(:)];
inside =  in_polyhedron(faces, vertices, points);
BW = reshape(inside, size(X));  % 构造二值体积

%% 4. 三维骨架提取（skeletonization）
% 使用 MATLAB 内置 bwskel (要求 R2017b 及以上)
skel = bwskel(BW, 'MinBranchLength', 10);  % 可根据需要调整参数

%% 5. 提取骨架点并转换为实际坐标
[sy, sx, sz] = ind2sub(size(skel), find(skel)); 
% 注意：由于 meshgrid 的排列，x 对应第二维，y 对应第一维，z 对应第三维
% 将体素坐标转换为实际坐标
skelPoints = [sx, sy, sz] * voxelSize; 
% 加上网格起始偏移量
skelPoints(:,1) = skelPoints(:,1) + xmin - voxelSize;
skelPoints(:,2) = skelPoints(:,2) + ymin - voxelSize;
skelPoints(:,3) = skelPoints(:,3) + zmin - voxelSize;

%% 6. 可视化结果
figure;
% 绘制 STL 模型
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
    'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', [0.7 0.7 1]);
camlight; lighting gouraud;
hold on;
% 绘制骨架点
scatter3(skelPoints(:,1), skelPoints(:,2), skelPoints(:,3), 20, 'r', 'filled');
title('STL 模型与提取的骨架（中心线）');
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal; grid on; view(3);
