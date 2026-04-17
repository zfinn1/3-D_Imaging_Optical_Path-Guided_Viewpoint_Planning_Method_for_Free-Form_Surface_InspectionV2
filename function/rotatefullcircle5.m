
 function [savedViews, savedIntersections, Q] = rotatefullcircle5(AllPts_prev, stl_file, n_ref, numViewsFirstRing)
% 智能边界检测版 rotatefullcircle1
% - 基于交点凸包面积判定上下边界区
% - 区分无交点、中部区、边界区，选择不同旋转模式

%% 1. 读取模型并构建 KD-Tree
model     = stlread(stl_file);
faces1    = model.ConnectivityList;
vertices1 = model.Points;
kdtree1   = buildKDTreeForTriangles(faces1, vertices1);

%% 2. 参数设置
epsilon         = 0.1;
numSamples      = 15;
step_size       = 1;
max_rotation    = 360;
angleThresh     = 23;   % 中部区：夹角阈值
alpha           = 0.7;  % 边界区：面积比例阈值

%% 3. 输出预分配
savedViews         = cell(numViewsFirstRing+1,1);
savedIntersections = cell(numViewsFirstRing+1,1);

%% 4. 初始视场调整（保留原有逻辑）
isIntersections=[];
isIntersections = computeIntersectionsWithKD(AllPts_prev(1:4,:), model, 1e-2, kdtree1, 8);

previntersectionflag=0;
if ~isempty(isIntersections)
    fprintf('---------------------\n');
    fprintf('检测到初始面有交点。\n');
    
    maxAdjustments = 3;  % 总共最多调整3次（初始调整 + 再调整2次）
    numAdjustments = 0;
    AllPts_current = AllPts_prev; 
    intersectionsCurrent = isIntersections;
    
    while ~isempty(intersectionsCurrent) && (numAdjustments < maxAdjustments)
        % 调整视场
        [AllPts_current,~,~] = adjustpos(AllPts_current, intersectionsCurrent, stl_file, 15, 1, 360);
        numAdjustments = numAdjustments + 1;
        fprintf('调整 %d 次后检测交点...\n', numAdjustments);
        % 重新计算当前视场的交点
        intersectionsCurrent = computeIntersectionsWithKD(AllPts_current(1:4,:), model, 1e-2, kdtree1, 8);
    end
    
    % 如果循环结束后依然有交点，则将初始视场与当前调整结果进行排序合并
    if ~isempty(intersectionsCurrent)
        fprintf('调整 %d 次后仍然检测到交点。\n', numAdjustments);
        previntersectionflag=1;
         [orderedNear, orderedFar] = orderPts(AllPts_prev, AllPts_current);
        AllPts_current = [orderedNear; orderedFar];
        AllPts_prev=AllPts_current;
         [AllPts_tz, P_tz, F_tz] = autoRotateViewfield(AllPts_current, stl_file, 0.2, numSamples,1, max_rotation, 0.85,1);
         disp('我直接旋转了');
         currentViewField =AllPts_tz;
        savedViews{1} = AllPts_current;
        savedViews{2} = AllPts_tz;
    else
        [orderedNear, orderedFar] = orderPts(AllPts_prev, AllPts_current);
        AllPts_current = [orderedNear; orderedFar];
        AllPts_prev=AllPts_current;
        currentViewField = AllPts_current;
        savedViews{1} = AllPts_current;
    end
    
    
else
    currentViewField = AllPts_prev;
    savedViews{1} = AllPts_prev;
    fprintf('---------------------\n');
    fprintf('没有检测到初始面有交点。\n');
end
Q=currentViewField;


%% 5. 计算基线面积 area0
P0 = currentViewField(5:8,:);           % 初始远面顶点
in0 = computeIntersectionsWithKD(P0, model, epsilon, kdtree1, 8);
in0 = filterIntersectionsByZ(in0, P0);
if isempty(in0)
    % 无交点时用远面矩形面积
    vec1 = P0(2,:) - P0(1,:);
    vec2 = P0(4,:) - P0(1,:);
    area0 = norm(cross(vec1, vec2));
else
    area0 = hullAreaOnPlane(in0, P0);
end

