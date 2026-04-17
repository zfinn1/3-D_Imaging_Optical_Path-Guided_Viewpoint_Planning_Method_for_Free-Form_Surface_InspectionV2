% function intersections = computeAllRayIntersections(P, basePoints, vertices, faces, threshold)
% % computeAllRayIntersections - 对视点 P 到 basePoints 中各点的射线求交
% %
% %  输入参数：
% %    P          : 视点（1×3 向量）
% %    basePoints : 底面顶点矩阵（4×3，每一行对应 P1, P2, P3, P4）
% %    vertices   : STL 模型所有顶点（Mx3）
% %    faces      : STL 模型面片索引（Nx3）
% %    threshold  : 候选筛选阈值（比如 2，根据模型尺寸调整）
% %
% %  输出参数：
% %    intersections : 结构体数组，每个元素包含字段：
% %         .Q                 — 当前射线终点（例如 P1/P2/P3/P4）
% %         .visibleFace       — 选中的面片索引（-1 表示没有找到）
% %         .visibleIntersection – 交点坐标（1×3）
% %         .best_t            — 射线参数（距离 P 的距离）
% 
%     numRays = size(basePoints,1);
%     intersections = repmat(struct('Q', [], 'visibleFace', -1, 'visibleIntersection', [], 'best_t', inf), numRays, 1);
%     
%     for i = 1:numRays
%         Q = basePoints(i,:);
%         [faceIdx, interP, t_val] = computeRayIntersection(P, Q, vertices, faces, threshold);
%         intersections(i).Q = Q;
%         intersections(i).visibleFace = faceIdx;
%         intersections(i).visibleIntersection = interP;
%         intersections(i).best_t = t_val;
%     end
% end
% 
% function [visibleFace, visibleIntersection, best_t] = computeRayIntersection(P, Q, vertices, faces, threshold)
% % computeRayIntersection - 对单条射线（从 P 到 Q）进行候选筛选、交点求解与正面判断
% %
% %  输入参数：
% %    P         : 视点（1×3 向量）
% %    Q         : 射线终点（1×3 向量），例如取自底面某顶点
% %    vertices  : STL 模型所有顶点（Mx3）
% %    faces     : STL 模型面片索引（Nx3）
% %    threshold : 候选筛选阈值
% %
% %  输出参数：
% %    visibleFace       : 选中的面片索引（如果没有找到，则为 -1）
% %    visibleIntersection : 交点坐标（1×3 向量）
% %    best_t            : 射线参数，即交点到 P 的距离（越小越靠前）
% 
%     % 计算射线方向（单位向量）
%     v = (Q - P);
%     v = v / norm(v);
%     
%     % 预先计算所有面片的中心点（用于候选筛选）
%     faceCenters = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) / 3;
%     
%     % 对于每个面片中心，计算其到射线的最短距离
%     vecs = faceCenters - repmat(P, size(faceCenters,1), 1);
%     projLengths = dot(vecs, repmat(v, size(vecs,1), 1), 2);
%     projPoints = repmat(P, size(faceCenters,1), 1) + projLengths .* repmat(v, size(vecs,1), 1);
%     distances = sqrt(sum((faceCenters - projPoints).^2, 2));
%     
%     % 筛选候选面片
%     candidateIdx = find(distances < threshold);
%     
%     best_t = inf;
%     visibleFace = -1;
%     visibleIntersection = [];
%     
%     for idx = candidateIdx'
%         % 取出候选面片的三个顶点
%         a = vertices(faces(idx,1),:);
%         b = vertices(faces(idx,2),:);
%         c = vertices(faces(idx,3),:);
%         
%         % 计算候选面片的平面方程系数（假设函数 compute_plane_coeffs 返回 [A, B, C, D]）
%         [A, B, C, D] = compute_plane_coeffs(a, b, c);
%         
%         % 求射线与面平面的交点
%         intersection_point = line_plane_intersection(P, Q, [A, B, C, D]);
%         if isempty(intersection_point)
%             continue;  % 如果无交点则跳过
%         end
%         
%         % 判断交点是否在该三角形内部
%         if ~isPointInTriangle3D(a, b, c, intersection_point)
%             continue;
%         end
%         
%         % 计算候选面片的法向量（确保非退化）
%         normal = cross(b - a, c - a);
%         if norm(normal) == 0
%             continue;
%         end
%         normal = normal / norm(normal);
%         
%         % 计算视线方向：从交点指向视点 P
%         viewDir = P - intersection_point;
%         viewDir = viewDir / norm(viewDir);
%         
%         % 判断该面是否朝向视点（正面）
%         if dot(normal, viewDir) <= 0
%             continue;
%         end
%         
%         % 计算当前交点对应的射线参数 t（用距离替代）
%         t = norm(intersection_point - P);
%         if t < best_t
%             best_t = t;
%             visibleFace = idx;
%             visibleIntersection = intersection_point;
%         end
%     end
% end
%  
function intersections = computeAllRayIntersections(P, basePoints, vertices, faces, threshold)
% computeAllRayIntersections - 对视点 P 到 basePoints 中各点的射线求交
%
%  输入参数：
%    P          : 视点（1×3 向量）
%    basePoints : 底面顶点矩阵（4×3，每一行对应 P1, P2, P3, P4）
%    vertices   : STL 模型所有顶点（Mx3）
%    faces      : STL 模型面片索引（Nx3）
%    threshold  : 候选筛选阈值（例如 2，根据模型尺寸调整）
%
%  输出参数：
%    intersections : 结构体数组，每个元素包含字段：
%         .Q                 — 当前射线终点（例如 P1/P2/P3/P4）
%         .visibleFace       — 选中的面片索引（-1 表示没有找到）
%         .visibleIntersection – 交点坐标（1×3 向量）
%         .best_t            — 射线参数，即交点到 P 的距离（越小越靠前）
%         .triangle          — 目标面片的顶点坐标，3×3 矩阵

    numRays = size(basePoints,1);
    intersections = repmat(struct('Q', [], 'visibleFace', -1, 'visibleIntersection', [], 'best_t', inf, 'triangle', []), numRays, 1);
    
    for i = 1:numRays
        Q = basePoints(i,:);
        [faceIdx, interP, t_val, tri] = computeRayIntersection(P, Q, vertices, faces, threshold);
        intersections(i).Q = Q;
        intersections(i).visibleFace = faceIdx;
        intersections(i).visibleIntersection = interP;
        intersections(i).best_t = t_val;
        intersections(i).triangle = tri;
    end
