% clear;
% close all;
% clc;
% 
% % 读取飞机叶片模型
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% model = stlread(stlFile); % 使用 stlread 函数加载 STL 文件，获取模型的几何数据
% vertices = model.Points; % 提取模型的顶点坐标（点云数据）
% faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）
% 
% % 计算每个面的法向量
% faceNormals = faceNormal(triangulation(faces, vertices)); 
% % 使用 faceNormal 函数计算每个三角形面的法向量
% 
% % 参数设置
% viewDistance = 30; % 视点距离，即视点距离每个面中心点的距离
% 
% % 为每个面生成视点
% viewpoints = []; % 初始化视点存储矩阵，视点以行向量形式存储，每行代表一个视点的 [x, y, z] 坐标
% for i = 1:size(faces, 1) % 遍历每个三角面片
%     % 获取面中心点
%     faceCenter = mean(vertices(faces(i, :), :), 1); 
%     % 通过取面片的 3 个顶点的均值，计算出三角面的中心点坐标
% 
%     % 生成面法向外的视点
%     viewpoint = faceCenter + faceNormals(i, :) * viewDistance; 
%     % 根据面法向量的方向和视点距离，计算该面的观察点（沿法向方向延伸）
% 
%     % 添加视点
%     viewpoints = [viewpoints; viewpoint]; % 将计算的视点坐标添加到视点列表中
% end
% 
% % 可视化生成的视点
% figure; % 创建一个新的图形窗口
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'k'); 
% % 绘制飞机叶片的三角网格模型
% hold on; % 保持当前图形，添加视点数据
% 
% % 绘制视点（调整大小）
% scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 5, 'r', 'filled'); 
% 
% % 绘制每个三角形面的法向量
% for i = 1:size(faces, 1)
%     % 获取面中心点
%     faceCenter = mean(vertices(faces(i, :), :), 1); 
%     % 绘制法向量（每个面片的法向量从面中心延伸）
%     quiver3(faceCenter(1), faceCenter(2), faceCenter(3), ...
%             faceNormals(i, 1), faceNormals(i, 2), faceNormals(i, 3), ...
%             10, 'Color', 'g', 'LineWidth', 2);
% end
% 
% title('基于法向的视点生成和法向量');
% xlabel('X'); ylabel('Y'); zlabel('Z');
% axis equal;

clear;
close all;
clc;

% 读取飞机叶片模型
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
model = stlread(stlFile); % 使用 stlread 函数加载 STL 文件，获取模型的几何数据
vertices = model.Points; % 提取模型的顶点坐标（点云数据）
faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）

% 计算每个面的法向量
faceNormals = faceNormal(triangulation(faces, vertices)); 
% 使用 faceNormal 函数计算每个三角形面的法向量

% 计算每个三角形的曲率（估算）
curvature = zeros(size(faces, 1), 1);
for i = 1:size(faces, 1)
    % 通过法向量的变化估算曲率
    v1 = vertices(faces(i, 1), :);
    v2 = vertices(faces(i, 2), :);
    v3 = vertices(faces(i, 3), :);
    edge1 = v2 - v1;
    edge2 = v3 - v1;
    % 曲率与边长的关系（假设较大边长的曲率较小）
    curvature(i) = norm(cross(edge1, edge2)) / (norm(edge1) * norm(edge2));
end

% 正规化曲率值，便于控制法向量密度
curvature = curvature / max(curvature);

% 参数设置
viewDistance = 30; % 视点距离，即视点距离每个面中心点的距离
minCurvatureThreshold = 0.5; % 曲率阈值，小于该值的地方不绘制法向量
samplingInterval = 5; % 法向量绘制间隔，每隔几面绘制一个法向量

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
    'FaceColor', 'cyan', 'EdgeColor', 'k'); 
% 绘制飞机叶片的三角网格模型
hold on; % 保持当前图形，添加视点数据

% 绘制视点（调整大小）
scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 5, 'r', 'filled'); 

% 绘制法向量（根据曲率调整密度）
for i = 1:round(size(faces, 1) / samplingInterval)
    idx = i * samplingInterval; % 每隔几面绘制一次
    if curvature(idx) > minCurvatureThreshold % 只在曲率较大的地方绘制法向量
        % 获取面中心点
        faceCenter = mean(vertices(faces(idx, :), :), 1); 
        % 绘制法向量（每个面片的法向量从面中心延伸）
        quiver3(faceCenter(1), faceCenter(2), faceCenter(3), ...
                faceNormals(idx, 1), faceNormals(idx, 2), faceNormals(idx, 3), ...
                5 * curvature(idx), 'Color', 'g', 'LineWidth', 2);
    end
end

title('根据曲率优化法向量密度');
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal;

