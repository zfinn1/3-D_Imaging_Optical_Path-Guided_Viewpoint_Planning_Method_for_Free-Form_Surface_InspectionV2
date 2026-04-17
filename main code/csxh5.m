%% 主程序 - 生成一圈视场域
clear;
close all;
clc;

%% 1. 读取 STL 数据
stlFile = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;

%% 2. 选取一个面片生成初始视场域（此处取第 initialface 个面）
initialface = 3418;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);

% 调用视场生成函数生成初始视场域（正四棱锥/长方体）
% 参数示例：正方形边长10, 厚度0.5, 偏移28
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 28);
Allpts = [P1; P2; P3; P4; F1; F2; F3; F4];
% 初始视场底面用远面（F1~F4）定义，这里取其中心作为参考
Centresquare_prev = mean(Allpts(5:8,:),1);

%% 3. 绘制初始视场域（仅用于参考）
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.2);
hold on; axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
h_near_prev = fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
h_far_prev  = fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);
for i = 1:4
    plot3([Allpts(i,1), Allpts(i+4,1)], [Allpts(i,2), Allpts(i+4,2)], [Allpts(i,3), Allpts(i+4,3)], 'k-', 'LineWidth',2);
end
scatter3(P(1), P(2), P(3), 120, 'r', 'filled');
for i = 1:4
    plot3([P(1), Allpts(i+4,1)], [P(2), Allpts(i+4,2)], [P(3), Allpts(i+4,3)], 'g', 'LineWidth', 2);
end
title('初始视场域');
hold off;

%% 4. 定义旋转参考参数
% 以初始视场域中近面 P3 和 P4对应的边（或远面边也可以）作为旋转参考
E3 = (P3 + F3)/2;
E4 = (P4 + F4)/2;
rotationCenter = (E3 + E4)/2;  % 以边中点为旋转中心
axis_vec = (E4 - E3) / norm(E4 - E3);

%% 5. 循环生成一圈视场域
% 我们定义旋转步长 deltaTheta 和循环区域数 numRegions
deltaTheta = 15;   % 每次旋转15度
numRegions = 360 / deltaTheta;  % 生成一圈（例如24个区域）

% 保存每个区域的视点和视场顶点（8x3矩阵）
viewpoints = zeros(numRegions, 3);
Allpts_all = cell(numRegions, 1);

% 初始区域
viewpoints(1,:) = P;
Allpts_all{1} = Allpts;

% 作为下一次迭代基础，初始区域直接使用 Allpts
current_Allpts = Allpts;
currentViewpoint = P;

% 循环生成后续区域
for k = 2:numRegions
    % 调用 spanviewfield 进行旋转，直到检测到相切条件成立
    % 这里 faceFlag 设为0表示以近面（下表面）作为条件
    Allpts_new = spanviewfield(0.1, 1, 15, h_near_prev, h_far_prev, rotationCenter, axis_vec, current_Allpts, model, 0);
    
    % 保存当前旋转区域
    Allpts_all{k} = Allpts_new;
    
    % 更新当前视点和区域基础
    % 这里以旋转后近面（前4行）的中心作为新视点参考
    currentViewpoint = mean(Allpts_new(1:4,:),1);
    viewpoints(k,:) = currentViewpoint;
    current_Allpts = Allpts_new;
    
    % 更新显示（如果需要，可在每次迭代后绘图）
%     figure(100);
% %     trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
%     hold on;
%     scatter3(viewpoints(k,1), viewpoints(k,2), viewpoints(k,3), 120, 'm', 'filled');
%     title(sprintf('第 %d 个视场域', k));
%     axis equal; grid on;
%     drawnow;
%     hold off;
    
    pause(0.5);  % 暂停观察
end

%% 6. 全局绘制所有视场域的视点
figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
hold on;
scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 120, 'm', 'filled');
for k = 1:numRegions
    text(viewpoints(k,1), viewpoints(k,2), viewpoints(k,3), sprintf(' V%d', k), 'FontSize',10, 'Color','k');
