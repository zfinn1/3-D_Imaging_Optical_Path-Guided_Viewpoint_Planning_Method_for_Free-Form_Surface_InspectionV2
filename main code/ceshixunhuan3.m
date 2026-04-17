% %% 主程序
% clear;
% close all;
% clc;
% 
% % 1. 读取 STL 文件及数据
% stlFile = 'C:\Users\86132\Desktop\c\111.stl';
% model = stlread(stlFile);
% vertices = model.Points;
% faces = model.ConnectivityList;
% 
% % 2. 选取一个面片生成视场区域（此处取第 initialface 个面）
% initialface = 2478;
% A = vertices(faces(initialface,1),:);
% B = vertices(faces(initialface,2),:);
% C = vertices(faces(initialface,3),:);
% 
% % 调用你已有的视场生成函数（确保此函数在路径中）
% [P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 3, 28);
% 
% % 3. 绘制初始长方体（近面和远面）
% figure;
% hold on; axis equal; grid on;
% xlabel('X'); ylabel('Y'); zlabel('Z');
% 
% % 绘制近面（红色，半透明）
% h_near = fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
% 
% % 绘制初始远面（上平面，蓝色，半透明）
% h_far = fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
%         'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.2);
% % 4. 设置旋转参数及检测参数
% tol =0.8;         % 距离容差（可根据实际情况调整）
% max_angle = 360;     % 最大允许旋转角度（单位：度）
% deltaTheta = 1;     % 每步旋转角度（度）
% currentTheta = 0;   % 累计旋转角度
% 
% 
% 
% 
% E4 = (P4+F4)/2;
% E3 =( P3+F3)/2;
% % E4 =P2;
% % E3 =P1;
% rotationCenter = (E3+E4)/2;
% axis_vec= (E4 - E3) / norm(E4 - E3);
% 
% 
% % 采样参数：在上平面区域内采样（采用均匀网格）
% numSamples = 15;     % 每个方向的采样数量
% 
% % 5. 旋转迭代检测
% while currentTheta < max_angle
%     % 计算当前旋转角度（弧度）及旋转矩阵（Rodrigues公式）
%     theta_rad = deg2rad(currentTheta);
%     K = [  0         -axis_vec(3)   axis_vec(2);
%            axis_vec(3)  0         -axis_vec(1);
%           -axis_vec(2) axis_vec(1)   0         ];
%     R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
%     
%    P1_new = rotationCenter + (R*(P1' - rotationCenter'))';
%    P2_new = rotationCenter + (R*(P2' - rotationCenter'))';
%    P3_new = rotationCenter + (R*(P3' - rotationCenter'))';  % 理论上P3_new = P3
%    P4_new = rotationCenter + (R*(P4' - rotationCenter'))';  % 理论上P4_new = P4
%    F1_new = rotationCenter + (R*(F1' - rotationCenter'))';
%    F2_new = rotationCenter + (R*(F2' - rotationCenter'))';
%    F3_new = rotationCenter + (R*(F3' - rotationCenter'))';
%    F4_new = rotationCenter + (R*(F4' - rotationCenter'))';
%    P_new= rotationCenter + (R*(P' - rotationCenter'))';
%     
%     % 利用旋转后的远面三个点计算上平面（远面）的平面方程
%     [n_plane, d_plane] = computePlane(P1_new, P2_new, P3_new);  % n_plane 为归一化法向量
%     if currentTheta>=180
%         n_plane=-n_plane;
%     end
%     % 构造上平面局部坐标系：
%     % 以远面中心为原点
%     P_center = (P1_new + P2_new + P3_new + P4_new) / 4;
%     % 选择 u 方向：取 F2_new - F1_new 去除 n_plane 分量后归一化
%     u = P2_new - P1_new;
%     u = u - dot(u, n_plane)*n_plane;
%     u = u / norm(u);
%     % v 方向：叉乘 n_plane 与 u
%     v = cross(n_plane, u);
%     
%     % 假设上平面为正方形，其边长 L 由 F1_new 与 F2_new 估计
%     L = norm(P2_new - P1_new);
%     
%     % 在上平面区域内均匀采样，检测采样点与模型表面的距离
%     alphas = linspace(-L/2, L/2, numSamples);
%     betas  = linspace(-L/2, L/2, numSamples);
%     isTangent = false;
%     
%     for a = alphas
%         for b = betas
%             % 计算采样点全局坐标
%             X = P_center + a*u + b*v;
%             % 计算采样点到模型所有点的最小距离（用 model.Points）
%             dist = min(pdist2(X, model.Points));
%             if dist < tol
%                 % 如需检测法向量对齐，获取模型在此处的法向量
%                 n_model = getModelNormalAt(X, model);
%                 if abs(dot(n_plane, n_model)) > 0.99
%                     isTangent = true;
%                     break;
%                 end
%             end
%         end
%         if isTangent
%             break;
%         end
%     end
%     
%     if isTangent
%         fprintf('检测到上平面区域与模型相切，旋转角度 = %f 度\n', currentTheta);
%         break;
%     end
%     
%     % 更新图形：更新远面 patch 对象顶点
%     newVertices = [P1_new; P2_new; P3_new; P4_new];
%     set(h_near, 'Vertices', newVertices);
%     
%     drawnow;
%     pause(0.05);
%     
%     currentTheta = currentTheta + deltaTheta;
% end
% 
% %% 辅助函数
% 
% function [n, d] = computePlane(P1, P2, P3)
%     % 根据三个点 P1, P2, P3 计算平面法向量 n（归一化）及常数 d
%     v1 = P2 - P1;
%     v2 = P3 - P1;
%     n = cross(v1, v2);
%     n = n / norm(n);
%     d = -dot(n, P1);
% end
% 
% function n = getModelNormalAt(X, model)
%     % 根据模型面片计算，返回与点 X 最近的面片的法向量
%     faces = model.ConnectivityList;
%     vertices = model.Points;
%     numFaces = size(faces,1);
%     centroids = zeros(numFaces,3);
%     normals = zeros(numFaces,3);
%     for i = 1:numFaces
%         v1 = vertices(faces(i,1),:);
%         v2 = vertices(faces(i,2),:);
%         v3 = vertices(faces(i,3),:);
%         centroids(i,:) = (v1+v2+v3) / 3;
%         n_i = cross(v2 - v1, v3 - v1);
%         if norm(n_i) > 0
%             normals(i,:) = n_i / norm(n_i);
%         else
%             normals(i,:) = [0,0,0];
%         end
%     end
%     % 找到使采样点 X 与面片重心距离最小的面
%     dists = sqrt(sum((centroids - X).^2,2));
%     [~, idx] = min(dists);
%     n = normals(idx,:)';
% end
% 
% 
%% 主程序
clear;
close all;
clc;

