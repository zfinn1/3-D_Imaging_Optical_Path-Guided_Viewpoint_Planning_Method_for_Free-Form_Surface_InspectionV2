% 读取 STL 模型并获取投影点
fv = stlread('C:\Users\86132\Desktop\c\111.stl');
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
vertices = fv.Points;
faces = fv.ConnectivityList;
xy_vertices = vertices(:, 1:2);
 kdtree = buildKDTreeForTriangles(faces, vertices);
% % 示例调用
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
prevCircleViews=allSavedViews{5};
% for step=3:8
% %     if step~=4
%     currVF=allSavedViews{6,1}{step,1};
%     maybe_new = adjustViewfield(fv, currVF, prevCircleViews, faces, vertices, 0.05, 1e-6);
%     visualizeViewField(maybe_new(1:4,:), maybe_new(5:8,:));
%     hold on
% %     end
% end
tic
 currVF=allSavedViews{6,1}{3,1};
    maybe_new = adjustViewfield(fv, currVF, prevCircleViews, faces, vertices, 0.05, 1e-6);
maybe_new=adjustVdthroughN(maybe_new,faces,vertices);

[savedViews_current, savedIntersections_current,E] = rotatefullcircle4(maybe_new, stl_file, n_ref, 15,allSavedViews{6,1}{1,1});

shift = 2;  % 后移的位数
n = numel(savedViews_current);  % cell 数组的总个数
newC = cell(n,1);  % 创建一个新的 cell 数组

% 将前 shift 个元素设为空
newC(1:shift) = {[]};

% 将原数组前 n-shift 个元素移动到后面
newC(shift+1:end) = savedViews_current(1:n-shift);     
 savedViews_current=newC;    
 savedViews_current{1}=allSavedViews{6,1}{1,1};    
savedViews_current{2}=allSavedViews{6,1}{2,1};  

allSavedViews{6}=savedViews_current;
toc
disp(['第一段运行时间: ',num2str(toc)]);

tic
last_circle=cell(numel(savedViews_current),1);   
for i=1:numel(savedViews_current)
AllPts=savedViews_current{i,1};
if isempty(AllPts)
   break;
end
[AllPts_new, P_final, F_final] = autoRotateViewfield(AllPts, stl_file, 0.1, 15, 1, 360, 0.7, 0.2,2);
if AllPts_new==AllPts
    AllPts_new=[];
    last_circle{i}=AllPts_new;
    break;
end
 last_circle{i}=AllPts_new;

end
allSavedViews{7}=last_circle;
% 
toc
disp(['第二段运行时间: ',num2str(toc)]);


tic
J=last_circle{7};

[A, AP, AF] = autoRotateViewfield(J, stl_file, 0.1, 15, 1, 360, 0.85, 0.1,2);
A=[AF; AP];
[A, ~,~] = autoRotateViewfield(A, stl_file, 0.1, 15, 1, 360, 0.85, 0.1,4);
[A1,~, ~] = autoRotateViewfield(A, stl_file, 0.1, 15, 1, 360, 0.85, 0.1,4);
[A2, ~,~] = autoRotateViewfield(A, stl_file, 0.1, 15, 1, 360, 0.85, 0.1,1);
[A3, ~,~] = autoRotateViewfield(A1, stl_file, 0.1, 15, 1, 360, 0.85, 0.1,1);

Complexedge=cell(4,1); 
Complexedge{1}=A;
Complexedge{2}=A1;
Complexedge{3}=A2;
Complexedge{4}=A3;

allSavedViews{8}=Complexedge;
toc
disp(['第三段运行时间: ',num2str(toc)]);

for circle = 1:8
    currentCircleViews = allSavedViews{circle};
    for t = 1:length(currentCircleViews)
        if ~isempty(currentCircleViews{t})
            viewField = currentCircleViews{t};
            P_final = viewField(1:4,:);
            F_final = viewField(5:8,:);
            visualizeViewField(P_final, F_final);
            visualizeNormalVector((P_final+F_final)/2, 'k');
        end
    end
