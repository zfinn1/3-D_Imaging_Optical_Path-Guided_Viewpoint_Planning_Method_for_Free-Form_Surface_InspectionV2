%  a=[0,0,0];
%  b=[0,1,0];
%  c=[1,0,0];
% 
% % 向量 AB 和 AC
%     AB = b - a;
%     AC = c- a;
% 
%     % 计算法向量 n = [A, B, C]，通过叉积获得
%     n = cross(AB, AC);
%     
%     % 提取法向量的分量 A, B, C
%     A = n(1);
%     B = n(2);
%     C = n(3);
% 
%     % 使用点 A 的坐标代入平面方程 Ax + By + Cz + D = 0，求 D
%     D = -(A * a(1) + B * a(2) + C * a(3));
% 
%     % 显示结果
%     fprintf('平面方程: %fx + %fy + %fz + %f = 0\n', A, B, C, D);
% 
% clear;
% close all;
% clc;
% 
% % 读取 STL 文件及数据
% stlFile = 'C:\Users\86132\Desktop\c\111.stl';
% model = stlread(stlFile);
% vertices = model.Points;
% faces = model.ConnectivityList;
% 
% 
% initialface=2478;
% % 选取一个面片生成视场区域
% A = vertices(faces(initialface,1),:);
% B = vertices(faces(initialface,2),:);
% C = vertices(faces(initialface,3),:);
% 
% [P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 3, 28);
% 
% % 假设你已经定义了 A, B, C, nearSide, depth, extra
% 
% [a,b,c,d]=compute_plane_coeffs(P1, P2, P3);
% [a1,b1,c1,d1]=compute_plane_coeffs(F1, F2, F3);
% 
% theta_deg = 5;
% theta_rad = deg2rad(theta_deg);
% 
% % 计算旋转轴的单位向量 d
% d = P4 - P3;
% d = d / norm(d);
% 
% % 构造旋转矩阵（Rodrigues 公式）
% K = [  0      -d(3)   d(2);
%       d(3)     0     -d(1);
%      -d(2)    d(1)    0    ];
% R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
% 
% 
% r1=(P4+P3)/2;
% % 对远面顶点进行旋转：注意这里以 P1 作为旋转基点（可根据需要调整）
% F1_new = r1 + R * (F1(:) - r1);
% F2_new = r1 + R * (F2(:) - r1);
% F3_new = r1 + R * (F3(:) - r1);
% F4_new = r1 + R * (F4(:) - r1);
% 
% figure;
% % trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
% %         'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
% 
% hold on; axis equal; grid on;
% xlabel('X'); ylabel('Y'); zlabel('Z');
% 
% % 绘制参考三角形
% fill3([A(1) B(1) C(1)], [A(2) B(2) C(2)], [A(3) B(3) C(3)], 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'k');
% 
% % 近面正方形
% fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
% 
% % 远面正方形
% fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);
% fill3([F1_new(1) F2_new(1) F3_new(1) F4_new(1)], [F1_new(2) F2_new(2) F3_new(2) F4_new(2)], [F1_new(3) F2_new(3) F3_new(3) F4_new(3)], 'b', 'FaceAlpha', 0.5);
% % 连接近面和远面四条边
% plot3([P1(1) F1(1)], [P1(2) F1(2)], [P1(3) F1(3)], 'k');
% plot3([P2(1) F2(1)], [P2(2) F2(2)], [P2(3) F2(3)], 'k');
% plot3([P3(1) F3(1)], [P3(2) F3(2)], [P3(3) F3(3)], 'k');
% plot3([P4(1) F4(1)], [P4(2) F4(2)], [P4(3) F4(3)], 'k');
% 
% % 侧面四边形
% % fill3([P1(1) P2(1) F2(1) F1(1)], [P1(2) P2(2) F2(2) F1(2)], [P1(3) P2(3) F2(3) F1(3)], 'g', 'FaceAlpha', 0.5);
% % fill3([P2(1) P3(1) F3(1) F2(1)], [P2(2) P3(2) F3(2) F2(2)], [P2(3) P3(3) F3(3) F2(3)], 'g', 'FaceAlpha', 0.5);
% % fill3([P3(1) P4(1) F4(1) F3(1)], [P3(2) P4(2) F4(2) F3(2)], [P3(3) P4(3) F4(3) F3(3)], 'g', 'FaceAlpha', 0.5);
% % fill3([P4(1) P1(1) F1(1) F4(1)], [P4(2) P1(2) F1(2) F4(2)], [P4(3) P1(3) F1(3) F4(3)], 'g', 'FaceAlpha', 0.5);
% 
% % 绘制视点
% plot3(P(1), P(2), P(3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
% % 
% % 连接视点与远面四个顶点，形成四棱锥
% fill3([P(1) F1(1) F2(1)], [P(2) F1(2) F2(2)], [P(3) F1(3) F2(3)], 'y', 'FaceAlpha', 0.5);
% fill3([P(1) F2(1) F3(1)], [P(2) F2(2) F3(2)], [P(3) F2(3) F3(3)], 'y', 'FaceAlpha', 0.5);
% fill3([P(1) F3(1) F4(1)], [P(2) F3(2) F4(2)], [P(3) F3(3) F4(3)], 'y', 'FaceAlpha', 0.5);
% fill3([P(1) F4(1) F1(1)], [P(2) F4(2) F1(2)], [P(3) F4(3) F1(3)], 'y', 'FaceAlpha', 0.5);
% 
% view(3);
% 
% function [A, B, C, D] = compute_plane_coeffs(a, b, c)
%     % a, b, c: 三角形顶点的坐标 [x, y, z]
% 
%     % 向量 AB 和 AC
%     AB = b - a;
%     AC = c - a;
% 
%     % 计算法向量 n = [A, B, C]，通过叉积获得
%     n = cross(AB, AC);
%     
%     % 提取法向量的分量 A, B, C
%     A = n(1);
%     B = n(2);
%     C = n(3);
% 
%     % 使用点 A 的坐标代入平面方程 Ax + By + Cz + D = 0，求 D
%     D = -(A * a(1) + B * a(2) + C * a(3));
% 
%     % 显示结果
%     fprintf('平面方程: %fx + %fy + %fz + %f = 0\n', A, B, C, D);
% end
clear;
close all;
clc;

% 读取 STL 文件及数据
stlFile = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;

% initialface = 3415;
initialface = 2488;
% 选取一个面片生成视场区域
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);

[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 1.5, 28);

% 设定旋转角度（例如5度）
theta_deg =195;
theta_rad = deg2rad(theta_deg);

% % 选择旋转轴为近面边 P3-P4，旋转中心选取 P3
E4 = (P4+F4)/2;
E3 =( P3+F3)/2;
% E4 =P2;
% E3 =P1;
rotationCenter = (E3+E4)/2;
d = (E4 - E3) / norm(E4 - E3);

% 构造旋转矩阵（Rodrigues 公式）
K = [   0      -d(3)   d(2);
      d(3)      0     -d(1);
     -d(2)    d(1)     0    ];
R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);

