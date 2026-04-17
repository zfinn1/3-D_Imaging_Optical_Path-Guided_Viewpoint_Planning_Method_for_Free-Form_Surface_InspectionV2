function uniqueIntersections = computeIntersections(F_new, model, tolerance)
% 计算远面平面与模型的交点并去除重复点
    nFar = zeros(1,3);
    dFar = 0;
    % 计算远面平面的法向量和d
    F1 = F_new(1,:);
    F2 = F_new(2,:);
    F3 = F_new(3,:);
    [nFar, dFar] = computePlane(F1, F2, F3);
    
    % 初始化交点数组
    intersections = [];
    vertices = model.Points;
    faces = model.ConnectivityList;
    numFaces = size(faces, 1);
    for i = 1:numFaces
        v1 = vertices(faces(i, 1), :);
        v2 = vertices(faces(i, 2), :);
        v3 = vertices(faces(i, 3), :);
        d1 = dot(nFar, v1) + dFar;
        d2 = dot(nFar, v2) + dFar;
        d3 = dot(nFar, v3) + dFar;
        % 检查每条边上的交点
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
    % 去除重复点
    uniqueIntersections = removeDuplicatePoints(intersections, tolerance);
end

function uniquePoints = removeDuplicatePoints(points, tolerance)
% 去除重复的点
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

function [n, d] = computePlane(P1, P2, P3)
% 计算通过三个点的平面
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = dot(n, P1) * (-1);
end


