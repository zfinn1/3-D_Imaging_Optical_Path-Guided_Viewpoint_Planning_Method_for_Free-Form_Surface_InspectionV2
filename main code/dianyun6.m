clear; clc;
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
numClusters = 150; % 聚类数目（可根据需求调整）
viewDistance = 30; % 偏移距离
maxIterations = 100; % K 均值最大迭代次数
fieldSize = 10; % 视场域底面边长
viewToFieldDistance = 30; % 视点到视场域底面的距离

% 计算视场角
fovX = 2 * atan(fieldSize / (2 * viewToFieldDistance));
fovY = fovX; % 假设水平和垂直视场角相同

% 初始化 K 均值聚类
rng(1); % 固定随机数种子
initialCenters = triangleData(randperm(size(triangleData, 1), numClusters), :);
figure;
trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k'); % 'FaceColor' 为面片的颜色，'EdgeColor' 为边缘的颜色
hold on;
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
    distances = pdist2(triangleData(:, 1:3), initialCenters(:, 1:3));  % 欧氏距离
    similarity = distances + angles; % 综合相似度

    % 更新聚类分配
    [~, clusterIndices] = min(similarity, [], 2);

    % 重新计算聚类中心
    newCenters = zeros(numClusters, size(triangleData, 2)); % 预分配内存
    for i = 1:numClusters
        idx = clusterIndices == i;
        if any(idx)
            newCenters(i, :) = mean(triangleData(idx, :), 1);
        else
            % 如果某个聚类为空，保持原来的聚类中心
            newCenters(i, :) = initialCenters(i, :);
        end
    end

    % 检查收敛
    if norm(newCenters - initialCenters, 'fro') < 1e-4
        break;
    end
    initialCenters = newCenters;
end

% 偏移聚类中心生成视点
viewpoints = initialCenters(:, 1:3) + initialCenters(:, 4:6) * viewDistance;
viewpointNormals = initialCenters(:, 4:6);

% 生成视场域并投射到模型表面
numViewpoints = size(viewpoints, 1);
for i = 1:numViewpoints
    normal = viewpointNormals(i, :);
    % 计算视场域边界向量
    u = cross([0, 0, 1], normal);
    if norm(u) == 0
        u = [1, 0, 0];
    end
    u = u / norm(u);
    v = cross(normal, u);
    u = u * tan(fovX / 2);
    v = v * tan(fovY / 2);

    % 生成视场域的边界方向向量
    directions = [
        -u - v;
        u - v;
        u + v;
        -u + v
    ];

    % 光线投射
    intersections = zeros(4, 3);
    for k = 1:4
        direction = directions(k, :);
        [~, intersection] = intersectLineTriangles(viewpoints(i, :), direction, vertices, faces);
        if ~isempty(intersection)
            intersections(k, :) = intersection;
        end
    end

    % 筛选有效的交点
    validIndices = all(intersections ~= 0, 2);
    validIntersections = intersections(validIndices, :);

    % 绘制投射到模型表面的视场域
  
        patch(validIntersections(:, 1), validIntersections(:, 2), validIntersections(:, 3), 'g', 'FaceAlpha', 0.3);
   
end

% 可视化模型、视点和法向量

scatter3(viewpoints(:, 1), viewpoints(:, 2), viewpoints(:, 3), 'r', 'filled');
quiver3(viewpoints(:, 1), viewpoints(:, 2), viewpoints(:, 3), ...
    viewpointNormals(:, 1), viewpointNormals(:, 2), viewpointNormals(:, 3), ...
   'm', 'LineWidth', 1);

title('基于 K 均值聚类生成的视点、法向量及投射到模型表面的视场域');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;

function [hit, intersection] = intersectLineTriangles(origin, direction, vertices, faces)
    numFaces = size(faces, 1);
    hit = false;
    minDistance = Inf;
    intersection = [];

    for i = 1:numFaces
        face = faces(i, :);
        v0 = vertices(face(1), :);
        v1 = vertices(face(2), :);
        v2 = vertices(face(3), :);

        [currentHit, currentIntersection, distance] = intersectLineTriangle(origin, direction, v0, v1, v2);
        if currentHit && distance < minDistance
            hit = true;
            minDistance = distance;
            intersection = currentIntersection;
        end
    end
end

function [hit, intersection, distance] = intersectLineTriangle(origin, direction, v0, v1, v2)
    edge1 = v1 - v0;
    edge2 = v2 - v0;
    h = cross(direction, edge2);
    a = dot(edge1, h);

    if abs(a) < eps
        hit = false;
        intersection = [];
        distance = Inf;
        return;
    end

    f = 1 / a;
    s = origin - v0;
    u = f * dot(s, h);

    if u < 0 || u > 1
        hit = false;
        intersection = [];
        distance = Inf;
        return;
    end

    q = cross(s, edge1);
    v = f * dot(direction, q);

    if v < 0 || u + v > 1
        hit = false;
        intersection = [];
        distance = Inf;
        return;
    end

    t = f * dot(edge2, q);

    if t > eps
        hit = true;
        intersection = origin + t * direction;
        distance = t;
    else
        hit = false;
        intersection = [];
        distance = Inf;
    end
end
    