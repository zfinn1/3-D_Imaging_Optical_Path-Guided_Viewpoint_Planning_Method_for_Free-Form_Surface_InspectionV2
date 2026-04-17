clear;
close all;
clc;


% 已知底面顶点坐标

x1=0;
y1=0;
z1=0;

% x2=5*sqrt(2);
% y2=-5*sqrt(2);
% z2=0;
x2=0;
y2=10;
z2=0;


x3=10;
y3=0;
z3=0;

x4=10;
y4=10;
z4=0;

P1 = [x1, y1, z1];
P2 = [x2, y2, z2];
P3 = [x3, y3, z3];
P4 = [x4, y4, z4];





% 高度 h
h = 30; % 例如

% 计算底面中心
x_c = mean([P1(1), P2(1), P3(1), P4(1)]);
y_c = mean([P1(2), P2(2), P3(2), P4(2)]);
z_c = mean([P1(3), P2(3), P3(3), P4(3)]);

% 计算底面法向量 n
n = cross(P3 - P1, P2 - P1);
n = n / norm(n);

% 计算顶点坐标 V
V = [x_c, y_c, z_c] + h * n;

% 定义底面和侧面
faces = [
    1, 2, 3, 4;  % 底面
    1, 2, 5, 5;  % 面1
    2, 3, 5, 5;  % 面2
    3, 4, 5, 5;  % 面3
    4, 1, 5, 5   % 面4
];

% 将底面和顶点的坐标合并
vertices = [P1; P2; P3; P4; V];

% 使用 patch 绘制四棱锥
figure;
patch('Vertices', vertices, 'Faces', faces, ...
      'FaceColor', 'cyan', 'EdgeColor', 'black', 'FaceAlpha', 0.5);
hold on;

% 标注顶点
scatter3(V(1), V(2), V(3), 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
scatter3(vertices(1:4,1), vertices(1:4,2), vertices(1:4,3), 'filled');

% 设置图形参数
xlabel('X'); ylabel('Y'); zlabel('Z');
title('正四棱锥的可视化');
grid on; axis equal; view(3);

L1 = norm(V - P1);
L2 = norm(V - P2);
L3 = norm(V - P3);
L4 = norm(V - P4);

% 输出棱线长度
disp('棱线长度:');
fprintf('L1 (V to P1): %.2f\n', L1);
fprintf('L2 (V to P2): %.2f\n', L2);
fprintf('L3 (V to P3): %.2f\n', L3);
fprintf('L4 (V to P4): %.2f\n', L4);