end
axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('一圈生成的视场域视点');
hold off;

%%【辅助函数】
function [newViewpoint, newBase, candidateTriangle] = generateNextViewFieldFromEdge(P_edge1, P_edge2, side, d_offset, vertices, faces)
    % 根据两个交点生成下一视场域，构造正方形底面使得两个交点中点位于正方形上边中点，
    % 新视点取候选面片重心加上 d_offset 沿该面片单位法向偏移。
    %
    % 1. 计算中点 M
    M = (P_edge1 + P_edge2) / 2;
    
    % 2. 在 STL 模型中搜索与 M 连线与面片法向夹角最小的候选面片
    [candidateTriangle, candidateCentroid] = findClosestTriangleCentroidByAngle(M, vertices, faces);
    
    % 3. 计算候选面片单位法向量
    a0 = candidateTriangle(1,:);
    b0 = candidateTriangle(2,:);
    c0 = candidateTriangle(3,:);
    n_candidate = cross(b0 - a0, c0 - a0);
    if norm(n_candidate) < 1e-6
        error('候选面片退化，无法计算法向量。');
    end
    n_candidate = n_candidate / norm(n_candidate);
    
    % 4. 构造候选面平面内正交基 {u,v}
    globalX = [1, 0, 0];
    u = globalX - dot(globalX, n_candidate)*n_candidate;
    if norm(u) < 1e-6
        globalY = [0, 1, 0];
        u = globalY - dot(globalY, n_candidate)*n_candidate;
    end
    u = u / norm(u);
    v = cross(n_candidate, u);
    v = v / norm(v);
    
    % 5. 生成正方形底面，使得 M 为正方形上边中点
    % 令正方形中心 X = M - (side/2)*v，则正方形上边中点 = X + (side/2)*v = M
    X = M - (side/2)*v;
    half_side = side/2;
    Q1 = X + half_side*(u+v);
    Q2 = X + half_side*(-u+v);
    Q3 = X + half_side*(-u-v);
    Q4 = X + half_side*(u-v);
    newBase = [Q1; Q2; Q3; Q4];
    
    % 6. 新视点取候选面片重心加上 d_offset 沿 n_candidate 偏移
    newViewpoint = candidateCentroid + d_offset * n_candidate;
end

function [closestTriangle, centroid] = findClosestTriangleCentroidByAngle(M, vertices, faces)
    numFaces = size(faces, 1);
    minAngle = inf;
    closestTriangle = [];
    centroid = [];
    for ii = 1:numFaces
        tri_temp = vertices(faces(ii,:), :);
        c_temp = mean(tri_temp, 1);
        n_temp = cross(tri_temp(2,:) - tri_temp(1,:), tri_temp(3,:) - tri_temp(1,:));
        if norm(n_temp) < 1e-6, continue; end
        n_temp = n_temp / norm(n_temp);
        V = c_temp - M;
        if norm(V) < 1e-6, continue; end
        V = V / norm(V);
        angle_val = acos(min(1, dot(V, n_temp)));
        if angle_val < minAngle
            minAngle = angle_val;
            closestTriangle = tri_temp;
            centroid = c_temp;
        end
    end
end

function [n, d] = computePlane(P1, P2, P3)
    v1 = P2 - P1; v2 = P3 - P1;
    n = cross(v1, v2); n = n/norm(n);
    d = -dot(n, P1);
end

function n = getModelNormalAt(X, model)
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    centroids = zeros(numFaces,3); normals = zeros(numFaces,3);
    for i = 1:numFaces
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        centroids(i,:) = (v1+v2+v3)/3;
        n_i = cross(v2-v1, v3-v1);
        if norm(n_i) > 0
            normals(i,:) = n_i / norm(n_i);
        else
            normals(i,:) = [0,0,0];
        end
    end
    dists = sqrt(sum((centroids - X).^2,2));
    [~, idx] = min(dists);
    n = normals(idx,:)';
end


