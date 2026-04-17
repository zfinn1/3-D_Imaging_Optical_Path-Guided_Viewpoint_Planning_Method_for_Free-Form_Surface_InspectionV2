clear;
close all;
clc;

% 读取 STL 文件及数据
stlFile = 'E:\111.stl';
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;


initialface=2478;
% 选取一个面片生成视场区域
tp1 = vertices(faces(initialface,1),:);
tp2 = vertices(faces(initialface,2),:);
tp3 = vertices(faces(initialface,3),:);
[P1, P2, P3, P4, P,n] = viewfield(tp1, tp2, tp3);


% 定义底面四个点（P1, P2, P3, P4）
basePoints = [P1; P2; P3; P4];

% 设置候选筛选阈值
threshold = 2;

% 获取从视点 P 到底面四个点的射线交点信息
intersections = computeAllRayIntersections(P, basePoints, vertices, faces, threshold);

currentIntersections=intersections.visibleIntersection;
currentViewpoint=P;

% 假设已有初始视场域交点 currentIntersections 和当前视点 currentViewpoint
% 同时你已通过 viewfield 得到初始数据

% 定义目标偏移距离（例如 28）和目标值（例如 28.3862）
givenDistance = 28;
targetDistance = 28.3862;

% 定义扫描角度初始值和增量（单位：度）
currentAngle = 0;         % 从 0° 开始
angleIncrement = 30;      % 每次更新 30°

numSteps = 360 / angleIncrement;  % 一圈

for k = 1:numSteps
    % 计算当前期望扫描方向（在水平面上），以 degrees 转换为弧度
  desiredAngleRad = deg2rad(currentAngle);
desiredDir = [cos(desiredAngleRad), sin(desiredAngleRad)];  % 只保留 X 和 Y 分量
    
    % 计算两个交点中点 M（例如取 currentIntersections 中你认为合适的两个交点的中点）
    % 这里假设取 currentIntersections 的第3和第4个交点：
    M = (P3 + P4) / 2;
    
    % 遍历模型面片，找到候选面片：
    minAngleDiff = inf;
    bestFaceIdx = -1;
    bestCandidateViewpoint = [];
    numFaces = size(faces,1);
    for i = 1:numFaces
        % 取当前面片的三个顶点
        tri = vertices(faces(i,:),:);
        centroid = mean(tri,1);
        % 计算该面片的单位法向量
        n = cross(tri(2,:) - tri(1,:), tri(3,:) - tri(1,:));
        if norm(n) < 1e-6
            continue;
        end
        n = n / norm(n);
        % 计算候选视点：沿法向偏移 givenDistance
        candidateV = centroid + givenDistance * n;
        % 投影到水平面（XY 平面）：只保留 X, Y 分量
        projCandidate = candidateV(1:2);
        % 计算候选视点水平方向的单位向量
        if norm(projCandidate) == 0
            continue;
        end
        candidateDir = projCandidate / norm(projCandidate);
        % 计算期望方向和候选方向之间的角差（单位：弧度）
        angleDiff = acos( min(1, dot(candidateDir, desiredDir)) );
        % 也可以考虑候选视点与 M 的距离接近 targetDistance
        distCandidate = norm(candidateV - M);
        distDiff = abs(distCandidate - targetDistance);
        % 综合考虑角差和距离差（例如简单加权）
        weightAngle = 1;  % 可调
        weightDist = 1;   % 可调
        score = weightAngle * angleDiff + weightDist * distDiff;
        if score < minAngleDiff
            minAngleDiff = score;
            bestFaceIdx = i;
            bestCandidateViewpoint = candidateV;
        end
    end
    
    if bestFaceIdx == -1
        error('未找到合适的候选面片');
    end
    
    % 得到最佳候选面片
    bestTri = vertices(faces(bestFaceIdx,:),:);
    candidateCentroid = mean(bestTri,1);
    % 新视点取候选面片重心沿法向偏移一定距离（例如 d_offset）
    newViewpoint = candidateCentroid + 28 * n;  % 这里 n 为 bestTri 的法向量
    % 接下来，根据 bestTri 和中点 M 构造新的正方形底面
    % 为确保 M 是新正方形某边的中点，我们采用类似下面的方法：
    
    % 构造候选平面正交基
    globalX = [1, 1, 0];
    u = globalX - dot(globalX, n)*n;
    if norm(u) < 1e-6
        globalY = [0, 1, 1];
        u = globalY - dot(globalY, n)*n;
    end
    u = u / norm(u);
    v = cross(n, u);
    v = v / norm(v);
    
    % 为使 M 为正方形上边中点，设新正方形中心 X = M - (side/2)*v
    side=10;
    X = M - (side/2)*v;
    half = side/2;
    Q1 = X + half*(u+v);
    Q2 = X + half*(-u+v);
    Q3 = X + half*(-u-v);
    Q4 = X + half*(u-v);
    newBase = [Q1; Q2; Q3; Q4];
    
    % 更新当前视场数据，方便下一次迭代
    currentViewpoint = newViewpoint;
    currentIntersections = newBase;
    
    % 可视化当前更新结果
    figure;
    trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;
    scatter3(newViewpoint(1), newViewpoint(2), newViewpoint(3), 100, 'm', 'filled');
    text(newViewpoint(1), newViewpoint(2), newViewpoint(3), '  New Viewpoint','FontSize',12);
    scatter3(newBase(:,1), newBase(:,2), newBase(:,3), 100, 'r', 'filled');
    fill3(newBase(:,1), newBase(:,2), newBase(:,3), 'r', 'FaceAlpha', 0.5);
    % 绘制连线
    for j = 1:4
        plot3([newViewpoint(1), newBase(j,1)], [newViewpoint(2), newBase(j,2)], [newViewpoint(3), newBase(j,3)], 'k-', 'LineWidth', 2);
    end
    axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(sprintf('第 %d 次更新，目标角度：%.1f°', k, currentAngle));
    hold off;
    
    % 更新扫描角度
    currentAngle = mod(currentAngle + angleIncrement, 360);
    
    % 如果需要将每一步结果保存下来，可将 newViewpoint 和 newBase 存入数组中。
    
    pause(1);  % 暂停1秒，便于观察
end

