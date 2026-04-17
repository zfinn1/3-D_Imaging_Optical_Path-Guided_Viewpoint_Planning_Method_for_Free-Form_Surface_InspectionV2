function [AllPts_new, P_final, F_final] = autoRotateViewfield2(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation, threshold,minthreshold, direction) 
    % 参数说明：
    %   AllPts: 原始视场顶点（包含近面和远面顶点，共8个点）
    %   stl_file: 模型STL文件路径
    %   epsilon: 用于判断共面或相切的容差
    %   numSamples: 采样点数量
    %   step_size: 旋转角度步长（度）
    %   max_rotation: 最大旋转角度（度）
    %   threshold: 判断相切条件的阈值
    %   direction: 旋转方向标记（如1或其它）
    %
    % 返回值：
    %   AllPts_new: 经过最佳旋转后的视场顶点（8x3矩阵）
    %   P_final: 近面顶点（4x3矩阵）
    %   F_final: 远面顶点（4x3矩阵）
    
    % 读取STL文件，得到模型面和顶点数据
    model = stlread(stl_file);
    faces = model.ConnectivityList;
    vertices = model.Points;
    
    % 记录最佳候选
    best_theta = NaN;
    best_ratioInsideF = -inf;
    best_view = AllPts;
    found_valid = false;
    
    % 设定一个最小阈值，避免无限降低
    orig_threshold = threshold;
    min_threshold = 0.1 * orig_threshold;
    
    % 外层循环：如果未找到合适候选则降低阈值后重新搜索
    while ~found_valid && threshold >= min_threshold
        theta_deg = 0;
        % 内部遍历旋转角度
        while theta_deg <= max_rotation
            [AllPts_rot, P_new, F_new] = applyRotation(AllPts, theta_deg, direction);
            kdtree = buildKDTreeForTriangles(faces, vertices);
            
            % 先检测当前视场是否满足相切条件（isValidTangent要求近面基本相切）
            if isValidTangent(P_new, F_new, faces, vertices, epsilon, numSamples, threshold, kdtree) && (theta_deg > 30)
                % 对近面采样，保证近面内部采样点数很少（要求接近0）
                ptsP = sampleFace(P_new, numSamples);
                insideP = in_polyhedron(faces, vertices, ptsP);
                count_insideP = sum(insideP);
                if count_insideP < 6
                    % 对远面采样，采样点数越多说明相切效果越好
                    ptsF = sampleFace(F_new, numSamples);
                    insideF = in_polyhedron(faces, vertices, ptsF);
                    count_insideF = sum(insideF);
                    fprintf('角度 %d 度: 远面内部采样点数 = %d, 近面采样点数 = %d\n', theta_deg, count_insideF, count_insideP);
                    
                    % 如果是首次满足条件或更优，则更新最佳记录
                    if ~found_valid || (count_insideF > best_ratioInsideF)
                        best_theta = theta_deg;
                        best_ratioInsideF = count_insideF;
                        best_view = AllPts_rot;
                        found_valid = true;
                    end
                else
%                     fprintf('角度 %d 度: 近面内部采样点数 = %d，不符合要求（应接近0），跳过此候选。\n', theta_deg, count_insideP);
                end
            else
                % 如果已有合适候选，则可提前退出内层循环
                if found_valid
                    break;
                end
            end
            theta_deg = theta_deg + step_size;
        end
        
        % 如果当前阈值下未找到合适候选，则降低阈值后重新搜索
        if ~found_valid
            fprintf('当前阈值 %f 下未找到合适候选，降低阈值后重新搜索。\n', threshold);
            threshold = threshold * 0.8;  % 降低阈值，可根据需要调整降低比例
        end
        if threshold<minthreshold
            found_valid=false;
            break;
        end
    end
    
    if ~found_valid
        fprintf('未找到满足相切且近面无穿透的旋转角度，使用原始视场作为输出。\n');
    else
        fprintf('选定最佳旋转角度为 %d 度, 远面采样点数 = %d\n', best_theta, best_ratioInsideF);
    end
    
    % 最终视场：近面为前4个点，远面为后4个点
    AllPts_new = best_view;
    P_final = best_view(1:4, :);
    F_final = best_view(5:8, :);
    
    % 后处理：根据旋转角度范围和旋转方向，对顶点顺序进行调整
    if (theta_deg > 90 && theta_deg < 345)
        if direction == 1
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
    AllPts_new = [P_final; F_final];
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
    axis_vec = (E3 - E2) / norm(E3 - E2);
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
    
    % 利用 inpolyhedron 判断采样点是否在模型内部（返回 true 表示在内部）
    insideP = in_polyhedron(faces, vertices, ptsP);
    insideF = in_polyhedron(faces, vertices, ptsF);
    
   % 计算内部点的比例
    ratioInsideP = sum(insideP) / 225;  % 近面内部点占比
    ratioInsideF = sum(insideF) / 225;  % 远面内部点占比
     
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