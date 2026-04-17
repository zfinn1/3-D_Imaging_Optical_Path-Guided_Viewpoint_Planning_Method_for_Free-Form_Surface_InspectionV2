function [savedViews,savedIntersections] = rotatefullcircle8(AllPts_prev, stl_file, n_ref, numViewsFirstRing,kdtree)

model = stlread(stl_file);
faces1 = model.ConnectivityList;
vertices1 = model.Points;
kdtree1 = buildKDTreeForTriangles(faces1, vertices1);

epsilon = 0.1;
numSamples = 15;
step_size = 1;
max_rotation = 360;

savedViews = cell(numViewsFirstRing + 1, 1);
savedIntersections = cell(numViewsFirstRing + 1, 1);
savedIntersections{1} = [];

isIntersections = computeIntersectionsWithKD(AllPts_prev(1:4,:), model, 1e-2, kdtree1, 8);
if ~isempty(isIntersections)
    fprintf('---------------------\n');
    fprintf('检测到初始面有交点。\n');
    
    maxAdjustments = 3;
    numAdjustments = 0;
    AllPts_current = AllPts_prev;
    intersectionsCurrent = isIntersections;

    while ~isempty(intersectionsCurrent) && (numAdjustments < maxAdjustments)
        [AllPts_current, ~, ~] = adjustpos(AllPts_current, intersectionsCurrent, stl_file, 15, 1, 360);
        numAdjustments = numAdjustments + 1;
        fprintf('调整 %d 次后检测交点...\n', numAdjustments);
        intersectionsCurrent = computeIntersectionsWithKD(AllPts_current(1:4,:), model, 1e-2, kdtree1, 8);
    end
    [orderedNear,orderedFar]=orderPts(AllPts_prev,AllPts_current);
    AllPts_prev= [orderedNear;orderedFar];
end
% 检测初始面是否有交点
isIntersections = computeIntersectionsWithKD(AllPts_prev(1:4,:), model, 1e-2, kdtree1, 8);

 [AllPts_final, P_final, F_final, intersections_final] = ...
    autoAdjustViewField(AllPts_prev, isIntersections, kdtree, stl_file, ...
                         3, 1e-2, 8, 0.8);
[orderedNear,orderedFar]=orderPts(AllPts_prev,AllPts_final);
 AllPts_final= [orderedNear;orderedFar];
currentViewField=AllPts_final;
AllPts_prev=AllPts_final;
savedViews{1} =AllPts_prev;


for step = 1:numViewsFirstRing
    fprintf('---------------------\nStep %d:\n', step);
    P_new = currentViewField(1:4,:);
    F_new = currentViewField(5:8,:);
    
    Intersections = computeIntersectionsWithKD(P_new, model, 1e-2, kdtree1, 8);
    n_plane = getModelNormalAt(P_new(4,:), model);
    n_plane = n_plane / norm(n_plane);

    intersections = [];
    for i = 1:size(Intersections,1)
        pt = Intersections(i,:);
        n = getModelNormalAt(pt, model);
        n = n / norm(n);
        if dot(n, n_plane) > 0
            intersections = [intersections; pt];
        end
    end

    % ========== 主逻辑分支：是否存在交点 ==========
    if ~isempty(intersections)
%         intersections = filterIntersectionsByZ(intersections, P_new);
         [AllPts_final, P_final, F_final, intersections_final] = ...
    autoAdjustViewField(currentViewField, intersections, kdtree, stl_file, ...
                         5, 1e-2, 8, 0.8);
