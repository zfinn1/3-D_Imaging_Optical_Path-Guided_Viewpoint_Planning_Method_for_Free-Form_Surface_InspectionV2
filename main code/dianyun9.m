
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;
figure;
hold on;
% 利用 triangulation 计算每个三角形的中心点和法向量
tri = triangulation(faces, vertices);
faceCenters = incenter(tri);    % N×3，每一行是一个三角形中心坐标
faceNormals = faceNormal(tri);   % N×3，每一行是对应三角形的法向量

% 构造六维数据 [x, y, z, nx, ny, nz]，用于聚类时同时考虑位置和法向量
triangleData = [faceCenters, faceNormals];


numClusters =150;      % 聚类数目（可根据需求调整）
viewDistance = 30;      % 视点偏移距离（沿法向量方向延伸）
maxIterations = 150;    % K 均值最大迭代次数

rng(1); % 固定随机数种子以保证复现
% 随机选取聚类初始中心
centers = triangleData(randperm(size(triangleData, 1), numClusters), :);

for iter = 1:maxIterations
    % 计算每个样本与每个聚类中心的相似度
    % 相似度由位置欧氏距离和法向量差异构成
    distances = pdist2(triangleData(:,1:3), centers(:,1:3)); % 位置距离
    angles = zeros(size(triangleData, 1), numClusters);        % 法向量差异（余弦距离）
    for j = 1:numClusters
        clusterNormal = centers(j, 4:6); % 第 j 个中心的法向量
        % 余弦差值 (1 - cosθ) 越小，两个法向量越接近
        angles(:, j) = 1 - dot(triangleData(:,4:6), repmat(clusterNormal, size(triangleData,1),1), 2);
    end
    similarity = distances + angles; % 综合相似度（数值越小表示越相似）
    
    % 更新每个面所属的聚类：取相似度最小的中心
    [~, clusterIndices] = min(similarity, [], 2);
    
    % 重新计算各聚类中心
    newCenters = zeros(numClusters, 6);
    for i = 1:numClusters
        idx = (clusterIndices == i);
        if any(idx)
            newCenters(i, :) = mean(triangleData(idx, :), 1);
        else
            newCenters(i, :) = centers(i, :); % 如果该簇没有成员，则保持原值
        end
    end
    centers = newCenters;
end

% 偏移聚类中心生成视点（沿各中心的法向量偏移一定距离）
viewpoints = centers(:, 1:3) + centers(:, 4:6) * viewDistance;


% 此处利用所有面中心计算，每个视点吸引力来自落在一定距离范围内的所有面中心
numViewpoints = size(viewpoints, 1);
viewDirs = zeros(numViewpoints, 3);

% 这里的 fmin 和 fmax 是针对概率势场计算的，需根据具体模型尺度调整
a =1;
pfmin = 30;    % 这里设置一个较大值，因 viewDistance 和模型尺度的关系不同
pfmax = 30.41; % pfmin 与 pfmax 取较窄区间（数值可调），确保只选取靠近某一距离的面中心

for i = 1:numViewpoints
    pv = viewpoints(i, :);
    viewDirs(i, :) = generateViewDirection(pv, faceCenters, a, pfmin, pfmax);
end

%% 6. 所有视点的联合可见性分析
numTriangles = size(faceCenters, 1);
globalVisibleMask = false(numTriangles, 1); % 初始化总可见掩码

% 视场参数
fov = deg2rad(20);
vf_fmin = 20;
vf_fmax = 30.41;

for i = 1:numViewpoints
    pv = viewpoints(i, :);
    dir = viewDirs(i, :);
    % 对每个视点生成可见性掩码
    visibleMask_i = generateViewField(pv, dir, faceCenters, vf_fmin, vf_fmax, fov);
    scatter3(faceCenters(visibleMask_i,1), faceCenters(visibleMask_i,2), faceCenters(visibleMask_i,3), 10, 'r', 'filled');

    % 合并：任意一个视点能看到就算被覆盖
    globalVisibleMask = globalVisibleMask | visibleMask_i;
end

%% 方法1：基于可见三角形数量
coveredCount = sum(globalVisibleMask);
coverageRate_count = coveredCount / numTriangles;
fprintf('【数量法】总覆盖率为：%.2f%%\n', coverageRate_count * 100);

%% 方法2：基于三角形面积加权
areas = zeros(numTriangles,1);
for i = 1:numTriangles
    idx = faces(i, :);
    v1 = vertices(idx(1),:);
    v2 = vertices(idx(2),:);
    v3 = vertices(idx(3),:);
    areas(i) = norm(cross(v2 - v1, v3 - v1)) / 2;
end
totalArea = sum(areas);
coveredArea = sum(areas(globalVisibleMask));
coverageRate_area = coveredArea / totalArea;
fprintf('【面积法】总覆盖率为：%.2f%%\n', coverageRate_area * 100);

%% 5. 可视化结果

% 绘制 STL 网格模型
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k');
alpha 0.5;  % 使模型半透明
% 绘制所有面中心（灰色散点）
scatter3(faceCenters(:,1), faceCenters(:,2), faceCenters(:,3), 5, [0.8 0.8 0.8], 'filled');
% 绘制第一个视点（蓝色大点）
scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 20, 'b', 'filled');
% 绘制第一个视点的观察方向箭头
scale =5;
quiver3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), scale*viewDirs(:, 1) ,scale*viewDirs(:, 2),scale*viewDirs(:, 3) , ...
    0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.8);
% 将落在视场域内的面中心点用红色标记

xlabel('X'); ylabel('Y'); zlabel('Z');
title('STL模型、视点、观察方向及第一个视点的视场域');
grid on;
axis equal;
hold off;

%% ===== 函数部分 =====

% 计算概率势场下的观察方向
function view_dir = generateViewDirection(pv, pts, a, fmin, fmax)
    % 计算所有面中心与视点的差值向量
    diff_vec = pts - pv;
    % 计算每个向量的欧氏距离
    dists = sqrt(sum(diff_vec.^2, 2));
    % 过滤掉不在指定距离区间内的点
    valid_idx = (dists > fmin) & (dists < fmax);
    if ~any(valid_idx)
        view_dir = [0, 0, 1];
        return;
    end
    valid_diff = diff_vec(valid_idx, :);
    valid_dists = dists(valid_idx);
    % 计算贡献，每个贡献为 a * 向量 / (距离^3)
    contributions = a * valid_diff ./ (valid_dists.^3);
    sum_vector = sum(contributions, 1);
    norm_sum = norm(sum_vector);
    if norm_sum == 0
        view_dir = [0, 0, 1];
    else
        view_dir = sum_vector / norm_sum;
    end
end

% 判断面中心是否落在由视点和观察方向构成的视场域内
function visibleMask = generateViewField(pv, view_dir, pts, fmin, fmax, fov)
    % 输入:
    % pv       - 视点坐标 1×3
    % view_dir - 观察方向单位向量 1×3
    % pts      - 待判断的面中心 Nx3
    % fmin,fmax- 距离限制
    % fov      - 视场角（弧度）
    
    diff_vec = pts - pv;
    dists = sqrt(sum(diff_vec.^2, 2));
    valid_dist = (dists >= fmin) &(dists <= fmax);
    
    % 归一化向量
    diff_norm = diff_vec ./ (dists + eps);
    % 计算每个向量与观察方向的夹角
    cos_angles = sum(diff_norm .* repmat(view_dir, size(diff_norm, 1), 1), 2);
    angles = acos(cos_angles);
    valid_angle = angles <= (fov/2);
    
    visibleMask = valid_dist & valid_angle;
end