%% 6. 主循环：旋转生成视场
for step = 1 : numViewsFirstRing
    P_new = currentViewField(1:4,:);
    F_new = currentViewField(5:8,:);

    % 6.1 计算并过滤交点
    inters = computeIntersectionsWithKD(P_new, model, epsilon, kdtree1, 8);
    inters = filterIntersectionsByZ(inters, P_new);
    savedIntersections{step+1} = inters;

    % 6.2 计算交点凸包面积比例
    if isempty(inters)
        areaRatio = inf;
    else
        area    = hullAreaOnPlane(inters, F_new);
        areaRatio = area / area0;
    end

    % 6.3 根据区域选择旋转模式
    if isempty(inters)
        % 无交点：直接旋转模式
        [viewNext, ~, ~] = autoRotateViewfield(currentViewField, stl_file, 0.2, numSamples, 1, max_rotation, 0.85, 1);
        modeStr = 'Mode1: direct';
    elseif areaRatio < alpha
        % 边界区：平滑过渡模式（直接旋转1）
        [viewNext, ~, ~] = autoRotateViewfield1(currentViewField, stl_file, epsilon, numSamples, step_size, max_rotation, 0.3, 1);
        modeStr = 'Boundary: smooth';
    else
        % 中部区：原有夹角+法向量逻辑
        [angle_deg, mf, mn] = computeAngleFromIntersectionsAndEdge(P_new(3,:), P_new(4,:), inters);
        if angle_deg < angleThresh
            % 模式2：基准重构后旋转
            [sqV, basefield] = generateSquareFromProjection(P_new, mf, 10);
            viewNext = autoRotatebasefield(basefield, stl_file, epsilon, numSamples, 1, max_rotation, 0.7);
            modeStr = 'Mode2: rebuild';
        else
            % 模式1 / 模式2 变体
            [normal_prev, ~] = computePlane(currentViewField(1,:), currentViewField(2,:), currentViewField(3,:));
            normal_prev = normal_prev / norm(normal_prev);
            if dot(normal_prev, n_ref) > 0
                % 同侧：直接旋转模式1
                [viewNext, ~, ~] = autoRotateViewfield1(currentViewField, stl_file, epsilon, numSamples, step_size, max_rotation, 0.3, 1);
                modeStr = 'Mode1 var: same-side';
            else
                % 异侧：基准重构模式2 var
                [sqV, basefield] = generateSquareFromProjection(P_new, mf, 10);
                viewNext = autoRotatebasefield(basefield, stl_file, epsilon, numSamples, 1, max_rotation, 0.9);
                modeStr = 'Mode2 var: opp-side';
            end
        end
    end

    fprintf('Step %d - %s, areaRatio=%.2f\n', step, modeStr, areaRatio);

    % 6.4 保存并更新
    savedViews{step+1}    = viewNext;
    currentViewField       = viewNext;
end

end

%% 辅助函数：计算平面点的凸包面积
function A = hullAreaOnPlane(pts3d, planePts)
    % 若交点数量不足三，则面积为0
    if size(pts3d,1) < 3
        A = 0;
        return;
    end
    origin = planePts(1,:);
    uDir   = planePts(2,:) - origin;
    vDir   = planePts(4,:) - origin;
    U = uDir / norm(uDir);
    V = vDir / norm(vDir);
    % 正确构建 m×2 矩阵
    uv = [(pts3d - origin) * U', (pts3d - origin) * V'];
    k  = convhull(uv(:,1), uv(:,2));
    A  = polyarea(uv(k,1), uv(k,2));
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
    E3= (P(4,:) + F(4,:)) / 2;
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

function [AllPts_new, P_final, F_final] = autoRotateViewfield(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation, threshold, direction)
% 加速版 autoRotateViewfield：不改变逻辑，仅优化性能
%  - STL 读取与 KD-Tree 构建移动到函数开头
%  - 预生成旋转角度向量，避免每次循环计算 sin/cos
%  - 提前构建 KD-Tree，避免内层重复
%  - 在满足条件后提前退出角度遍历

%% 1. 预加载模型和 KD-Tree
model    = stlread(stl_file);
faces    = model.ConnectivityList;
vertices = model.Points;
kdtree   = buildKDTreeForTriangles(faces, vertices);

%% 2. 初始化变量
best_theta       = NaN;
best_ratioInsideF = -inf;
best_view        = AllPts;
found_valid      = false;
orig_threshold   = threshold;
min_threshold    = 0.1 * orig_threshold;

%% 3. 预生成旋转角度及三角函数表
thetas = 0 : step_size : max_rotation;
sinTbl = sind(thetas);
cosTbl = cosd(thetas);

