function [AllPts_new, P_final, F_final] = autoRotateViewfield(AllPts, stl_file, epsilon, numSamples, coarse_step, max_rotation, threshold, minthreshold, direction)

    model = stlread(stl_file);
    faces = model.ConnectivityList;
    vertices = model.Points;

    % 构建一次 KD 树
    kdtree = buildKDTreeForTriangles(faces, vertices);

    best_theta = NaN;
    best_ratioInsideF = -inf;
    best_view = AllPts;
    found_valid = false;

    orig_threshold = threshold;
    min_threshold = minthreshold;  % ✅ 正确使用传入的 minthreshold 参数

    fine_step = 1; % 细步长

    while ~found_valid && threshold >= min_threshold

        % --------- 粗搜索 ---------
        coarse_angles = 0:coarse_step:max_rotation;
        valid_angles = [];
        valid_ratios = [];

        for theta_deg = coarse_angles
            [AllPts_rot, P_new, F_new] = applyRotation(AllPts, theta_deg, direction);

            ptsP = sampleFace(P_new, numSamples);
            insideP = in_polyhedron(faces, vertices, ptsP);
            count_insideP = sum(insideP);
            if count_insideP >= 10
                continue;  % 近面在内太多，跳过
            end

            if ~isTangentToSurface(P_new, faces, vertices, epsilon, numSamples, kdtree)
                continue;
            end

            ptsF = sampleFace(F_new, numSamples);
            insideF = in_polyhedron(faces, vertices, ptsF);
            count_insideF = sum(insideF);

            fprintf('[粗] 角度 %d 度: 远面 = %d, 近面 = %d\n', theta_deg, count_insideF, count_insideP);

            if (count_insideF / numSamples^2 > threshold) && (count_insideP / numSamples^2 < 1 - threshold)
                valid_angles(end+1) = theta_deg;
                valid_ratios(end+1) = count_insideF;
            end
        end

        if isempty(valid_angles)
            fprintf('阈值 %.3f 下粗筛无解，降低阈值继续。\n', threshold);
            threshold = threshold * 0.8;
            continue;
        end

        % --------- 细搜索 ---------
        [~, best_idx] = max(valid_ratios);
        best_coarse = valid_angles(best_idx);
        fine_angles = max(0, best_coarse - coarse_step):fine_step:min(max_rotation, best_coarse + coarse_step);

        for theta_deg = fine_angles
            [AllPts_rot, P_new, F_new] = applyRotation(AllPts, theta_deg, direction);

            ptsP = sampleFace(P_new, numSamples);
            insideP = in_polyhedron(faces, vertices, ptsP);
            count_insideP = sum(insideP);
            if count_insideP >= 10
                continue;
            end

            if ~isTangentToSurface(P_new, faces, vertices, epsilon, numSamples, kdtree)
                continue;
            end

            ptsF = sampleFace(F_new, numSamples);
            insideF = in_polyhedron(faces, vertices, ptsF);
            count_insideF = sum(insideF);

            fprintf('[细] 角度 %d 度: 远面 = %d, 近面 = %d\n', theta_deg, count_insideF, count_insideP);

            if (count_insideF / numSamples^2 > threshold) && (count_insideP / numSamples^2 < 1 - threshold)
                if count_insideF > best_ratioInsideF
                    best_theta = theta_deg;
                    best_ratioInsideF = count_insideF;
                    best_view = AllPts_rot;
                    found_valid = true;
                end
            end
        end

        if ~found_valid
            fprintf('细搜失败，降低阈值继续。\n');
            threshold = threshold * 0.8;
        end
    end

    if ~found_valid
        fprintf('无满足条件的旋转角度，返回原始视场。\n');
    else
        fprintf('选定最佳角度 %d 度, 远面点数 = %d\n', best_theta, best_ratioInsideF);
    end

    AllPts_new = best_view;
    P_final = best_view(1:4, :);
    F_final = best_view(5:8, :);

    if (best_theta > 90 && best_theta < 345)
        if direction == 1
            P_final = flipud(AllPts_new(5:8, :));
            F_final = flipud(AllPts_new(1:4, :));
        else
            P_final = AllPts_new([6,5,8,7], :);
            F_final = AllPts_new([2,1,4,3], :);
        end
        AllPts_new = [P_final; F_final];
    end
end



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
    E3= (P(4,:) + F(4,:)) / 2;
    E1 = (P(1,:) +F(1,:)) / 2;
    rotationCenter= (E3 + E1) / 2;
    axis_vec = (E1 - E3) / norm(E1 - E3);
  elseif direction==3  
    E3= (P(3,:) + F(3,:)) / 2;
    E2 = (P(2,:) +F(2,:)) / 2;
    rotationCenter= (E3 + E2) / 2;
    axis_vec = (E3 - E2) / norm(E3 - E2);
  else 
    E3= (P(1,:) + F(1,:)) / 2;
    E2 = (P(2,:) +F(2,:)) / 2;
    rotationCenter= (E3 + E2) / 2;
    axis_vec = -(E3 - E2) / norm(E3 - E2);
  end  

    AllPts_new = rotatePoints(AllPts, rotationCenter, axis_vec, theta_deg);
    P_new = AllPts_new(1:4, :);
    F_new = AllPts_new(5:8, :);
    
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
    
 ptsAll = [ptsP; ptsF];
insideAll = in_polyhedron(faces, vertices, ptsAll);
insideP = insideAll(1:size(ptsP,1));
insideF = insideAll(size(ptsP,1)+1:end);
    
% if isempty(gcp('nocreate'))
%     parpool;  % 启动默认并行池
% end
% 
% % 初始化结果数组
% insideP = false(size(ptsP,1),1);
% 
% % parfor 并行判定每个点是否在多面体内
% parfor i = 1:size(ptsP,1)
%     insideP(i) = in_polyhedron(faces, vertices, ptsP(i,:), accelStruct.aabbTree);
% end
% 
% if isempty(gcp('nocreate'))
%     parpool;  % 启动默认并行池
% end
% 
% % 初始化结果数组
% insideF = false(size(ptsP,1),1);
% 
% % parfor 并行判定每个点是否在多面体内
% parfor i = 1:size(ptsP,1)
%     insideF(i) = in_polyhedron(faces, vertices, ptsF(i,:), accelStruct.aabbTree);
% end

   % 计算内部点的比例
    ratioInsideP = sum(insideP) /numSamples^2;  % 近面内部点占比
    ratioInsideF = sum(insideF) /numSamples^2;  % 远面内部点占比
     
    % 设置合理的阈值
%     threshold = 0.3;
    if  (ratioInsideF>threshold) && (ratioInsideP < (1-threshold))
%         fprintf('ratioInsideF=%d 。\n',sum(insideF));
%         fprintf('ratioInsideP=%d 。\n',sum(insideP));
        result = true;
    else
        result = false;
    end
end

%%采样某个面内的点（面由 4 个顶点组成） 采样函数为下一步限制相切做铺垫
function samplePts = sampleFace(facePts, numSamples)
    [u,v] = meshgrid(linspace(0,1,numSamples));
    u = u(:); v = v(:);
    samplePts = (1-u-v).*facePts(1,:) + u.*facePts(2,:) + v.*facePts(4,:);
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
