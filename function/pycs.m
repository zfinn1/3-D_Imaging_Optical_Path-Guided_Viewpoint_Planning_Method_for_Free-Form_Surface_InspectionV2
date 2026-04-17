% 读取 STL 模型并获取投影点
fv = stlread('C:\Users\86132\Desktop\c\111.stl');
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
vertices = fv.Points;
faces = fv.ConnectivityList;
xy_vertices = vertices(:, 1:2);
 kdtree = buildKDTreeForTriangles(faces, vertices);
% 示例调用
prevCircleViews=allSavedViews{5};
currVF=allSavedViews{6,1}{5,1};
[adjustedVF,closestVF] = alignViewfield(currVF, prevCircleViews, 1.1);
[vp,vf]=caiyang(adjustedVF(1:4,:),adjustedVF(5:8,:),faces,vertices);
X=mean(adjustedVF(1:4,:),1);
 [n,idx]= getModelNormalAt(X, fv);
initialface1 = idx;
 A = vertices(faces(initialface1,1),:);
B = vertices(faces(initialface1,2),:);
C = vertices(faces(initialface1,3),:);
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);

maybe=[P1;P2;P3;P4;F1;F2;F3;F4];
 g_ref=closestVF(4,:)-closestVF(3,:);
 g_ref = g_ref(:,1:2) ;
 g_ref=g_ref/norm(g_ref);
v_current = P2 - P1;
v_current = v_current(:,1:2) ;
v_current = v_current / norm(v_current);  % 归一化


% 计算旋转角度（弧度）
cos_theta = dot(v_current, g_ref);
theta_rad = acos(cos_theta);



theta_deg = theta_rad ;  % 旋转角度（度）

rotationCenter =mean(maybe,1);
n = mean(maybe(1:4,:),1) -mean(maybe(5:8,:),1);
axis_vec = n/norm(n);

% 旋转所有顶点
maybe_new = rotatePoints(maybe, rotationCenter,axis_vec  , theta_deg);

m=0;

while vp1<0.99 && vf1<1e-6
    disp('分割符儿');
    maybe_new = maybe_new+m* n;
    [vp1,vf1]=caiyang(maybe_new(1:4,:),maybe_new(5:8,:),faces,vertices);
    m=m+0.05;
end   




figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
% visualizeViewField(currVF(1:4,:), currVF(5:8,:));
visualizeViewField(closestVF(1:4,:), closestVF(5:8,:));
%  visualizeViewField(adjustedVF(1:4,:), adjustedVF(5:8,:));
 visualizeViewField(maybe_new(1:4,:), maybe_new(5:8,:));
% visualizeViewField(NadjustedVF(1:4,:), NadjustedVF(5:8,:));

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


function [currAdjustedVF,closestVF] = alignViewfield(currVF, prevCircleViews, factor)
% alignViewfield 将当前圈中的一个视场域与上一圈中最靠近的视场域对齐
%
% 输入：
%   currVF         - 当前圈的视场域（8x3矩阵，8个顶点坐标）
%   prevCircleViews- 上一圈所有视场域的cell数组，每个cell存放一个8x3矩阵
%   factor         - 调整比例因子（例如1表示完全对齐，0.5表示平移一半距离）
%
% 输出：
%   currAdjustedVF - 平移后的当前视场域（8x3矩阵）
%
% 计算当前视场域中心
currCenter = mean(currVF, 1);
prevCircleViews = prevCircleViews(~cellfun(@isempty, prevCircleViews));

% 对上一圈中所有视场域计算中心点
numPrev = numel(prevCircleViews);
prevCenters = zeros(numPrev, 3);
for j = 1:numPrev
    if ~isempty(prevCircleViews{j})
        prevCenters(j,:) = mean(prevCircleViews{j}, 1);
    else
        % 如果某个视场为空，赋予较大值（或忽略）
        prevCenters(j,:) = [Inf, Inf, Inf];
    end
end

% 计算当前中心与每个上一圈中心的欧式距离
dists = vecnorm(prevCenters - currCenter, 2, 2);

% 找到距离最小的视场（即最近的中心）
[~, idx] = min(dists);
closestVF = prevCircleViews{idx};
closestCenter = mean(closestVF, 1);
prevEdgeMid=(closestVF(1,:)+closestVF(4,:))/2;
currEdgeMid=(currVF(2,:)+currVF(3,:))/2;
% 计算平移向量（可根据需要乘以比例因子）
% translationVec = factor * (closestCenter - currCenter);
translationVec = factor * (prevEdgeMid - currEdgeMid);
translationVec(3) = 0;
% 对当前视场域进行平移
currAdjustedVF = currVF +translationVec;
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

%%旋转函数
function [AllPts_new,P_new, F_new] = applyRotation(AllPts, theta_deg,rotationCenter,axis_vec)
 
    AllPts_new = rotatePoints(AllPts, rotationCenter, axis_vec, theta_deg);
    P_new = AllPts_new(1:4, :);
    F_new = AllPts_new(5:8, :);
    
end

%%采样某个面内的点（面由 4 个顶点组成） 采样函数为下一步限制相切做铺垫
function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
end


function [ratioInsideP,ratioInsideF]=caiyang(P_new,F_new,faces,vertices)
ptsP = sampleFace(P_new, 20);
ptsF = sampleFace(F_new, 20);
% 利用 inpolyhedron 判断采样点是否在模型内部（返回 true 表示在内部）
    insideP = in_polyhedron(faces, vertices, ptsP);
    insideF = in_polyhedron(faces, vertices, ptsF);
 % 计算内部点的比例
    ratioInsideP = sum(insideP) / 400;  % 近面内部点占比
    ratioInsideF = sum(insideF) / 400;  % 远面内部点占比
disp( ratioInsideP);
disp( ratioInsideF);
end
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