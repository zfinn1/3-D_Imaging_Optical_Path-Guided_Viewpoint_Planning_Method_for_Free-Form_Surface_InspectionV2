% 
% clear; clc;
% % 读取飞机叶片模型
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% model = stlread(stlFile);
% vertices = model.Points;
% faces = model.ConnectivityList;
% 
% % 计算每个三角形的中心点和法向量
% tri = triangulation(faces, vertices);
% faceCenters = incenter(tri); % 三角形中心点
% faceNormals = faceNormal(tri); % 三角形法向量
% 
% % 构造六维向量 [x, y, z, nx, ny, nz]
% triangleData = [faceCenters, faceNormals];
% 
% % 参数设置
% numClusters = 50; % 聚类数目（可根据需求调整）
% viewDistance = 30; % 偏移距离
% maxIterations = 100; % K 均值最大迭代次数
% 
% % 初始化 K 均值聚类
% rng(1); % 固定随机数种子
% initialCenters = triangleData(randperm(size(triangleData, 1), numClusters), :);
% 
% % K 均值聚类
% for iter = 1:maxIterations
%     % 修正法向量夹角计算
%     angles = zeros(size(triangleData, 1), numClusters); % 初始化夹角矩阵
%     for j = 1:numClusters
%         % 计算所有点与第 j 个聚类中心之间的法向量夹角
%         clusterNormal = initialCenters(j, 4:6); % 第 j 个聚类中心的法向量
%         angles(:, j) = 1 - dot(triangleData(:, 4:6), repmat(clusterNormal, size(triangleData, 1), 1), 2);
%     end
% 
%     % 计算相似度矩阵
%     distances = pdist2(triangleData(:, 1:3), initialCenters(:, 1:3)); % 欧氏距离
%     similarity = distances + angles; % 综合相似度
% 
%     % 更新聚类分配
%     [~, clusterIndices] = min(similarity, [], 2);
% 
%     % 重新计算聚类中心
%     newCenters = arrayfun(@(i) mean(triangleData(clusterIndices == i, :), 1), 1:numClusters, 'UniformOutput', false);
%     newCenters = cell2mat(newCenters')';
% % 
% %     % 检查收敛
% %     if norm(newCenters - initialCenters, 'fro') < 1e-4
% %         break;
% %     end
% %     initialCenters = newCenters;
% end
% 
% % 偏移聚类中心生成视点
% viewpoints = initialCenters(:, 1:3) + initialCenters(:, 4:6) * viewDistance;
% 
% % 可视化
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'none');
% hold on;
% scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 'r', 'filled');
% title('基于 K 均值聚类生成的视点');
% xlabel('X'); ylabel('Y'); zlabel('Z');
% axis equal;
%  clear; clc;
 % 读取飞机叶片模型
 stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
 model = stlread(stlFile);
 vertices = model.Points;
 faces = model.ConnectivityList;
 
 % 计算每个三角形的中心点和法向量
 tri = triangulation(faces, vertices);
 faceCenters = incenter(tri); % 三角形中心点
 faceNormals = faceNormal(tri); % 三角形法向量
 
 % 构造六维向量 [x, y, z, nx, ny, nz]
 triangleData = [faceCenters, faceNormals];
 
 % 参数设置
 numClusters =150; % 聚类数目（可根据需求调整）
 viewDistance = 30; % 偏移距离
 maxIterations = 100; % K 均值最大迭代次数
 
 % 初始化 K 均值聚类
 rng(1); % 固定随机数种子
 initialCenters = triangleData(randperm(size(triangleData, 1), numClusters), :);
 
 % K 均值聚类
 for iter = 1:maxIterations
     % 修正法向量夹角计算
     angles = zeros(size(triangleData, 1), numClusters); % 初始化夹角矩阵
     for j = 1:numClusters
        % 计算所有点与第 j 个聚类中心之间的法向量夹角
         clusterNormal = initialCenters(j, 4:6); % 第 j 个聚类中心的法向量
        angles(:, j) = 1 - dot(triangleData(:, 4:6), repmat(clusterNormal, size(triangleData, 1), 1), 2);
    end
 
     % 计算相似度矩阵
     distances = pdist2(triangleData(:, 1:3), initialCenters(:, 1:3));  %欧氏距离
     similarity = distances + angles; % 综合相似度
 
    % 更新聚类分配
    [~, clusterIndices] = min(similarity, [], 2);

    % 重新计算聚类中心
     newCenters = arrayfun(@(i) mean(triangleData(clusterIndices == i, :), 1), 1:numClusters, 'UniformOutput', false);
     newCenters = cell2mat(newCenters')';

 end

 % 偏移聚类中心生成视点
viewpoints = initialCenters(:, 1:3) + initialCenters(:, 4:6) * viewDistance;


% 预分配存储每个视点的计算结果
numViewpoints = size(viewpoints, 1);
viewDirs = zeros(numViewpoints, 3);

% 对每个视点计算观察方向
for i = 1:numViewpoints
    pv = viewpoints(i, :);  % 取出第 i 个视点
    viewDirs(i, :) = generateViewDirection(pv, faceCenters, 1, 30, 30.41);
    
end

 % 可视化
figure;
%  trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'none');
 trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k'); % 'FaceColor' 为面片的颜色，'EdgeColor' 为边缘的颜色
 hold on;

