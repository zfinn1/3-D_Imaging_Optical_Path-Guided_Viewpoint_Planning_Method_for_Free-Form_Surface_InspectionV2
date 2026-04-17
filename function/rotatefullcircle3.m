function [savedViews,savedIntersections]=rotatefullcircle3(AllPts_prev,stl_file,n_ref,numViewsFirstRing)

model = stlread(stl_file);
faces1 = model.ConnectivityList;
vertices1 = model.Points;
kdtree1 = buildKDTreeForTriangles(faces1, vertices1);
% intersections=[];
xy_vertices = vertices1(:, 1:2);

k = boundary(xy_vertices(:,1), xy_vertices(:,2), 0.8);
boundary_xy = xy_vertices(k, :);  % 获取边界点坐标
epsilon = 0.1;          % 相切距离阈值
numSamples = 15;        % 采样点数（每面 numSamples^2 个）
step_size = 1;          % 每次旋转步长（度）
max_rotation = 360;     % 最大旋转角度（度）
% angleThreshold = 30;    % 夹角阈值（度），低于此值需要基准重构


savedViews = cell(numViewsFirstRing+1, 1);      % 保存初始视场和每一步旋转后的视场
savedIntersections = cell(numViewsFirstRing+1, 1);% 用于保存直接旋转模式下的交点（如果有的话）

% 保存初始视场
savedViews{1} = AllPts_prev;
savedIntersections{1} = [];  % 初始时没有交点



currentViewField=AllPts_prev;

for step = 1:numViewsFirstRing
    fprintf('---------------------\nStep %d:\n', step);
    P_new=currentViewField(1:4,:);
    F_new=currentViewField(5:8,:);
    % 求取新视场域底面交点（F_new 与模型的交点）
    Intersections = computeIntersectionsWithKD(P_new, model, 1e-2, kdtree1, 8);
     n_plane=getModelNormalAt(P_new(4,:), model);
%     [n_plane, ~] = computePlane(A, B,C);
    n_plane=n_plane/norm(n_plane);
    intersections = [];

   
   for i = 1:size(Intersections,1)
        pt = Intersections(i,:);
        n=getModelNormalAt(pt, model);
        n=n/norm(n);
        if dot(n,n_plane)>0
           intersections = [intersections; pt];
        end
   end



% 取 intersections 的 XY 投影（忽略 Z 轴）
proj_intersections = intersections(:, 1:2);
 
% 设置阈值：若交点到轮廓线段距离小于 threshold，则认为它落在边界上
threshold = 1e-1;
isOnBoundary = false(size(proj_intersections, 1), 1);

% 对轮廓上每一条边进行检测
for i = 1:length(k)-1
    p1 = boundary_xy(i, :);
    p2 = boundary_xy(i+1, :);
    
    % 计算所有交点到当前边界线段 (p1, p2) 的最小距离
    d = point_to_segment_distance(proj_intersections, p1, p2);
    
    % 如果某个交点到该边的距离小于阈值，则标记该交点
    isOnBoundary = isOnBoundary | (d < threshold);
end

% 过滤掉落在边界上的交点
filtered_intersections = intersections(~isOnBoundary, :);
intersections=filtered_intersections;   
    % 根据角度和交点情况选择旋转模式
    if ~isempty(intersections)
            % 计算底面边 P3P4 与交点生成直线的夹角
        [angle_deg, mf, mn] = computeAngleFromIntersectionsAndEdge(P_new(3,:), P_new(4,:), intersections);
%         scatter3(mf(:,1), mf(:,2), mf(:,3), 100, 'g', 'filled');
%         scatter3(mn(:,1), mn(:,2), mn(:,3), 100, 'g', 'filled');
        fprintf('检测到有交点。\n'); 
        fprintf('检测到夹角为 %.2f°。\n', angle_deg);
        if (angle_deg < 20)
        % 模式2：基准重构后旋转模式
     
        fprintf('采用基准重构后旋转模式。\n');
       % 计算交点处的法向量
intersection_normals = [];
for i = 1:size(intersections,1)
    pt = intersections(i,:);
    n = getModelNormalAt(pt, model);
    n = n / norm(n);
    intersection_normals = [intersection_normals; n];
end

% 计算交点法向量与参考法向量 n_ref 之间的夹角
n_ref_replicated = repmat(n_ref, size(intersection_normals,1), 1);
angles_to_ref = acosd(sum(intersection_normals .* n_ref_replicated, 2)); 
% 取最大夹角作为判断依据
max_angle_to_ref = max(angles_to_ref);
fprintf('交点最大法向量夹角: %.2f°\n', max_angle_to_ref);

% 设置一个阈值，例如 45°
if max_angle_to_ref > 45
    fprintf('法向量偏差较大，调整 autoRotatebasefield 参数。\n');
    threshold_param = 0.3;  % 调整 autoRotatebasefield 的 threshold 参数
else
    threshold_param = 0.7;  % 正常参数
end