end

function [visibleFace, visibleIntersection, best_t, visibleTriangle] = computeRayIntersection(P, Q, vertices, faces, threshold)
% computeRayIntersection - 对单条射线（从 P 到 Q）进行候选筛选、交点求解与正面判断
%
%  输入参数：
%    P         : 视点（1×3 向量）
%    Q         : 射线终点（1×3 向量），例如取自底面某顶点
%    vertices  : STL 模型所有顶点（Mx3）
%    faces     : STL 模型面片索引（Nx3）
%    threshold : 候选筛选阈值
%
%  输出参数：
%    visibleFace       : 选中的面片索引（如果没有找到，则为 -1）
%    visibleIntersection : 交点坐标（1×3 向量）
%    best_t            : 射线参数，即交点到 P 的距离（越小越靠前）
%    visibleTriangle   : 交点所在面片的顶点，3×3 矩阵（若未找到，则为空）

    % 初始化输出
    best_t = inf;
    visibleFace = -1;
    visibleIntersection = [];
    visibleTriangle = [];
    
    % 计算射线方向（单位向量）
    v = Q - P;
    v = v / norm(v);
    
    % 预先计算所有面片的中心点（用于候选筛选）
    faceCenters = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) / 3;
    
    % 对于每个面片中心，计算其到射线的最短距离
    vecs = faceCenters - repmat(P, size(faceCenters,1), 1);
    projLengths = dot(vecs, repmat(v, size(vecs,1), 1), 2);
    projPoints = repmat(P, size(faceCenters,1), 1) + projLengths .* repmat(v, size(vecs,1), 1);
    distances = sqrt(sum((faceCenters - projPoints).^2, 2));
    
    % 筛选候选面片
    candidateIdx = find(distances < threshold);
    
    for idx = candidateIdx'
        % 取出候选面片的三个顶点
        a = vertices(faces(idx,1),:);
        b = vertices(faces(idx,2),:);
        c = vertices(faces(idx,3),:);
        
        % 计算候选面片的平面方程系数（假设 compute_plane_coeffs 返回 [A, B, C, D]）
        [A, B, C, D] = compute_plane_coeffs(a, b, c);
        
        % 求射线与该面平面的交点
        intersection_point = line_plane_intersection(P, Q, [A, B, C, D]);
        if isempty(intersection_point)
            continue;  % 如果无交点则跳过
        end
        
        % 判断交点是否在该三角形内部
        if ~isPointInTriangle3D(a, b, c, intersection_point)
            continue;
        end
        
        % 计算候选面片的法向量（确保非退化）
        normal = cross(b - a, c - a);
        if norm(normal) == 0
            continue;
        end
        normal = normal / norm(normal);
        
        % 计算视线方向：从交点指向视点 P
        viewDir = P - intersection_point;
        viewDir = viewDir / norm(viewDir);
        
        % 判断该面是否朝向视点（正面）
        if dot(normal, viewDir) <= 0
            continue;
        end
        
        % 计算当前交点对应的射线参数 t（用距离替代）
        t = norm(intersection_point - P);
        if t < best_t
            best_t = t;
            visibleFace = idx;
            visibleIntersection = intersection_point;
            visibleTriangle = [a; b; c];
        end
    end
end
