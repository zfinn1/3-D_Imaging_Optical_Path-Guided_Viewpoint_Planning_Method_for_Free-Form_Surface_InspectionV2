clc; clear; close all;
figure;
hold on; 
% grid on; 
 axis equal;
 axis off;
% xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);
title('Camera Imaging: World, Camera, Image and Pixel CS with Improved Image Plane');

%% ------------------ 1. 绘制世界坐标系 ------------------
% 定义世界坐标系的旋转矩阵，让世界坐标系倾斜
R_world = angle2dcm(pi/6, pi/6, pi/6); 
R_world = R_world'; 

% 绘制世界坐标系的坐标轴
quiver3(0,0,0, 1*R_world(1,1), 1*R_world(2,1), 1*R_world(3,1), 'r', 'LineWidth', 2); % X_w
quiver3(0,0,0, 1*R_world(1,2), 1*R_world(2,2), 1*R_world(3,2), 'g', 'LineWidth', 2); % Y_w
quiver3(0,0,0, 1*R_world(1,3), 1*R_world(2,3), 1*R_world(3,3), 'b', 'LineWidth', 2); % Z_w
% text(1.2*R_world(1,1), 1.2*R_world(2,1), 1.2*R_world(3,1), 'X_w');
% text(1.2*R_world(1,2), 1.2*R_world(2,2), 1.2*R_world(3,2), 'Y_w');
% text(1.2*R_world(1,3), 1.2*R_world(2,3), 1.2*R_world(3,3), 'Z_w');
% text(-0.5,-0.5,-0.5, 'World CS');

%% ------------------ 2. 绘制相机坐标系（Camera CS） ------------------
T_cam = [3; 2; 1];  % 相机原点在世界坐标下的位置
% 让相机坐标系保持正的，使用单位矩阵作为旋转矩阵
R_cam = eye(3);  

% 为了显示清晰，在相机坐标系中使用较大坐标轴（长度 3 个单位）
quiver3(T_cam(1), T_cam(2), T_cam(3), 3*R_cam(1,1), 3*R_cam(2,1), 3*R_cam(3,1), 'r', 'LineWidth', 2); % X_c
quiver3(T_cam(1), T_cam(2), T_cam(3), 3*R_cam(1,2), 3*R_cam(2,2), 3*R_cam(3,2), 'g', 'LineWidth', 2); % Y_c
quiver3(T_cam(1), T_cam(2), T_cam(3), 3*R_cam(1,3), 3*R_cam(2,3), 3*R_cam(3,3), 'b', 'LineWidth', 2); % Z_c
% text(T_cam(1)+3*R_cam(1,1), T_cam(2)+3*R_cam(2,1), T_cam(3)+3*R_cam(3,1), 'X_c');
% text(T_cam(1)+3*R_cam(1,2), T_cam(2)+3*R_cam(2,2), T_cam(3)+3*R_cam(3,2), 'Y_c');
% text(T_cam(1)+3*R_cam(1,3), T_cam(2)+3*R_cam(2,3), T_cam(3)+3*R_cam(3,3), 'Z_c');
% text(T_cam(1)-0.5, T_cam(2)-0.5, T_cam(3)-0.5, 'Camera CS');

%% ------------------ 3. 绘制图像平面坐标系（Image CS） ------------------
focal_length = 1;  % 焦距 f
% 图像平面在相机坐标系中：中心点为 [0; 0; f]
% 转换到世界坐标：image_plane_center = T_cam + R_cam*[0; 0; f]
image_plane_center = T_cam + R_cam * [0; 0; focal_length];

% 定义图像平面尺寸，假设图像平面宽度为 4， 高度为 4
w = 4; h = 4;
% 图像平面四角在图像坐标系下（单位：任意）
img_plane_corners = [ -w/2, -h/2, focal_length;
                       w/2, -h/2, focal_length;
                       w/2,  h/2, focal_length;
                      -w/2,  h/2, focal_length ]';

