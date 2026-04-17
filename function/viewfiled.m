clear;
close all;
clc;

stlFile = 'G.stl';
model = stlread(stlFile); % 使用 stlread 函数加载 STL 文件，获取模型的几何数据
vertices = model.Points; % 提取模型的顶点坐标（点云数据）
faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）

tp1=vertices(faces(2500,1),:);
tp2=vertices(faces(2500,2),:);
tp3=vertices(faces(2500,3),:);
%viewfield生成选中面片的视场区域以及各个顶点的坐标
[P1,P2,P3,P4,P]=viewfield(tp1,tp2,tp3);

d  = (P2 - P);
d  = d / norm(d);  % 单位化

%% 1. 计算每个面片的中心点
faceCenters = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) / 3;

%% 2. 计算每个中心点到棱线的距离
% 对于每个面片，计算 (C - P0)
vecs = faceCenters - repmat(P, size(faceCenters,1), 1);
% 计算投影长度，注意：dot运算后需沿行向量取结果
projLengths = dot(vecs, repmat(d, size(vecs,1),1), 2);
% 计算棱线上最近点
projPoints = repmat(P, size(faceCenters,1), 1) + projLengths .* repmat(d, size(vecs,1), 1);
% 距离
distances = sqrt(sum((faceCenters - projPoints).^2, 2));

% 设置阈值：根据模型尺度设定一个合适的阈值
threshold = 1;  
candidateIdx = find(distances < threshold);
fprintf('候选面片数量：%d\n', numel(candidateIdx));


%compute_plane_coeffs生成目标面片的面方程
a=vertices(faces(candidateIdx(1),1),:);
b=vertices(faces(candidateIdx(1),2),:);
c=vertices(faces(candidateIdx(1),3),:);
[A, B, C, D] = compute_plane_coeffs(a, b, c);

%line_plane_intersection处理各个棱线与目标面片的交点，输入顶点坐标，输出交点坐标
intersection_point = line_plane_intersection(P, P2, [A,B,C,D]);

isPointInTriangle3D(a,b,c,intersection_point);



% 绘制三角形
figure;
fill3([a(1), b(1), c(1)], [a(2), b(2), c(2)], [a(3), b(3), c(3)], 'r');
hold on;
% 绘制交点
scatter3(intersection_point(1), intersection_point(2), intersection_point(3), 'b', 'filled');
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');


% 绘制底面
fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'g', 'FaceAlpha', 0.5);


% % 绘制四个侧面
fill3([P1(1) P2(1) P(1)], [P1(2) P2(2) P(2)], [P1(3) P2(3) P(3)], 'g', 'FaceAlpha', 0.5); % P1-P2-P
fill3([P2(1) P3(1) P(1)], [P2(2) P3(2) P(2)], [P2(3) P3(3) P(3)], 'b', 'FaceAlpha', 0.5); % P2-P3-P
fill3([P3(1) P4(1) P(1)], [P3(2) P4(2) P(2)], [P3(3) P4(3) P(3)], 'y', 'FaceAlpha', 0.5); % P3-P4-P
fill3([P4(1) P1(1) P(1)], [P4(2) P1(2) P(2)], [P4(3) P1(3) P(3)], 'black', 'FaceAlpha', 0.5); % P4-P1-P

scatter3(P1(1), P1(2), P1(3), 'k', 'filled');
text(P1(1), P1(2), P1(3), ' P1', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

scatter3(P2(1), P2(2), P2(3), 'k', 'filled');
text(P2(1), P2(2), P2(3), ' P2', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

scatter3(P3(1), P3(2), P3(3), 'k', 'filled');
text(P3(1), P3(2), P3(3), ' P3', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

scatter3(P4(1), P4(2), P4(3), 'k', 'filled');
text(P4(1), P4(2), P4(3), ' P4', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

scatter3(P(1), P(2), P(3), 'k', 'filled');
text(P(1), P(2), P(3), ' P', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
     'FaceColor', 'cyan', 'EdgeColor', 'k'); % 'FaceColor' 为面片的颜色，'EdgeColor' 为边缘的颜色
axis equal; % 设置坐标轴比例，使各轴单位长度相等
title('飞机叶片三角形面片分布');
xlabel('X'); ylabel('Y'); zlabel('Z');

% 
% % 计算直线的方向向量
% d = P - P2;
% 
% 
% 
% % 画无限延长的直线
% t = -10:0.1:10;  % 参数 t 的范围，调整范围以获得更长的直线
% line_coords = P2 + t' * d;  % 直线的坐标
% 
% % 绘制直线
% plot3(line_coords(:,1), line_coords(:,2), line_coords(:,3), 'r-', 'LineWidth', 2);
% 
% % 标注点 P1 和 P
% hold on;
% scatter3(P1(1), P1(2), P1(3), 'bo', 'filled'); % 绘制 P1 点
% text(P1(1), P1(2), P1(3), ' P1', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
% scatter3(P(1), P(2), P(3), 'go', 'filled'); % 绘制 P 点
% text(P(1), P(2), P(3), ' P', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');






