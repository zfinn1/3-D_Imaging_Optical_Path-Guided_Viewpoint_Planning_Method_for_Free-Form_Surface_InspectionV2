% AllPts=[20.2011954770721,85.6395608881246,35.9015544809194;18.0486456525870,75.8739929368425,35.8869996878584;13.0975062095276,76.9524858942891,44.5080826335283;15.2500560340127,86.7180538455712,44.5226374265892;19.3594547362944,85.8258546220405,35.3948324959821;17.2069049118093,76.0602866707584,35.3802777029211;12.2557654687499,77.1387796282049,44.0013606485909;14.4083152932350,86.9043475794870,44.0159154416519];
 AllPts=allSavedViews{6,1}{3,1};

% AllPts=[20.6569682864205,85.5585336022202,45.4128213194908;19.3122583041677,75.6517689143286,45.1942612994196;20.9337415053265,75.2141911498401,55.0522183863816;22.2784514875793,85.1209558377317,55.2707784064528;19.6794073047319,85.6875506212049,45.5793419965625;18.3346973224791,75.7807859333133,45.3607819764913;19.9561805236380,75.3432081688248,55.2187390634533;21.3008905058907,85.2499728567164,55.4372990835245];
% AllPts=[20.7988756732276,95.5960759805204,45.8350289710672;
% 20.8277542480763,85.6061662594776,45.3868439720668;
% 22.4492374492351,85.1685884949891,55.2448010590288;
% 22.4203588743864,95.1584982160319,55.6929860580293;
% 19.8121135020015,95.5859618985356,45.9968873127826;
% 19.8409920768502,85.5960521774928,45.5487023137822;
% 21.4624752780090,85.1584744130042,55.4066594007442;
% 21.4335967031604,95.1483841340471,55.8548443997446]
figure
%  isIntersections=[];
% isIntersections = computeIntersectionsWithKD(allSavedViews{7,1}{3,1}(1:4,:), model, 1e-2, kdtree1, 8);
% isIntersections = filterIntersectionsByZ(isIntersections , allSavedViews{7,1}{3,1}(1:4,:));
% [angle_deg, mf, mn] = computeAngleFromIntersectionsAndEdge(allSavedViews{7,1}{3,1}(3,:), allSavedViews{7,1}{3,1}(4,:), isIntersections );
% 
% [newSquareVertices, basefield] = generateSquareFromProjection(allSavedViews{7,1}{3,1}(1:4,:), mn, 10); % 生成基准平面
%  rotatedPts = autoRotatebasefield(basefield, stl_file, 0.1, 15, 1, 360, 0.7); % 固定阈值
% rotatedPts =basefield;
%  [rotatedPts, P_final, F_final] = autoRotateViewfield(basefield, stl_file, 0.1, 15, 1, 360, 0.5, 0.1, 4);
%   AllPts=basefield;
% AllPts=[24.8724017308122,61.8431769775218,62.7795680074656;20.1063452716368,53.0587857996759,63.1247888969471;19.8738261087407,52.7921937585497,53.1310476794403;24.6398825679161,61.5765849363957,52.7858267899588;25.7512113840753,61.3660669239892,62.7718485418291;20.9851549248999,52.5816757461432,63.1170694313106;20.7526357620038,52.3150837050171,53.1233282138038;25.5186922211792,61.0994748828631,52.7781073243223];
% rotationCenter = (AllPts(1,:) + AllPts(2,:)+AllPts(5,:)+AllPts(6,:)) /4;
% axis_vec = (AllPts(1,:) - AllPts(2,:)) / norm(AllPts(1,:) - AllPts(2,:));
% rotatedPts = rotatePoints(AllPts, rotationCenter, axis_vec, 55);
% rotatedPts =adjustVdthroughN(rotatedPts ,faces,vertices);
% rotatedPts =previousViewField;
% P=rotatedPts (1:4,:);                
% ptsP = sampleFace(P, 15);
% insideP = in_polyhedron(faces, vertices, ptsP);
% count_insideP = sum(insideP);
tic
% % [rotatedPts, P_final, F_final] = autoRotateViewfield(AllPts, stl_file, 0.2, 15, 1, 360, 0.63, 1);
 [rotatedPts, P_final, F_final] = autoRotateViewfield_v2(AllPts, stl_file, 0.1, 15, 2, 360, 0.5, 0.1, 2);
 toc
 disp(['旋转函数调用时间: ',num2str(toc)]);
 % [bestAngle, rotatedPts] = autoRotateViewfield_v2(AllPts, faces, vertices, 2, 0.1, 15, 0.5, 2);
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
%     hold on;
visualizeViewField(AllPts(1:4,:), AllPts(5:8,:));
visualizeViewField(rotatedPts(1:4,:), rotatedPts(5:8,:));

