% % clc; clear; close all;
% figure;
% hold on; 
% % grid on; 
% axis equal;
% axis off;
% % xlabel('X'); ylabel('Y'); zlabel('Z');
% view(3);
% title('Camera Imaging: World, Camera, Image and Pixel CS with Improved Image Plane');
% 
% % % ------------------ 1. 绘制世界坐标系 ------------------
% % % 定义世界坐标系的旋转矩阵，让世界坐标系倾斜
% % R_world = angle2dcm(pi/6, pi/6, pi/6); 
% % R_world = R_world'; 
% 
% % % 绘制世界坐标系的坐标轴，颜色改为黑色
% % quiver3(0,0,0, 1*R_world(1,1), 1*R_world(2,1), 1*R_world(3,1), 'k', 'LineWidth', 2); % X_w
% % quiver3(0,0,0, 1*R_world(1,2), 1*R_world(2,2), 1*R_world(3,2), 'k', 'LineWidth', 2); % Y_w
% % quiver3(0,0,0, 1*R_world(1,3), 1*R_world(2,3), 1*R_world(3,3), 'k', 'LineWidth', 2); % Z_w
% % text(1.2*R_world(1,1), 1.2*R_world(2,1), 1.2*R_world(3,1), 'X_w', 'Color', 'k');
% % text(1.2*R_world(1,2), 1.2*R_world(2,2), 1.2*R_world(3,2), 'Y_w', 'Color', 'k');
% % text(1.2*R_world(1,3), 1.2*R_world(2,3), 1.2*R_world(3,3), 'Z_w', 'Color', 'k');
% % text(-0.5,-0.5,-0.5, 'World CS', 'Color', 'k');
% 
% % ------------------ 2. 绘制相机坐标系（Camera CS） ------------------
% T_cam = [3; 2; 1];  % 相机原点在世界坐标下的位置
% % 让相机坐标系保持正的，使用单位矩阵作为旋转矩阵
% R_cam = eye(3);  
% 
% % 为了显示清晰，在相机坐标系中使用较大坐标轴（长度 3 个单位），颜色改为黑色
% quiver3(T_cam(1), T_cam(2), T_cam(3), 3*R_cam(1,1), 3*R_cam(2,1), 3*R_cam(3,1), 'k', 'LineWidth', 2); % X_c
% quiver3(T_cam(1), T_cam(2), T_cam(3), 3*R_cam(1,2), 3*R_cam(2,2), 3*R_cam(3,2), 'k', 'LineWidth', 2); % Y_c
% quiver3(T_cam(1), T_cam(2), T_cam(3), 3*R_cam(1,3), 3*R_cam(2,3), 3*R_cam(3,3), 'k', 'LineWidth', 2); % Z_c
% text(T_cam(1)+3*R_cam(1,1), T_cam(2)+3*R_cam(2,1), T_cam(3)+3*R_cam(3,1), 'X_c', 'Color', 'k');
% text(T_cam(1)+3*R_cam(1,2), T_cam(2)+3*R_cam(2,2), T_cam(3)+3*R_cam(3,2), 'Y_c', 'Color', 'k');
% text(T_cam(1)+3*R_cam(1,3), T_cam(2)+3*R_cam(2,3), T_cam(3)+3*R_cam(3,3), 'Z_c', 'Color', 'k');
% text(T_cam(1)-0.5, T_cam(2)-0.5, T_cam(3)-0.5, 'Camera CS', 'Color', 'k');
% 
% % ------------------ 3. 绘制图像平面坐标系（Image CS） ------------------
% focal_length = 1;  % 焦距 f
% % 图像平面在相机坐标系中：中心点为 [0; 0; f]
% % 转换到世界坐标：image_plane_center = T_cam + R_cam*[0; 0; f]
% image_plane_center = T_cam + R_cam * [0; 0; focal_length];
% 
% % 定义图像平面尺寸，假设图像平面宽度为 4， 高度为 4
% w = 4; h = 4;
% % 图像平面四角在图像坐标系下（单位：任意）
% img_plane_corners = [ -w/2, -h/2, focal_length;
%                        w/2, -h/2, focal_length;
%                        w/2,  h/2, focal_length;
%                       -w/2,  h/2, focal_length ]';
% 
% % 将图像平面四角从相机坐标系转换到世界坐标系
% img_plane_corners_world = T_cam + R_cam * img_plane_corners;
% 
% % 绘制图像平面（使用 patch 填充，并描边使边界清晰）
% % patch('XData', img_plane_corners_world(1,:), 'YData', img_plane_corners_world(2,:), 'ZData', img_plane_corners_world(3,:), ...
% %       'FaceColor', [0.8 0.8 0.8], 'FaceAlpha', 0.6, 'EdgeColor', 'k', 'LineWidth', 1.5);
% %   
% % 绘制图像平面中的坐标轴 x_i 和 y_i（以图像平面中心为原点），颜色改为黑色
% % 定义图像坐标轴向量（在图像坐标系中：x 轴为 [1;0;0], y 轴为 [0;1;0]）
% xi_axis = [1;0;0]; 
% yi_axis = [0;1;0];
% % 将向量从相机坐标系映射到世界坐标系（旋转即可，不需平移，因为已基于图像平面中心）
% xi_axis_world = R_cam * xi_axis;
% yi_axis_world = R_cam * yi_axis;
% 
% % 绘制图像平面坐标轴 (选择合适的长度，如 1.5 个单位)
% quiver3(image_plane_center(1), image_plane_center(2), image_plane_center(3), 1.5*xi_axis_world(1), 1.5*xi_axis_world(2), 1.5*xi_axis_world(3), 'k', 'LineWidth', 2);
% quiver3(image_plane_center(1), image_plane_center(2), image_plane_center(3), 1.5*yi_axis_world(1), 1.5*yi_axis_world(2), 1.5*yi_axis_world(3), 'k', 'LineWidth', 2);
% text(image_plane_center(1)+1.7*xi_axis_world(1), image_plane_center(2)+1.7*xi_axis_world(2), image_plane_center(3)+1.7*xi_axis_world(3), 'x_i', 'FontSize', 12, 'Color', 'k');
% text(image_plane_center(1)+1.7*yi_axis_world(1), image_plane_center(2)+1.7*yi_axis_world(2), image_plane_center(3)+1.7*yi_axis_world(3), 'y_i', 'FontSize', 12, 'Color', 'k');
% text(image_plane_center(1)-0.5, image_plane_center(2)-0.5, image_plane_center(3)+0.1, 'Image CS', 'Color', 'k');
% 
% % 绘制原点到图像平面的连线，显示焦距 f
% line([T_cam(1) image_plane_center(1)], [T_cam(2) image_plane_center(2)], [T_cam(3) image_plane_center(3)], 'Color', 'k', 'LineWidth', 2);
% text((T_cam(1)+image_plane_center(1))/2, (T_cam(2)+image_plane_center(2))/2, (T_cam(3)+image_plane_center(3))/2, 'f', 'FontSize', 12, 'Color', 'k');
% 
% % ------------------ 4. 绘制像素坐标系（Pixel CS） ------------------
% % % 增大像素坐标系的显示范围，调整其位置和坐标轴长度
% % pixel_center = image_plane_center + R_cam * [-2; -2; 0];  % 相对于图像平面中心偏移更大的距离
% % quiver3(pixel_center(1), pixel_center(2), pixel_center(3), 6*R_cam(1,1), 6*R_cam(2,1), 6*R_cam(3,1), 'k', 'LineWidth', 2);
% % quiver3(pixel_center(1), pixel_center(2), pixel_center(3), 6*R_cam(1,2), 6*R_cam(2,2), 6*R_cam(3,2), 'k', 'LineWidth', 2);
% % text(pixel_center(1)+2.5*R_cam(1,1), pixel_center(2)+2.5*R_cam(2,1), pixel_center(3)+2.5*R_cam(3,1), 'u', 'FontSize', 12, 'Color', 'k');
% % text(pixel_center(1)+2.5*R_cam(1,2), pixel_center(2)+2.5*R_cam(2,2), pixel_center(3)+2.5*R_cam(3,2), 'v', 'FontSize', 12, 'Color', 'k');
% % text(pixel_center(1)-0.3, pixel_center(2)-0.3, pixel_center(3), 'Pixel CS', 'FontSize', 12, 'Color', 'k');
% 
% % ------------------ 5. 投影演示及相似三角形示意 ------------------
% % 选择一个点 P 在相机坐标系中 (确保 Z > focal_length)
% P_cam = [1.5; 1; 3];  % P 点的相机坐标 (X_c, Y_c, Z_c)
% % 针孔模型投影公式: x = f*(X/Z), y = f*(Y/Z)
% P_img = [ focal_length * P_cam(1)/P_cam(3);
%           focal_length * P_cam(2)/P_cam(3);
%           focal_length ];
%       
% % 将 P 和 P_img 分别转换为世界坐标
% P_world = T_cam + R_cam * P_cam;
% P_img_world = T_cam + R_cam * P_img;
%   
% % 绘制 P 和其投影 P'，颜色改为黑色
% plot3(P_world(1), P_world(2), P_world(3), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
% plot3(P_img_world(1), P_img_world(2), P_img_world(3), 'k*', 'MarkerSize', 10);
% text(P_world(1)+0.1, P_world(2)+0.1, P_world(3)+0.1, 'P', 'Color', 'k');
% text(P_img_world(1)+0.1, P_img_world(2)+0.1, P_img_world(3)+0.1, 'P''', 'Color', 'k');
% 
% % 绘制从相机光心(T_cam)到 P (蓝虚线)和到 P' (红虚线)的射线，颜色改为黑色
% line([T_cam(1), P_world(1)], [T_cam(2), P_world(2)], [T_cam(3), P_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
% line([T_cam(1), P_img_world(1)], [T_cam(2), P_img_world(2)], [T_cam(3), P_img_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
% 
% % 绘制相似三角形示意：
% % 大三角形: 顶点为 O (T_cam)、P、及 Q，在 P 在相机 CS 中在 Z 轴上的投影, Q = [0;0;P_cam(3)]
% Q_cam = [0; 0; P_cam(3)];
% Q_world = T_cam + R_cam * Q_cam;
% plot3([T_cam(1), Q_world(1)], [T_cam(2), Q_world(2)], [T_cam(3), Q_world(3)], 'k-', 'LineWidth', 1);
% line([Q_world(1), P_world(1)], [Q_world(2), P_world(2)], [Q_world(3), P_world(3)], 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1.5);
% text(Q_world(1)-0.3, Q_world(2)-0.3, Q_world(3), 'Q', 'Color', 'k');
% 
% % 小三角形: 顶点为 O、P'、及 Q'；其中 Q' 为 [0;0;focal_length] 在世界坐标下
% Q_img = [0; 0; focal_length];
% Q_img_world = T_cam + R_cam * Q_img;
% plot3([T_cam(1), Q_img_world(1)], [T_cam(2), Q_img_world(2)], [T_cam(3), Q_img_world(3)], 'k-', 'LineWidth', 1);
% line([Q_img_world(1), P_img_world(1)], [Q_img_world(2), P_img_world(2)], [Q_img_world(3), P_img_world(3)], 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1.5);
% text(Q_img_world(1)-0.3, Q_img_world(2)-0.3, Q_img_world(3), 'Q''', 'Color', 'k');
% 
% % 虚线连接 P 与 P' 表示映射关系，颜色改为黑色
% line([P_world(1), P_img_world(1)], [P_world(2), P_img_world(2)], [P_world(3), P_img_world(3)], 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 1);
% 
% % 注释相似三角形关系：(x / X) = (f / Z)，颜色改为黑色
% str_large = sprintf('X = %.2f', P_cam(1));
% str_small = sprintf('x = %.2f', P_img(1));
% text(P_world(1)/2, P_world(2)/2, P_world(3)/2, str_large, 'Color', 'k');
% text(P_img_world(1)/2, P_img_world(2)/2, focal_length/2, str_small, 'Color', 'k');    % 清除工作区和命令窗口
% 清除工作区和命令窗口
% 清除工作区和命令窗口
clear;
clc;

% 创建一个新的图形窗口
figure('Position', [100, 100, 1200, 600]);

% 绘制小光圈成像情况
subplot(1, 2, 1);
% 绘制镜头
rectangle('Position', [0.2, 0.2, 0.05, 0.6], 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'black');
% 绘制小光圈
rectangle('Position', [0.21, 0.45, 0.03, 0.1], 'FaceColor', 'white', 'EdgeColor', 'black');
% 绘制光线从物点到小光圈
hold on;
for i = 1:5
    % 随机生成物点位置
    obj_y = 0.2 + (0.6 - 0.2) * rand();
    line([0.1, 0.215], [obj_y, 0.475], 'Color', 'blue', 'LineWidth', 1);
end
% 绘制光线从小光圈到成像平面
for i = 1:5
    % 随机生成成像点位置
    img_y = 0.25 + (0.5 - 0.25) * rand();
    line([0.215, 0.8], [0.475, img_y], 'Color', 'blue', 'LineWidth', 1);
end
% 绘制成像区域
rectangle('Position', [0.3, 0.25, 0.6, 0.5], 'FaceColor', 'none', 'EdgeColor', 'blue');
% 添加标题和标签
title('小光圈 - 景深大');
xlabel('物距方向');
ylabel('垂直方向');
axis equal;
axis([0, 1, 0, 1]);
% 添加网格线增强可视化
grid on;
hold off;

% 绘制大光圈成像情况
subplot(1, 2, 2);
% 绘制镜头
rectangle('Position', [0.2, 0.2, 0.05, 0.6], 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'black');
% 绘制大光圈
rectangle('Position', [0.21, 0.3, 0.03, 0.4], 'FaceColor', 'white', 'EdgeColor', 'black');
% 绘制光线从物点到大光圈
hold on;
for i = 1:5
    % 随机生成物点位置
    obj_y = 0.2 + (0.6 - 0.2) * rand();
    line([0.1, 0.215], [obj_y, 0.4], 'Color', 'red', 'LineWidth', 1);
end
% 绘制光线从大光圈到成像平面
for i = 1:5
    % 随机生成成像点位置
    img_y = 0.35 + (0.65 - 0.35) * rand();
    line([0.215, 0.8], [0.4, img_y], 'Color', 'red', 'LineWidth', 1);
end
% 绘制成像区域
rectangle('Position', [0.3, 0.35, 0.6, 0.3], 'FaceColor', 'none', 'EdgeColor', 'red');
% 添加标题和标签
title('大光圈 - 景深小');
xlabel('物距方向');
ylabel('垂直方向');
axis equal;
axis([0, 1, 0, 1]);
% 添加网格线增强可视化
grid on;
hold off;    


%%
% 光心位置（相机原点）
O = [0, 0, 0];

% 四个顶点坐标（视场域棱锥的底面）
P1 = [-1, 0, -1];
P2 = [-1, 0,  1];
P3 = [-1, 1,  1];
P4 = [-1, 1, -1];

% 可视化
figure;
hold on; grid on; axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);

% 画四条射线（从 O 指向 P1 ~ P4）
line([O(1), P1(1)], [O(2), P1(2)], [O(3), P1(3)], 'Color', 'b', 'LineWidth', 2);
line([O(1), P2(1)], [O(2), P2(2)], [O(3), P2(3)], 'Color', 'b', 'LineWidth', 2);
line([O(1), P3(1)], [O(2), P3(2)], [O(3), P3(3)], 'Color', 'b', 'LineWidth', 2);
line([O(1), P4(1)], [O(2), P4(2)], [O(3), P4(3)], 'Color', 'b', 'LineWidth', 2);

% 绘制底面方形
fill3([P1(1), P2(1), P3(1), P4(1)], ...
      [P1(2), P2(2), P3(2), P4(2)], ...
      [P1(3), P2(3), P3(3), P4(3)], ...
      'c', 'FaceAlpha', 0.3);

% 标注各个点
text(O(1), O(2), O(3), '  O (光心)', 'FontSize', 10, 'Color', 'k');
text(P1(1), P1(2), P1(3), '  P1', 'FontSize', 10, 'Color', 'r');
text(P2(1), P2(2), P2(3), '  P2', 'FontSize', 10, 'Color', 'r');
text(P3(1), P3(2), P3(3), '  P3', 'FontSize', 10, 'Color', 'r');
text(P4(1), P4(2), P4(3), '  P4', 'FontSize', 10, 'Color', 'r');

title('从光心出发的视场域四条射线');
%%
clc; clear; close all;
figure; hold on; axis equal; axis off;

% Parameters
f = 4;                 % focal length
s_focus = 10;           % focus plane distance
s_near  = 7;           % near defocus plane distance
s_far   = 13;          % far defocus plane distance
x_img   = f * s_focus / (s_focus - f);  % image plane location

% 调整光线起始位置，增大间隔
offsets = [-1.5, 0, 1.5];  
num_rays = length(offsets);
% 减小最大偏差角度（弧度）
max_angle_deviation = pi / 18;  

% Draw lens as ellipse
t = linspace(0,2*pi,200);
a = 0.8; b = 2;
x_lens = a*cos(t);
y_lens = b*sin(t);
plot(x_lens, y_lens, 'k', 'LineWidth', 2);
text(0, -b - 0.2, 'Lens', 'HorizontalAlignment', 'center', 'FontSize', 12);

% Draw image plane
plot([x_img, x_img], [-3, 3], 'k-', 'LineWidth', 1.5);
text(x_img + 0.3, 3, 'Image Plane', 'FontSize', 12);

% Draw object planes: focus, near, far
planes = [s_focus, s_near, s_far];
labels = {'Focus Plane', 'Near Plane', 'Far Plane'};
styles = {'g--', 'r--', 'b--'};
for i = 1:3
    x_p = -planes(i);
    plot([x_p, x_p], [-2.5, 2.5], styles{i}, 'LineWidth', 1);
    text(x_p, 2.7, labels{i}, 'Color', styles{i}(1), 'FontSize', 10, 'HorizontalAlignment', 'center');
end

% Draw rays and blur circles
for i = 1:3
    s = planes(i);
    col = styles{i}(1);
    % Compute image distance for this object plane
    s_im = f * s / (s - f);
    y_int = zeros(size(offsets));
    intersection_points = zeros(num_rays, 2); % 用于存储光线在像平面的交点坐标

    for k = 1:num_rays
        y0 = offsets(k);
        % 随机生成偏差角度
        angle_deviation = (2 * rand() - 1) * max_angle_deviation;
        % 计算光线与透镜交点的坐标
        x0 = -s;
        % 计算光线在透镜处的高度
        y_lens_intersect = y0 + x0 * tan(angle_deviation);
        % Object to lens entry
        plot([x0, 0], [y0, y_lens_intersect], ':', 'Color', col);
        % Ray refracted direction toward its image point
        % 这里简化假设折射后光线指向像点
        dir = [s_im, -y_lens_intersect];
        dir = dir / norm(dir);
        % Intersection with fixed image plane
        t_int = (x_img - 0) / dir(1);
        P_int = [0, y_lens_intersect] + t_int * dir;
        y_int(k) = P_int(2);
        intersection_points(k, :) = P_int;
        % Draw refracted ray
        plot([0, P_int(1)], [y_lens_intersect, P_int(2)], '-', 'Color', col, 'LineWidth', 1.5);
    end

    % 根据交点计算弥散圆的圆心和半径
    if i ~= 1
        center_x = mean(intersection_points(:, 1));
        % 将弥散圆放到光轴下方
        center_y = mean(intersection_points(:, 2)) - max(abs(intersection_points(:, 2))); 
        distances = pdist2(intersection_points, [center_x, center_y], 'euclidean');
        r = max(distances); % 以最远点到圆心的距离作为半径

        theta = linspace(0, 2 * pi, 100);
        xc = center_x;
        yc = center_y;
        plot(xc + r * cos(theta), yc + r * sin(theta), col, 'LineWidth', 1.2);
        text(xc + 0.3, yc + r + 0.2, [labels{i} ' Blur'], 'Color', col, 'FontSize', 10);
    else
        % 重点标识绿线的交点
        for k = 1:num_rays
            plot(intersection_points(k, 1), intersection_points(k, 2), 'go', 'MarkerSize', 10, 'LineWidth', 2);
        end
    end
end

title('Depth of Field Visualization with Deviated Rays', 'FontSize', 14);
   %%
clc; clear; close all;
figure;
hold on;
axis equal;

% 设置视角，使 xz 平面水平，y 轴向上
view(30, 20);
xlabel('X'); ylabel('Y'); zlabel('Z');

% 相机光心 O_c
T_cam = [3; 2; 1];
plot3(T_cam(1), T_cam(2), T_cam(3), 'ks', 'MarkerSize', 8, 'MarkerFaceColor','k');
text(T_cam(1)+0.2, T_cam(2)+0.2, T_cam(3)+0.2, 'O_c (3,2,1)', 'FontSize',12);

% 相机坐标系
scale_cam = 3;
quiver3(T_cam(1), T_cam(2), T_cam(3), scale_cam, 0, 0, 'k', 'LineWidth',2); % X_c
quiver3(T_cam(1), T_cam(2), T_cam(3), 0, scale_cam, 0, 'k', 'LineWidth',2); % Y_c
quiver3(T_cam(1), T_cam(2), T_cam(3), 0, 0, scale_cam, 'k', 'LineWidth',2); % Z_c
text(T_cam(1)+scale_cam+0.2, T_cam(2), T_cam(3), 'X_c', 'FontSize',12);
text(T_cam(1), T_cam(2)+scale_cam+0.2, T_cam(3), 'Y_c', 'FontSize',12);
text(T_cam(1), T_cam(2), T_cam(3)+scale_cam+0.2, 'Z_c', 'FontSize',12);

% 焦距与图像平面
f = 1;
P_img_center = T_cam + [0;0;f];
line([T_cam(1), P_img_center(1)], [T_cam(2), P_img_center(2)], [T_cam(3), P_img_center(3)], 'Color','k','LineWidth',2);
mid = (T_cam + P_img_center)/2;
text(mid(1), mid(2), mid(3)+0.1, 'f', 'FontSize',14,'HorizontalAlignment','center');

% 图像坐标系原点
plot3(P_img_center(1), P_img_center(2), P_img_center(3), 'ko', 'MarkerSize',6);
text(P_img_center(1)+0.2, P_img_center(2)+0.2, P_img_center(3)+0.2, 'Image CS origin','FontSize',12);

% 图像坐标系轴 x, y
quiver3(P_img_center(1), P_img_center(2), P_img_center(3), 1.5, 0, 0, 'k','LineWidth',2);
quiver3(P_img_center(1), P_img_center(2), P_img_center(3), 0, 1.5, 0, 'k','LineWidth',2);
text(P_img_center(1)+1.7, P_img_center(2), P_img_center(3), 'x', 'FontSize',12);
text(P_img_center(1), P_img_center(2)+1.7, P_img_center(3), 'y', 'FontSize',12);

% 点 P 及其投影 p
P_cam = [1.5; 1; 3];
p_cam = [f*P_cam(1)/P_cam(3); f*P_cam(2)/P_cam(3); f];
P_world = T_cam + P_cam;
p_world = T_cam + p_cam;
plot3(P_world(1), P_world(2), P_world(3), 'ko', 'MarkerSize',8,'MarkerFaceColor','k');
text(P_world(1)+0.2, P_world(2)+0.2, P_world(3)+0.2, sprintf('P(%.1f,%.1f,%.1f)',P_cam), 'FontSize',12);
plot3(p_world(1), p_world(2), p_world(3), 'k*', 'MarkerSize',10);
text(p_world(1)+0.2, p_world(2)+0.2, p_world(3)+0.2, sprintf('p(%.2f,%.2f)',p_cam(1:2)'), 'FontSize',12);

% 投影射线 O_c->P 和 O_c->p
line([T_cam(1), P_world(1)], [T_cam(2), P_world(2)], [T_cam(3), P_world(3)], 'Color','k','LineStyle','--','LineWidth',1.5);
line([T_cam(1), p_world(1)], [T_cam(2), p_world(2)], [T_cam(3), p_world(3)], 'Color','k','LineStyle','--','LineWidth',1.5);

% 相似三角形: 大三角形 O_c-Q-P
Q_cam = [0; 0; P_cam(3)];
Q_world = T_cam + Q_cam;
plot3(Q_world(1), Q_world(2), Q_world(3), 'kd', 'MarkerSize',8,'MarkerFaceColor','k');
text(Q_world(1)+0.2, Q_world(2)+0.2, Q_world(3)+0.2, 'Q', 'FontSize',12);
line([T_cam(1), Q_world(1)], [T_cam(2), Q_world(2)], [T_cam(3), Q_world(3)], 'Color','k','LineStyle','--','LineWidth',1);
line([Q_world(1), P_world(1)], [Q_world(2), P_world(2)], [Q_world(3), P_world(3)], 'Color','k','LineStyle','--','LineWidth',1);

% 小三角形 O_c-Q'-p
Qp_cam = [0; 0; f];
Qp_world = T_cam + Qp_cam;
plot3(Qp_world(1), Qp_world(2), Qp_world(3), 'k^', 'MarkerSize',8,'MarkerFaceColor','k');
text(Qp_world(1)+0.2, Qp_world(2)+0.2, Qp_world(3)+0.2, "Q'", 'FontSize',12);
line([T_cam(1), Qp_world(1)], [T_cam(2), Qp_world(2)], [T_cam(3), Qp_world(3)], 'Color','k','LineStyle','--','LineWidth',1);
line([Qp_world(1), p_world(1)], [Qp_world(2), p_world(2)], [Qp_world(3), p_world(3)], 'Color','k','LineStyle','--','LineWidth',1);

% 关于 x 轴的相似三角形
% 大三角形：O_c - Qx - Px
Qx_cam = [P_cam(1); 0; P_cam(3)];
Qx_world = T_cam + Qx_cam;
plot3(Qx_world(1), Qx_world(2), Qx_world(3), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
text(Qx_world(1) + 0.2, Qx_world(2) + 0.2, Qx_world(3) + 0.2, 'Qx', 'FontSize', 12);
line([T_cam(1), Qx_world(1)], [T_cam(2), Qx_world(2)], [T_cam(3), Qx_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
line([Qx_world(1), P_world(1)], [Qx_world(2), P_world(2)], [Qx_world(3), P_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);

% 小三角形：O_c - Qpx - px
Qpx_cam = [p_cam(1); 0; f];
Qpx_world = T_cam + Qpx_cam;
plot3(Qpx_world(1), Qpx_world(2), Qpx_world(3), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
text(Qpx_world(1) + 0.2, Qpx_world(2) + 0.2, Qpx_world(3) + 0.2, 'Qpx', 'FontSize', 12);
line([T_cam(1), Qpx_world(1)], [T_cam(2), Qpx_world(2)], [T_cam(3), Qpx_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
line([Qpx_world(1), p_world(1)], [Qpx_world(2), p_world(2)], [Qpx_world(3), p_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);

% 关于 y 轴的相似三角形
% 大三角形：O_c - Qy - Py
Qy_cam = [0; P_cam(2); P_cam(3)];
Qy_world = T_cam + Qy_cam;
plot3(Qy_world(1), Qy_world(2), Qy_world(3), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
text(Qy_world(1) + 0.2, Qy_world(2) + 0.2, Qy_world(3) + 0.2, 'Qy', 'FontSize', 12);
line([T_cam(1), Qy_world(1)], [T_cam(2), Qy_world(2)], [T_cam(3), Qy_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
line([Qy_world(1), P_world(1)], [Qy_world(2), P_world(2)], [Qy_world(3), P_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);

% 小三角形：O_c - Qpy - py
Qpy_cam = [0; p_cam(2); f];
Qpy_world = T_cam + Qpy_cam;
plot3(Qpy_world(1), Qpy_world(2), Qpy_world(3), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
text(Qpy_world(1) + 0.2, Qpy_world(2) + 0.2, Qpy_world(3) + 0.2, 'Qpy', 'FontSize', 12);
line([T_cam(1), Qpy_world(1)], [T_cam(2), Qpy_world(2)], [T_cam(3), Qpy_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
line([Qpy_world(1), p_world(1)], [Qpy_world(2), p_world(2)], [Qpy_world(3), p_world(3)], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);

title('Camera Projection with Similar Triangles');
    %%
% clc; clear;
% figure;
% hold on; axis equal;
% % xlim([-10, 14]);
% % ylim([-6, 6]);
% 
% % ================================
% % 参数设置
% lens_center_x = 0;
% lens_center_y = 0;
% a = 5;  % 椭圆长轴长度（y方向）
% b = 1;  % 椭圆短轴长度（x方向）
% focal_length = 4;  % 焦距
% image_plane_x = lens_center_x + 2 * focal_length;  % 成像面位置
% 
% % ================================
% % 画透镜（用椭圆）
% theta = linspace(0, 2*pi, 200);
% x_lens = lens_center_x + b * cos(theta);
% y_lens = lens_center_y + a * sin(theta);
% fill(x_lens, y_lens, [0.5 0.8 1], 'EdgeColor', 'b', 'FaceAlpha', 0.3);
% text(lens_center_x, a + 0.5, '透镜', 'HorizontalAlignment', 'center');
% 
% % ================================
% % 焦点位置
% focal_point = [lens_center_x + focal_length, 0];
% plot(focal_point(1), focal_point(2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
% text(focal_point(1)+0.3, 0.3, '焦点', 'Color', 'r');
% 
% % ================================
% % 成像面
% plot([image_plane_x, image_plane_x], [-6, 6], '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5);
% text(image_plane_x + 0.3, 5.5, '成像面');
% plot([image_plane_x-8, image_plane_x-8], [-6, 6], '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5);
% plot([image_plane_x-4, image_plane_x-4], [-6, 0], '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5);
% % ================================
% % 绘制光轴虚线
% plot([-10, 14], [lens_center_y, lens_center_y], '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5);
% 
% % ================================
% % 平行光线入射（左边射入）
% num_rays = 3;
% y_rays = linspace(-3, 3, num_rays);
% x_start = -8;
% x_lens = lens_center_x;  % 入射点横坐标
% 
% for i = 1:num_rays
%     % 入射点
%     y0 = y_rays(i);
%     
%     % 入射线（平行光）
%     plot([x_start, x_lens], [y0, y0], 'k', 'LineWidth', 1.5);
% 
%     % 折射线：从透镜中心点指向焦点
%     % 求直线方向向量
%     dir = focal_point - [x_lens, y0];
%     dir = dir / norm(dir);  % 单位向量
% 
%     % 延长线段到成像面（求交点）
%     t = (image_plane_x - x_lens) / dir(1);  % 沿x方向到成像面距离
%     x_end = x_lens + t * dir(1);
%     y_end = y0 + t * dir(2);
% 
%     % 折射线段：透镜 -> 成像面
%     plot([x_lens, x_end], [y0, y_end], 'r', 'LineWidth', 1.5);
% 
%     % 标注成像点（简单点）
%     plot(x_end, y_end, 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
% end
% 
% % ================================
% % 美化图形
% title('二维透镜聚焦 + 成像示意', 'FontSize', 14, 'FontWeight', 'bold');
% xlabel('X 轴');
% ylabel('Y 轴');
%     

