% grid_cuboid.m
% 演示示例：绘制长方体（长10, 宽10, 高2），上下底面半透明蓝色填充，并标注采样点和角点文本标签（增大字体）

% 参数设置
L = 10;    % 长度 (X)
W = 10;    % 宽度 (Y)
H = 2;     % 高度 (Z)

nx = 5;   % X方向采样点数 (15 x 15 = 225)
ny = 5;   % Y方向采样点数

% 生成采样点网格（用于标记点）
[x, y] = meshgrid(linspace(0, L, nx), linspace(0, W, ny));
z_bottom = zeros(size(x));
z_top    = H * ones(size(x));

% 四角点坐标
P1 = [0, 0, 0]; P2 = [L, 0, 0]; P3 = [L, W, 0]; P4 = [0, W, 0];
F1 = [0, 0, H]; F2 = [L, 0, H]; F3 = [L, W, H]; F4 = [0, W, H];

% 绘图
figure; hold on; axis equal;

% 绘制底面网格（半透明蓝色面+黑色网格线）
surf(x, y, z_bottom, 'FaceColor', 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'k', 'LineWidth', 0.5);
% 绘制顶面网格（半透明蓝色面+黑色网格线）
surf(x, y, z_top,    'FaceColor', 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'k', 'LineWidth', 0.5);

% 绘制棱线（黑色）
corners = [P1; P2; P3; P4];
for i = 1:4
    j = mod(i,4) + 1;
    % 底边和顶边
    plot3(corners([i,j],1), corners([i,j],2), [0,0], 'k-', 'LineWidth',1.5);
    plot3(corners([i,j],1), corners([i,j],2), [H,H], 'k-', 'LineWidth',1.5);
    % 侧棱
    plot3([corners(i,1), corners(i,1)], [corners(i,2), corners(i,2)], [0,H], 'k-', 'LineWidth',1.5);
end

% 标注采样点（红色）
plot3(x(:), y(:), z_bottom(:), 'ro', 'MarkerFaceColor', 'r');
plot3(x(:), y(:), z_top(:),    'ro', 'MarkerFaceColor', 'r');

% 文本标注角点名称，增大字体
fontSize = 14; % 字体大小
names_bot = {'P1','P2','P3','P4'};
names_top = {'F1','F2','F3','F4'};
for k = 1:4
    pb = corners(k,:);    % 底面位置
    text(pb(1), pb(2), 0, names_bot{k}, 'HorizontalAlignment','center', 'FontSize', fontSize);
    text(pb(1), pb(2), H, names_top{k}, 'HorizontalAlignment','center', 'FontSize', fontSize);
end

% 坐标标签与视图设置
xlabel('X'); ylabel('Y'); zlabel('Z');
set(gca, 'FontSize', 12); % 坐标轴字体大小

title('长方体示意图：采样点与角点标签', 'FontSize', 16);
view(3); hold off;
axis off;