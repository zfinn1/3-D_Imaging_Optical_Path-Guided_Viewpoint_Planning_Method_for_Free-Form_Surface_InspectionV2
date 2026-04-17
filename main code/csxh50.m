clc;
clear; 
tic
diary('output.txt');
% 读取 STL 模型并获取投影点
fv = stlread('G:\model2_youduanmian.stl');
stl_file = 'G:\model2_youduanmian.stl';
vertices = fv.Points;
faces = fv.ConnectivityList;
xy_vertices = vertices(:, 1:2);
kdtree = buildKDTreeForTriangles(faces, vertices);
% 计算非凸边界（可以调整因子）
k = boundary(xy_vertices(:,1), xy_vertices(:,2), 0.8);
boundary_points = xy_vertices(k, :);  % 获取边界点坐标

scatter(xy_vertices(:,1), xy_vertices(:,2), 10, 'blue', 'filled'); % 原始点集（蓝色）
hold on;
plot(boundary_points(:,1), boundary_points(:,2), 'r-', 'LineWidth', 2);   % 边界线（红色连线）
plot(boundary_points(1,1), boundary_points(1,2), 'go', 'MarkerSize', 10); % 起点（绿色圆圈）
plot(boundary_points(14,1), boundary_points(14,2), 'mo', 'MarkerSize', 10); % 第14点（品红圆圈）
title('STL投影点集边界');
xlabel('X坐标');
ylabel('Y坐标');
legend('原始点', '边界线', '起点 (k(1))', '切线起点 (k(14))');
grid on;
hold off;

 fprintf('多圈层旋转结束。\n');

% 选择一个边界点作为直线起点（这里选 k 中的第一个点）
start_point = xy_vertices(k(14), :);

% 选择另一个边界点确定直线方向（例如这里取 k 中的第 3 个点）
if length(k) > 2
    next_index = k(3);
else
    error('边界点不足以确定方向');
end
next_point = xy_vertices(next_index, :);

% 计算切向量并归一化
tangent = next_point - start_point;
tangent = tangent / norm(tangent);

% 定义直线长度（正方形边长）
line_length = 10;
% 计算直线终点（在 xy 平面上，z=0）
end_point = start_point + line_length * tangent;

% 构造正方形的 4 个顶点（初始在 xy 平面上，即 z=0）
V2 = [start_point, 0];          % 底边起点
V1 = [end_point, 0];            % 底边终点
V4 = [end_point, line_length];  % 顶边终点（沿 z 方向延伸）
V3 = [start_point, line_length];% 顶边起点

% 计算参考点在模型中的 z 坐标
% 这里以正方形底边起点为参考，寻找其在 STL 模型中最近的点
d = sqrt((vertices(:,1) - start_point(1)).^2 + (vertices(:,2) - start_point(2)).^2);
[~, idx] = min(d);
z_surface = vertices(idx, 3);  % 该处的 z 坐标


% 将正方形所有顶点在 z 方向上平移，使得底边位于模型表面附近
V1(3) = z_surface;
V2(3) = z_surface;
% 顶边相对于底边保持相同的高度差（这里为 line_length）
V3(3) = z_surface + line_length;
V4(3) = z_surface + line_length;
X=(V1+V2+V3+V4)/4;
[n_plane,idx]= getModelNormalAt(X, fv);

initialface = idx;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);

maybe=[P1;P2;P3;P4;F1;F2;F3;F4];

v_current = P2 - P1;
v_current = v_current(:,1:2) ;
v_current = v_current / norm(v_current);  % 归一化


% 计算旋转角度（弧度）
cos_theta = dot(v_current, tangent);
theta_rad = acos(cos_theta);



theta_deg = theta_rad ;  % 旋转角度（度）

rotationCenter =mean(maybe,1);
[n, ~] = computePlane(maybe(1,:),maybe(2,:), maybe(3,:));
axis_vec = n/norm(n);

% 旋转所有顶点
maybe_new = rotatePoints(maybe, rotationCenter,axis_vec  , theta_deg);


