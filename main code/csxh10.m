clear; clc;

%% 读取 STL 模型
stl_file = 'G:\22.stl';
model = stlread(stl_file);
faces1 = model.ConnectivityList;
vertices1 = model.Points;

%% 选取一个面生成初始视场区域（例如利用某个面作为参考）
initialface = 2478;
A = vertices1(faces1(initialface,1),:);
B = vertices1(faces1(initialface,2),:);
C = vertices1(faces1(initialface,3),:);
targetFace = [A; B; C];
[n_ref, ~] = computePlane(A, B,C);
n_ref = n_ref / norm(n_ref);
N_ref=n_ref;
%% 生成基础视场域（调用 viewfieldPyrCuboid）
% 假设 viewfieldPyrCuboid 返回：摄像机位置 P，以及视场域底面（P1,P2,P3,P4）和远面（F1,F2,F3,F4）顶点
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);
% 初始视场域的八个顶点（按顺序：底面，然后远面）
AllPts_prev = [P1; P2; P3; P4; F1; F2; F3; F4];
PF0 = AllPts_prev(1:4,:);
FF0 = AllPts_prev(5:8,:);
K = [P1; P2; P3; P4; F1; F2; F3; F4];

%% 循环生成三圈视场域
savedViewsList = {}; % 保存每圈的视场域结果
savedIntersectionsList = {}; % 保存每圈的交点结果

for i = 1:5       
    if i == 1
        [savedViews, savedIntersections] = rotatefullcircle(AllPts_prev, stl_file, n_ref, 13);
    elseif i == 5
        [savedViews, savedIntersections,Q] = rotatefullcircle1(AllPts_prev, stl_file, n_ref, 11);
    else
        [savedViews, savedIntersections,Q] = rotatefullcircle1(AllPts_prev, stl_file, n_ref, 13);
    end
    
    savedViewsList{i} = savedViews;
    savedIntersectionsList{i} = savedIntersections;
    
    % 更新视场域顶点为本轮的第一个视场结果
    AllPts_last = savedViews{1};
    
    % 自动调整视场域
    [AllPts_prev, P_new, ~] = autoRotateViewfield(AllPts_last, stl_file, 0.1, 15, 1, 360, 0.8, 3);
    
    % 计算新的法向量
    [n_ref_new, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
    n_ref_new = n_ref_new / norm(n_ref_new);
    n_ref = n_ref_new; % 更新法向量供下一轮使用
    
end

%% 绘制结果
figure;
clf;
trisurf(faces1, vertices1(:,1), vertices1(:,2), vertices1(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
visualizeViewField(PF0, FF0);

% 绘制每圈生成的视场域
for i = 1:length(savedViewsList)
    savedViews = savedViewsList{i};
    for t = 1:length(savedViews)
        if ~isempty(savedViews{t})
            nonEmptyData = savedViews{t};
            [P_final, F_final] = splitPF(nonEmptyData);
            visualizeViewField(P_final, F_final);
            visualizeNormalVector((P_final + F_final)/2, 'k');
        end
    end
end

title('最终视场域');
xlabel('X'); ylabel('Y'); zlabel('Z');
grid on; axis equal; rotate3d on;
%%视场可视化函数
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
% 
%%法向量可视化函数
function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector);
    center = mean(pts, 1);
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 3, color, 'LineWidth', 2, 'MaxHeadSize', 5);
end


function [P, F] = splitPF(AllPts)
    P = AllPts(1:4, :);
    F = AllPts(5:8, :);
end
  
 %%计算平面法向量的函数
function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量 n（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end
% 
function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    theta_rad = deg2rad(theta_deg); % 角度转换为弧度
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1 - cos(theta_rad))*(K*K);
    rotatedPts = (R * (pts - center)')' + center; 
end

%%旋转函数
function [AllPts_new,P_new, F_new] = applyRotation(AllPts, theta_deg,direction)
    P = AllPts(1:4, :);
    F = AllPts(5:8, :);
  if direction==1 
    E3 = (P(3,:) + F(3,:)) / 2;
    E4 = (P(4,:) + F(4,:)) / 2;
    rotationCenter = (E3 + E4) / 2;
    axis_vec = (E4 - E3) / norm(E4 - E3);
  elseif direction==2
    E3= (P(3,:) + F(3,:)) / 2;
    E1 = (P(1,:) +F(1,:)) / 2;
    rotationCenter= (E3 + E1) / 2;
    axis_vec = (E1 - E3) / norm(E1 - E3);
  else  
    E3= (P(3,:) + F(3,:)) / 2;
    E2 = (P(2,:) +F(2,:)) / 2;
    rotationCenter= (E3 + E2) / 2;
    axis_vec = (E3 - E2) / norm(E3 - E2);
  end  

    AllPts_new = rotatePoints(AllPts, rotationCenter, axis_vec, theta_deg);
    P_new = AllPts_new(1:4, :);
    F_new = AllPts_new(5:8, :);
    
end

%%自动旋转生成视点函数
function [AllPts_new,P_final, F_final] = autoRotateViewfield(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation,threshold,direction)
    theta_deg = 0;
    P_final = AllPts(1:4, :);
    F_final = AllPts(5:8, :);
    
     model = stlread(stl_file);
     faces = model.ConnectivityList;
     vertices = model.Points;
    
    
    while theta_deg <= max_rotation
        [~,P_new, F_new] = applyRotation(AllPts, theta_deg,direction);
%         C_new=(P_new+ F_new)/2;
        kdtree = buildKDTreeForTriangles(faces, vertices);
      if isValidTangent(P_new, F_new, faces, vertices, epsilon, numSamples,threshold,kdtree)&&(theta_deg>30)
         
            P_final = P_new;
            F_final = F_new;
            fprintf('相切检测在旋转 %d 度时触发。\n', theta_deg);
            break;
      end
        
        theta_deg = theta_deg + step_size;
    end
    if (theta_deg > 359)
        
        fprintf('那就是没找到咯。\n');
    end
    AllPts_new=[P_final;F_final];
     if (345> theta_deg) && (theta_deg > 90)
      if direction==1  
P_final(1,:) = AllPts_new(8,:);
P_final(2,:) = AllPts_new(7,:);
P_final(3,:) = AllPts_new(6,:);
P_final(4,:) = AllPts_new(5,:);
F_final(1,:) = AllPts_new(4,:);
F_final(2,:) = AllPts_new(3,:);
F_final(3,:) = AllPts_new(2,:);
F_final(4,:) = AllPts_new(1,:);
      else
P_final(1,:) = AllPts_new(6,:);
P_final(2,:) = AllPts_new(5,:);
P_final(3,:) = AllPts_new(8,:);
P_final(4,:) = AllPts_new(7,:);
F_final(1,:) = AllPts_new(2,:);
F_final(2,:) = AllPts_new(1,:);
F_final(3,:) = AllPts_new(4,:);
F_final(4,:) = AllPts_new(3,:);
      end  


    end
    AllPts_new=[P_final;F_final];
    
end


%%判断相切条件函数
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

%%采样某个面内的点（面由 4 个顶点组成） 采样函数为下一步限制相切做铺垫
function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
end


%限制相切函数
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


%%生成关于三角形面片质心的KDtree
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

%%计算一个点到 STL 模型（所有三角形）的最小距离
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

%%计算点到三角形的距离（参考 Real-Time Collision Detection 算法）
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

