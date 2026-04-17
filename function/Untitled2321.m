% clc; clear; close all;
% 
% f   = 5;    % 透镜焦距
% do1 = 10;   % 合焦物面到透镜距离
% do2 = 8;    % 非合焦物面到透镜距离
% % 薄透镜成像公式：1/f = 1/do + 1/di
% di1 = 1 / (1/f - 1/do1);   % 合焦像平面位置
% di2 = 1 / (1/f - 1/do2);   % 非合焦实际会聚面位置
% y1 = 1.0;   % 合焦物点高度
% y2 = 1.0;   % 非合焦物点高度
% 
% 
% figure;
% hold on;
% axis equal;
% xlabel('x (光轴)'); 
% ylabel('y');
% title('二维简化光路示意（含散焦圆）');
% 
% % 画透镜：在 x=0 处用细长椭圆截面
% theta = linspace(-pi/2, pi/2, 200);
% a = 0.05;    % 椭圆横向半径 (非常细)
% b = 1.5;     % 椭圆竖向半径
% Xl = zeros(size(theta));
% Yl = b * sin(theta);
% plot(Xl, Yl, 'k', 'LineWidth', 2);
% plot(Xl, -Yl, 'k', 'LineWidth', 2);
% text(0.1, 1.6, '透镜', 'FontSize', 10);
% 
% % 标出物面和像平面
% plot([-do1 -do1], [-2 2], '--', 'Color', [0.8 0.4 0], 'LineWidth', 1.5);
% text(-do1, 2.1, '物面 A (合焦)', 'Color', [0.8 0.4 0]);
% plot([-do2 -do2], [-2 2], '--', 'Color', [0 0.4 0.8], 'LineWidth', 1.5);
% text(-do2, 2.1, '物面 B (非合焦)', 'Color', [0 0.4 0.8]);
% plot([di1 di1], [-2 2], '--', 'Color', [0 0.6 0.2], 'LineWidth', 1.5);
% text(di1, 2.1, '像平面', 'Color', [0 0.6 0.2]);
% 
% 
% P1 = [-do1, y1];
% % 主光线：P1 -> 透镜光心 -> 像平面
% plot([P1(1), 0, di1], [P1(2), 0, 0], '--', 'Color', [0.8 0.4 0], 'LineWidth', 1.5);
% % 平行光线：P1 -> (0,y1) -> 焦点 (di1,0)
% plot([P1(1), 0], [P1(2), P1(2)], '-', 'Color', [0.8 0.4 0], 'LineWidth', 1.5);
% plot([0, di1], [P1(2), 0], '-', 'Color', [0.8 0.4 0], 'LineWidth', 1.5);
% % 合焦像点
% plot(di1, 0, 'o', 'MarkerFaceColor', [0.8 0.4 0], 'MarkerSize', 6);
% text(di1+0.1, -0.1, 'A''', 'Color', [0.8 0.4 0]);
% 
% 
% P2 = [-do2, y2];
% % 主光线
% plot([P2(1), 0, di1], [P2(2), 0, 0], '--b', 'LineWidth', 1.5);
% % 平行光线会聚到 (di2,0) 再发散到像平面
% plot([P2(1), 0], [P2(2), P2(2)], '-b', 'LineWidth', 1.5);
% plot([0, di2], [P2(2), 0], '-b', 'LineWidth', 1.5);
% % 从 (di2,0) 往像平面 di1 延伸形成散焦点
% r = abs((di1 - di2) * (P2(2) / di2));  % 散焦圆半径
% % 两条边缘光线
% plot([di2, di1], [0, r], '--b', 'LineWidth', 1.5);
% plot([di2, di1], [0, -r], '--b', 'LineWidth', 1.5);
% % 画散焦圆
% t = linspace(0, 2*pi, 200);
% Yc = r * cos(t);
% Zc = r * sin(t);  % 二维平面内
% plot(di1*ones(size(t)), Yc, ':b', 'LineWidth', 1.5);
% text(di1+0.1, r+0.1, '散焦圆', 'Color', 'b');
% 
% 
% legend({'透镜', '物面 A', '物面 B', '像平面', ...
%         'A 主光线', 'A 准直光线', 'A 像点', ...
%         'B 主光线', 'B 准直光线', '边缘光线', '散焦圆'}, ...
%        'Location', 'northeastoutside');
% xlim([-do2-1, di1+1]);
% ylim([-2, 2]);
% grid on;
% 清除命令窗口、工作区变量并关闭所有图形窗口
clc; clear; close all;

% 定义透镜参数
f = 5; % 焦距
do = 8; % 物距

% 根据薄透镜公式 1/f = 1/do + 1/di 计算像距
di = 1 / (1/f - 1/do);

% 定义物点高度
y_obj = 2;

% 绘制透镜（椭圆）
theta = linspace(0, 2*pi, 100);
a = 0.2; % 椭圆长半轴
b = 2;   % 椭圆短半轴
x_lens = a * cos(theta);
y_lens = b * sin(theta);
plot(x_lens, y_lens, 'k', 'LineWidth', 2);
hold on;

% 绘制光轴
plot([-do - 1, di + 1], [0 0], '--k', 'LineWidth', 1);

% 绘制物面和像面
% plot([-do - 0.1, -do + 0.1], [-y_obj - 0.5, -y_obj - 0.5], 'r', 'LineWidth', 2);
% plot([-do - 0.1, -do + 0.1], [y_obj + 0.5, y_obj + 0.5], 'r', 'LineWidth', 2);
% text(-do, y_obj + 0.7, '物面', 'Color', 'r');
% 
% plot([x_image_plane, x_image_plane], [-b*1.2, b*1.2], '--', 'LineWidth',1);
% text(x_image_plane, b*1.3, '像平面', 'HorizontalAlignment','center');% 
% % 绘制物点
% plot(-do, y_obj, 'ro', 'MarkerFaceColor', 'r');
% text(-do - 0.2, y_obj, '物点', 'Color', 'r');
% 
% % 定义光线数量
% num_rays = 5;
% y_lens_points = linspace(-b, b, num_rays);
% 
% % 绘制光线
% for i = 1:num_rays
%     % 计算光线在透镜上的交点
%     x_lens_intersect = 0;
%     y_lens_intersect = y_lens_points(i);
%     
%     % 计算光线折射后的斜率
%     m1 = (y_lens_intersect - y_obj) / (x_lens_intersect + do);
%     
%     % 假设理想薄透镜，使用几何光学原理计算折射光线
%     % 这里简单假设平行光经过透镜后过焦点，过焦点的光经过透镜后平行于光轴
%     if y_lens_intersect > 0
%         if m1 > 0
%             % 光线向上倾斜入射
%             x2 = di;
%             y2 = 0;
%         else
%             % 光线向下倾斜入射
%             x2 = di;
%             y2 = -y_obj * di / do;
%         end
%     else
%         if m1 < 0
%             % 光线向下倾斜入射
%             x2 = di;
%             y2 = 0;
%         else
%             % 光线向上倾斜入射
%             x2 = di;
%             y2 = -y_obj * di / do;
%         end
%     end
%     
%     % 绘制光线
%     plot([-do, x_lens_intersect, x2], [y_obj, y_lens_intersect, y2], 'b', 'LineWidth', 1);
% end
% 
% % 绘制像点
% plot(di, -y_obj * di / do, 'go', 'MarkerFaceColor', 'g');
% text(di + 0.2, -y_obj * di / do, '像点', 'Color', 'g');

% 设置坐标轴属性
xlabel('x 轴');
ylabel('y 轴');
title('透镜成像原理演示（光线从透镜前一点射出）');
axis off;
grid on;
    