[orderedNear,orderedFar]=orderPts(currentViewField,AllPts_final);
 currentViewField= [orderedNear;orderedFar];
  intersections = computeIntersectionsWithKD(currentViewField(1:4,:), model, 1e-2, kdtree1, 8);
  intersections = filterIntersectionsByZ(intersections, currentViewField(1:4,:));
  disp(intersections);
        % 判断 Z 过滤后是否仍有交点
        if isempty(intersections)
            fprintf('交点过滤后为空，采用直接旋转模式。\n');
            [AllPts_new, P_new, F_new] = autoRotateViewfield(currentViewField, stl_file, 0.2, numSamples, step_size, max_rotation, 0.85, 1);
            currentViewField = AllPts_new;
        else
            fprintf('检测到有交点。\n');

            % 计算与底面边缘的夹角和相关投影矩阵
            [angle_deg, mf, mn] = computeAngleFromIntersectionsAndEdge(P_new(3,:), P_new(4,:), intersections);
            fprintf('检测到夹角为 %.2f°。\n', angle_deg);
            disp(mf);
            disp(mn);
            if angle_deg < 23
                fprintf('采用基准重构后旋转模式。\n');
                intersection_normals = [];
                for i = 1:size(intersections,1)
                    pt = intersections(i,:);
                    n = getModelNormalAt(pt, model);
                    intersection_normals = [intersection_normals; n / norm(n)];
                end

                angles_to_ref = acosd(sum(intersection_normals .* repmat(n_ref, size(intersection_normals,1), 1), 2));
                max_angle_to_ref = max(angles_to_ref);
                fprintf('交点最大法向量夹角: %.2f°\n', max_angle_to_ref);

                threshold_param = (max_angle_to_ref > 45) * 0.4 + (max_angle_to_ref <= 45) * 0.9;

                [newSquareVertices, basefield] = generateSquareFromProjection(P_new, mf, 10);
                newCuboid = autoRotatebasefield(basefield, stl_file, 0.1, numSamples, 1, max_rotation, threshold_param);
                if newCuboid==basefield
                            rotationCenter = (basefield(1,:) + basefield(2,:)+basefield(5,:)+basefield(6,:)) /4;
                            axis_vec = (basefield(1,:) - basefield(2,:)) / norm(basefield(1,:) - basefield(2,:));
                            rotatedPts = rotatePoints(basefield, rotationCenter, axis_vec, 30);
                            isIntersections = computeIntersectionsWithKD(rotatedPts(1:4,:), model, 1e-2, kdtree, 8);
                            [AllPts_final, P_final, F_final, intersections_final] = ...
                                autoAdjustViewField(rotatedPts, isIntersections, kdtree, stl_file, ...
                                3, 1e-2, 8, 0.8);
                            [orderedNear,orderedFar]=orderPts(rotatedPts,AllPts_final);
                          
                            newCuboid=[orderedNear,orderedFar];
                end
                currentViewField = newCuboid;
            else
                [normal_prev, ~] = computePlane(currentViewField(1,:), currentViewField(2,:), currentViewField(3,:));
                normal_prev = normal_prev / norm(normal_prev);
                if normal_prev(3) * n_ref(3) < 0
                    n_ref = -n_ref;
                end
                if dot(normal_prev, n_ref) > 0
                    fprintf('夹角过大且法向量在同侧，采用直接旋转模式。\n');
                    [AllPts_new, P_new, F_new] = autoRotateViewfield1(currentViewField, stl_file, 0.2, numSamples, step_size, max_rotation, 0.3, 1);
                    currentViewField = AllPts_new;
                    savedIntersections{step + 1} = intersections;
                else
                    fprintf('夹角过大且法向量在不同侧，采用基准重构后旋转模式。\n');
                    [newSquareVertices, basefield] = generateSquareFromProjection(P_new, mf, 10);
                    newCuboid = autoRotatebasefield(basefield, stl_file, 0.1, numSamples, 1, max_rotation, 0.9);
                           if newCuboid==basefield
                            rotationCenter = (basefield(1,:) + basefield(2,:)+basefield(5,:)+basefield(6,:)) /4;
                            axis_vec = (basefield(1,:) - basefield(2,:)) / norm(basefield(1,:) - basefield(2,:));
                            rotatedPts = rotatePoints(basefield, rotationCenter, axis_vec, 30);
                            isIntersections = computeIntersectionsWithKD(rotatedPts(1:4,:), model, 1e-2, kdtree, 8);
                            [AllPts_final, P_final, F_final, intersections_final] = ...
                                autoAdjustViewField(rotatedPts, isIntersections, kdtree, stl_file, ...
                                3, 1e-2, 8, 0.8);
                            [orderedNear,orderedFar]=orderPts(rotatedPts,AllPts_final);
                          
                            newCuboid=[orderedNear,orderedFar];
                end
                    currentViewField = newCuboid;
                end
            end
        end
    else
        fprintf('无交点，采用直接旋转模式。\n');
        [AllPts_new, P_new, F_new] = autoRotateViewfield(currentViewField, stl_file, 0.2, numSamples, 1, max_rotation, 0.85, 1);
        currentViewField = AllPts_new;
    end

    % 视场保存
   currentViewField=adjustVdthroughN(currentViewField,faces1,vertices1);
        savedViews{step + 1} = currentViewField;

prevSavedIdx = find(~cellfun(@isempty, savedViews), 1, 'last');

% 如果当前与上一个保存的视场重合，则终止
if checkOBBIntersection(savedViews{prevSavedIdx-1}, currentViewField, 0.5)

    disp('转360度了，不行不行');
    break;
else
    disp('正常');
end

    % 判断是否重叠
    if checkOBBIntersection(AllPts_prev, currentViewField, 0.1)
        if step == 1
            savedViews{1} = currentViewField;
            disp('循环视场第一步就出现重叠，动态调整');
        else
            disp('循环视场出现重叠，停止生成下一个视场');
            break;
        end
    else
        disp('未重叠，继续生成');
    end
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
                if count_insideP <10
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
    tol = 2;  % 容差值
    
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



