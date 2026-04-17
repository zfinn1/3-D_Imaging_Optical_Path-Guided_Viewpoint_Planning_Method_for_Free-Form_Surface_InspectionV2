%% 主程序：基于局部曲率动态选择生成新视场域
% clear; close all; clc;
clear;clc;
%% 1. 读取 STL 文件及数据
stlFile = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stlFile);
vertices = model.Points;%返回所有顶点的坐标
faces = model.ConnectivityList;

numFaces = size(faces, 1);
faceCentroids = zeros(numFaces, 3);


for i = 1:numFaces
    faceIndices = faces(i, :);
    v1 = vertices(faceIndices(1), :);
    v2 = vertices(faceIndices(2), :);
    v3 = vertices(faceIndices(3), :);
    faceCentroids(i, :) = (v1 + v2 + v3) / 3;
end
%% 2. 选取一个面生成初始视场区域
initialface =2478;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);
targetFace = [A; B; C];

% 调用视场生成函数（返回摄像机位置、近面和远面顶点）
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);
Allpts = [P1; P2; P3; P4; F1; F2; F3; F4];

%% 3. 初始旋转处理
% 计算近面和远面部分边界的中点，作为旋转中心及旋转轴
E3 = (P3 + F3) / 2;
E4 = (P4 + F4) / 2;
rotationCenter = (E3 + E4) / 2;
axis_vec = (E4 - E3) / norm(E4 - E3);
[Allpts_new, currentNear,currentFar] = spanviewfield(0.1875, 1, 15, [], [], rotationCenter, axis_vec, Allpts, model, 0);



% 接下来，对前4个顶点（近面）和后4个顶点（远面）分别重新排序
% orderedNear = reorderFaceVertices_byRef(currentNear, Allpts(1:4,:));
% orderedFar  = reorderFaceVertices_byRef(currentFar, Allpts(5:8,:));
% 
% Allpts_new = [orderedNear; orderedFar];



% 以结构体保存初始视场域（近面、远面及整体顶点）
% currentViewField.near = orderedNear;
% currentViewField.far  = orderedFar;
currentViewField.near = currentNear;
currentViewField.far  = currentFar;
currentViewField.allpts = Allpts_new;

%% 4. 参数设置
maxSteps = 7;                   % 循环步数
curvatureThreshold = 0.3;       % 曲率阈值（单位：弧度，根据实际情况调整）
rotationAngle = 1;             % 低曲率时每步旋转角度（单位：度）

% 参数结构体，用于翻越操作与旋转操作
params.flipScale   = 0.23; 
params.flipFactor  = 0.5; 
params.flipIter    = 15;
params.rotateFactor = 1; 
params.rotateIter  = 15;
params.sideLength  = 10; 
params.halfLength  = 5;

%% 5. 初始视场域可视化
figure; 
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on; axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
h_near_prev=fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
h_far_prev=fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);

for i = 1:4
    plot3([Allpts(i,1), Allpts(i+4,1)], [Allpts(i,2), Allpts(i+4,2)], [Allpts(i,3), Allpts(i+4,3)], 'k-', 'LineWidth',2);
end

scatter3(P(1), P(2), P(3), 120, 'r', 'filled');
for i = 1:4
    plot3([P(1), Allpts(i+4,1)], [P(2), Allpts(i+4,2)], [P(3), Allpts(i+4,3)], 'g', 'LineWidth', 2);
end
xlabel('X'); ylabel('Y'); zlabel('Z');
visualizeViewField(currentViewField);
u=0;
%% 6. 循环：根据局部曲率生成连续的视场域
for step = 1:maxSteps
    curvature = computeLocalCurvature(currentViewField,model);
    fprintf('Step %d: curvature = %.3f\n', step, curvature);
    
    if curvature > 0.6
        % 高曲率区域：求交点生成新基础长方体，再进行翻越变换
        fprintf('高曲率区域：调用 generateNewCuboidWithIntersections\n');
%         newViewField = rotateViewField(currentViewField, rotationAngle, model, params,step);
       newViewField = generateNewCuboidWithIntersections(currentViewField, model, targetFace, params,faceCentroids);
       
    elseif (0.6>curvature)&&(curvature>0.4)
     
        u=u+1;
        fprintf('低中曲率过度区域：调用 rotateViewField\n');
        newViewField = rotateViewField(currentViewField, rotationAngle, model, params,u,2);
    else
        u=u+1;
        fprintf('低曲率区域：调用 rotateViewField\n');
        if step==4
         K = currentViewField.near;  % 当前近面顶点（4×3矩阵）
         uniqueIntersections = computeIntersections(K, model, 1e-6);
         
         % Step 1: 确定原正方形的方向向量