% 将图像平面四角从相机坐标系转换到世界坐标系
img_plane_corners_world = T_cam + R_cam * img_plane_corners;

% 绘制图像平面（使用 patch 填充，并描边使边界清晰）
patch('XData', img_plane_corners_world(1,:), 'YData', img_plane_corners_world(2,:), 'ZData', img_plane_corners_world(3,:), ...
      'FaceColor', [0.8 0.8 0.8], 'FaceAlpha', 0.6, 'EdgeColor', 'k', 'LineWidth', 1.5);
  
% 绘制图像平面中的坐标轴 x_i 和 y_i（以图像平面中心为原点）
% 定义图像坐标轴向量（在图像坐标系中：x 轴为 [1;0;0], y 轴为 [0;1;0]）
xi_axis = [1;0;0]; 
yi_axis = [0;1;0];
% 将向量从相机坐标系映射到世界坐标系（旋转即可，不需平移，因为已基于图像平面中心）
xi_axis_world = R_cam * xi_axis;
yi_axis_world = R_cam * yi_axis;

% 绘制图像平面坐标轴 (选择合适的长度，如 1.5 个单位)
quiver3(image_plane_center(1), image_plane_center(2), image_plane_center(3), 1.5*xi_axis_world(1), 1.5*xi_axis_world(2), 1.5*xi_axis_world(3), 'm', 'LineWidth', 2);
quiver3(image_plane_center(1), image_plane_center(2), image_plane_center(3), 1.5*yi_axis_world(1), 1.5*yi_axis_world(2), 1.5*yi_axis_world(3), 'c', 'LineWidth', 2);
% text(image_plane_center(1)+1.7*xi_axis_world(1), image_plane_center(2)+1.7*xi_axis_world(2), image_plane_center(3)+1.7*xi_axis_world(3), 'x_i','FontSize',12, 'Color','m');
% text(image_plane_center(1)+1.7*yi_axis_world(1), image_plane_center(2)+1.7*yi_axis_world(2), image_plane_center(3)+1.7*yi_axis_world(3), 'y_i','FontSize',12, 'Color','c');
% text(image_plane_center(1)-0.5, image_plane_center(2)-0.5, image_plane_center(3)+0.1, 'Image CS');

% 绘制原点到图像平面的连线，显示焦距 f
line([T_cam(1) image_plane_center(1)], [T_cam(2) image_plane_center(2)], [T_cam(3) image_plane_center(3)], 'Color', 'k', 'LineWidth', 2);
% text((T_cam(1)+image_plane_center(1))/2, (T_cam(2)+image_plane_center(2))/2, (T_cam(3)+image_plane_center(3))/2, 'f', 'FontSize',12, 'Color','k');

%% ------------------ 4. 绘制像素坐标系（Pixel CS） ------------------
% 增大像素坐标系的显示范围，调整其位置和坐标轴长度
pixel_center = image_plane_center + R_cam * [-2; -2; 0];  % 相对于图像平面中心偏移更大的距离
quiver3(pixel_center(1), pixel_center(2), pixel_center(3), 6*R_cam(1,1), 6*R_cam(2,1), 6*R_cam(3,1), 'k', 'LineWidth', 2);
quiver3(pixel_center(1), pixel_center(2), pixel_center(3), 6*R_cam(1,2), 6*R_cam(2,2), 6*R_cam(3,2), 'k', 'LineWidth', 2);
% text(pixel_center(1)+2.5*R_cam(1,1), pixel_center(2)+2.5*R_cam(2,1), pixel_center(3)+2.5*R_cam(3,1), 'u','FontSize',12);
% text(pixel_center(1)+2.5*R_cam(1,2), pixel_center(2)+2.5*R_cam(2,2), pixel_center(3)+2.5*R_cam(3,2), 'v','FontSize',12);
% text(pixel_center(1)-0.3, pixel_center(2)-0.3, pixel_center(3), 'Pixel CS','FontSize',12);