targetFace = [A; B; C];
[n_ref, ~] = computePlane(A, B,C);
n_ref = n_ref / norm(n_ref);

[savedViews, savedIntersections]=rotatefullcircle3(maybe_new,stl_file,n_ref,10);

%% 第一圈计算好后，结果存储在 savedViews 和 savedIntersections 中
% savedViews：cell 数组，每个 cell 存储一圈中每步的视场域（8个顶点），
% savedIntersections：cell 数组，每个 cell 存储相应步骤的交点数据

% 当前初始法向量（第一圈基于选定面计算）
current_n_ref = n_ref;

% 保存所有圈的结果
numCircles =6;  % 总共3圈（第一圈 + 后续2圈）
allSavedViews = cell(numCircles, 1);
allSavedIntersections = cell(numCircles, 1);

% 第一圈保存结果（假设已经计算好）
allSavedViews{1} = savedViews;
allSavedIntersections{1} = savedIntersections;
nonEmptyIdx = find(~cellfun(@isempty, savedViews), 1, 'last');  % 只返回最后一个非空索引
if isempty(nonEmptyIdx)
    error('上一圈中没有非空的视场数据。');
else
    target_z=mean(savedViews{nonEmptyIdx}(:,3));%给每圈基准视场域一个参考的高度值索引
end

target_circle=10;%假设要转10圈
%% 从第二圈开始循环，每一圈都以上一圈最后一步的视场为基准

 for circle =2:7