dir1 = K(2,:) - K(1,:);
dir2 = K(3,:) - K(2,:);

% 确保向量正交
if abs(dot(dir1, dir2)) > 1e-6
    error('原正方形的方向向量不正交，请检查顶点坐标。\n');
end

% 步骤 2：正交化和单位化方向向量
dir1 = dir1 / norm(dir1);
dir2 = dir2 - (dot(dir2, dir1) / norm(dir1)^2) * dir1;
dir2 = dir2 / norm(dir2);
 % 定义原正方形的四条边
    edges = [K(1,:); K(2,:);
             K(2,:); K(3,:);
             K(3,:); K(4,:);
             K(4,:); K(1,:)];

    % 寻找最靠近原正方形两侧边的交点
    numEdges = 4;
    minDistances = inf(numEdges, 1);
    closestPoints = zeros(numEdges, 3);

    for i = 1:numEdges
        % 当前边的起点和终点
        startEdge = edges(2*i - 1, :);
        endEdge = edges(2*i, :);
        direction = endEdge - startEdge;
        
        for j = 1:size(uniqueIntersections, 1)
            point = uniqueIntersections(j, :);
            
            % 计算点到边的投影参数t
            t = max(0, min(1, (dot(point - startEdge, direction)) / (norm(direction)^2)));
            projPoint = startEdge + t * direction;
            dist = norm(point - projPoint);
            
            if dist < minDistances(i)
                minDistances(i) = dist;
                closestPoints(i, :) = point;
            end
        end
    end

    % 选择最接近的两个点作为基准点
    [~, indices] = sort(minDistances);
    P1 = closestPoints(indices(1), :);
    P2 = closestPoints(indices(2), :);


% 步骤 4：计算新正方形的中心
PCT = (P1 + P2) / 2 ;

% 步骤 5：生成正方形的顶点
sideLength = 10;
halfLength = sideLength / 2;

vertex1 = PCT -5 * dir1- 1 * dir2;
vertex2 = PCT +5 * dir1- 1 * dir2;
vertex3 = PCT +5 * dir1 + 9 * dir2;
vertex4 = PCT -5 * dir1 + 9 * dir2;
newSquareVertices = [vertex1; vertex2; vertex3; vertex4];

hold on; grid on; axis equal;
patch('Vertices', newSquareVertices, 'Faces', [1 2 3 4], 'FaceColor', 'yellow', 'FaceAlpha', 0.5);
plot3(PCT(1),PCT(2),PCT(3),'o');
plot3(newSquareVertices(:,1), newSquareVertices(:,2), newSquareVertices(:,3), 'ko-', 'LineWidth', 2);
    for i = 1:4
        text(newSquareVertices(i,1), newSquareVertices(i,2), newSquareVertices(i,3), sprintf(' V%d', i), 'FontSize', 12, 'Color', 'b');
    end
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('生成的正方形');
    drawnow;



n_plane = cross(dir1, dir2);
n_plane = n_plane / norm(n_plane);  % 归一化
half_thickness = 0.5;  % 上下平移的距离
topFace =newSquareVertices + repmat(half_thickness * n_plane, size(newSquareVertices,1), 1);
bottomFace =newSquareVertices - repmat(half_thickness * n_plane, size(newSquareVertices,1), 1);


d=[topFace;bottomFace];
rotationCenter1 = (newSquareVertices(1,:) + newSquareVertices(2,:)) / 2;
axis_vec1 = (newSquareVertices(2,:) - newSquareVertices(1,:)) / norm(newSquareVertices(2,:) - newSquareVertices(1,:));
[Allpts_new, newNear,newFar] = spanviewfield2(0.1875, params.rotateFactor, params.rotateIter, [], [], rotationCenter1, axis_vec1, d, model,0);
 newViewField.near = newNear;
 newViewField.far  = newFar;
 newViewField.allpts =Allpts_new;       
        else
         newViewField = rotateViewField(currentViewField, rotationAngle, model, params,u,0);
        
       end
        
        
    end
    
    % 更新当前视场域
    currentViewField = newViewField;
    
    % 可视化新生成的视场域
    visualizeViewField(currentViewField);
    pause(1);  % 每步暂停 1 秒，便于观察
