function [squareVertices, filteredIntersections, topFace, bottomFace] = generateSquareFromNewFace(F_new, model, targetFace, side_length, half_length)
% generateSquareFromNewFace 计算给定远面所在平面与模型的交点，
% 过滤出落在远面正方形内部的点，通过 PCA 得到主要方向，
% 进而以该线段为边生成新的正方形面。
%
% 输入参数：
%   F_new      - 4×3 矩阵，新远面顶点（F1_new, F2_new, F3_new, F4_new）
%   model      - 模型结构体，包含字段 Points 和 ConnectivityList
%   targetFace - 3×3 矩阵，参考面顶点（例如 [A;B;C]），用于确定模型表面期望法向量
%   side_length- 正方形边长（默认 10）
%   half_length- 线段一半长度（默认 side_length/2，即 5）
%   filterSide - （可选）过滤模式，可设置为 'expected'（默认），表示按照旋转后远面法向与参考面法向比较过滤
%                如果省略，则默认 'expected'
%
% 输出参数：
%   squareVertices - 4×3 矩阵，生成的正方形面顶点
%   filteredIntersections - N×3 矩阵，过滤后的交点
%   topFace      - 上平面的4个顶点
%   bottomFace   - 下平面的4个顶点

    if nargin < 4
        side_length = 10;
    end
    if nargin < 5
        half_length = side_length / 2;
    end
%     if nargin < 6
%         filterSide = 'expected';
%     end

    % 提取远面各顶点（假设顺序为 F1, F2, F3, F4）
    F1_new = F_new(1,:);
    F2_new = F_new(2,:);
    F3_new = F_new(3,:);
    F4_new = F_new(4,:);
    
    % 计算远面平面（选用 F1, F2, F3）
    [n_far, d_far] = computePlane(F1_new, F2_new, F3_new);
    
    % 计算模型与该平面的交点
    intersections = [];
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    for i = 1:numFaces
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        
        d1 = dot(n_far, v1) + d_far;
        d2 = dot(n_far, v2) + d_far;
        d3 = dot(n_far, v3) + d_far;
        
        pts = [];
        if d1 * d2 < 0
            t = -d1 / (d2-d1);
            pt = v1 + t*(v2-v1);
            pts = [pts; pt];
        end
        if d2 * d3 < 0
            t = -d2 / (d3-d2);
            pt = v2 + t*(v3-v2);
            pts = [pts; pt];
        end
        if d3 * d1 < 0
            t = -d3 / (d1-d3);
            pt = v3 + t*(v1-v3);
            pts = [pts; pt];
        end
        
        if ~isempty(pts)
            intersections = [intersections; pts];
        end
    end

    % 去除重复交点（容差1e-6）
    tolDup = 1e-6;
    uniqueIntersections = [];
    for i = 1:size(intersections,1)
        pt = intersections(i,:);
        if isempty(uniqueIntersections)
            uniqueIntersections = pt;
        else
            dists = sqrt(sum((uniqueIntersections - pt).^2,2));
            if all(dists > tolDup)
                uniqueIntersections = [uniqueIntersections; pt];
            end
        end
    end

    % 构造远面正方形的局部坐标系（以 F_new 中 F1 与 F2 为例）
    F_center = (F1_new + F2_new + F3_new + F4_new) / 4;
    u_far = F2_new - F1_new;
    u_far = u_far - dot(u_far, n_far)*n_far;
    u_far = u_far / norm(u_far);
    v_far = cross(n_far, u_far);
    L_far = norm(F2_new - F1_new);
    
    % 利用参考面 targetFace 计算期望法向量 s0
    A_ref = targetFace(1,:);
    B_ref = targetFace(2,:);
    C_ref = targetFace(3,:);
    [s0, ~] = computePlane(A_ref, B_ref, C_ref);
    
    % 过滤交点：
    % 首先计算旋转后远面法向量（作为旋转结果代表），
    % 假设 F_new 的前3个点计算得到：
    [n_rotated, ~] = computePlane(F1_new, F2_new, F3_new);
    
    filteredIntersections = [];
    for i = 1:size(uniqueIntersections,1)
        pt = uniqueIntersections(i,:);
        % 计算局部坐标
        local_coord = [dot(pt - F_center, u_far), dot(pt - F_center, v_far)];
        if abs(local_coord(1)) <= L_far/2 && abs(local_coord(2)) <= L_far/2
           filteredIntersections = [filteredIntersections; pt];
        end
    end

    % 计算过滤后交点的质心
    mu = mean(filteredIntersections, 1);
    
    % 利用 PCA 得到主要方向
    coeff = pca(filteredIntersections);
    dir = coeff(:,1);  % 第一主成分方向（3×1 向量）
    dir2 = coeff(:,2); % 第二主成分方向
    
    % 构造以 mu 为中心、长度为 side_length 的线段（作为正方形的一条边）
    L1 = mu - half_length * dir';
    L2 = mu + half_length * dir';
    
    % 以线段为一条边，利用 dir2 构造正方形的另外两顶点
    V1 = L1;
    V2 = L2;
    V3 = L2 + (side_length * dir2');
    V4 = L1 + (side_length * dir2');
    squareVertices = [V1; V2; V3; V4];
    
    % 构造新正方形面上下平面
    n_plane = cross(dir, dir2);
    n_plane = n_plane / norm(n_plane);  % 归一化
    half_thickness = 0.5;  % 上下平移的距离
    topFace = squareVertices + repmat(half_thickness * n_plane', size(squareVertices,1), 1);
    bottomFace = squareVertices - repmat(half_thickness * n_plane', size(squareVertices,1), 1);
    
    % 可视化部分（可选）
  
    hold on; grid on; axis equal;
    plot3(filteredIntersections(:,1), filteredIntersections(:,2), filteredIntersections(:,3), 'bo', 'MarkerFaceColor', 'b');
    plot3([L1(1) L2(1)], [L1(2) L2(2)], [L1(3) L2(3)], 'r-', 'LineWidth', 2);
    plot3(mu(1), mu(2), mu(3), 'kx', 'MarkerSize', 10, 'LineWidth',2);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('拟合出的线段');
    drawnow;
    

    hold on; grid on; axis equal;
    patch('Vertices', squareVertices, 'Faces', [1 2 3 4], 'FaceColor', 'yellow', 'FaceAlpha', 0.5);
    plot3(squareVertices(:,1), squareVertices(:,2), squareVertices(:,3), 'ko-', 'LineWidth', 2);
    for i = 1:4
        text(squareVertices(i,1), squareVertices(i,2), squareVertices(i,3), sprintf(' V%d', i), 'FontSize', 12, 'Color', 'b');
    end
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('生成的正方形');
    drawnow;
end

%% 辅助函数
function [n, d] = computePlane(P1, P2, P3)
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end

function n = getModelNormalAt(X, model)
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    centroids = zeros(numFaces,3);
    normals = zeros(numFaces,3);
    for i = 1:numFaces
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        centroids(i,:) = (v1 + v2 + v3) / 3;
        n_i = cross(v2 - v1, v3 - v1);
        if norm(n_i) > 0
            normals(i,:) = n_i / norm(n_i);
        else
            normals(i,:) = [0, 0, 0];
        end
    end
    dists = sqrt(sum((centroids - X).^2,2));
    [~, idx] = min(dists);
    n = normals(idx,:)';
end
