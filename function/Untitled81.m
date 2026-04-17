% % 定义三角形的三个顶点 A, B, C
% A = [0, 0, 0];
% B = [1, 0, 0];
% C = [0, 1, 0];
% 
% % 生成七个点
% 
% % 第一个点：距离顶点 A 最近
% point1 = A - [0.1, 0.1, 0.1];
% 
% % 第二个点：距离顶点 B 最近
% point2 = B + [0.1, 0.1, 0.1];
% 
% % 第三个点：距离顶点 C 最近
% point3 = C + [0.1, 0.1, 0.1];
% 
% % 第四个点：投影在 AB 上
% t_AB = 0.2; % 可调整该参数在 0 到 1 之间改变投影位置
% point4 = (1 - t_AB) * A + t_AB * B+[0, 0, 1];
% 
% % 第五个点：投影在 AC 上
% t_AC = 0.4; % 可调整该参数在 0 到 1 之间改变投影位置
% point5 = (1 - t_AC) * A + t_AC * C+[0, 0, 0.1];
% 
% % 第六个点：投影在 BC 上
% t_BC = 0.5; % 可调整该参数在 0 到 1 之间改变投影位置
% point6 = (1 - t_BC) * B + t_BC * C+[0, 0, 0.8];
% 
% % 第七个点：投影到三角形内部
% % 这里使用重心坐标法生成投影在内部的点
% alpha = 0.2;
% beta = 0.3;
% gamma = 1 - alpha - beta;
% point7 = alpha * A + beta * B + gamma * C+[0, 0, -0.5];
% 
% % 将所有点存储在一个矩阵中
% points = [point1; point2; point3; point4; point5; point6; point7];
% 
% % 绘制三角形和生成的点
% figure;
% hold on;
% patch([A(1), B(1), C(1)], [A(2), B(2), C(2)], [A(3), B(3), C(3)], 'b', 'FaceAlpha', 0.2); % 绘制三角形
% scatter3(points(:, 1), points(:, 2), points(:, 3), 50, 'r', 'filled'); % 绘制点
% 
% % 为七个生成的点添加标号
% for i = 1:size(points, 1)
%     text(points(i, 1), points(i, 2), points(i, 3), num2str(i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 14);
% end
% 
% % 为三角形的三个顶点添加标号
% vertex_labels = {'A', 'B', 'C'};
% vertices = [A; B; C];
% for i = 1:size(vertices, 1)
%     text(vertices(i, 1), vertices(i, 2), vertices(i, 3), vertex_labels{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'g', 'FontSize', 14);
% end
% 
% hold off;
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% title('Triangle and Generated Points with All Labels');
% grid on;
 % 定义长方体的顶点
P1 = [0, 0, 0];
P2 = [10, 0, 0];
P3 = [10, 10, 0];
P4 = [0, 10, 0];
F1 = [0, 0, 1];
F2 = [10, 0, 1];
F3 = [10, 10, 1];
F4 = [0, 10, 1];

% 存储所有顶点
vertices = [P1; P2; P3; P4; F1; F2; F3; F4];

% 定义长方体的面
faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];

% 绘制长方体
figure;
patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'b', 'FaceAlpha', 0.2);
axis equal;
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Cuboid with Numbered Vertices and Two - face Grid');

% 为顶点编号
vertex_labels = {'P1', 'P2', 'P3', 'P4', 'F1', 'F2', 'F3', 'F4'};
for i = 1:size(vertices, 1)
    text(vertices(i, 1), vertices(i, 2), vertices(i, 3), vertex_labels{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 14);
end

% 定义网格划分数量
num_divisions = 5; % 可以调整网格划分的数量

% 对底面进行网格划分
x_bottom = linspace(P1(1), P2(1), num_divisions);
y_bottom = linspace(P1(2), P4(2), num_divisions);
[X_bottom, Y_bottom] = meshgrid(x_bottom, y_bottom);
Z_bottom = zeros(size(X_bottom));

% 绘制底面网格线
hold on;
for i = 1:num_divisions
    plot3([X_bottom(i, 1), X_bottom(i, end)], [Y_bottom(i, 1), Y_bottom(i, end)], [Z_bottom(i, 1), Z_bottom(i, end)], 'k');
    plot3([X_bottom(1, i), X_bottom(end, i)], [Y_bottom(1, i), Y_bottom(end, i)], [Z_bottom(1, i), Z_bottom(end, i)], 'k');
end

% 标红底面网格交界点
scatter3(X_bottom(:), Y_bottom(:), Z_bottom(:), 50, 'r', 'filled');

% 对顶面进行网格划分
x_top = linspace(F1(1), F2(1), num_divisions);
y_top = linspace(F1(2), F4(2), num_divisions);
[X_top, Y_top] = meshgrid(x_top, y_top);
Z_top = ones(size(X_top));

% 绘制顶面网格线
for i = 1:num_divisions
    plot3([X_top(i, 1), X_top(i, end)], [Y_top(i, 1), Y_top(i, end)], [Z_top(i, 1), Z_top(i, end)], 'k');
    plot3([X_top(1, i), X_top(end, i)], [Y_top(1, i), Y_top(end, i)], [Z_top(1, i), Z_top(end, i)], 'k');
end

% 标红顶面网格交界点
scatter3(X_top(:), Y_top(:), Z_top(:), 50, 'r', 'filled');
hold off;
    