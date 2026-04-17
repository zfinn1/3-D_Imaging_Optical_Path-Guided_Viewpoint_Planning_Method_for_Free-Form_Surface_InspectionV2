
stlFile = 'G:\\model1.stl'; % 替换为你的 STL 文件路径
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;

% 可视化
figure; hold on;
% 利用 triangulation 计算每个三角形的中心点和法向量
tri = triangulation(faces, vertices);
faceCenters = incenter(tri);    % N×3，每一行是一个三角形中心坐标
faceNormals = faceNormal(tri);   % N×3，每一行是对应三角形的法向量

% 构造六维数据 [x, y, z, nx, ny, nz]，用于聚类时同时考虑位置和法向量
triangleData = [faceCenters, faceNormals];


numClusters =350;      % 聚类数目（可根据需求调整）
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
    minDist = rayToModelMinDistance(pv, viewDirs(i, :), vertices, faces);
    while minDist < 30
    pv=pv-1*viewDirs(i, :);
    minDist = rayToModelMinDistance(pv, viewDirs(i, :), vertices, faces);
     viewpoints(i, :)=pv;
   end
end

prev_right = [];

% 初始化两个数组：一个存储所有 right，一个存储所有 up
rights = zeros(numViewpoints, 3);
ups = zeros(numViewpoints, 3);

for j = 1:numViewpoints
    forward = viewDirs(j, :);
    [right, up] = generateStableBasis(forward, prev_right);
    
    rights(j, :) = right;
    ups(j, :) = up;
    
    prev_right = right;  % 用于保持朝向平滑
end

% pv = viewpoints(9, :);
% dir = viewDirs(9, :);
boxDepth = 1;        % 视场域长度（可调）
w = 10; h = 10; d = 30;  % 视场底面参数

viewBoxes = cell(numViewpoints, 1);  % 初始化 cell 数组

for i = 1:numViewpoints
    pv = viewpoints(i, :);
    dir = viewDirs(i, :);

    % 计算视场底面矩形
    corners = getViewRectangle(pv, dir, w, h, d,rights(i, :),ups(i, :),faces,vertices);
    
    % 构建长方体视场域（向 view_dir 反方向拉 boxDepth）
    boxVertices = buildViewBox(corners, dir, boxDepth);
    
    % （可选）确保顺时针顺序一致
    boxVertices(1:4,:) = flipud(boxVertices(1:4,:));
    boxVertices(5:8,:) = flipud(boxVertices(5:8,:));
    maybe_new=boxVertices;
  maybe_new=adjustVdthroughN(boxVertices,faces,vertices);
    % 存入 cell 数组
    viewBoxes{i} = maybe_new;

%     scatter3(pv(1), pv(2), pv(3), 80, 'b', 'filled'); % 视点
end

for i = 1:numViewpoints
   maybe_new=viewBoxes{i} ;
        [n, d] = computePlane(maybe_new(1,:), maybe_new(2,:), maybe_new(3,:));
    pv=mean(maybe_new(:,:),1)+n*30;

    scatter3(pv(1), pv(2), pv(3), 80, 'b', 'filled'); % 视点
end


% for i=1:numClusters
%     maybe_new=viewBoxes{i};
%     visualizeViewField(maybe_new(1:4,:), maybe_new(5:8,:));
% end



% 构造可视化的面（patch）
facesBox = [1 2 3 4;    % bottom
            5 6 7 8;    % top
            1 2 6 5;    % side 1
            2 3 7 6;    % side 2
            3 4 8 7;    % side 3
            4 1 5 8];   % side 4


for i=1:numClusters 
    maybe_new=viewBoxes{i};
    visualizeViewField(maybe_new(1:4,:), maybe_new(5:8,:));
end
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceAlpha', 0.3); % STL 模型
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
quiver3(pv(1), pv(2), pv(3), 10*dir(1), 10*dir(2), 10*dir(3), 'r', 'LineWidth', 2); % 朝向