% visualizeIntersections(isIntersections);

function [n,idx]= getModelNormalAt(X, model)
    % 根据模型面片计算，返回与点 X 最近的面片的法向量和索引
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    centroids = zeros(numFaces,3);
    normals = zeros(numFaces,3);
    
    % 计算每个面片的重心和法向量
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

    % 找到最近的面片索引
    dists = sqrt(sum((centroids - X).^2, 2));
    [~, idx] = min(dists);
    
    % 返回对应的法向量
    n = normals(idx,:)';
end


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
function visualizeNormalVector1(pts)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector);
    center = mean(pts, 1);
    Pk=center+30.5*normal_vector;
    gw=center;
    scatter3(Pk(1), Pk(2), Pk(3), 60, 'm', 'filled');
    P=pts(5:8,:);
   for i = 1:4
    plot3([Pk(1), P(i,1)], [Pk(2), P(i,2)], [Pk(3),P(i,3)], 'b', 'LineWidth', 1);
   end
  plot3([Pk(1), gw(1)], [Pk(2), gw(2)], [Pk(3),gw(3)], 'r','LineStyle', '--', 'LineWidth', 2);
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


function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    theta_rad = deg2rad(theta_deg); % 角度转换为弧度
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1 - cos(theta_rad))*(K*K);
    rotatedPts = (R * (pts - center)')' + center; 
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
            if theta_deg==183
                disp('明明进入了啊');
                isValidTangent(P_new, F_new, faces, vertices, epsilon, numSamples, threshold, kdtree);
            end
            % 先检测当前视场是否满足相切条件（isValidTangent要求近面基本相切）
            if isValidTangent(P_new, F_new, faces, vertices, epsilon, numSamples, threshold, kdtree)
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
                        best_view = AllPts_rot ;
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
            if theta_deg==185
                disp('明明进入了啊')
            end
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



function visualizeIntersections(intersections, varargin)
% visualizeIntersections 可视化 3D 空间中的交点集
%
% 输入：
%   intersections: N x 3 数组，表示交点坐标
% 可选输入参数（通过名称-值对）：
%   'Color'      - 点的颜色，默认 'r'
%   'Size'       - 散点大小，默认 80
%   'ShowIndex'  - 是否显示编号标签，默认 false
%   'TagPrefix'  - 标签前缀字符串，默认 ''
%
% 示例：
%   visualizeIntersections(isIntersections, 'Color', 'g', 'ShowIndex', true)

    % 默认参数
    color = 'r';
    sz = 80;
    showIndex = false;
    tagPrefix = '';

    % 解析可选参数
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case 'color'
                color = varargin{i+1};
            case 'size'
                sz = varargin{i+1};
            case 'showindex'
                showIndex = varargin{i+1};
            case 'tagprefix'
                tagPrefix = varargin{i+1};
        end
    end

    % 可视化交点
    scatter3(intersections(:,1), intersections(:,2), intersections(:,3), ...
        sz, color, 'filled');

    % 添加编号标签（如果启用）
    if showIndex
        for i = 1:size(intersections, 1)
            text(intersections(i,1), intersections(i,2), intersections(i,3), ...
                sprintf('%s%d', tagPrefix, i), ...
                'FontSize', 8, 'Color', 'k', 'VerticalAlignment', 'bottom');
        end
    end

    % 画图设置
    axis equal;
    grid on;
    rotate3d on;
end
   function dist = point_to_line_distance(Q, P1, P2)
% 计算点Q到由P1和P2确定的直线的距离
% 输入:
%   Q  = [x, y, z]，待计算的点坐标
%   P1 = [x1, y1, z1]，直线上的第一个点
%   P2 = [x2, y2, z2]，直线上的第二个点
% 输出:
%   dist = 点Q到直线的距离

    % 计算直线的方向向量
    v = P2 - P1;
    
    % 计算从P1到Q的向量
    w = Q - P1;
    
    % 计算叉积的模长
    cross_product = cross(w, v);
    cross_norm = norm(cross_product);
    
    % 计算方向向量的模长
    v_norm = norm(v);
    
    % 计算距离
    dist = cross_norm / v_norm;
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