end

%% ================= 辅助函数 ================


function curvature = computeLocalCurvature(viewField, model)
    % 计算当前视场域附近区域的局部曲率
    % viewField: 当前视场域（包含 near 面的顶点）
    % model: STL 3D 模型数据
    % 返回：局部曲率（一个标量）
    
    nearVertices = viewField.near; % 近面四个顶点
    numPoints = size(nearVertices, 1);
    
    % 存储法向量
    normals = zeros(numPoints, 3);
    
    % 计算每个点的法向量（基于 STL 模型）
    for i = 1:numPoints
        normals(i, :) = getModelNormalAt(nearVertices(i, :), model);
    end
    
    % 计算相邻法向量之间的角度变化
    curvatureValues = zeros(numPoints, 1);
    for i = 1:numPoints
        i_next = mod(i, numPoints) + 1; % 下一个点（循环索引）
        dotProduct = dot(normals(i, :), normals(i_next, :));
        curvatureValues(i) = acos(max(min(dotProduct, 1), -1)); % 限制范围防止误差
    end
    
    % 计算平均曲率
    curvature = mean(curvatureValues);
end
%


%
function newViewField = rotateViewField(currentViewField, rotationAngle, model, params,step,condition)
    % 直接旋转当前视场域：利用 spanviewfield 沿固定轴旋转
    if mod(step,2)==0
      E3 = (currentViewField.near(3,:) + currentViewField.far(3,:)) / 2;
      E4 = (currentViewField.near(4,:) + currentViewField.far(4,:)) / 2;
      rotationCenter2 = (E3 + E4) / 2;
      axis_vec2 = (E4 - E3) / norm(E4 - E3);
    else
      E3 = (currentViewField.near(1,:) + currentViewField.far(1,:)) / 2;
      E4 = (currentViewField.near(2,:) + currentViewField.far(2,:)) / 2;
      rotationCenter2 = (E3 + E4) / 2;
      axis_vec2 = (E3 - E4) / norm(E3 - E4);    
    end
    Allpts = currentViewField.allpts;
    [Allpts_new, newNear,newFar] = spanviewfield(0.1875, params.rotateFactor, params.rotateIter, [], [], rotationCenter2, axis_vec2, Allpts, model, condition);
    
%     orderednewNear = reorderFaceVertices_byRef(newNear, Allpts(1:4,:));
%     orderednewFar  = reorderFaceVertices_byRef(newFar, Allpts(5:8,:));
% 
%     Allpts_new = [orderednewNear; orderednewFar];
    
    
%     
   newViewField.near=newNear;
    newViewField.far=newFar;
    
%     newViewField.near=orderednewNear;
%     newViewField.far=orderednewFar;
    newViewField.allpts = Allpts_new;
end

