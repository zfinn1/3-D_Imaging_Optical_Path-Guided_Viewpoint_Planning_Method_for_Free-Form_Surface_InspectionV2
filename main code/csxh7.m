% clear; clc;

stl_file = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stl_file);
vertices1 = model.Points;%返回所有顶点的坐标
faces1 = model.ConnectivityList;

%% 2. 选取一个面生成初始视场区域
initialface =2478;
A = vertices1(faces1(initialface,1),:);
B = vertices1(faces1(initialface,2),:);
C = vertices1(faces1(initialface,3),:);
targetFace = [A; B; C];

% 调用视场生成函数（返回摄像机位置、近面和远面顶点）
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);



epsilon =0.1;             % 相切阈值
numSamples = 15;            % 在 P 面内采样的点数（每个方向）
step_size = 1;              % 每次旋转步长 (度)
max_rotation = 360;         % 最大旋转角度 (度)


% 定义视场的八个顶点
AllPts_prev = [P1;P2;P3;P4;F1;F2;F3;F4]; % 远面
PF0=AllPts_prev(1:4,:);
FF0=AllPts_prev(5:8,:); 
%第一次旋转并生成新的视场域
[AllPts_final,P_final, F_final] = autoRotateViewfield(AllPts_prev(), stl_file, epsilon, numSamples, step_size, max_rotation,0.62);
kdtree1 = buildKDTreeForTriangles(faces1, vertices1);
%第二次旋转并生成新的视场域
[AllPts_final1,P_final1, F_final1] = autoRotateViewfield(AllPts_final(), stl_file, epsilon, numSamples, step_size, max_rotation,0.62);
%求出视场域底面与模型的交点
intersections=computeIntersectionsWithKD(P_final1, model, 1e-2, kdtree1, 8);
%根据交点集来计算最远交点与最近交点构成的直线与P3P4夹角并返回最远交点与最近交点
[angle_deg,mf,mn]=computeAngleFromIntersectionsAndEdge(P_final1(3,:), P_final1(4,:), intersections);
fprintf('检测到夹角为 %.2f度 。\n', angle_deg);

[newSquareVertices,basefield] = generateSquareFromProjection(P_final1, mf, 10);
[AllPts_final2,P_final2, F_final2] = autoRotateViewfield(AllPts_final1, stl_file, epsilon, numSamples, step_size, max_rotation,0.3);
%求出视场域底面与模型的交点

% [AllPts_new,PF1, FF1] = applyRotation(AllPts, 190);
% [~,PF2, FF2] = applyRotation(AllPts_new, 190);
%% 可视化部分
figure;
trisurf(faces1, vertices1(:,1), vertices1(:,2), vertices1(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
    
visualizeViewField(P_final, F_final);
visualizeNormalVector((P_final+F_final)/2, 'k');

visualizeViewField(P_final1, F_final1);
visualizeNormalVector((P_final1+F_final1)/2, 'k');
visualizeViewField(F_final2, P_final2);
visualizeNormalVector((P_final2+F_final2)/2, 'k');
visualizeViewField(PF0, FF0);
visualizeNormalVector((PF0+FF0)/2, 'k');

if ~isempty(intersections)
    scatter3(intersections(:,1), intersections(:,2), intersections(:,3), ...
        50, 'r', 'filled');
    title('Intersection Points on Model');
else
    title('No Intersection Points Found');
end
xlabel('X'); ylabel('Y'); zlabel('Z');
grid on; axis equal; rotate3d on;
scatter3(mn(1), mn(2), mn(3), 100, 'g', 'filled');
scatter3(mf(1),mf(2), mf(3), 100, 'g', 'filled');
% scatter3(PCT(1),PCT(2), PCT(3), 100, 'm', 'filled');

hold on; grid on; axis equal;
patch('Vertices', newSquareVertices, 'Faces', [1 2 3 4], 'FaceColor', 'yellow', 'FaceAlpha', 0.5);

plot3(newSquareVertices(:,1), newSquareVertices(:,2), newSquareVertices(:,3), 'ko-', 'LineWidth', 2);
    for i = 1:4
        text(newSquareVertices(i,1), newSquareVertices(i,2), newSquareVertices(i,3), sprintf(' V%d', i), 'FontSize', 12, 'Color', 'b');
    end
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('生成的正方形');
    drawnow;
    
    
% % 初始可视化
% visualizeViewField(PF1, FF1);
% visualizeNormalVector((PF1+FF1)/2, 'k');
% visualizeViewField(PF2, FF2);
% visualizeNormalVector((PF2+FF2)/2, 'k');

% 统一设置
title('视场旋转可视化');
xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
grid on; axis equal; rotate3d on;

%% 辅助函数旋转函数
function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    theta_rad = deg2rad(theta_deg); % 角度转换为弧度
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1 - cos(theta_rad))*(K*K);
    rotatedPts = (R * (pts - center)')' + center; 
end

%% 视场可视化函数
function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
        % 标注点
    for i = 1:4
        text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
        text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
    end
    
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end

%% 法向量可视化函数
function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector);
    center = mean(pts, 1);
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 3, color, 'LineWidth', 2, 'MaxHeadSize', 5);
end