%   circle =7;
    fprintf('----- 当前第 %d 圈 -----\n', circle);
    % 从上一圈中取最后一步的视场作为新基准
   prevViews = allSavedViews{circle-1};

     previousViewField = prevViews{1};

 [normal_vector, ~] = computePlane(previousViewField(1,:), previousViewField(2,:), previousViewField(3,:));
   [closest_idx, closest_view] = findClosestViewByZ(prevViews, target_z, normal_vector);
   previousViewField = prevViews{closest_idx};

    % 自动调整视场域：旋转一定角度直到触发相切条件
    [AllPts_prev, P_new, ~] = autoRotateViewfield(previousViewField, stl_file, 0.1, 15, 1, 360, 0.8,0.5 ,2);

    % 若找不到下一个初始视场即代表已经旋转完毕，则退出循环
    if AllPts_prev==previousViewField
            disp(AllPts_prev);
          fprintf('多圈层旋转结束。\n');
        break;
    end   
    % 计算新的法向量：以当前近面前三个点计算平面
    [n_ref_new, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
    current_n_ref = n_ref_new / norm(n_ref_new);


    % 基于更新后的视场和法向量，再执行一圈旋转（这里调用 rotatefullcircle1 函数，可根据需要调整采样步长）
%   [savedViews_current, savedIntersections_current, Q] = rotatefullcircle7(AllPts_prev, stl_file, current_n_ref, 15);
    [savedViews_current, savedIntersections_current] = rotatefullcircle9(AllPts_prev, stl_file, current_n_ref, 15,kdtree);
    % 保存当前圈的结果
    allSavedViews{circle} = savedViews_current;
    allSavedIntersections{circle} = savedIntersections_current;

    
    
end

%% 进行修正间隙和进行最后区域的平移
allSavedViews= smoothTranslateViews(allSavedViews, faces, vertices, 4);
%生成边界视场
% savedEdgeViews=generateEdgeViewfield(stl_file,0.8,5,0.4, 2,1,6,k);
 leftCircle = sweepLeftFromCircle(allSavedViews{6}, stl_file, faces, vertices);

allSavedViews{7}=leftCircle;    
% [AllPts_prev, P_new, ~] = autoRotateViewfield(allSavedViews{6}{1}, stl_file, 0.1, 15, 1, 360, 0.8,0.1 ,2);
%%   kk 
% [savedViews_current, savedIntersections_current] = rotatefullcircle1(AllPts_prev, stl_file, current_n_ref, 15);
    % 保存当前圈的结果
    [AllPts_prev, P_new, ~] = autoRotateViewfield(allSavedViews{6}{1}, stl_file, 0.1, 15, 1, 360, 0.8,0.1 ,2);
%     [AllPts_new, P_final, F_final] = autoRotateViewfield_v2(AllPts, stl_file, epsilon, numSamples, coarse_step, max_rotation, threshold, minthreshold, direction)
    allSavedViews{7} = savedViews_current;
% toc
% disp(['平滑部分运行时间: ',num2str(toc)]);
% 
% diary off;
%% 可视化前两圈
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
for circle = 1:6
    currentCircleViews = allSavedViews{circle};
    for t = 1:length(currentCircleViews)
        viewField = currentCircleViews{t};
        if ~isempty(viewField)
            P_final = viewField(1:4,:); F_final = viewField(5:8,:);
            visualizeViewField(P_final, F_final);
            visualizeNormalVector((P_final + F_final)/2, 'k');
        end
    end
end
axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('多圈旋转生成的视场域');

%% ------- 辅助函数区 --------



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
%     for i = 1:4
%         text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%         text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%     end
%     
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


function [closest_idx, closest_view] = findClosestViewByZ(viewField, target_z, normal_vector)
% 输入：viewField - N×1的cell数组，每个元素是8×3的矩阵
%       target_z - 目标Z坐标（默认50）
%       normal_vector - 参考法向量（3×1向量），用于方向约束
% 输出：closest_idx - 最接近的视场域索引（原始viewField中的索引）
%       closest_view - 最接近的视场域矩阵

    if nargin < 2
        target_z = 50;  % 默认目标Z坐标为50
    end
    
    if nargin < 3 || isempty(normal_vector)
        error('请提供参考法向量normal_vector（3×1向量）');
    end
    
    % 过滤空视场域
    [filtered_viewField, valid_indices] = filterEmptyViews(viewField);
    
    min_diff = inf;
    closest_idx = 0;
    
    % 遍历所有有效视场域
    for i = 1:length(filtered_viewField)
        view = filtered_viewField{i};
        
        % 1. 计算当前视场域的中心Z坐标
        center = mean(view, 1);  % 按行求平均，得到1×3的中心坐标
        center_z = center(3);    % 提取Z坐标
        
       [normal, ~] = computePlane(view(1,:), view(2,:), view(3,:));
       
%         % 确保法向量方向一致性（取与Z轴正方向点积为正的方向）
%         if dot(normal, [0; 0; 1]) < 0
%             normal = -normal;
%         end
        
        % 3. 检查法向量方向约束（与参考向量点积大于0）
        if dot(normal, normal_vector) > 0
            % 计算与目标Z的差值
            diff = abs(center_z - target_z);
            
            % 更新最小差值和索引
            if diff < min_diff
                min_diff = diff;
                closest_idx = i;
            end
        end
    end
    
    % 返回结果（映射回原始viewField中的索引）
    if closest_idx > 0
        closest_view = filtered_viewField{closest_idx};
        closest_idx = valid_indices(closest_idx);  % 转换为原始索引
    else
        closest_view = [];
        closest_idx = [];
    end
end

function [filtered_viewField, valid_indices] = filterEmptyViews(viewField)
% 输入：viewField - N×1的cell数组，可能包含空矩阵
% 输出：filtered_viewField - 过滤后的非空cell数组（N_valid×1）
%       valid_indices - 有效数据的原始索引

    valid_indices = [];
    filtered_viewField = {};
    
    for i = 1:length(viewField)
        % 检查当前元素是否为非空的8×3矩阵
        if ~isempty(viewField{i}) && size(viewField{i},1)==8 && size(viewField{i},2)==3
            filtered_viewField{end+1} = viewField{i};
            valid_indices(end+1) = i;
        else
            disp(['警告：第', num2str(i), '个视场域为空或尺寸不符，已排除']);
        end
    end
end






