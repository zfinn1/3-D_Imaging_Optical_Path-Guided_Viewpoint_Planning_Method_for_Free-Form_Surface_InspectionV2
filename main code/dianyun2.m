% 读取飞机叶片模型
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
model = stlread(stlFile); % 使用 stlread 函数加载 STL 文件，获取模型的几何数据
vertices = model.Points; % 提取模型的顶点坐标（点云数据）
faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）

% 可视化叶片模型
figure; % 创建一个新的图形窗口
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'none'); % 使用 trisurf 绘制三角网格模型
axis equal; % 设置坐标轴比例，使各轴单位长度相等
title('飞机叶片模型'); % 设置图形标题
xlabel('X'); ylabel('Y'); zlabel('Z'); % 设置坐标轴标签

% 计算每个面的法向量
faceNormals = faceNormal(triangulation(faces, vertices)); 
% 使用 faceNormal 函数计算每个三角形面的法向量
% 需要将顶点和面片信息封装成 triangulation 对象

% 参数设置
viewDistance = 30; % 视点距离，即视点距离每个面中心点的距离
fovAngle = 30; % 相机视场角（度），可用于后续可见性分析（未用到此代码中）
overlapFactor = 1.2; % 覆盖重叠因子，用于调整视点的覆盖范围（未用到此代码中）

% 为每个面生成视点
viewpoints = []; % 初始化视点存储矩阵，视点以行向量形式存储，每行代表一个视点的 [x, y, z] 坐标
for i = 1:size(faces, 1) % 遍历每个三角面片
    % 获取面中心点
    faceCenter = mean(vertices(faces(i, :), :), 1); 
    % 通过取面片的 3 个顶点的均值，计算出三角面的中心点坐标

    % 生成面法向外的视点
    viewpoint = faceCenter + faceNormals(i, :) * viewDistance; 
    % 根据面法向量的方向和视点距离，计算该面的观察点（沿法向方向延伸）

    % 添加视点
    viewpoints = [viewpoints; viewpoint]; % 将计算的视点坐标添加到视点列表中
end

% 可视化生成的视点
figure; % 创建一个新的图形窗口
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
    'FaceColor', 'blue', 'EdgeColor', 'none'); 
% 绘制飞机叶片的三角网格模型
hold on; % 保持当前图形，添加视点数据
scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 'r', 'filled'); 
% 用红色点表示生成的视点
title('基于法向的视点生成'); % 设置图形标题
xlabel('X'); ylabel('Y'); zlabel('Z'); % 设置坐标轴标签

% clear; 
% close all; 
% clc;

% 读取 STL 文件
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% clear;
% close all;
% clc;
% stlFile = 'C:\Users\86132\Desktop\c\111.stl';
% model = stlread(stlFile); % 使用 stlread 函数加载 STL 文件，获取模型的几何数据
% vertices = model.Points; % 提取模型的顶点坐标（点云数据）
% faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）
% 
% 
% 
% % 可视化叶片模型的三角形面片
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'k'); % 'FaceColor' 为面片的颜色，'EdgeColor' 为边缘的颜色
% axis equal; % 设置坐标轴比例，使各轴单位长度相等
% title('飞机叶片三角形面片分布');
% xlabel('X'); ylabel('Y'); zlabel('Z');
% % 假设已有三角形网格 faces 和顶点 vertices
% % faces 是 n×3 的矩阵，vertices 是 m×3 的顶点矩阵