%% ------------------ 5. 投影演示及相似三角形示意 ------------------
% 选择一个点 P 在相机坐标系中 (确保 Z > focal_length)
P_cam = [1.5; 1; 3];  % P 点的相机坐标 (X_c, Y_c, Z_c)
% 针孔模型投影公式: x = f*(X/Z), y = f*(Y/Z)
P_img = [ focal_length * P_cam(1)/P_cam(3);
          focal_length * P_cam(2)/P_cam(3);
          focal_length ];
      
% 将 P 和 P_img 分别转换为世界坐标
P_world = T_cam + R_cam * P_cam;
P_img_world = T_cam + R_cam * P_img;
  
% 绘制 P 和其投影 P'
plot3(P_world(1), P_world(2), P_world(3), 'bo', 'MarkerSize', 8, 'MarkerFaceColor','b');
plot3(P_img_world(1), P_img_world(2), P_img_world(3), 'r', 'MarkerSize',10);
% text(P_world(1)+0.1, P_world(2)+0.1, P_world(3)+0.1, 'P');
% text(P_img_world(1)+0.1, P_img_world(2)+0.1, P_img_world(3)+0.1, 'P''');

% 绘制从相机光心(T_cam)到 P (蓝虚线)和到 P' (红虚线)的射线
line([T_cam(1), P_world(1)], [T_cam(2), P_world(2)], [T_cam(3), P_world(3)], 'Color','b', 'LineStyle','--', 'LineWidth',1.5);
line([T_cam(1), P_img_world(1)], [T_cam(2), P_img_world(2)], [T_cam(3), P_img_world(3)], 'Color','r', 'LineStyle','--', 'LineWidth',1.5);

% 绘制相似三角形示意：
% 大三角形: 顶点为 O (T_cam)、P、及 Q，在 P 在相机 CS 中在 Z 轴上的投影, Q = [0;0;P_cam(3)]
Q_cam = [0; 0; P_cam(3)];
Q_world = T_cam + R_cam * Q_cam;
plot3([T_cam(1), Q_world(1)], [T_cam(2), Q_world(2)], [T_cam(3), Q_world(3)], 'k-', 'LineWidth',1);
line([Q_world(1), P_world(1)], [Q_world(2), P_world(2)], [Q_world(3), P_world(3)], 'Color','b', 'LineStyle','-', 'LineWidth',1.5);
% text(Q_world(1)-0.3, Q_world(2)-0.3, Q_world(3), 'Q');

% 小三角形: 顶点为 O、P'、及 Q'；其中 Q' 为 [0;0;focal_length] 在世界坐标下
Q_img = [0; 0; focal_length];
Q_img_world = T_cam + R_cam * Q_img;
plot3([T_cam(1), Q_img_world(1)], [T_cam(2), Q_img_world(2)], [T_cam(3), Q_img_world(3)], 'k-', 'LineWidth',1);
line([Q_img_world(1), P_img_world(1)], [Q_img_world(2), P_img_world(2)], [Q_img_world(3), P_img_world(3)], 'Color','r', 'LineStyle','-', 'LineWidth',1.5);
% text(Q_img_world(1)-0.3, Q_img_world(2)-0.3, Q_img_world(3), 'Q''');

% 虚线连接 P 与 P' 表示映射关系
% line([P_world(1), P_img_world(1)], [P_world(2), P_img_world(2)], [P_world(3), P_img_world(3)], 'Color',[0.5 0.5 0.5], 'LineStyle','--', 'LineWidth',1);
% 
% % 注释相似三角形关系：(x / X) = (f / Z)
% str_large = sprintf('X = %.2f', P_cam(1));
% str_small = sprintf('x = %.2f', P_img(1));
% text(P_world(1)/2, P_world(2)/2, P_world(3)/2, str_large, 'Color','b');
% text(P_img_world(1)/2, P_img_world(2)/2, focal_length/2, str_small, 'Color','r');    