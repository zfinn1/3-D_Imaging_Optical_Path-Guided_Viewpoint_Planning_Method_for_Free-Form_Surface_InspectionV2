maybe=[24.2921502077203,79.5325516655595,58.6601138518546;21.1707040376606,70.0484447544679,58.1048752487257;25.4129496135503,68.1340522398911,66.9557765459934;28.5343957836100,77.6181591509826,67.5110151491224;23.4420918198359,79.7852732000420,59.1222096895292;20.3206456497762,70.3011662889504,58.5669710864002;24.5628912256658,68.3867737743735,67.4178723836681;27.6843373957256,77.8708806854651,67.9731109867970];
stlFile = 'C:\Users\86132\Desktop\c\111.stl';
visualizeMaybe(maybe, stlFile, kdtree);

function visualizeMaybe(maybe, stlFile, kdtree)
% visualizeMaybe  综合可视化视场域和交点：
%   maybe   : 8×3 矩阵，前4行为 P1-P4，后4行为 F1-F4
%   stlFile : STL 文件路径
%   kdtree  : 预构建的 KD 树，用于交点计算

% 拆分视场域顶底点
P_new = maybe(1:4, :);
F_new = maybe(5:8, :);
P1 = P_new(1,:); P2 = P_new(2,:);
P3 = P_new(3,:); P4 = P_new(4,:);
F1 = F_new(1,:); F2 = F_new(2,:);
F3 = F_new(3,:); F4 = F_new(4,:);

% 计算观察位置和平面法向量
[n, d] = computePlane(P1, P2, P3);
centerOffset = mean(maybe,1) + n*28;
P = centerOffset;
n = n';  % 单位法向量行向量

% 圆柱参数
h_base = 4; r_base = 1.5;
h_neck = 2; r_neck = 0.5;
N = 40;

% 生成圆柱网格
[XB0,YB0,ZB0] = cylinder([r_base r_base], N);
ZB0 = ZB0 * h_base;
[XN0,YN0,ZN0] = cylinder([r_neck r_neck], N);
ZN0 = ZN0 * h_neck;

% 旋转对齐：将圆柱轴从 [0,0,1] 旋向 n
v = [0;0;1];  % 原轴向量
axis_rot = cross(v, n');
if norm(axis_rot)<1e-6
    R = eye(3);
else
    axis_rot = axis_rot/norm(axis_rot);
    theta = acos(dot(v,n'));
    K = [0, -axis_rot(3), axis_rot(2);
         axis_rot(3), 0, -axis_rot(1);
        -axis_rot(2), axis_rot(1), 0];
    R = eye(3) + sin(theta)*K + (1-cos(theta))*(K*K);
end

% 合并顶底顶点
VB = [XB0(:), YB0(:), ZB0(:)];
VN = [XN0(:), YN0(:), ZN0(:)+h_base];
VB_rot = (R*VB')';  VN_rot = (R*VN')';

% 平移到 P
opt_center_local = R*[0;0;h_base];
T = P' - opt_center_local;
VB_rot = VB_rot + T';  VN_rot = VN_rot + T';

% 重塑用于绘制
XB = reshape(VB_rot(:,1), size(XB0));
YB = reshape(VB_rot(:,2), size(YB0));
ZB = reshape(VB_rot(:,3), size(ZB0));
XN = reshape(VN_rot(:,1), size(XN0));
YN = reshape(VN_rot(:,2), size(YN0));
ZN = reshape(VN_rot(:,3), size(ZN0));

% 读取 STL 模型
[vertices, faces] = stlread(stlFile);

% 计算交点
Intersections = computeIntersectionsWithKD(P_new, vertices, faces, 1e-2, kdtree, 8);

% 可视化开始
figure; hold on; axis equal;
% 绘制模型透明
patch('Faces', faces, 'Vertices', vertices, 'FaceColor', [0.6 0.8 1], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
% 绘制圆柱部件
surf(XB, YB, ZB, 'FaceColor', [0.5 0.5 0.5],'EdgeColor','none','FaceAlpha',0.8);
surf(XN, YN, ZN, 'FaceColor', [0.5 0.5 0.5],'EdgeColor','none','FaceAlpha',0.8);
% 绘制光心
plot3(P(1), P(2), P(3), 'ro', 'MarkerSize',8, 'LineWidth',2);

% 绘制视场域
visualizeViewField(P_new, F_new);

% 绘制交点
if ~isempty(Intersections)
    visualizePoints(Intersections);
end

hold off; view(3);
end

function [n, d] = computePlane(P1, P2, P3)
    v1 = P2 - P1; v2 = P3 - P1;
    n = cross(v1, v2); n = n/norm(n);
    d = -dot(n, P1);
end

function visualizeViewField(nearPts, farPts)
    % 绘制近远平面
    patch('Faces',[1 2 3 4],'Vertices',nearPts,'FaceColor','r','FaceAlpha',0.4,'EdgeColor','k');
    patch('Faces',[1 2 3 4],'Vertices',farPts,'FaceColor','b','FaceAlpha',0.4,'EdgeColor','k');
    % 视线
    for i=1:4
        plot3([nearPts(i,1),farPts(i,1)], [nearPts(i,2),farPts(i,2)], [nearPts(i,3),farPts(i,3)], 'k-','LineWidth',1.5);
    end
    xlabel('X'); ylabel('Y'); zlabel('Z'); grid on;
end

function visualizePoints(points)
    % 绘制三维交点
    plot3(points(:,1), points(:,2), points(:,3), 'mo', 'MarkerFaceColor','m');
end