end
%      currentCircleViews = savedViews_current;
%     for t = 1:length(currentCircleViews)
%         if ~isempty(currentCircleViews{t})
%             viewField = currentCircleViews{t};
%             P_final = viewField(1:4,:);
%             F_final = viewField(5:8,:);
%             visualizeViewField(P_final, F_final);
%             visualizeNormalVector((P_final+F_final)/2, 'k');
%         end
%     end
%      currentCircleViews =allSavedViews{6} ;
%         for t = 1:2
%         if ~isempty(currentCircleViews{t})
%             viewField = currentCircleViews{t};
%             P_final = viewField(1:4,:);
%             F_final = viewField(5:8,:);
%             visualizeViewField(P_final, F_final);
%             visualizeNormalVector((P_final+F_final)/2, 'k');
%         end
%        end


%  visualizeViewField(J(1:4,:), J(5:8,:));
%  visualizeViewField(A(1:4,:), A(5:8,:));
% visualizeViewField(currVF(1:4,:), currVF(5:8,:));
% visualizeViewField(closestVF(1:4,:), closestVF(5:8,:));
%  visualizeViewField(adjustedVF(1:4,:), adjustedVF(5:8,:));
%  visualizeViewField(maybe_new(1:4,:), maybe_new(5:8,:));
% visualizeViewField(NadjustedVF(1:4,:), NadjustedVF(5:8,:));


function maybe_new = adjustViewfield(fv, currVF, prevCircleViews, faces, vertices, m_step, tolerance)
    % 设置默认参数
    if nargin < 7
        m_step = 0.025;
        tolerance = 1e-6;
    end
    
    % 验证输入参数
    if isempty(currVF) || isempty(prevCircleViews) || isempty(faces) || isempty(vertices)
        error('Input不能为Empty');
    end
    
    try
        % 对齐视场域
        [adjustedVF, closestVF] = alignViewfield(currVF, prevCircleViews, 1.1);
    catch
        error('alignViewfield函数调用失败');
    end
    
    % 计算可见性和体积
    [vp, vf] = caiyang(adjustedVF(1:4,:), adjustedVF(5:8,:), faces, vertices);
    
    % 计算X
    X = mean(adjustedVF(1:4,:), 1);
    
    % 获取模型在X处的法向量和面索引
    [n, idx] = getModelNormalAt(X, fv);
    
    % 获取对应的三个顶点
    faceVertices = vertices(faces(idx, :) ,:);
    if size(faceVertices,1) ~= 3
        error('获取面顶点失败，索引超出范围');
    end
    A = faceVertices(1,:);
    B = faceVertices(2,:);
    C = faceVertices(3,:);
    
    % 生成金字塔状视场域
    try
        [P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);
    catch
        error('viewfieldPyrCuboid函数调用失败');
    end
    maybe = [P1; P2; P3; P4; F1; F2; F3; F4];
    
    % 计算参考方向和当前方向
    g_ref = closestVF(4,:)-closestVF(3,:);
    g_ref = g_ref(:,1:2);
    g_ref = g_ref / norm(g_ref);
    
    v_current = P2 - P1;
    v_current = v_current(:,1:2);
    v_current = v_current / norm(v_current);
    
    % 计算旋转角度
    cos_theta = dot(v_current, g_ref);
    theta_rad = acos(cos_theta);
    theta_deg = theta_rad; % 保持弧度，根据需要可转为度
    
    % 旋转中心和旋转轴向量
    rotationCenter = mean(maybe, 1);
    long_vec = mean(maybe(1:4,:), 1) - mean(maybe(5:8,:), 1);
    axis_vec = long_vec / norm(long_vec);
    
    % 旋转视场域顶点
    maybe_new = rotatePoints(maybe, rotationCenter, axis_vec, theta_deg);
    
    % 验证并调整
    [vp1, vf1] = caiyang(maybe_new(1:4,:), maybe_new(5:8,:), faces, vertices);
    n_self = mean(maybe(1:4,:),1) -mean(maybe(5:8,:),1);
    n_self=n_self/norm(n_self);
    m = 0;
    while vp1 < 0.99 && vf1 < tolerance
        % 平移调整
        maybe_new = maybe_new + m * n_self;
        % 更新参数
        [vp1, vf1] = caiyang(maybe_new(1:4,:), maybe_new(5:8,:), faces, vertices);
        m = m + m_step;
        % 防止无限循环
        if m > 100
            warning('调整过程超过步数限制，停止');
            break;
        end
    end
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