function [Allpts_new, P_new,F_new] = spanviewfield1(tol, deltaTheta, numSamples, h_near, h_far, rotationCenter, axis_vec, Allpts, model, faceFlag,faceCentroids)
% spanviewfield - 旋转视场区域直到选定面（上表面或下表面）与模型表面相切，
% 并保证近面与远面分布在模型表面的两侧（一个内部，一个外部）
%
% 输入参数：
%   tol           - 距离容差
%   deltaTheta    - 每步旋转角度（度）
%   numSamples    - 在选定面内采样数量（每个方向）
%   h_near, h_far - 近面和远面的 patch 对象句柄
%   rotationCenter- 旋转中心
%   axis_vec      - 旋转轴（单位向量）
%   Allpts        - 初始视场区域所有顶点，前4行为近面（下表面），后4行为远面（上表面）
%   model         - STL 模型数据结构
%   faceFlag      - 判断标志，若为1则以远面（上表面）为条件，
%                   若为0则以近面与远面之间正中心的面为条件
%
% 输出参数：
%   Allpts_new    - 旋转后的所有顶点（8×3矩阵）
% 提取初始正方形（近面和远面）顶点
P1 = Allpts(1,:); P2 = Allpts(2,:); P3 = Allpts(3,:); P4 = Allpts(4,:);
F1 = Allpts(5,:); F2 = Allpts(6,:); F3 = Allpts(7,:); F4 = Allpts(8,:);
max_angle = 360;      % 最大旋转角度（度）
currentTheta = 0;     % 累计旋转角度
% 将所有顶点组合为矩阵，前4行为近面，后4行为远面
allPts = [P1; P2; P3; P4; F1; F2; F3; F4];
delayTime = 0.05;  % 每帧延时（秒）
while currentTheta < max_angle
    theta_rad = deg2rad(currentTheta);
    K = [ 0, -axis_vec(3), axis_vec(2);
          axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
    % 旋转所有顶点
    allPts_new = rotationCenter + (R * (allPts' - rotationCenter'))';
    % 分离近面和远面
    P_new = allPts_new(1:4, :);
    F_new = allPts_new(5:8, :);
    % 根据 faceFlag 选择条件面
    if faceFlag == 1
        % 以远面为条件（原有方式）
        [n_plane, ~] = computePlane(F_new(1,:), F_new(2,:), F_new(3,:));
        faceCenter = mean(F_new,1);
    elseif faceFlag == 2
        % 以远面为条件（原有方式）
        [n_plane, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
        faceCenter = mean(P_new,1);
    else
        % 以近面与远面之间正中心的面为条件
        centerPts = (P_new + F_new) / 2;
        faceCenter = mean(centerPts, 1);
        % 分别计算近面和远面的法向量，取平均后归一化
        [n_near, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
        [n_far, ~]  = computePlane(F_new(1,:), F_new(2,:), F_new(3,:));
        n_plane = (n_near + n_far) / 2;
        n_plane = n_plane / norm(n_plane);
    end
    % 当旋转角度大于180度时，翻转条件面法向量
    if currentTheta >= 180
        n_plane = -n_plane;
    end
    % 构造局部坐标系：以条件面中心 faceCenter 为原点
    if faceFlag == 1
        u = F_new(2,:) - F_new(1,:);
    elseif     faceFlag == 2
        u =  P_new(2,:) - P_new(1,:);
    else
        u = centerPts(2,:) - centerPts(1,:);
    end
    u = u - dot(u, n_plane)*n_plane;
    u = u / norm(u);
    v = cross(n_plane, u);
    % 估计选定面正方形边长 L
    if faceFlag == 1
        L = norm(F_new(2,:) - F_new(1,:));
    elseif     faceFlag == 2
        L = norm(P_new(2,:) - P_new(1,:));
    else
        L = norm(centerPts(2,:) - centerPts(1,:));
    end
    % 向量化生成所有采样点 X_all (numSamples^2 x 3)
    alphas = linspace(-L/8, L/8, numSamples);
    betas  = linspace(-L/8, L/8, numSamples);
    [Agrid, Bgrid] = meshgrid(alphas, betas);
    Agrid = Agrid(:);
    Bgrid = Bgrid(:);
    X_all = faceCenter + Agrid*u + Bgrid*v;
    
    
     % 修改后的距离计算方式：遍历所有面片，找到最小距离
        faces1 = model.ConnectivityList;
        vertices1 = model.Points;
        numFaces1 = size(faces1, 1);
        dists1 = zeros(size(X_all, 1), 1);

        for m = 1:size(X_all, 1)
            X = X_all(m, :);
            min_dist = inf;

            for n = 1:numFaces1
                face = faces1(n, :);
                A = vertices1(face(1), :);
                B = vertices1(face(2), :);
                C = vertices1(face(3), :);

                dist1 = distancePointToTriangle(X, A, B, C);
                  if dist1 < min_dist
                    min_dist = dist1;
                  end

                % 早期终止条件
                if min_dist <= tol
                        idxCandidates = 1;
                    break;
                end
            end

            dists1(m) = min_dist;
        end
     isTangent = false;
    if ~isempty(idxCandidates)
        % 对候选点逐一检查法向匹配
        for i = 1:length(idxCandidates)
            X = X_all(idxCandidates(i), :);
             if abs(dot(n_plane, getModelNormalAt(X, model))) > 0.99
                isTangent = true;
                break;
            end
        end
    end
    
cubeCenter=mean(allPts_new,1);


faces = model.ConnectivityList;
numFaces = size(faces, 1);

% 计算每个面片重心到长方体中心的距离
distances = zeros(numFaces, 1);
for i = 1:numFaces
    distances(i) = norm(faceCentroids(i, :) - cubeCenter);
end

% 找到距离最小的面片的重心
[~, minDistanceIndex] = min(distances);
judgeCenter= faceCentroids(minDistanceIndex, :);


%     检查近面与远面是否分布在模型两侧（保证一个在内部，一个在外部）
    if isTangent
        nearCenter= mean(P_new,1);
        farCenter  = mean(F_new,1);
        modelNormal = getModelNormalAt(cubeCenter, model);
        % 如果近面与远面都在模型法向同一侧，则不满足要求
        if dot(modelNormal, farCenter - judgeCenter) * dot(modelNormal, nearCenter - judgeCenter) > 0
            % 不满足内部/外部条件，继续旋转
            isTangent = false;
        end
%         if dot(modelNormal, P_new(1,:) - judgeCenter) * dot(modelNormal, F_new(1,:) - judgeCenter) > 0
%             % 不满足内部/外部条件，继续旋转
%             isTangent = false;
%         end
% %           if dot(modelNormal, P_new(2,:) - judgeCenter) * dot(modelNormal, F_new(2,:) - judgeCenter) > 0
% %             % 不满足内部/外部条件，继续旋转
% %             isTangent = false;
% %           end
%           if dot(modelNormal, P_new(3,:) - judgeCenter) * dot(modelNormal, F_new(3,:) - judgeCenter) > 0
%             % 不满足内部/外部条件，继续旋转
%             isTangent = false;
%           end
%            if dot(modelNormal, P_new(4,:) - judgeCenter) * dot(modelNormal, F_new(4,:) - judgeCenter) > 0
%             % 不满足内部/外部条件，继续旋转
%             isTangent = false;
%           end
    end
    if isTangent
        fprintf('检测到条件面（faceFlag=%d）与模型相切，旋转角度 = %f 度\n', faceFlag, currentTheta);
        break;
    end
    
      % 动态调整旋转步长
    if currentTheta >= max_angle - deltaTheta
        deltaTheta = deltaTheta / 2;
    end
    % 更新图形显示（更新 h_near 和 h_far 的 Vertices，如有句柄）
    if ~isempty(h_near)
        set(h_near, 'Vertices', P_new);
    end
    if ~isempty(h_far)
        set(h_far, 'Vertices', F_new);
    end
    drawnow;
    pause(delayTime);
    currentTheta = currentTheta + deltaTheta;
end
if  currentTheta> 90
    C=F_new;
    F_new=P_new;
    P_new=C;
end
Allpts_new = [P_new; F_new];
end


function newViewField = generateNewCuboidWithIntersections(currentViewField, model, targetFace, params,faceCentroids)
    % 利用当前近面作为基础，通过求交点、PCA 拟合等生成新的基础长方体，
    % 再通过翻越操作生成新的视场域
    PF_new = currentViewField.near;  % 当前近面顶点（4×3矩阵）
    [squareVertices, filteredIntersections, topFace, bottomFace] = generateSquareFromNewFace(PF_new, model, targetFace, params.sideLength, params.halfLength);
    
    % 构造基础立体：上下两个面
    cuboidVertices = [topFace; bottomFace];
    
    % 根据是否生成了新的基础长方体选择旋转轴计算方式
   
    % 使用新生成基础长方体中“12面”计算旋转轴：取 squareVertices 的第 1 和第 2 个顶点
     rotationCenter1 = (squareVertices(1,:) + squareVertices(2,:)) / 2;
     axis_vec1 = (squareVertices(2,:) - squareVertices(1,:)) / norm(squareVertices(2,:) - squareVertices(1,:));
   
%  [cuboidVertices_new, newNear,newFar] = spanviewfield_fixed(55,
%  rotationCenter1 , axis_vec1, cuboidVertices, 2)    ;     

    
    
    % 翻越操作：利用 spanviewfield 对 cuboidVertices 进行旋转变换
    [cuboidVertices_new, newNear,newFar] = spanviewfield1(0.05,1,15, [], [], rotationCenter1, axis_vec1, cuboidVertices, model,2,faceCentroids);

%     [secondsquareVertices, secondfilteredIntersections, secondtopFace, secondbottomFace] = generateSquareFromNewFace(newNear, model, targetFace, params.sideLength, params.halfLength);
%      secondrotationCenter1 = (secondsquareVertices(1,:) + secondsquareVertices(2,:)) / 2;
%     secondaxis_vec1 = (secondsquareVertices(2,:) - secondsquareVertices(1,:)) / norm(secondsquareVertices(2,:) - secondsquareVertices(1,:));
%     secondcuboidVertices=[secondtopFace;secondbottomFace];
%      [cuboidVertices_new, newNear,newFar] = spanviewfield1(0.2, 0.5, params.flipIter, [], [], secondrotationCenter1, secondaxis_vec1, secondcuboidVertices, model, 2);
%     
    newViewField.near = newNear;
    newViewField.far  = newFar;
    newViewField.allpts = cuboidVertices_new;
end




function visualizeViewField(viewField)
    % 绘制视场域：近面用红色，远面用蓝色，并用黑色连线显示对应顶点连接关系
    nearPts = viewField.near;
    farPts  = viewField.far;
    fill3(nearPts(:,1), nearPts(:,2), nearPts(:,3), 'r', 'FaceAlpha', 0.5);
    fill3(farPts(:,1), farPts(:,2), farPts(:,3), 'b', 'FaceAlpha', 0.5);
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth',2);
    end
    drawnow;
end


function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量 n（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end

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


function [Allpts_new, P_new, F_new] = spanviewfield_fixed(rotateAngle, rotationCenter, axis_vec, Allpts, faceFlag)
% spanviewfield_fixed - 将视场区域绕指定旋转轴旋转给定角度，并返回旋转后的顶点
%
% 输入参数：
%   rotateAngle   - 固定旋转角度（单位：度）
%   rotationCenter- 旋转中心（1×3向量）
%   axis_vec      - 旋转轴（单位向量，1×3）
%   Allpts        - 原始视场区域所有顶点（8×3矩阵），前4行为近面，后4行为远面
%   faceFlag      - 判断标志（预留，可根据需要扩展处理），当前函数中未做额外处理
%
% 输出参数：
%   Allpts_new    - 旋转后的所有顶点（8×3矩阵）
%   P_new         - 旋转后的近面顶点（4×3矩阵）
%   F_new         - 旋转后的远面顶点（4×3矩阵）
%
% 注意：
%   如果旋转角度大于90度，可能会导致近面与远面互换，
%   此处提供一个可选的处理方式：如果 rotateAngle>90，则交换返回的近面和远面。

    % 将旋转角度转换为弧度
    theta_rad = deg2rad(rotateAngle);
    
    % 计算旋转矩阵（Rodrigues公式）
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
    
    % 对所有顶点进行旋转
    Allpts_new = rotationCenter + (R * (Allpts' - rotationCenter'))';
    
    % 分离近面和远面
    P_new = Allpts_new(1:4, :);
    F_new = Allpts_new(5:8, :);
    
    % 可选：如果旋转角度大于90度，可能会导致近面与远面互换，
    % 这里你可以选择交换两组（如果你希望始终返回的前4行为离模型较近的面）
    if rotateAngle > 90
        temp = P_new;
        P_new = F_new;
        F_new = temp;
        Allpts_new = [P_new; F_new];
    end
end
function dist = distancePointToTriangle(P, A, B, C)
    % P 是点坐标，A、B、C 是三角形的三个顶点坐标
    % 向量 AB 和 AC
    AB = B - A;
    AC = C - A;
    AP = P - A;
    BC=B-C;
    CA=C-A;
    % 计算叉积和点积
    cross_AB_AC = cross(AB, AC);
    cross_AP_AB = cross(AP, AB);
    cross_AP_AC = cross(AP, AC);

    % 计算面积平方
    a = dot(cross_AB_AC, cross_AB_AC);
    if a < eps
        % 面片退化，按点到 A 的距离计算
        dist = norm(AP);
        return;
    end

    % 计算投影参数
    u = dot(cross_AP_AC, cross_AB_AC) / a;
    v = dot(cross_AP_AB, cross_AB_AC) / a;

    if u <= 0 && v <= 0
        % 最近点是 A
        dist = norm(AP);
    elseif u >= 1 && v >= 0 && (u + v) <= 1
        % 最近点是 B
        dist = norm(P - B);
    elseif v >= 1 && (u <= 0 || u + v >= 1)
        % 最近点是 C
        dist = norm(P - C);
    elseif u > 0 && v > 0 && (u + v) < 1
        % 投影在三角形内部，计算垂直距离
        dist = abs(dot(AP, cross_AB_AC)) / sqrt(a);
    else
        % 计算到三个边的距离
        d1 = norm(cross(AP, AB)) / norm(AB);
        d2 = norm(cross(P - B, BC)) / norm(BC);
        d3 = norm(cross(P - C, CA)) / norm(CA);
        dist = min([d1, d2, d3]);
    end
end