% 1. 读取 STL 文件及数据
stlFile = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;

% 2. 选取一个面片生成视场区域（此处取第 initialface 个面）
% initialface = 2478;
initialface = 3418;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);

% 调用视场生成函数（请确保 viewfieldPyrCuboid 函数在路径中）
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 3, 28);

% 3. 绘制初始长方体（近面和远面）
figure;
hold on; axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');

% 绘制近面（红色，半透明）
h_near = fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
% 绘制远面（上平面，蓝色，半透明）
h_far = fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);
% 绘制整个模型（仅作背景参考）
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.2);

% 4. 设置旋转参数及检测参数
tol = 0.08;           % 距离容差
max_angle = 360;     % 最大允许旋转角度（度）
deltaTheta = 1;      % 每步旋转角度（度）
currentTheta = 0;    % 累计旋转角度

% 设定旋转轴：这里选择上平面边的中点构成的线作为旋转轴
% 例如先计算边 E3-E4，E3 = (P3+F3)/2, E4 = (P4+F4)/2
E3 = (P3 + F3)/2;
E4 = (P4 + F4)/2;
rotationCenter = (E3 + E4)/2; % 以边中点为旋转中心
axis_vec = (E4 - E3) / norm(E4 - E3);

% 采样参数：在上平面区域内采样（均匀网格）
numSamples = 15;    % 每个方向的采样数量
h_near_prev = fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'y', 'FaceAlpha', 0.5);
% 绘制远面正方形（原始）
h_far_prev = fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'y', 'FaceAlpha', 0.5);

