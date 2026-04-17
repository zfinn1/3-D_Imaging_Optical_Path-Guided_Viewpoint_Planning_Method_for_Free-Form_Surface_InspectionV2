function uniqueFilteredIntersections = computeIntersectionsWithKD(F_new, model, tolerance, kdTree, candidateRange)
    % 计算远面平面的法向量和截距
    F1 = F_new(1,:);
    F2 = F_new(2,:);
    F3 = F_new(3,:);
    F4 = F_new(4,:);
    [nFar, dFar] = computePlane(F1, F2, F3);
    
    % 读取模型数据
    vertices = model.Points;
    faces = model.ConnectivityList;
    
    % 计算远面中心（用于查询 KD‐Tree）
    farCenter = mean(F_new, 1);
    
    % 利用 KD‐Tree 查询候选三角形（质心距离远面中心小于 candidateRange 的）
    % 此处我们假设 kdTree 是基于 STL 模型三角形质心构建的
    candidateIndicesCell = rangesearch(kdTree, farCenter, candidateRange);
    candidateIndices = candidateIndicesCell{1}; % 得到候选索引
    
    % 初始化交点数组
    intersections = [];
    
    % 只遍历候选三角形
    for idx = candidateIndices(:)'
        v1 = vertices(faces(idx, 1), :);
        v2 = vertices(faces(idx, 2), :);
        v3 = vertices(faces(idx, 3), :);
        d1 = dot(nFar, v1) + dFar;
        d2 = dot(nFar, v2) + dFar;
        d3 = dot(nFar, v3) + dFar;
        % 对每条边检测交点（如果该边两端符号不同）
        if d1 * d2 < 0
            t = -d1 / (d2 - d1);
            pt = v1 + t * (v2 - v1);
            intersections = [intersections; pt];
        end
        if d2 * d3 < 0
            t = -d2 / (d3 - d2);
            pt = v2 + t * (v3 - v2);
            intersections = [intersections; pt];
        end
        if d3 * d1 < 0
            t = -d3 / (d1 - d3);
            pt = v3 + t * (v1 - v3);
            intersections = [intersections; pt];
        end
    end
   
     % 去除重复的交点
    uniqueIntersections = removeDuplicatePoints(intersections, tolerance);
    
    % 构造远面长方形的局部坐标系
    % 以 F1_new 为原点，利用 F1_new-F2_new 构造 u_far 方向
    F_center = (F1 + F2+ F3 + F4) / 4;
    u_far = F2 - F1;
    % 去除 u_far 中沿法向量的分量
    u_far = u_far - dot(u_far, nFar) * nFar;
    u_far = u_far / norm(u_far);
    v_far = cross(nFar, u_far);
    % 假设远面是正方形，边长取 F1_new 与 F2_new 的距离
    L_far = norm(F2 - F1);
    
    % 过滤交点：只保留落在远面长方形内部的交点
    filteredIntersections = [];
    for i = 1:size(uniqueIntersections, 1)
        pt = uniqueIntersections(i,:);
        % 将交点投影到局部坐标系中
        local_coord = [dot(pt - F_center, u_far), dot(pt - F_center, v_far)];
        if abs(local_coord(1)) <= L_far/2 && abs(local_coord(2)) <= L_far/2
            filteredIntersections = [filteredIntersections; pt];
        end
    end
    
    uniqueFilteredIntersections = filteredIntersections;
    
end

%% 计算通过三个点的平面（返回法向量和截距）
function [n, d] = computePlane(P1, P2, P3)
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end

%% 去除重复点函数
function uniquePoints = removeDuplicatePoints(points, tolerance)
    if isempty(points)
        uniquePoints = [];
        return;
    end
    uniquePoints = points(1,:);
    for i = 2:size(points, 1)
        pt = points(i, :);
        distances = sqrt(sum((uniquePoints - pt) .^ 2, 2));
        if all(distances > tolerance)
            uniquePoints = [uniquePoints; pt];
        end
    end
end

%% 计算三角形质心
function centroids = computeCentroids(faces, vertices)
    centroids = (vertices(faces(:,1), :) + vertices(faces(:,2), :) + vertices(faces(:,3), :)) / 3;
end
