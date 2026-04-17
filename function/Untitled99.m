% clc; clear;
%% 定义长方体视场（使用 viewfieldPyrCuboid 获取长方体顶点）
A = [0, 0, 0];
B = [4, 0, 0];
C = [4, 1, 4];
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);
maybe = [P1; P2; P3; P4; F1; F2; F3; F4];  % 8个顶点
% 计算近面与远面（用于后续绘制）
farPts = maybe(5:8,:);
nearPts = maybe(1:4,:);

%% 定义长方体面（按顶点编号连接）
faces = [...
    1 2 3 4;    % 底面
    5 6 7 8;    % 顶面
    1 2 6 5;    % 侧面1
    2 3 7 6;    % 侧面2
    3 4 8 7;    % 侧面3
    4 1 5 8     % 侧面4
];

% 计算平面法向量（基于 P1, P2, P3）
[n, d] = computePlane(P1, P2, P3);

% 设置旋转参数：以长方体中心作为旋转中心，旋转轴取计算得到的平面法向量
% rotationCenter = mean(maybe, 1);  % 长方体中心
% axis_vec = n;  % 旋转轴（你可根据需要调整为其它向量）
rotationCenter = (maybe(1,:)+maybe(4,:)+maybe(5,:)+maybe(8,:))/4;
axis_vec=maybe(1,:)-maybe(4,:);
axis_vec=axis_vec/norm(axis_vec);
%% 创建图形窗口，并初次绘制参考长方体、旋转中心与旋转轴
figure;
hold on;
axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('长方体绕轴旋转的动图（左边为固定参考）');
axis off; 
% 固定参考：初始长方体（半透明灰色，不随动画变化）
hRefPatch = patch('Faces', faces, 'Vertices', maybe, ...
    'FaceColor', [0.7 0.7 0.7], 'FaceAlpha', 0.3, 'EdgeColor', 'r');

% 动态对象：旋转后的长方体（起始时与参考对象一致）
hPatch = patch('Faces', faces, 'Vertices', maybe, ...
    'FaceColor', 'cyan', 'FaceAlpha', 0.6, 'EdgeColor', 'k');

% 绘制旋转中心（红色大圆点）
hCenter = scatter3(rotationCenter(1), rotationCenter(2), rotationCenter(3), ...
    150, 'r', 'filled');

% 绘制旋转轴（以旋转中心为中点，沿 axis_vec 延伸）
axisLen = 3;
axisStart = rotationCenter - axisLen * axis_vec;
axisEnd   = rotationCenter + axisLen * axis_vec;
hAxis = plot3([axisStart(1) axisEnd(1)], [axisStart(2) axisEnd(2)], [axisStart(3) axisEnd(3)], ...
    'm-', 'LineWidth', 3);

%% 动画：循环旋转并更新动态长方体的顶点（参考对象保持不变）
for theta_deg = 0:2:10800
    % 计算旋转后的顶点
    rotatedVertices = rotatePoints(maybe, rotationCenter, axis_vec, theta_deg);
    
    % 检查 hPatch 是否仍然有效
    if ~ishandle(hPatch)
        % 如果 hPatch 对象失效，则重新创建
        hPatch = patch('Faces', faces, 'Vertices', rotatedVertices, ...
            'FaceColor', 'cyan', 'FaceAlpha', 0.6, 'EdgeColor', 'k');
    else
        % 更新 patch 对象的顶点数据
        set(hPatch, 'Vertices', rotatedVertices);
    end
    
    drawnow;
    pause(0.1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 旋转函数（利用 Rodrigues 公式）
function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    % 将角度转换为弧度
    theta_rad = deg2rad(theta_deg);
    
    % 确保旋转轴为单位向量
    axis_vec = axis_vec / norm(axis_vec);
    
    % 构造 Rodrigues 旋转矩阵
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
        -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad) * K + (1 - cos(theta_rad)) * (K*K);
    
    % 将点平移到旋转中心，旋转，再平移回原位置
    rotatedPts = ((R * (pts - center)')') + center;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 计算平面法向量的函数
function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end
