figure;
hold on;
axis equal;
axis off;
view(3);
camlight;
lighting gouraud;

% 设置轴范围
xlim([-20 10]);
ylim([-5 5]);
zlim([-5 5]);

% 物距和焦距
object_distance = 8;
focal_length = 3;

% 目标（球体）位置
[xs, ys, zs] = sphere(30);
object_x_center = -object_distance;
object_radius = 0.5;
surf(object_x_center + object_radius * xs, object_radius * ys, object_radius * zs, 'FaceColor', [1 0 0], 'EdgeColor', 'none');
% text(object_x_center, 1.5, 0, '目标', 'FontSize', 12);

% 小孔
pinhole_x = 0;
pinhole_y = 0;
pinhole_z = 0;
pinhole_radius = 0.1; % 小孔半径
theta = linspace(0, 2 * pi, 100);
pinhole_xs = pinhole_x + zeros(size(theta));
pinhole_ys = pinhole_radius * cos(theta);
pinhole_zs = pinhole_radius * sin(theta);
fill3(pinhole_xs, pinhole_ys, pinhole_zs, [0, 0, 0]); % 绘制黑色圆孔
% text(pinhole_x, -1.5, 0, '孔', 'FontSize', 12);

% 成像盒体
box_size = 2;
box_x_min = pinhole_x;
box_x_max = pinhole_x + focal_length;
box_y_min = -box_size / 2;
box_y_max = box_size / 2;
box_z_min = -box_size / 2;
box_z_max = box_size / 2;

alpha_value = 0.3; % 设置透明度值

% bottom
fill3([box_x_min, box_x_max, box_x_max, box_x_min], [box_y_min, box_y_min, box_y_max, box_y_max], [box_z_min, box_z_min, box_z_min, box_z_min], [0.8, 0.8, 0.8], 'FaceAlpha', 1);
% top
fill3([box_x_min, box_x_max, box_x_max, box_x_min], [box_y_min, box_y_min, box_y_max, box_y_max], [box_z_max, box_z_max, box_z_max, box_z_max], [0.8, 0.8, 0.8], 'FaceAlpha', 1);
% back (成像面)
fill3([box_x_max, box_x_max, box_x_max, box_x_max], [box_y_min, box_y_max, box_y_max, box_y_min], [box_z_min, box_z_min, box_z_max, box_z_max], [1, 1, 1],'FaceAlpha', 0.05);
% front (小孔所在面)
fill3([box_x_min, box_x_min, box_x_min, box_x_min], [box_y_min, box_y_max, box_y_max, box_y_min], [box_z_min, box_z_min, box_z_max, box_z_max], [0.5, 0.5, 0.5], 'FaceAlpha', 0.1);
% left side
fill3([box_x_min, box_x_max, box_x_max, box_x_min], [box_y_min, box_y_min, box_y_min, box_y_min], [box_z_min, box_z_min, box_z_max, box_z_max], [0.8, 0.8, 0.8], 'FaceAlpha', alpha_value);
% right side
fill3([box_x_min, box_x_max, box_x_max, box_x_min], [box_y_max, box_y_max, box_y_max, box_y_max], [box_z_min, box_z_min, box_z_max, box_z_max], [0.8, 0.8, 0.8], 'FaceAlpha', 1);

% 成像圆
image_x_center = box_x_max;
scale_factor = focal_length / object_distance;
image_radius = object_radius * scale_factor;
theta = linspace(0, 2 * pi, 100);
image_x = image_x_center + zeros(size(theta));
image_y = image_radius * cos(theta);
image_z = image_radius * sin(theta);
fill3(image_x, image_y, image_z, [1, 0, 0]);
% text(image_x_center + 0.5, -1.2, 0, '成像效果', 'FontSize', 12);
% text(image_x_center , 1.5, 0, '成像面', 'FontSize', 12);

% 光线（从球体边缘到小孔再到成像面）
num_rays = 4;
for i = 1:num_rays
    angle = 2 * pi * (i - 1) / num_rays;
    % 准确计算球体边缘点坐标
    
    x_obj = object_x_center + object_radius * cos(angle);
    y_obj = object_radius * sin(angle);
    z_obj = object_radius * cos(angle);
    if i==3
       x_obj = object_x_center + object_radius * cos(angle)+0.2; 
    end
    if i==1
       x_obj = object_x_center + object_radius * cos(angle)-0.3; 
    end
    % 计算成像圆上对应点坐标
    x_img = image_x_center;
    y_img = image_radius * cos(angle);
    z_img = image_radius * sin(angle);

    line([x_obj, pinhole_x, x_img], [y_obj, pinhole_y, y_img], [z_obj, pinhole_z, z_img], 'Color', 'y', 'LineWidth', 2);
end

% text(object_x_center + 1, -1.5, 1.5, '光线', 'FontSize', 12);
% 
% title('三维小孔成像示意图', 'FontSize', 14, 'FontWeight', 'bold');
    