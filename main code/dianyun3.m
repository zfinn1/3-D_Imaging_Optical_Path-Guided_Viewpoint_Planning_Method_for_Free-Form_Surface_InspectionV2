% clear;
% close all;
% clc;
% 
% % 读取飞机叶片模型
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% model = stlread(stlFile); % 使用 stlread 函数加载 STL 文件，获取模型的几何数据
% vertices = model.Points; % 提取模型的顶点坐标（点云数据）
% faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）
% clear;
% close all;
% clc;
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; 
% 读取 STL 文件
model= stlread(stlFile);
vertices = model.Points; % 提取模型的顶点坐标（点云数据）
faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成


[simplifiedFaces, simplifiedVertices] = reducepatch(faces, vertices, 1);
% 计算每个面的法向量
% faceNormals = faceNormal(triangulation(faces, vertices)); 
 faceNormals = faceNormal(triangulation(simplifiedFaces, simplifiedVertices));
% 使用 faceNormal 函数计算每个三角形面的法向量

% 参数设置
viewDistance = 30; % 视点距离，即视点距离每个面中心点的距离

% 为每个面生成视点
viewpoints = []; % 初始化视点存储矩阵，视点以行向量形式存储，每行代表一个视点的 [x, y, z] 坐标
for i = 1:size(simplifiedFaces, 1) % 遍历每个三角面片
    % 获取面中心点
    faceCenter = mean(vertices(faces(i, :), :), 1); 
    % 通过取面片的 3 个顶点的均值，计算出三角面的中心点坐标

    % 生成面法向外的视点
    viewpoint = faceCenter + faceNormals(i, :) * viewDistance; 
    % 根据面法向量的方向和视点距离，计算该面的观察点（沿法向方向延伸）

    % 添加视点
    viewpoints = [viewpoints; viewpoint]; % 将计算的视点坐标添加到视点列表中
end
figure; % 创建一个新的图形窗口
trisurf(simplifiedFaces, simplifiedVertices(:,1), simplifiedVertices(:,2), simplifiedVertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k'); 
% 绘制飞机叶片的三角网格模型
hold on; % 保持当前图形，添加视点数据
numClusters = 2;
[idx, viewCenters] = kmeans(viewpoints, numClusters);
for i=1:numClusters
    scatter3(viewCenters(:,1), viewCenters(:,2), viewCenters(:,3), 80, 'b', 'filled'); % 视点
end

for i = 1:numClusters
    pv = viewCenters(i, :);
    viewDirs(i, :) = generateViewDirection(pv, faceCenters, a, 30, 30.41);
    
end
scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 5, 'r', 'filled'); 
% for i=1:numClusters
% pv = viewCenters(i, :);
% dir = viewDirs(i, :);
% quiver3(pv(1), pv(2), pv(3), 10*dir(1), 10*dir(2), 10*dir(3), 'r', 'LineWidth', 2); % 朝向
% end

axis equal; grid on;
hold off;
% % 可选：计算每个聚类中心的朝向（朝向平均观察目标面心）
% viewDirs = zeros(numClusters, 3);
% for i = 1:numClusters
%     memberCenters = faceCenters(idx == i, :);
%     dirVec = mean(memberCenters - viewCenters(i,:), 1);
%     viewDirs(i, :) = dirVec / norm(dirVec);
% end

% boxDepth = 1;        % 视场域长度（可调）
% w = 10; h = 10; d = 30;  % 视场底面参数
% 
% viewBoxes = cell(numViewpoints, 1);  % 初始化 cell 数组
% 
% for i = 1:100
%     pv = viewpoints(i, :);
%     dir = viewDirs(i, :);
% 
%     % 计算视场底面矩形
%     corners = getViewRectangle(pv, dir, w, h, d);
%     
%     % 构建长方体视场域（向 view_dir 反方向拉 boxDepth）
%     boxVertices = buildViewBox(corners, dir, boxDepth);
%     
%     % （可选）确保顺时针顺序一致
%     boxVertices(1:4,:) = flipud(boxVertices(1:4,:));
%     boxVertices(5:8,:) = flipud(boxVertices(5:8,:));
%     maybe_new=boxVertices;
% % maybe_new=adjustVdthroughN(boxVertices,faces,vertices);
%     % 存入 cell 数组
%     viewBoxes{i} = maybe_new;
% end

% for i=1:100
%     maybe_new=viewBoxes{i};
%     visualizeViewField(maybe_new(1:4,:), maybe_new(5:8,:));
% end
function corners = getViewRectangle(pv, view_dir, width, height, distance)
% 输入：
% pv         - 视点位置 [1×3]
% view_dir   - 观察方向（单位向量）[1×3]
% width      - 正方形宽度（沿 X 方向）
% height     - 正方形高度（沿 Z 方向）
% distance   - 相机与底面之间的距离

% 输出：
% corners - 4×3 的矩阵，四个角点的坐标（顺时针排列）

% 首先确定相机前方矩形中心位置
center = pv + distance * view_dir;

% 固定使用 X 轴和 Z 轴作为平面基向量（注意需要正交于 view_dir）
forward = view_dir / norm(view_dir);  % 单位向量

    % 若 forward 接近 [0 1 0]，说明与 up 共线，需要特殊处理
    world_up = [0, 1, 0];
    if abs(dot(forward, world_up)) > 0.99
        world_up = [0, 0, 1];  % 避免退化，改用另一个参考方向
    end

    right = cross(world_up, forward);
    right = right / norm(right);

    up = cross(forward, right);
    up = up / norm(up);
% 投影平面上构建矩形的四个角点
half_w = width / 2;
half_h = height / 2;

% 四个角点（中心点 ± x ± z）
corners = [ center + half_w*right + half_h*up;
            center - half_w*right + half_h*up;
            center - half_w*right - half_h*up;
            center + half_w*right - half_h*up ];
end
function boxVertices = buildViewBox(corners, view_dir, depth)
% 根据底面矩形和观察方向构造视场域的矩形长方体（六个面）
% 输入：
%   corners   - 4x3 底面点，顺时针（右上，左上，左下，右下）
%   view_dir  - 观察方向（单位向量）
%   depth     - 向前延伸的长度
% 输出：
%   boxVertices - 8x3 矩阵，分别是底面和顶面的8个角点

    view_dir = view_dir / norm(view_dir);
    
    % 顶面 = 底面 + 方向 * depth
    top = corners - depth * view_dir;
    
    % 输出：前4行为底面，后4行为顶面（顺时针顺序）
    boxVertices = [corners; top];
end
function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
        % 标注点
%     for i = 1:4
%         text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%         text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%     end
    
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end
% 可视化生成的视点
function view_dir = generateViewDirection(pv, pts, a, fmin, fmax)
    % 计算所有面中心与视点的差值向量
    diff_vec = pts - pv;
    % 计算每个向量的欧氏距离
    dists = sqrt(sum(diff_vec.^2, 2));
    % 过滤掉不在指定距离区间内的点
    valid_idx = (dists > fmin) & (dists < fmax);
    if ~any(valid_idx)
        view_dir = [0, 0, 1];
        return;
    end
    valid_diff = diff_vec(valid_idx, :);
    valid_dists = dists(valid_idx);
    % 计算贡献，每个贡献为 a * 向量 / (距离^3)
    contributions = a * valid_diff ./ (valid_dists.^3);
    sum_vector = sum(contributions, 1);
    norm_sum = norm(sum_vector);
    if norm_sum == 0
        view_dir = [0, 0, 1];
    else
        view_dir = sum_vector / norm_sum;
    end
end
% 
% 
% % 绘制视点（调整大小）
% 

