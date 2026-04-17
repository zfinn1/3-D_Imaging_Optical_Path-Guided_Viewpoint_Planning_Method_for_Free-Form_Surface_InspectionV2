% lens_simple.m
% 演示薄透镜原理：从光轴上一物点射出两条光线，经过透镜后汇聚到像平面上的像点。
% 光线在物点前后延伸并保持原有方向。

% 参数设置
u = 10;    % 物距
f = 5;     % 焦距

% 延长长度
extend = 5;  % 光线在物点前后延伸距离

% 计算像距
v = f * u / (u - f);

% 点坐标
P_obj    = [-u, 0];   % 物点
P_img    = [ v, 0];   % 像点

% 透镜参数（细长椭圆）
a = 0.2;            % 半宽
aperture = 4;       % 孔径总高度
b = aperture / 2;   % 半高
theta = linspace(0,2*pi,200);
x_e = a * cos(theta);
y_e = b * sin(theta);

% 透镜上端和下端射入点
P_top    = [0,  b];
P_bottom = [0, -b];

% 光线起止X坐标
x_start = P_obj(1) - extend;
x_end   = P_img(1) + extend;

% 计算入射延伸端点Y值
slope_inc_top = (P_top(2) - P_obj(2)) / (P_top(1) - P_obj(1));
y_start_top  = P_obj(2) + slope_inc_top * (x_start - P_obj(1));

slope_inc_bot = (P_bottom(2) - P_obj(2)) / (P_bottom(1) - P_obj(1));
y_start_bot  = P_obj(2) + slope_inc_bot * (x_start - P_obj(1));

% 绘图
figure; hold on; axis equal;

% 光轴
plot([x_start, x_end], [0, 0], 'k-', 'LineWidth',1);

% 透镜
plot(x_e, y_e, 'b', 'LineWidth',2);

% 像平面
plot([P_img(1), P_img(1)], [-b*1.2, b*1.2], '--k', 'LineWidth',1);
text(P_img(1), b*1.3, '像平面', 'HorizontalAlignment','center');

plot([-8, -8], [b*1.2, -b*1.2], '--k', 'LineWidth',1);
plot([-14, -14], [b*1.2, -b*1.2], '--k', 'LineWidth',1);
plot([9.5, 9.5], [0.5, -0.5], '--k', 'LineWidth',1);
plot([10.5, 10.5], [0.5, -0.5], '--k', 'LineWidth',1);
plot([10.5,12], [0.1, 0.1], '--b', 'LineWidth',1);
plot([10.5,12], [-0.1, -0.1], '--b', 'LineWidth',1);
% 物点和像点标记
plot(P_obj(1), P_obj(2), 'ro', 'MarkerFaceColor','r');
text(P_obj(1), 0.3, '物点', 'HorizontalAlignment','center');
plot(P_img(1), P_img(2), 'go', 'MarkerFaceColor','g');
text(P_img(1), 0.3, '像点', 'HorizontalAlignment','center');

% 入射光线顶端
plot([x_start, P_obj(1), P_top(1)], [y_start_top, P_obj(2), P_top(2)], 'r-');
% 折射并延伸：透镜顶端->像点->延伸末点
slope_top = (P_img(2) - P_top(2)) / (P_img(1) - P_top(1));
y_end_top = P_img(2) + slope_top * (x_end - P_img(1));
plot([P_top(1), P_img(1), x_end], [P_top(2), P_img(2), y_end_top], 'r-');

% 入射光线底端
plot([x_start, P_obj(1), P_bottom(1)], [y_start_bot, P_obj(2), P_bottom(2)], 'r-');
% 折射并延伸：透镜底端->像点->延伸末点
slope_bot = (P_img(2) - P_bottom(2)) / (P_img(1) - P_bottom(1));
y_end_bot = P_img(2) + slope_bot * (x_end - P_img(1));
plot([P_bottom(1), P_img(1), x_end], [P_bottom(2), P_img(2), y_end_bot], 'r-');

% 坐标和样式
xlim([x_start-1, x_end+1]); ylim([-b*1.5, b*1.5]);
xlabel('光轴方向 (x)'); ylabel('高度 (y)');
title('延长后的薄透镜两条光线示意图');
grid on; hold off;
axis off;