% 5. 旋转迭代检测
while currentTheta < max_angle
    % 计算当前旋转角度（弧度）及旋转矩阵（Rodrigues公式）
    theta_rad = deg2rad(currentTheta);
    K = [  0         -axis_vec(3)   axis_vec(2);
           axis_vec(3)  0         -axis_vec(1);
          -axis_vec(2) axis_vec(1)   0         ];
    R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
    
    % 对整个长方体所有顶点应用旋转（近面、远面、视点）
    P1_new = rotationCenter + (R*(P1' - rotationCenter'))';
    P2_new = rotationCenter + (R*(P2' - rotationCenter'))';
    P3_new = rotationCenter + (R*(P3' - rotationCenter'))';  % 理论上接近固定
    P4_new = rotationCenter + (R*(P4' - rotationCenter'))';
    F1_new = rotationCenter + (R*(F1' - rotationCenter'))';
    F2_new = rotationCenter + (R*(F2' - rotationCenter'))';
    F3_new = rotationCenter + (R*(F3' - rotationCenter'))';
    F4_new = rotationCenter + (R*(F4' - rotationCenter'))';
    P_new    = rotationCenter + (R*(P' - rotationCenter'))';
    
    % 利用旋转后的近面三个点计算上平面（这里仍使用近面作为检测参考）
    [n_plane, d_plane] = computePlane(P1_new, P2_new, P3_new);  % n_plane为归一化法向量
    % 当旋转角超过180度时，可根据实际需要反转法向量方向
    if currentTheta >= 180
        n_plane = -n_plane;
    end
    
    % 构造上平面局部坐标系：以近面中心为原点
    P_center = (P1_new + P2_new + P3_new + P4_new) / 4;
    % 选择 u 方向：取 P2_new - P1_new 去除 n_plane 分量后归一化
    u = P2_new - P1_new;
    u = u - dot(u, n_plane)*n_plane;
    u = u / norm(u);
    % v 方向：叉乘 n_plane 与 u
    v = cross(n_plane, u);
    
    % 以近面为正方形，其边长 L 由 P2_new 与 P1_new 估计
    L = norm(P2_new - P1_new);
    
    % 在上平面区域内均匀采样，检测采样点与模型表面的距离
    alphas = linspace(-L/2, L/2, numSamples);
    betas  = linspace(-L/2, L/2, numSamples);
    isTangent = false;
    
    for a = alphas
        for b = betas
            % 计算采样点全局坐标
            X = P_center + a*u + b*v;
            % 计算采样点到模型所有点的最小距离（用 model.Points）
            dist = min(pdist2(X, model.Points));
            if dist < tol
                % 如需检测法向量对齐，获取模型在此处的法向量
                n_model = getModelNormalAt(X, model);
                if abs(dot(n_plane, n_model)) > 0.99
                    isTangent = true;
                    break;
                end
            end
        end
        if isTangent
            break;
        end
    end
    
    if isTangent
        fprintf('检测到上平面区域与模型相切，旋转角度 = %f 度\n', currentTheta);
        break;
    end
    
    % 更新图形：更新近面和远面 patch 对象的顶点
    newVerticesNear = [P1_new; P2_new; P3_new; P4_new];
    newVerticesFar  = [F1_new; F2_new; F3_new; F4_new];
    set(h_near, 'Vertices', newVerticesNear);
    set(h_far,  'Vertices', newVerticesFar);
    
    drawnow;
    pause(0.05);
    
    currentTheta = currentTheta + deltaTheta;
end

%% 辅助函数

function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点 P1, P2, P3 计算平面法向量 n（归一化）及常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end

function n = getModelNormalAt(X, model)
    % 根据模型面片计算，返回与点 X 最近的面片的法向量
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    centroids = zeros(numFaces,3);
    normals = zeros(numFaces,3);
    for i = 1:numFaces
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        centroids(i,:) = (v1+v2+v3) / 3;
        n_i = cross(v2 - v1, v3 - v1);
        if norm(n_i) > 0
            normals(i,:) = n_i / norm(n_i);
        else
            normals(i,:) = [0,0,0];
        end
    end
    % 找到使采样点 X 与面片重心距离最小的面
    dists = sqrt(sum((centroids - X).^2,2));
    [~, idx] = min(dists);
    n = normals(idx,:)';
end
