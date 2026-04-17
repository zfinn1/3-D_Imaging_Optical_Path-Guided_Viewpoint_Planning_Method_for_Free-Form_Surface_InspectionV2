% % % 
% % % 
% % % function [newViewpoint, newIntersections] = generateNextViewFieldFromEdge(currentViewpoint, currentIntersections, fixedIndices, delta, d_offset, vertices, faces, threshold)
% % % % updateViewField - 根据当前视场交点更新生成下一个视场域
% % % %
% % % % 输入参数：
% % % %   currentViewpoint    : 当前视点（1×3 向量）
% % % %   currentIntersections: 当前交点矩阵（4×3，每行为一个交点，顺序如 P1, P2, P3, P4）
% % % %   fixedIndices        : 固定不变的交点索引（例如 [3,4]，表示 P3 和 P4保持不变）
% % % %   delta               : 平面内平移向量，用于更新非固定交点（例如 [dx, dy, 0]，单位与模型一致）
% % % %   d_offset            : 新视点相对于新底面中心沿参考平面法向的偏移距离
% % % %   vertices, faces     : STL 模型数据
% % % %   threshold           : 候选筛选阈值（用于 computeRayIntersection）
% % % %
% % % % 输出参数：
% % % %   newViewpoint    : 更新后的新视点（1×3 向量）
% % % %   newIntersections: 更新后的四个交点（4×3 矩阵）
% % % %
% % % % 说明：
% % % %   1. 固定的交点（例如 P3 和 P4）保持不变；
% % % %   2. 对于未固定的交点（例如 P1 和 P2），先将它们沿平面内方向平移 delta，
% % % %      然后利用求交函数 computeRayIntersection( currentViewpoint, predictedPoint, ... )
% % % %      重新计算交点；
% % % %   3. 计算更新后的新底面中心 newCenter，并用前三个交点计算出参考平面法向量 n_unit；
% % % %   4. 新视点 newViewpoint = newCenter + d_offset * n_unit。
% % % 
% % %     % 初始化 newIntersections 为当前交点
% % %     newIntersections = currentIntersections;
% % %     
% % %     % 所有交点索引
% % %     allIndices = 1:size(currentIntersections, 1);
% % %     % 未固定（需要更新）的索引
% % %     freeIndices = setdiff(allIndices, fixedIndices);
% % %     
% % %     % 对每个需要更新的交点进行处理
% % %     for i = freeIndices
% % %         % 对当前交点平移 delta 得到预测点（预测新交点所在位置）
% % %         predictedPoint = currentIntersections(i,:) + delta;
% % %         % 计算从当前视点出发、指向预测点的射线与模型的交点
% % %         [faceIdx, interP, t_val, tri] = computeRayIntersection(currentViewpoint, predictedPoint, vertices, faces, threshold);
% % %         if ~isempty(interP)
% % %             newIntersections(i,:) = interP;
% % %         else
% % %             fprintf('更新交点 %d 求交失败，保留原交点。\n', i);
% % %         end
% % %     end
% % %     
% % %     % 计算新底面中心（即更新后的四个交点的平均值）
% % %     newCenter = mean(newIntersections, 1);
% % %     
% % %     % 利用更新后的交点计算参考平面法向量
% % %     % 这里利用前 3 个交点（假设它们不共线）
% % %     v1 = newIntersections(2,:) - newIntersections(1,:);
% % %     v2 = newIntersections(3,:) - newIntersections(1,:);
% % %     n = cross(v1, v2);
% % %     if norm(n) < 1e-6
% % %         error('更新后的交点退化，无法计算参考平面法向量。');
% % %     end
% % %     n_unit = n / norm(n);
% % %     
% % %     % 新视点：取新底面中心沿参考平面法向偏移 d_offset 得到
% % %     newViewpoint = newCenter + d_offset * n_unit;
% % % end
% % % function [visibleFace, visibleIntersection, best_t, visibleTriangle] = computeRayIntersection(P, Q, vertices, faces, threshold)
% % % % computeRayIntersection - 对单条射线（从 P 到 Q）进行候选筛选、交点求解与正面判断
% % % %
% % % %  输入参数：
% % % %    P         : 视点（1×3 向量）
% % % %    Q         : 射线终点（1×3 向量），例如取自底面某顶点
% % % %    vertices  : STL 模型所有顶点（Mx3）
% % % %    faces     : STL 模型面片索引（Nx3）
% % % %    threshold : 候选筛选阈值
% % % %
% % % %  输出参数：
% % % %    visibleFace       : 选中的面片索引（如果没有找到，则为 -1）
% % % %    visibleIntersection : 交点坐标（1×3 向量）
% % % %    best_t            : 射线参数，即交点到 P 的距离（越小越靠前）
% % % %    visibleTriangle   : 交点所在面片的顶点，3×3 矩阵（若未找到，则为空）
% % % 
% % %     % 初始化输出
% % %     best_t = inf;
% % %     visibleFace = -1;
% % %     visibleIntersection = [];
% % %     visibleTriangle = [];
% % %     
% % %     % 计算射线方向（单位向量）
% % %     v = Q - P;
% % %     v = v / norm(v);
% % %     
% % %     % 预先计算所有面片的中心点（用于候选筛选）
% % %     faceCenters = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) / 3;
% % %     
% % %     % 对于每个面片中心，计算其到射线的最短距离
% % %     vecs = faceCenters - repmat(P, size(faceCenters,1), 1);
% % %     projLengths = dot(vecs, repmat(v, size(vecs,1), 1), 2);
% % %     projPoints = repmat(P, size(faceCenters,1), 1) + projLengths .* repmat(v, size(vecs,1), 1);
% % %     distances = sqrt(sum((faceCenters - projPoints).^2, 2));
% % %     
% % %     % 筛选候选面片
% % %     candidateIdx = find(distances < threshold);
% % %     
% % %     for idx = candidateIdx'
% % %         % 取出候选面片的三个顶点
% % %         a = vertices(faces(idx,1),:);
% % %         b = vertices(faces(idx,2),:);
% % %         c = vertices(faces(idx,3),:);
% % %         
% % %         % 计算候选面片的平面方程系数（假设 compute_plane_coeffs 返回 [A, B, C, D]）
% % %         [A, B, C, D] = compute_plane_coeffs(a, b, c);
% % %         
% % %         % 求射线与该面平面的交点
% % %         intersection_point = line_plane_intersection(P, Q, [A, B, C, D]);
% % %         if isempty(intersection_point)
% % %             continue;  % 如果无交点则跳过
% % %         end
% % %         
% % %         % 判断交点是否在该三角形内部
% % %         if ~isPointInTriangle3D(a, b, c, intersection_point)
% % %             continue;
% % %         end
% % %         
% % %         % 计算候选面片的法向量（确保非退化）
% % %         normal = cross(b - a, c - a);
% % %         if norm(normal) == 0
% % %             continue;
% % %         end
% % %         normal = normal / norm(normal);
% % %         
% % %         % 计算视线方向：从交点指向视点 P
% % %         viewDir = P - intersection_point;
% % %         viewDir = viewDir / norm(viewDir);
% % %         
% % %         % 判断该面是否朝向视点（正面）
% % %         if dot(normal, viewDir) <= 0
% % %             continue;
% % %         end
% % %         
% % %         % 计算当前交点对应的射线参数 t（用距离替代）
% % %         t = norm(intersection_point - P);
% % %         if t < best_t
% % %             best_t = t;
% % %             visibleFace = idx;
% % %             visibleIntersection = intersection_point;
% % %             visibleTriangle = [a; b; c];
% % %         end
% % %     end
% % % end
% % 
% % 
% % function [newViewpoint, newBase, newTriangle] = generateNextViewFieldFromEdge(P_edge1, P_edge2, side, d_offset, vertices, faces)
% % % generateNextViewFieldFromTwoPoints - 根据两个交点生成下一视场域
% % %
% % % 输入：
% % %   P_edge1, P_edge2 : 来自上一次视场域的两个交点（1×3 向量）
% % %   side             : 正方形边长，用于构造候选底面（例如 10 cm）
% % %   d_offset         : 新视点沿新底面法向的偏移距离（例如 10 cm）
% % %   vertices, faces  : STL 模型数据
% % %
% % % 输出：
% % %   newViewpoint : 新视点（1×3 向量）
% % %   newBase      : 新视场域候选底面的四个顶点（4×3 矩阵），即下一视场域交点
% % %   newTriangle  : 与候选底面中心最接近的三角形面片顶点（3×3 矩阵），用来确定新底面平面
% % 
% %     %% 1. 计算两个交点的中点 M
% %     M = (P_edge1 + P_edge2) / 2;
% %     
% %     %% 2. 在水平面内（假设水平为 XY 平面）生成一条水平线通过 M
% %     % 这里选定水平方向为 [1, 0, 0]，垂直方向为 [0, 1, 0]
% %     h_dir = [1, 0, 0]; % 水平方向
% %     v_dir = [0, 1, 0]; % 与 h_dir 垂直的水平方向
% %     
% %     % 构造候选正方形底面（候选底面在水平面上，Z 分量保持为 M 的 Z）
% %     half = side / 2;
% %     Q1 = M + half*(h_dir + v_dir);
% %     Q2 = M + half*(-h_dir + v_dir);
% %     Q3 = M + half*(-h_dir - v_dir);
% %     Q4 = M + half*(h_dir - v_dir);
% %     candidateBase = [Q1; Q2; Q3; Q4];
% %     
% %     %% 3. 计算候选底面中心
% %     centerCandidate = mean(candidateBase, 1);  % 理论上应与 M 相同
% %     
% %     %% 4. 将 centerCandidate 投影到模型上：
% %     % 遍历所有面片，找到重心与 centerCandidate 最近的三角形面片
% %     [newTriangle, triCentroid] = findClosestTriangleCentroid(centerCandidate, vertices, faces);
% %     
% %     %% 5. 计算 newTriangle 的法向量
% %     a = newTriangle(1,:);
% %     b = newTriangle(2,:);
% %     c = newTriangle(3,:);
% %     n_new = cross(b - a, c - a);
% %     if norm(n_new) < 1e-6
% %         error('新参考三角形退化，无法计算法向量。');
% %     end
% %     n_new = n_new / norm(n_new);
% %     
% %     %% 6. 新视点 = triCentroid + d_offset * n_new
% %     newViewpoint = triCentroid + d_offset * n_new;
% %     
% %     %% 7. 将 candidateBase 投影到新底面平面上
% %     % 对每个 candidateBase 的顶点 X，计算投影 X_proj = X - dot(X - triCentroid, n_new)*n_new
% %     newBase = zeros(size(candidateBase));
% %     for i = 1:size(candidateBase,1)
% %         X = candidateBase(i,:);
% %         newBase(i,:) = X - dot(X - triCentroid, n_new)*n_new;
% %     end
% % end
% % 
% % function [closestTriangle, centroid] = findClosestTriangleCentroid(M, vertices, faces)
% % % findClosestTriangleCentroid - 找到所有面片中与点 M 距离最近的三角形面片及其重心
% % %
% % % 输入：
% % %   M       : 待投影点（1×3）
% % %   vertices: STL 模型所有顶点（Mx3）
% % %   faces   : STL 模型面片索引（Nx3）
% % %
% % % 输出：
% % %   closestTriangle: 最近三角形的顶点（3×3 矩阵）
% % %   centroid       : 最近三角形的重心（1×3）
% % 
% %     numFaces = size(faces,1);
% %     minDist = inf;
% %     closestTriangle = [];
% %     centroid = [];
% %     for i = 1:numFaces
% %         tri = vertices(faces(i,:), :);
% %         c = mean(tri, 1);
% %         d = norm(M - c);
% %         if d < minDist
% %             minDist = d;
% %             closestTriangle = tri;
% %             centroid = c;
% %         end
% %     end
% % end
% function [newViewpoint, newBase, candidateTriangle] = generateNextViewFieldFromEdge(P_edge1, P_edge2, side, d_offset, vertices, faces)
% % generateNextViewField - 根据两个交点自动搜索下一视场域
% %
% % 输入：
% %   P_edge1, P_edge2 : 来自上次视场域的两个交点（1×3 向量）
% %   side             : 正方形边长，用于构造候选底面（例如 10 cm）
% %   d_offset         : 新视点相对于候选底面中心沿候选面法向的偏移距离（例如 10 cm）
% %   vertices, faces  : STL 模型数据
% %
% % 输出：
% %   newViewpoint   : 新视点（1×3 向量）
% %   newBase        : 新视场候选底面的四个顶点（4×3 矩阵）
% %   candidateTriangle : 被选中的候选面片顶点（3×3 矩阵）
% %
% % 算法：
% %   1. 计算 P_edge1 与 P_edge2 的中点 M；
% %   2. 遍历模型所有面片，找出其重心与 M 距离最小的面片（candidate face），返回该面片的顶点和重心；
% %   3. 由 candidate face 计算其单位法向量 n_candidate；
% %   4. 在 candidate face 的切平面上构造一个正方形，正方形中心设为 M（或直接用 M），正方形边长为 side。
% %      为在 candidate face 内构造正方形，我们选取一个参考方向 u：
% %         u = globalX投影到候选平面上，即 u = globalX - dot(globalX, n_candidate)*n_candidate；
% %         然后 v = cross(n_candidate, u)。
% %   5. 正方形顶点分别为：
% %         Q1 = M + half*(u+v)
% %         Q2 = M + half*(-u+v)
% %         Q3 = M + half*(-u-v)
% %         Q4 = M + half*(u-v)
% %   6. 新视点取候选面片重心加上 d_offset 沿 n_candidate 的偏移。
% %
% % 注意：这样生成的新底面与模型表面大致平行，能较好地作为下一视场域的底面。
% 
%     %% 1. 计算中点 M
%     M = (P_edge1 + P_edge2) / 2;
%     
%     %% 2. 在模型中搜索与 M 距离最近的面片
%     [candidateTriangle, candidateCentroid] = findClosestTriangleCentroid(M, vertices, faces);
%     
%     %% 3. 计算候选面片的单位法向量
%     a = candidateTriangle(1,:);
%     b = candidateTriangle(2,:);
%     c = candidateTriangle(3,:);
%     n_candidate = cross(b - a, c - a);
%     if norm(n_candidate) < 1e-6
%         error('候选面片退化，无法计算法向量。');
%     end
%     n_candidate = n_candidate / norm(n_candidate);
%     
%     %% 4. 构造候选底面正方形（在候选面平面内）
%     % 以 M 为正方形中心
%     half = side / 2;
%     % 定义参考方向：将全局 X 轴投影到候选平面上
%     globalX = [1, 0, 0];
%     u = globalX - dot(globalX, n_candidate) * n_candidate;
%     if norm(u) < 1e-6
%         % 若全局 X 轴接近候选面法向，则用全局 Y 轴
%         globalY = [0, 1, 0];
%         u = globalY - dot(globalY, n_candidate) * n_candidate;
%     end
%     u = u / norm(u);
%     v = cross(n_candidate, u);
%     v = v / norm(v);
%     
%     % 生成正方形顶点，注意这里正方形位于候选面平面上
%     Q1 = M + half * (u + v);
%     Q2 = M + half * (-u + v);
%     Q3 = M + half * (-u - v);
%     Q4 = M + half * (u - v);
%     newBase = [Q1; Q2; Q3; Q4];
%     
%     %% 5. 生成新视点
%     newViewpoint = candidateCentroid + d_offset * n_candidate;
% end
% 
% %% 辅助函数：在所有面片中找到与点 M 距离最近的三角形及其重心
% function [closestTriangle, centroid] = findClosestTriangleCentroid(M, vertices, faces)
%     numFaces = size(faces, 1);
%     minDist = inf;
%     closestTriangle = [];
%     centroid = [];
%     for i = 1:numFaces
%         tri = vertices(faces(i,:), :);
%         c = mean(tri, 1);
%         d = norm(M - c);
%         if d < minDist
%             minDist = d;
%             closestTriangle = tri;
%             centroid = c;
%         end
%     end
% end
function [newViewpoint, a1,b1,c1, candidateTriangle1] = generateNextViewFieldFromEdge(P_edge1, P_edge2, side, d_offset, vertices, faces)
% generateNextViewFieldFromTwoIntersections - 根据两个交点自动生成下一个视场域
%
% 输入：
%   P_edge1, P_edge2 : 来自上次视场域的两个交点（1×3 向量）
%   side             : 新正方形边长（例如 10 cm）
%   d_offset         : 新视点相对于候选面片重心沿候选面法向的偏移距离（例如 10 cm）
%   vertices, faces  : STL 模型数据
%
% 输出：
%   newViewpoint     : 新视点（1×3 向量）
%   newBase          : 新正方形底面的四个顶点（4×3 矩阵），此正方形位于候选面平面内，
%                      且其上边的中点为两个交点中点 M
%   candidateTriangle: 被选中的候选面片顶点（3×3 矩阵）
%
% 算法：
%   1. 计算两个交点的中点 M = (P_edge1 + P_edge2)/2。
%   2. 在 STL 模型中，搜索距离 M 最近的面片（candidate face），并返回其顶点和重心。
%   3. 利用 candidate face 的三个顶点计算其单位法向量 n_candidate。
%   4. 在 candidate face 所在平面内构造一组正交基 {u, v}。例如：  
%         u = globalX 投影到候选平面上；若 globalX 与 n_candidate 平行，则用 globalY；
%         v = cross(n_candidate, u)。
%   5. 为使 M 成为正方形上边中点，设新正方形边长为 side，令新正方形中心 X = M - (side/2)*v。
%      则正方形顶点为：
%         Q1 = X + 1/2*(u + v)
%         Q2 = X + 1/2*(-u + v)
%         Q3 = X + 1/2*(-u - v)
%         Q4 = X + 1/2*(u - v)
%      注意，上边的中点为 X + (side/2)*v = M。
%   6. 新视点取 candidate face 重心加上 d_offset 沿 n_candidate 的偏移。
%
    
    %% 1. 计算中点 M
    M = (P_edge1 + P_edge2) / 2;
    
    %% 2. 在模型中搜索与 M 距离最近的面片
    [candidateTriangle, candidateCentroid] = findClosestTriangleCentroid(M, vertices, faces);
    
    %% 3. 计算候选面片的单位法向量
    a = candidateTriangle(1,:);
    b = candidateTriangle(2,:);
    c = candidateTriangle(3,:);
    n_candidate = cross(b - a, c - a);
    if norm(n_candidate) < 1e-6
        error('候选面片退化，无法计算法向量。');
    end
    n_candidate = n_candidate / norm(n_candidate);
    
    %% 4. 在候选面平面内构造正交基 {u,v}
    globalX = [0.1, 1,0];
    u = globalX - dot(globalX, n_candidate) * n_candidate;
    if norm(u) < 1e-6
        globalY = [0, 1, 0.1];
        u = globalY - dot(globalY, n_candidate) * n_candidate;
    end
    u = u / norm(u);
    v = cross(n_candidate, u);
    v = v/ norm(v);
    %% 5. 生成正方形底面，使 M 为其上边的中点
    % 若我们希望 M 成为正方形上边（沿 v 方向）的中点，则设正方形中心为:
    X = M - (side/2)*v;
    half = side/2;
    % 正方形边平行于 u 和 v，顶点定义为 (以 X 为中心):
    Q1 = X + half*( u + v );
    Q2 = X + half*(-u + v );
    Q3 = X + half*(-u - v );
    Q4 = X + half*( u - v );
    newBase = [Q1; Q2; Q3; Q4];
    % 检查：上边的中点为 X + (side/2)*v = M
    C=(Q1+Q2+Q3+Q4)/4;
    [candidateTriangle1, candidateCentroid1] = findClosestTriangleCentroid(C, vertices, faces);
    a1 = candidateTriangle1(1,:);
    b1 = candidateTriangle1(2,:);
    c1 = candidateTriangle1(3,:);
    n_candidate1 = cross(b1 - a1, c1 - a1);
    if norm(n_candidate1) < 1e-6
        error('候选面片退化，无法计算法向量。');
    end
    n_candidate1 = n_candidate1 / norm(n_candidate1);
    %% 6. 新视点：沿候选面法向偏移 d_offset, 基于候选面重心
    newViewpoint = candidateCentroid1 + d_offset * n_candidate1;
end

%% 辅助函数：在所有面片中找到与点 M 距离最近的三角形及其重心
function [closestTriangle, centroid] = findClosestTriangleCentroid(M, vertices, faces)
    numFaces = size(faces, 1);
    minDist = inf;
    closestTriangle = [];
    centroid = [];
    for i = 1:numFaces
        tri = vertices(faces(i,:), :);
        c = mean(tri, 1);
        d = norm(M - c);
        if d < minDist
            minDist = d;
            closestTriangle = tri;
            centroid = c;
        end
    end
end