% 继续执行基准重构后旋转模式
[newSquareVertices, basefield] = generateSquareFromProjection(P_new, mf, 10);
newCuboid = autoRotatebasefield(basefield, stl_file, 0.1, numSamples, 1, 360, threshold_param);

         P_new=newCuboid(1:4,:);
         F_new=newCuboid(5:8,:);
        currentViewField = newCuboid;

        else
    % 模式1：直接旋转模式（无交点或夹角大于阈值）, 根据当前视场基准进行旋转，调用 autoRotateViewfield
     % autoRotateViewfield 的最后一个参数 threshold 可用于控制旋转停止的条件（此处设为 0.62，示例中不做详细说明）
    [AllPts_new, P_new, F_new] = autoRotateViewfield(currentViewField, stl_file, epsilon, numSamples, step_size, max_rotation, 0.3,1);
     fprintf('夹角过大采用直接旋转模式。\n');
     currentViewField = AllPts_new;
     %保存交点 
     savedIntersections{step+1} = intersections;
        end
    else
        fprintf('无交点采用直接旋转模式。\n');
        % 直接使用 autoRotateViewfield 的结果作为下一步旋转基础
        [AllPts_new, P_new, F_new] = autoRotateViewfield(currentViewField, stl_file, epsilon, numSamples, step_size, max_rotation, 0.62,1);
        currentViewField = AllPts_new;
    end
    %保存每个视场
    savedViews{step+1} = currentViewField;

    if checkOBBIntersection(AllPts_prev,currentViewField,0.11)
    disp('循环视场出现重叠，停止生成下一个视场');
    break;
    else
    disp('未重叠，继续生成');
    end
    
    % 可视化当前步骤
%     visualizeViewField(P_new, F_new);
%     visualizeNormalVector((P_new+F_new)/2, 'k');  
%     if ~isempty(intersections)
%         scatter3(intersections(:,1), intersections(:,2), intersections(:,3), 50, 'r', 'filled');
%     end

   
end
end
%% 辅助函数
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

%%分割函数
function [P, F] = splitPF(AllPts)
    P = AllPts(1:4, :);
    F = AllPts(5:8, :);
end

%%返回与该点距离最近的三角形面片的法向量
function n = getModelNormalAt(X, model)
    % 根据模型中离点 X 最近的面片，返回该面片的法向量（列向量）
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

%%计算平面法向量的函数
function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量 n（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end

%%判断视场域是否重合的函数
function isIntersecting = checkOBBIntersection(VA, VB,threshold)
    % VA: 视场 A 的 8 个顶点 (8x3 matrix)
    % VB: 视场 B 的 8 个顶点 (8x3 matrix)

    % 计算 A 和 B 的局部坐标轴
    X_A = VA(2,:) - VA(1,:);
    Y_A = VA(4,:) - VA(1,:);
    Z_A = VA(5,:) - VA(1,:);
    axes_A = [X_A; Y_A; Z_A];

    X_B = VB(2,:) - VB(1,:);
    Y_B = VB(4,:) - VB(1,:);
    Z_B = VB(5,:) - VB(1,:);
    axes_B = [X_B; Y_B; Z_B];

    % 计算 9 个额外的分离轴（叉积）
    crossAxes = cross(axes_A, axes_B);

    % 所有需要检查的分离轴
    testAxes = [axes_A; axes_B; crossAxes];

    % 过滤掉零向量
    testAxes = testAxes(vecnorm(testAxes, 2, 2) > 1e-6, :); 

    % 遍历所有轴进行检测
    for i = 1:size(testAxes, 1)
        axis = testAxes(i, :);
        if ~overlapOnAxis(axis, VA, VB,threshold)
            isIntersecting = false;
            return;
        end
    end

    isIntersecting = true;
end

%%
function isOverlapping = overlapOnAxis(axis, VA, VB, threshold)
    % 归一化轴
    axis = axis / norm(axis);

    % 使用矩阵乘法计算投影
    projA = VA * axis'; % (8x3) * (3x1) -> (8x1)
    projB = VB * axis'; % (8x3) * (3x1) -> (8x1)

    % 计算投影区间
    minA = min(projA); maxA = max(projA);
    minB = min(projB); maxB = max(projB);

    % 计算重叠长度
    overlap = max(0, min(maxA, maxB) - max(minA, minB));

    % 计算最大投影长度
    maxRange = max(maxA - minA, maxB - minB);

    % 计算重叠比例
    overlapRatio = overlap / maxRange;

    % 只有当重叠比例大于阈值，才认为真正重叠
    isOverlapping = overlapRatio > threshold;
end

function d = point_to_segment_distance(P, A, B)
   N = size(P,1);
    A_rep = repmat(A, N, 1);  % 将 A 重复 N 行
    B_rep = repmat(B, N, 1);  % 将 B 重复 N 行

    AP = P - A_rep;         % N×2 矩阵
    AB = B_rep - A_rep;     % N×2 矩阵，但每行相同
    AB_norm_sq = sum(AB(1,:).^2); % 计算一次 AB 的平方和（标量）
    
    % 计算投影参数 t
    t = sum(AP .* AB, 2) / AB_norm_sq;
    
    % 将 t 限制在 [0, 1] 范围内
    t = max(0, min(1, t));
    
    % 计算投影点坐标
    proj = A_rep + t .* AB;
    
    % 计算 P 到投影点的欧几里得距离
    d = sqrt(sum((P - proj).^2, 2));
end