%% 旋转函数（不含可视化）
function [AllPts_new,P_new, F_new] = applyRotation(AllPts, theta_deg)
    P = AllPts(1:4, :);
    F = AllPts(5:8, :);
    
    E3 = (P(3,:) + F(3,:)) / 2;
    E4 = (P(4,:) + F(4,:)) / 2;
    rotationCenter = (E3 + E4) / 2;
    axis_vec = (E4 - E3) / norm(E4 - E3);
    
    AllPts_new = rotatePoints(AllPts, rotationCenter, axis_vec, theta_deg);
    P_new = AllPts_new(1:4, :);
    F_new = AllPts_new(5:8, :);
    
end


function [AllPts_new,P_final, F_final] = autoRotateViewfield(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation,threshold)
    theta_deg = 0;
    P_final = AllPts(1:4, :);
    F_final = AllPts(5:8, :);
    
     model = stlread(stl_file);
     faces = model.ConnectivityList;
     vertices = model.Points;
    
    
    while theta_deg <= max_rotation
        [~,P_new, F_new] = applyRotation(AllPts, theta_deg);
        C_new=(P_new+ F_new)/2;
        kdtree = buildKDTreeForTriangles(faces, vertices);
      if isValidTangent(P_new, F_new, faces, vertices, epsilon, numSamples,threshold,kdtree)&&(theta_deg>30)
         
            P_final = P_new;
            F_final = F_new;
            fprintf('相切检测在旋转 %d 度时触发。\n', theta_deg);
            break;
      end
        
        theta_deg = theta_deg + step_size;
    end
    AllPts_new=[P_final;F_final];
     if (270 > theta_deg) && (theta_deg > 90)
P_final(1,:) = AllPts_new(8,:);
P_final(2,:) = AllPts_new(7,:);
P_final(3,:) = AllPts_new(6,:);
P_final(4,:) = AllPts_new(5,:);
F_final(1,:) = AllPts_new(4,:);
F_final(2,:) = AllPts_new(3,:);
F_final(3,:) = AllPts_new(2,:);
F_final(4,:) = AllPts_new(1,:);
    end
    AllPts_new=[P_final;F_final];
    
end


function result = isValidTangent(P, F, faces, vertices, epsilon, numSamples,threshold,kdtree)
    % 先检查近面是否与模型接触（距离小于阈值）
    resultNear = isTangentToSurface(P, faces, vertices, epsilon, numSamples,kdtree);
    if ~resultNear
        result = false;
        return;
    end
    
    % 对 P 面（近面）和 F 面（远面）各自采样
    ptsP = sampleFace(P, numSamples);
    ptsF = sampleFace(F, numSamples);
    
    % 利用 inpolyhedron 判断采样点是否在模型内部（返回 true 表示在内部）
    insideP = in_polyhedron(faces, vertices, ptsP);
    insideF = in_polyhedron(faces, vertices, ptsF);
    
   % 计算内部点的比例
    ratioInsideP = sum(insideP) / 225;  % 近面内部点占比
    ratioInsideF = sum(insideF) / 225;  % 远面内部点占比
     
    % 设置合理的阈值
