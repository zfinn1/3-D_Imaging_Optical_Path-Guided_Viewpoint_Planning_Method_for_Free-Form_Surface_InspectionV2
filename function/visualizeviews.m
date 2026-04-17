% 读取STL模型（只需要读取一次）
model = stlread('C:\Users\86132\Desktop\c\111.stl');
vertices = model.Points;
faces = model.ConnectivityList;
kdTree = buildKDTreeForTriangles(faces, vertices);

% 获取视场域数量
numViewFields = size(allSavedViews{1}, 1);%获取要可视化的视场域圈层的非空数量

% 创建图形窗口
figure;
hold on;

% 绘制STL模型（只需要绘制一次）
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
k=allSavedViews{1};
% 循环处理每个视场域
for i = 1:numViewFields 
    % 从视场域集合中获取当前视场域数据
    % 假设allSavedViews的每个元素包含P_new和F_new
    t=k{i};
    if ~isempty(t)
    P_new =t(1:4,:);  % 近平面点
    F_new =t(5:8,:);   % 远平面点
    
    % 提取四个点
    P1 = P_new(1,:);
    P2 = P_new(2,:);
    P3 = P_new(3,:);
    P4 = P_new(4,:);
    F1 = F_new(1,:);
    F2 = F_new(2,:);
    F3 = F_new(3,:);
    F4 = F_new(4,:);
    
    % 计算平面参数
    [n, d] = computePlane(P1, P2, P3);
    
    % 计算中点
    I1 = (P1 + F1) / 2;
    I2 = (P2 + F2) / 2;
    I3 = (P3 + F3) / 2;
    I4 = (P4 + F4) / 2;
    
    % 计算视场中心（基于当前视场域）
    P = mean([P_new; F_new], 1) + n*28;  % 基于当前视场域计算中心
    
    % 圆柱参数（可根据需要为每个视场域设置不同参数）
    h_base  = 4;   % 大圆柱高度
    r_base  = 1.5; % 大圆柱底部半径
    h_neck  = 2;   % 小圆柱高度
    r_neck  = 0.5; % 小圆柱半径
    N       = 40;  % 分辨率
    
    % 大圆柱
    [XB0,YB0,ZB0] = cylinder([r_base r_base], N);
    ZB0 = ZB0 * h_base;
    
    % 小圆柱
    [XN0,YN0,ZN0] = cylinder([r_neck r_neck], N);
    ZN0 = ZN0 * h_neck;
    
    % 旋转轴为 v × n，角度为 arccos(v·n)
    v = [0;0;-1];
    axis_rot = cross(v, n');
    if norm(axis_rot) < 1e-6
        R = eye(3);
    else
        axis_rot = axis_rot / norm(axis_rot);
        theta = acos(dot(v, n'));
        K = [      0, -axis_rot(3),  axis_rot(2);
             axis_rot(3),       0, -axis_rot(1);
            -axis_rot(2),  axis_rot(1),       0 ];
        R = eye(3) + sin(theta)*K + (1-cos(theta))*(K*K);
    end
    
    % 合并顶点
    VB = [XB0(:), YB0(:), ZB0(:)];  % base cylinder verts
    VN = [XN0(:), YN0(:), ZN0(:)+h_base]; % neck verts, 平移到大圆柱顶端
    
    % 旋转
    VB_rot = (R * VB')';
    VN_rot = (R * VN')';
    
    % 计算将 optical_center_local 移动到 P 所需的平移向量
    optical_center_local = R * [0; 0; h_base];  % 小圆柱底部旋转后的真实位置
    T = P(:) - optical_center_local;
    
    % 执行平移
    VB_rot = VB_rot + T';
    VN_rot = VN_rot + T';
    
    % 重塑为 surface 所需格式
    XB = reshape(VB_rot(:,1), size(XB0));
    YB = reshape(VB_rot(:,2), size(YB0));
    ZB = reshape(VB_rot(:,3), size(ZB0));
    XN = reshape(VN_rot(:,1), size(XN0));
    YN = reshape(VN_rot(:,2), size(YN0));
    ZN = reshape(VN_rot(:,3), size(ZN0));
    
    % 为每个视场域设置不同的颜色（使用HSV颜色空间）
    color = hsv(numViewFields);
    faceColor = color(i,:);
    
    % 绘制当前视场域的圆柱体模型
    surf(XB,YB,ZB, 'FaceColor', faceColor, 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    surf(XN,YN,ZN, 'FaceColor', faceColor, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
    
    % 绘制视场中心点
    plot3(P(1),P(2),P(3),'ro','MarkerSize',8,'LineWidth',2);
    
    % 计算并可视化交点
    Intersections = computeIntersectionsWithKD(P_new, model, 1e-2, kdtree, 8);
    if ~isempty(Intersections)
        visualizePoints(Intersections);
    end
    
    % 可视化视场域
    visualizeViewField(P_new, F_new);
    
    % 绘制从P到F的连线（使用与视场域相同的颜色）
    lineColor = faceColor * 0.7; % 稍微暗一点的颜色
    plot3([P(1), F1(1)], [P(2), F1(2)], [P(3), F1(3)], 'Color', lineColor, 'LineWidth', 1.5);
    plot3([P(1), F2(1)], [P(2), F2(2)], [P(3), F2(3)], 'Color', lineColor, 'LineWidth', 1.5);
    plot3([P(1), F3(1)], [P(2), F3(2)], [P(3), F3(3)], 'Color', lineColor, 'LineWidth', 1.5);
    plot3([P(1), F4(1)], [P(2), F4(2)], [P(3), F4(3)], 'Color', lineColor, 'LineWidth', 1.5);
    
    % 为每个视场域添加标签
    text(P(1), P(2)+0.5, P(3)+1.5, sprintf('视点 %d', i), 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
    end
end

% 设置图形属性
xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
title('多视场域可视化');
grid on; 
axis equal; 
view(3);
hold off;
axis off;
% 以下是原代码中的函数定义（保持不变）
function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
%     % 标注点
%     for i = 1:4
%         text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%         text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%     end
end

function visualizePoints(points)
    plot3(points(:,1), points(:,2), points(:,3), 'ro', 'MarkerFaceColor', 'r');
end

function [n, d] = computePlane(P1, P2, P3)
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end

function kdTree = buildKDTreeForTriangles(faces, vertices)
    numTri = size(faces,1);
    centroids = zeros(numTri, 3);
    for i = 1:numTri
        tri = vertices(faces(i,:), :);
        centroids(i,:) = mean(tri, 1);
    end
    kdTree = createns(centroids, 'NSMethod', 'kdtree');
end