% 绘制面中心点（灰色散点，可选显示面中心分布）
scatter3(faceCenters(:,1), faceCenters(:,2), faceCenters(:,3), 5, [0.8 0.8 0.8], 'filled');

% 绘制视点（蓝色大点）
scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 50, 'b', 'filled');

% 使用 quiver3 绘制从每个视点发出的观察方向箭头
% 注意：这里设置缩放因子 scale 用于调整箭头的长度，使显示效果更明显
scale = 5;
quiver3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), ...
    scale*viewDirs(:,1), scale*viewDirs(:,2), scale*viewDirs(:,3), 0, 'r', 'LineWidth', 1, 'MaxHeadSize', 0.5);

xlabel('X');
ylabel('Y');
zlabel('Z');
title('视点及其对应的观察方向');
grid on;
axis equal;
hold off;
% generateViewDirection 函数定义
function view_dir = generateViewDirection(pv, pts, a, fmin, fmax)
% generateViewDirection 计算候选视点的平均观察方向（基于概率势场方法）
%
% 输入参数:
%   pv   - 视点坐标，1x3向量，如 [x, y, z]
%   pts  - 面中心点集合，Nx3矩阵，每一行代表一个中心点 [x, y, z]
%   a    - 吸引力系数
%   fmin - 最小可视距离
%   fmax - 最大可视距离
%
% 输出参数:
%   view_dir - 归一化后的观察方向，1x3向量

    % 计算所有面中心与视点的差值向量 (N x 3)
    diff_vec = pts - pv;    % 每一行为 (pti - pv)
    
    % 计算每个差值向量的欧氏距离 (N x 1)
    dists = sqrt(sum(diff_vec.^2, 2));
    
    % 过滤掉不在 [fmin, fmax] 范围内的面中心点
    valid_idx = (dists > fmin) & (dists < fmax);
    
    % 如果没有满足条件的点，则返回默认方向 [0,0,1]
    if ~any(valid_idx)
        view_dir = [0, 0, 1];
        return;
    end
    
    % 只考虑满足条件的面中心点及其距离
    valid_diff = diff_vec(valid_idx, :);
    valid_dists = dists(valid_idx);
    
    % 根据公式计算每个点的贡献： a * (差值向量除以距离的立方)
    contributions = a * valid_diff ./ (valid_dists.^3);
    
    % 将所有贡献向量相加
    sum_vector = sum(contributions, 1);
    
    % 防止除零问题，若sum_vector为零则返回默认方向
    norm_sum = norm(sum_vector);
    if norm_sum == 0
        view_dir = [0, 0, 1];
    else
        % 归一化后返回最终观察方向
        view_dir = sum_vector / norm_sum;
    end
end


function visibleMask = generateViewField(pv, view_dir, pts, fmin, fmax, fov)
% generateViewField 生成视场域
%
% 输入参数:
%   pv       - 视点坐标，1×3 向量 [x, y, z]
%   view_dir - 视点对应的观察方向，1×3 单位向量
%   pts      - 面中心点集合，M×3 矩阵，每行代表一个面中心点 [x, y, z]
%   fmin     - 最小可视距离
%   fmax     - 最大可视距离
%   fov      - 视场角（以弧度表示），例如 60° ≈ 1.0472 rad
%
% 输出参数:
%   visibleMask - M×1 的逻辑向量，true 表示对应的面中心在视锥体内

    % 计算从视点到所有面中心的向量
    diff_vec = pts - pv;      % M×3
    % 计算每个点的距离
    dists = sqrt(sum(diff_vec.^2, 2));  % M×1
    
    % 筛选处于有效距离内的面中心点
    valid_dist = (dists >= fmin) & (dists <= fmax);
    
    % 归一化从视点到每个点的向量，注意处理距离为 0 的情况
    diff_vec_norm = diff_vec ./ (dists + eps);  % 防止除零
    
    % 计算这些向量与视线之间的夹角余弦值
    cos_angles = sum(diff_vec_norm .* repmat(view_dir, size(diff_vec_norm, 1), 1), 2);
    % 计算夹角（单位：弧度）
    angles = acos(cos_angles);
    
    % 定义判断条件：角度小于等于半个视场角
    valid_angle = (angles <= fov/2);
    
    % 两者同时满足，则该面中心点在视场域内
    visibleMask = valid_dist & valid_angle;
end

