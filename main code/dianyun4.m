% clear; 
% close all; 
% clc;
% % 读取飞机叶片模型
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% 
% model = stlread(stlFile);
% vertices = model.Points; % 获取模型的顶点坐标
% faces = model.ConnectivityList; % 获取面片索引（每个三角形由 3 个顶点组成）
% 
% % 可视化3D模型
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'none');
% axis equal;
% title('飞机叶片模型');
% xlabel('X'); ylabel('Y'); zlabel('Z');
% 
% % 计算模型的中心点
% center = mean(vertices, 1);  % 计算模型质心
% 
% % 定义球面参数
% viewDistance = 100; % 视点到模型的距离
% numViewpoints = 36; % 旋转视点数量（可以根据需要调整）
% theta = linspace(0, 2*pi, numViewpoints); % 方位角，沿圆周均匀分布
% phi = linspace(0, 2*pi, 12); % 仰角（可以调整，确保覆盖叶片的顶部）
% % 均匀分布的角度
% % 生成旋转视点（围绕模型旋转）
% viewpoints = [];
% for i = 1:length(phi)
%     for j = 1:length(theta)
%         % 计算旋转视点的笛卡尔坐标，绕 Y 轴旋转
%         x = center(1) + viewDistance * cos(phi(i)) * cos(theta(j));
%         y = center(2) + viewDistance * sin(phi(i));
%         z = center(3) + viewDistance * cos(phi(i)) * sin(theta(j));
% 
% 
%         % 将视点添加到列表
%         viewpoints = [viewpoints; x, y, z];
%     end
% end
% 
% % 可视化旋转视点
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k');
% hold on;
% scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 'r', 'filled');
% title('旋转视点生成');
% xlabel('X'); ylabel('Y'); zlabel('Z');
% 
% 
% % 计算每个面的法向量（可以利用 triangulation 函数）
% faceNormals = faceNormal(triangulation(faces, vertices));
% 
% 
% % 可见性分析：计算哪些区域已被旋转视点覆盖
% % 创建一个二进制数组，标记每个点是否已被覆盖
% coveredPoints = false(size(vertices, 1), 1);
% 
% % 检查每个旋转视点覆盖的区域
% for v = 1:size(viewpoints, 1)
%     viewpoint = viewpoints(v, :);
%     
%     % 计算当前视点能覆盖的点（通过距离和方向判断）
%     distances = vecnorm(vertices - viewpoint, 2, 2);  % 计算每个顶点到视点的距离
%     coveredPoints = coveredPoints | (distances < viewDistance);  % 标记被覆盖的点
% end
% 
% % 找到未被覆盖的点
% uncoveredPoints = vertices(~coveredPoints, :);
% 
% % 生成补充视点（只针对未覆盖的区域）
% gapViewpoints = [];
% for i = 1:size(uncoveredPoints, 1)
%     % 获取未被覆盖的点
%     point = uncoveredPoints(i, :);
%     
%     % 计算该点所在面片的法向量
%     distances = vecnorm(vertices - point, 2, 2);  % 计算与所有点的距离
%     [~, closestFaceIdx] = min(distances);  % 找到与该点最近的面片
%     normal = faceNormals(closestFaceIdx, :); % 取该面的法向量
%     
%     % 生成补充视点：沿法向量方向延伸
%     gapViewpoint = point + normal * viewDistance;
%     
%     % 将补充视点添加到列表
%     gapViewpoints = [gapViewpoints; gapViewpoint];
% end
% 
% % 可视化生成的补充视点
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'none');  % 绘制模型
% hold on;
% scatter3(gapViewpoints(:,1), gapViewpoints(:,2), gapViewpoints(:,3), 'g', 'filled');  % 绘制补充视点
% title('补充视点生成');
% xlabel('X'); ylabel('Y'); zlabel('Z');



% % 假设我们已知所有旋转视点，接下来生成间隙填充视点
% gapViewpoints = [];
% for i = 1:size(faces, 3)
%     faceCenter = mean(vertices(faces(i, :), :), 1);
%     normal = faceNormals(i, :); % 当前面片的法向量
%     
%     % 生成补充视点（按法向量方向）
%     gapViewpoint = faceCenter + normal * viewDistance;  % 在法向量方向延伸
%     gapViewpoints = [gapViewpoints; gapViewpoint];
% end
% 
% % 可视化间隙填充视点
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'none');
% hold on;
% scatter3(gapViewpoints(:,1), gapViewpoints(:,2), gapViewpoints(:,3), 'black', 'filled');
% title('间隙填充视点');
% xlabel('X'); ylabel('Y'); zlabel('Z');
clear;
close all;
clc;

% 读取飞机叶片模型
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
model = stlread(stlFile);

vertices = model.Points; % 提取顶点数据
faces = model.ConnectivityList; % 提取三角面片索引

% 可视化 STL 模型
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.5); % 半透明模型
hold on;
axis equal;
camlight;
lighting phong;
title('Surface Slicing with Surrounding Rings');

% 参数设置
numSlices = 10; % 表面切片数量（基于模型高度）
overlapRate = 0.2; % 重叠率，控制切片间的表面区域重叠程度
ringRadiusFactor = 1.2; % 环绕线的半径比例，环绕线半径 = 模型边界最大尺寸 * 此比例
numRingPoints = 50; % 环绕线的点数

% 计算每个三角形面的中心点
faceCenters = (vertices(faces(:,1), :) + vertices(faces(:,2), :) + vertices(faces(:,3), :)) / 3; % 面中心点

% 获取模型的高度范围和边界
[minZ, maxZ] = bounds(vertices(:,3));
[minXY, maxXY] = bounds(vertices(:,1:2), 'all');
modelCenter = mean(vertices(:,1:2)); % 模型的中心点（在 X-Y 平面）
ringRadius = ringRadiusFactor * max(maxXY - minXY); % 环绕线半径

% 切片高度范围
sliceHeights = linspace(minZ, maxZ, numSlices); % 切片高度
colors = jet(numSlices); % 使用颜色区分不同切片

% 按表面切片生成环绕线
for i = 1:numSlices-1
    % 当前切片的高度范围
    zMin = sliceHeights(i);
    zMax = sliceHeights(i+1) + overlapRate * (sliceHeights(i+1) - sliceHeights(i));
    
    % 找到属于该切片的面
    inSlice = (faceCenters(:,3) >= zMin & faceCenters(:,3) < zMax);
    sliceCenters = faceCenters(inSlice, :);
    
    % 可视化该切片的面中心点
    scatter3(sliceCenters(:,1), sliceCenters(:,2), sliceCenters(:,3), 10, colors(i, :), 'filled');
    
    % 在当前切片高度绘制环绕线
    theta = linspace(0, 2*pi, numRingPoints); % 环绕线的角度范围
    ringX = modelCenter(1) + ringRadius * cos(theta); % 环绕线的 X 坐标
    ringY = modelCenter(2) + ringRadius * sin(theta); % 环绕线的 Y 坐标
    ringZ = ones(1, numRingPoints) * mean([zMin, zMax]); % 环绕线的 Z 坐标（切片高度中值）
    plot3(ringX, ringY, ringZ, 'r-', 'LineWidth', 1.5); % 绘制环绕线
end

hold off;
disp('切片和环绕线可视化完成。');