%% 4. 外层循环：根据阈值逐步搜索
while ~found_valid && threshold >= min_threshold
    for idx = 1 : numel(thetas)
        theta = thetas(idx);
        % 4.1 旋转视场
        [AllPts_rot, P_new, F_new] = applyRotation(AllPts, theta, direction);
        
        % 4.2 相切检测（只在 theta > 30 时调用）
        if theta > 30 && isValidTangent(P_new, F_new, faces, vertices, epsilon, numSamples, threshold, kdtree)
            % 近面采样并检测
            ptsP = sampleFace(P_new, numSamples);
            insideP = in_polyhedron(faces, vertices, ptsP);
            count_insideP = sum(insideP);
            if count_insideP < 6
                % 远面采样并检测
                ptsF = sampleFace(F_new, numSamples);
                insideF = in_polyhedron(faces, vertices, ptsF);
                count_insideF = sum(insideF);
                fprintf('角度 %d°: 远面采样=%d, 近面采样=%d\n', theta, count_insideF, count_insideP);
                % 更新最佳记录
                if ~found_valid || count_insideF > best_ratioInsideF
                    best_theta = theta;
                    best_ratioInsideF = count_insideF;
                    best_view = AllPts_rot;
                    found_valid = true;
                end
                % 找到有效后，退出角度循环
                break;
            end
        end
    end
    % 4.3 若未找到有效视场，降低阈值并重新搜索
    if ~found_valid
        threshold = threshold * 0.9;
        fprintf('阈值降低至 %.4f，继续搜索。\n', threshold);
    end
    if threshold < 0.2
        break;
    end
end

%% 5. 输出结果
if ~found_valid
    fprintf('未找到满足条件的旋转角度，使用原视场。\n');
else
    fprintf('最佳旋转角度: %d°，远面采样点=%d\n', best_theta, best_ratioInsideF);
end
AllPts_new = best_view;
P_final = best_view(1:4, :);
F_final = best_view(5:8, :);

%% 6. 后处理：调整顶点顺序（保持原逻辑）
theta_last = best_theta;
if theta_last > 90 && theta_last < 345
    if direction == 1
        P_final = AllPts_new([8,7,6,5], :);
        F_final = AllPts_new([4,3,2,1], :);
    else
        P_final = AllPts_new([6,5,8,7], :);
        F_final = AllPts_new([2,1,4,3], :);
    end
end

AllPts_new = [P_final; F_final];
end


function [AllPts_new, P_final, F_final] = autoRotateViewfield1(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation, threshold, direction)
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
                if count_insideP < 10
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
                    fprintf('角度 %d 度: 近面内部采样点数 = %d，不符合要求（应接近0），跳过此候选。\n', theta_deg, count_insideP);
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
            threshold = threshold * 0.9;  % 降低阈值，可根据需要调整降低比例
        end
        if threshold<0.2
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

function filteredIntersections = filterIntersectionsByZ(intersections, P)
    % filterIntersectionsByZ 过滤掉很接近 P(1,:) - P(2,:) 直线的交点
    %
    % 输入：
    %   intersections: N x 3 的交点集合，每一行一个交点
    %   P: 4 x 3 的点集，取 P(1,:) 和 P(2,:) 定义参考直线
    %
    % 输出：
    %   filteredIntersections: 过滤后的交点集合（不包含那些离参考直线太近的交点）
    disp('我进入过滤啦！');
    % 设定容差（可以根据模型尺度进行调整）
    tol = 1e-3;  % 示例容差值
    
    % 参考直线的两个端点
    P1 = P(1,:);
    P2 = P(2,:);
    lineVec = P2 - P1;
    lineNorm = norm(lineVec);
    
    % 如果线段长度太小，直接返回原交点
    if lineNorm < eps
        filteredIntersections = intersections;
        return;
    end
    
    % 初始化结果
    filteredIntersections = [];
    
    % 对每个交点计算其到参考直线的距离
    for i = 1:size(intersections,1)
        pt = intersections(i,:);
        % 利用向量叉乘计算点到直线的距离：
        % dist = norm(cross(pt - P1, lineVec)) / norm(lineVec)
        dist = norm(cross(pt - P1, lineVec)) / lineNorm;
        % 如果距离大于容差，则保留该交点
        if dist > tol
            filteredIntersections = [filteredIntersections; pt];
        end
    end
end