xlabel('X'); ylabel('Y'); zlabel('Z');
title('视点及其观察方向与视场域盒子');
axis equal; grid on;
hold off;


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
function corners = getViewRectangle(pv, view_dir, width, height, distance,right,up,faces,vertices)
% 输入：
% pv         - 视点位置 [1×3]
% view_dir   - 观察方向（单位向量）[1×3]
% width      - 正方形宽度（沿 X 方向）
% height     - 正方形高度（沿 Z 方向）
% distance   - 相机与底面之间的距离

% 输出：
% corners - 4×3 的矩阵，四个角点的坐标（顺时针排列）

% 首先确定相机前方矩形中心位置
center = pv + distance * view_dir;

% 投影平面上构建矩形的四个角点
half_w = width / 2;
half_h = height / 2;

% 四个角点（中心点 ± x ± z）
corners = [ center + half_w*right + half_h*up;
            center - half_w*right + half_h*up;
            center - half_w*right - half_h*up;
            center + half_w*right - half_h*up ];
end
function boxVertices = buildViewBox(corners, view_dir, depth)
% 根据底面矩形和观察方向构造视场域的矩形长方体（六个面）
% 输入：
%   corners   - 4x3 底面点，顺时针（右上，左上，左下，右下）
%   view_dir  - 观察方向（单位向量）
%   depth     - 向前延伸的长度
% 输出：
%   boxVertices - 8x3 矩阵，分别是底面和顶面的8个角点

    view_dir = view_dir / norm(view_dir);
    
    % 顶面 = 底面 + 方向 * depth
    top = corners - depth * view_dir;
    
    % 输出：前4行为底面，后4行为顶面（顺时针顺序）
    boxVertices = [corners; top];
end

function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量 n（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end
function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
        % 标注点
%     for i = 1:4
%         text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%         text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%     end
    
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end


function [right, up] = generateStableBasis(forward, prev_right)
    forward = forward / norm(forward);

    % 默认的 world_up（仅在首次生成时使用）
    if nargin < 2 || isempty(prev_right)
        world_up = [0, 1, 0];
        if abs(dot(forward, world_up)) > 0.99
            world_up = [0, 0, 1];
        end
        right = cross(world_up, forward);
    else
        % 保证 right 尽可能与前一个 right 方向一致（同向优先）
        right = cross(forward, cross(prev_right, forward));
    end

    right = right / norm(right);
    up = cross(forward, right);
    up = up / norm(up);
end

function minDist = rayToModelMinDistance(pv, view_dir, vertices, faces)
    minDist = inf;
    view_dir = view_dir / norm(view_dir);

    % 遍历所有三角形面片
    for i = 1:size(faces, 1)
        triVerts = vertices(faces(i,:), :);
        [isHit, dist] = rayTriangleIntersection(pv, view_dir, triVerts);
        if isHit && dist < minDist
            minDist = dist;
        end
    end
end


function [hit, t] = rayTriangleIntersection(orig, dir, vert)
    % vert: 3x3 (三个顶点)
    eps = 1e-6;
    v0 = vert(1,:)'; v1 = vert(2,:)'; v2 = vert(3,:)';
    edge1 = v1 - v0;
    edge2 = v2 - v0;
    h = cross(dir', edge2);
    a = dot(edge1, h);

    if abs(a) < eps
        hit = false; t = inf;
        return;
    end

    f = 1.0 / a;
    s = orig' - v0;
    u = f * dot(s, h);

    if u < 0.0 || u > 1.0
        hit = false; t = inf;
        return;
    end

    q = cross(s, edge1);
    v = f * dot(dir', q);

    if v < 0.0 || u + v > 1.0
        hit = false; t = inf;
        return;
    end

    % At this stage we can compute t to find out where the intersection point is on the line.
    t = f * dot(edge2, q);
    if t > eps
        hit = true;
    else
        hit = false;
        t = inf;
    end
end
