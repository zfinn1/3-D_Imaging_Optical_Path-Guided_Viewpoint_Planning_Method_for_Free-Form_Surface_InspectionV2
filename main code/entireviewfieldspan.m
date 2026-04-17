clear;
% close all;
clc;

% 读取 STL 文件及数据
stlFile = '111.stl';
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;

initialface = 2478;
% 选取一个面片生成视场区域
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);

[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 3, 30);

% 计算参考平面和远平面（可选，用于调试平面方程）
[a,b,c,d]   = compute_plane_coeffs(P1, P2, P3);
[a1,b1,c1,d1] = compute_plane_coeffs(F1, F2, F3);

theta_deg = 30;
theta_rad = deg2rad(theta_deg);

% 选择近面一条边作为旋转轴，这里选取 P4-P3
axis_vec = P4 - P3;
axis_vec = axis_vec / norm(axis_vec);

% 构造旋转矩阵（Rodrigues 公式）
K = [  0       -axis_vec(3)  axis_vec(2);
      axis_vec(3)   0       -axis_vec(1);
     -axis_vec(2)  axis_vec(1)    0     ];
R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);

r1=(P4+P3)/2;
% 对远面顶点进行旋转：注意这里以 P1 作为旋转基点（可根据需要调整）
% F1_new = r1 + R * (F1(:) - r1(:));
% F2_new = r1 + R * (F2(:) - r1(:));
% F3_new = r1 + R * (F3(:) - r1(:));
% F4_new = r1 + R * (F4(:) - r1(:));
F1_new = r1 + R * (F1(:) - r1);
F2_new = r1 + R * (F2(:) - r1);
F3_new = r1 + R * (F3(:) - r1);
F4_new = r1 + R * (F4(:) - r1);

figure;
hold on; axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');

% 绘制参考三角形
fill3([A(1) B(1) C(1)], [A(2) B(2) C(2)], [A(3) B(3) C(3)], 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'k');

% 绘制近面正方形
fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);

% 绘制原始远面正方形
fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);

% 绘制旋转后的远面正方形
fill3([F1_new(1) F2_new(1) F3_new(1) F4_new(1)], [F1_new(2) F2_new(2) F3_new(2) F4_new(2)], [F1_new(3) F2_new(3) F3_new(3) F4_new(3)], 'b', 'FaceAlpha', 0.5);

% 连接近面和远面四条边（仅示意原始远面）
plot3([P1(1) F1(1)], [P1(2) F1(2)], [P1(3) F1(3)], 'k');
plot3([P2(1) F2(1)], [P2(2) F2(2)], [P2(3) F2(3)], 'k');
plot3([P3(1) F3(1)], [P3(2) F3(2)], [P3(3) F3(3)], 'k');
plot3([P4(1) F4(1)], [P4(2) F4(2)], [P4(3) F4(3)], 'k');

% 绘制视点
plot3(P(1), P(2), P(3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

% 绘制四棱锥（连接视点与远面顶点）
fill3([P(1) F1(1) F2(1)], [P(2) F1(2) F2(2)], [P(3) F1(3) F2(3)], 'y', 'FaceAlpha', 0.5);
fill3([P(1) F2(1) F3(1)], [P(2) F2(2) F3(2)], [P(3) F2(3) F3(3)], 'y', 'FaceAlpha', 0.5);
fill3([P(1) F3(1) F4(1)], [P(2) F3(2) F4(2)], [P(3) F3(3) F4(3)], 'y', 'FaceAlpha', 0.5);
fill3([P(1) F4(1) F1(1)], [P(2) F4(2) F1(2)], [P(3) F4(3) F1(3)], 'y', 'FaceAlpha', 0.5);

view(3);

%% 添加顶点标号

% 标注视点
text(P(1), P(2), P(3), '  P', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');

% 标注近面顶点
text(P1(1), P1(2), P1(3), '  P1', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
text(P2(1), P2(2), P2(3), '  P2', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
text(P3(1), P3(2), P3(3), '  P3', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
text(P4(1), P4(2), P4(3), '  P4', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');

% 标注原始远面顶点
text(F1(1), F1(2), F1(3), '  F1', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F2(1), F2(2), F2(3), '  F2', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F3(1), F3(2), F3(3), '  F3', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F4(1), F4(2), F4(3), '  F4', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');

% 标注旋转后的远面顶点
text(F1_new(1), F1_new(2), F1_new(3), '  F1_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F2_new(1), F2_new(2), F2_new(3), '  F2_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F3_new(1), F3_new(2), F3_new(3), '  F3_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F4_new(1), F4_new(2), F4_new(3), '  F4_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');

%% 辅助函数
function [A, B, C, D] = compute_plane_coeffs(a, b, c)
    % a, b, c: 三角形顶点的坐标 [x, y, z]
    
    % 向量 AB 和 AC
    AB = b - a;
    AC = c - a;
    
    % 计算法向量 n = [A, B, C]
    n = cross(AB, AC);
    
    % 提取法向量分量
    A = n(1);
    B = n(2);
    C = n(3);
    
    % 计算 D，使得平面方程为 Ax + By + Cz + D = 0
    D = -(A * a(1) + B * a(2) + C * a(3));
    
    fprintf('平面方程: %fx + %fy + %fz + %f = 0\n', A, B, C, D);
end