% 对所有长方体顶点进行旋转
P1_new = rotationCenter + (R*(P1' - rotationCenter'))';
P2_new = rotationCenter + (R*(P2' - rotationCenter'))';
P3_new = rotationCenter + (R*(P3' - rotationCenter'))';  % 理论上P3_new = P3
P4_new = rotationCenter + (R*(P4' - rotationCenter'))';  % 理论上P4_new = P4
F1_new = rotationCenter + (R*(F1' - rotationCenter'))';
F2_new = rotationCenter + (R*(F2' - rotationCenter'))';
F3_new = rotationCenter + (R*(F3' - rotationCenter'))';
F4_new = rotationCenter + (R*(F4' - rotationCenter'))';
P_new= rotationCenter + (R*(P' - rotationCenter'))';
% Pm_new= rotationCenter + (R1*(P' - rotationCenter'))';
%% 可视化原始长方体与旋转后的长方体

figure;
hold on; axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
plot3(P_new(1), P_new(2), P_new(3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
% plot3(Pm_new(1), Pm_new(2), Pm_new(3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
plot3(P(1), P(2), P(3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'y');
% 绘制近面正方形（原始）
h_near = fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
% 绘制远面正方形（原始）
h_far = fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);

% 绘制旋转后的近面与远面
h_near_new = fill3([P1_new(1) P2_new(1) P3_new(1) P4_new(1)], [P1_new(2) P2_new(2) P3_new(2) P4_new(2)], [P1_new(3) P2_new(3) P3_new(3) P4_new(3)], 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'k');
h_far_new  = fill3([F1_new(1) F2_new(1) F3_new(1) F4_new(1)], [F1_new(2) F2_new(2) F3_new(2) F4_new(2)], [F1_new(3) F2_new(3) F3_new(3) F4_new(3)], 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'k');

% 绘制连接近面和远面的边（旋转后的效果）
plot3([P1_new(1) F1_new(1)], [P1_new(2) F1_new(2)], [P1_new(3) F1_new(3)], 'k');
plot3([P2_new(1) F2_new(1)], [P2_new(2) F2_new(2)], [P2_new(3) F2_new(3)], 'k');
plot3([P3_new(1) F3_new(1)], [P3_new(2) F3_new(2)], [P3_new(3) F3_new(3)], 'k');
plot3([P4_new(1) F4_new(1)], [P4_new(2) F4_new(2)], [P4_new(3) F4_new(3)], 'k');

% 标记顶点（旋转后的）
text(P1_new(1), P1_new(2), P1_new(3), '  P1_{new}', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
text(P2_new(1), P2_new(2), P2_new(3), '  P2_{new}', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
text(P3_new(1), P3_new(2), P3_new(3), '  P3_{new}', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
text(P4_new(1), P4_new(2), P4_new(3), '  P4_{new}', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');

text(F1_new(1), F1_new(2), F1_new(3), '  F1_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F2_new(1), F2_new(2), F2_new(3), '  F2_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F3_new(1), F3_new(2), F3_new(3), '  F3_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
text(F4_new(1), F4_new(2), F4_new(3), '  F4_{new}', 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');

% 标记旋转中心和旋转轴
plot3(rotationCenter(1), rotationCenter(2), rotationCenter(3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
text(rotationCenter(1), rotationCenter(2), rotationCenter(3), '  rotationCenter', 'FontSize', 12, 'Color', 'k');

% 绘制旋转轴（从 P3 到 P4，新旧都应不变）
plot3([P3(1) P4(1)], [P3(2) P4(2)], [P3(3) P4(3)], 'm', 'LineWidth', 2);
text(P4(1), P4(2), P4(3), '  P4', 'FontSize', 12, 'Color', 'm', 'FontWeight', 'bold');
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.2);
view(3);