%     threshold = 0.3;
    if  (ratioInsideF>threshold) && (ratioInsideP < (1-threshold))
        fprintf('ratioInsideF=%d 。\n',sum(insideF));
        fprintf('ratioInsideP=%d 。\n',sum(insideP));
        result = true;
    else
        result = false;
    end
end

%% 采样某个面内的点（面由 4 个顶点组成）
function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
end






function result = isTangentToSurface(P, faces, vertices, epsilon, numSamples, kdTree)
    result = false;
    
    % 构建 P 面的局部坐标系（以 P(1,:) 为原点，v1 = P(2,:)-P(1,:) ，v2 = P(4,:)-P(1,:)）
    v1 = P(2,:) - P(1,:);
    v2 = P(4,:) - P(1,:);
    
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePoints = P(1,:) + A(:)*v1 + B(:)*v2;
    
    for i = 1:size(samplePoints,1)
        pt = samplePoints(i,:);
        % 使用 KD-Tree 加速的点到模型距离查询
        d = pointToMeshDistance(pt, faces, vertices, kdTree, 10);
        if d < epsilon
            result = true;
            return;
        end
    end
end

function kdTree = buildKDTreeForTriangles(faces, vertices)
    % 计算每个三角形的质心
    numTri = size(faces,1);
    centroids = zeros(numTri, 3);
    for i = 1:numTri
        tri = vertices(faces(i,:), :);
        centroids(i,:) = mean(tri, 1);
    end
    % 使用 MATLAB 内置的 createns 构建 KD-Tree
    kdTree = createns(centroids, 'NSMethod', 'kdtree');
end

%% 计算一个点到 STL 模型（所有三角形）的最小距离
function d = pointToMeshDistance(pt, faces, vertices, kdTree, k)
    % k 为查询最近邻三角形的数量（例如 10）
    if nargin < 5
        k = 10;
    end
    % 使用 knnsearch 查询距离 pt 最近的 k 个三角形（质心）
    [idx, ~] = knnsearch(kdTree, pt, 'K', k);
    d = inf;
    % 对候选的每个三角形计算精确的点-三角形距离
    for i = 1:length(idx)
        tri = vertices(faces(idx(i),:), :);
        d_tri = pointTriangleDistance(pt, tri);
        if d_tri < d
            d = d_tri;
        end
    end
end

%% 计算点到三角形的距离（参考 Real-Time Collision Detection 算法）
function d = pointTriangleDistance(P, tri)
    A = tri(1,:);
    B = tri(2,:);
    C = tri(3,:);
    
    % 边向量
    AB = B - A;
    AC = C - A;
    AP = P - A;
    
    d1 = dot(AB, AP);
    d2 = dot(AC, AP);
    if d1 <= 0 && d2 <= 0
        d = norm(P - A);
        return;
    end
    
    BP = P - B;
    d3 = dot(AB, BP);
    d4 = dot(AC, BP);
    if d3 >= 0 && d4 <= d3
        d = norm(P - B);
        return;
    end
    
    CP = P - C;
    d5 = dot(AB, CP);
    d6 = dot(AC, CP);
    if d6 >= 0 && d5 <= d6
        d = norm(P - C);
        return;
    end
    
    vc = d1 * d4 - d3 * d2;
    if vc <= 0 && d1 >= 0 && d3 <= 0
        v = d1 / (d1 - d3);
        proj = A + v * AB;
        d = norm(P - proj);
        return;
    end
    
    vb = d5 * d2 - d1 * d6;
    if vb <= 0 && d2 >= 0 && d6 <= 0
        w = d2 / (d2 - d6);
        proj = A + w * AC;
        d = norm(P - proj);
        return;
    end
    
    va = d3 * d6 - d5 * d4;
    if va <= 0 && (d4 - d3) >= 0 && (d5 - d6) >= 0
        w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
        proj = B + w * (C - B);
        d = norm(P - proj);
        return;
    end
    
    % 如果点在三角形内部，则计算到平面的距离
    N = cross(AB, AC);
    d = abs(dot(P - A, N)) / norm(N);
end
