clear;
close all;
clc;

% 读取 STL 文件及数据
stlFile = 'C:\Users\86132\Desktop\c\111.stl';
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

% 显示结果
for i = 1:length(intersections)
    fprintf('射线 P -> P%d: 面片索引 = %d, t = %.3f\n', i, intersections(i).visibleFace, intersections(i).best_t);
end

% 可视化
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
hold on;
% 绘制视点
scatter3(P(1), P(2), P(3), 100, 'm', 'filled');
text(P(1), P(2), P(3), '  P', 'FontSize', 12);
% 绘制视场底面（四边形）

%   fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'g', 'FaceAlpha', 0.5);
    fill3([P1(1) P2(1) P(1)], [P1(2) P2(2) P(2)], [P1(3) P2(3) P(3)], 'g', 'FaceAlpha', 0.5);
    fill3([P2(1) P3(1) P(1)], [P2(2) P3(2) P(2)], [P2(3) P3(3) P(3)], 'b', 'FaceAlpha', 0.5);
    fill3([P3(1) P4(1) P(1)], [P3(2) P4(2) P(2)], [P3(3) P4(3) P(3)], 'y', 'FaceAlpha', 0.5);
    fill3([P4(1) P1(1) P(1)], [P4(2) P1(2) P(2)], [P4(3) P1(3) P(3)], 'k', 'FaceAlpha', 0.5);
fill3([tp1(1) tp2(1) tp3(1)], [tp1(2) tp2(2) tp3(2)], [tp1(3) tp2(3) tp3(3)], 'r', 'FaceAlpha', 0.5);

% 定义颜色数组
colors = ['r','b','y','k'];
for i = 1:length(intersections)
    if intersections(i).visibleFace ~= -1
        % 绘制交点
        scatter3(intersections(i).visibleIntersection(1), intersections(i).visibleIntersection(2), intersections(i).visibleIntersection(3), 50, colors(i), 'filled');
        % 绘制目标面片（以半透明方式显示）
        tri = intersections(i).triangle;
        fill3([tri(1,1) tri(2,1) tri(3,1)], [tri(1,2) tri(2,2) tri(3,2)], [tri(1,3) tri(2,3) tri(3,3)], colors(i), 'FaceAlpha', 0.6);
    end
end

point1=(intersections(1).visibleIntersection+intersections(2).visibleIntersection)/2;
point2=(intersections(3).visibleIntersection+intersections(4).visibleIntersection)/2;
% 生成直线上两个端点的坐标数组
X = [point1(1), point2(1)];
Y = [point1(2), point2(2)];
Z = [point1(3), point2(3)];

% 绘制直线

plot3(X, Y, Z, 'LineWidth', 2, 'Color', 'b');  % 使用 plot3 绘制 3D 直线
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('视场区域及四条射线交点和目标面片');
hold off;
