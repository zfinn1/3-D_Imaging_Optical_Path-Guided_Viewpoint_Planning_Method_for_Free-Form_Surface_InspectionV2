clear;
close all;
clc;

% 假设这是上次视场域计算得到的四个交点
% 这里给出示例数据（你实际中会由你的程序计算得到）
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
[P1, P2, P3, P4, P] = viewfield(tp1, tp2, tp3);
% 假设我们选取 P3 和 P4 作为生成新视场域的基边
currentViewpoint = P;
currentIntersections = [P1; P2; P3; P4];

% 设置求交候选阈值
threshold = 2;

% 调用 computeAllRayIntersections 检查初始视场交点
intersections = computeAllRayIntersections(currentViewpoint, currentIntersections, vertices, faces, threshold);
for i = 1:length(intersections)
    fprintf('射线 P -> P%d: 面片索引 = %d, t = %.3f\n', i, intersections(i).visibleFace, intersections(i).best_t);
end

% 下面开始自动更新（生成新的视场域）
% 假设我们希望固定交点 3 和 4 不变，即 fixedIndices = [3,4]
fixedIndices = [3, 4];
% 定义平面内平移向量 delta（例如向 x 方向平移 2 cm）
delta = [2, 0, 0];
% 定义新视点相对于新底面中心沿参考法向的偏移距离 d_offset（例如 10 cm）
d_offset = 10;

% 调用 updateViewField 生成新视场域
[newViewpoint, newIntersections] = generateNextViewFieldFromEdge(currentViewpoint, currentIntersections, fixedIndices, delta, d_offset, vertices, faces, threshold);

% 显示新视点与新交点
fprintf('新视点: [%.2f, %.2f, %.2f]\n', newViewpoint);
disp('新交点:');
disp(newIntersections);

% 可视化新视场域
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
hold on;
% 绘制新视点
scatter3(newViewpoint(1), newViewpoint(2), newViewpoint(3), 100, 'm', 'filled');
text(newViewpoint(1), newViewpoint(2), newViewpoint(3), '  NewViewpoint','FontSize',12);
% 绘制新交点
scatter3(newIntersections(:,1), newIntersections(:,2), newIntersections(:,3), 100, 'r', 'filled');
% 绘制从新视点到每个交点的连线
for i = 1:4
    plot3([newViewpoint(1), newIntersections(i,1)], ...
          [newViewpoint(2), newIntersections(i,2)], ...
          [newViewpoint(3), newIntersections(i,3)], 'k-', 'LineWidth', 2);
end
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('更新后的视场域');
hold off;
