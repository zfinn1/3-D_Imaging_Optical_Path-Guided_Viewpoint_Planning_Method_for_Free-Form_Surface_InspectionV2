% 读取 STL 文件
model = stlread('C:\Users\86132\Desktop\本科毕设\叶片模型.stl');

% 提取顶点数据
vertices = model.Points;

% 将顶点转换为点云对象
ptCloud = pointCloud(vertices);

% 可视化点云
figure;
pcshow(ptCloud);
title('Point Cloud from STL');

% 将点云保存为 PLY 文件
pcwrite(ptCloud, 'output_model.ply');

% 读取PLY文件
model = pcread('output_model.ply'); % 假设是点云数据

% 获取点云的包围盒，并计算几何中心
x_range = [min(model.Location(:,1)), max(model.Location(:,1))];
y_range = [min(model.Location(:,2)), max(model.Location(:,2))];
z_range = [min(model.Location(:,3)), max(model.Location(:,3))];
center = [(x_range(1) + x_range(2)) / 2, (y_range(1) + y_range(2)) / 2, (z_range(1) + z_range(2)) / 2];

% 定义球面的半径
radius = max([x_range(2) - x_range(1), y_range(2) - y_range(1), z_range(2) - z_range(1)]) / 2;

% 球面均匀分布的视点数量
num_points = 100;  % 可以调整点的数量

% 生成球面上的均匀分布视点（使用球面坐标系）
theta = linspace(0, 2*pi, num_points);  % 经度（0到2π）
phi = linspace(0, pi, num_points);      % 纬度（0到π）

% 计算球面坐标转换为笛卡尔坐标
viewpoints = zeros(num_points, 3);
for i = 1:num_points
    x = radius * sin(phi(i)) * cos(theta(i)) + center(1);
    y = radius * sin(phi(i)) * sin(theta(i)) + center(2);
    z = radius * cos(phi(i)) + center(3);
    viewpoints(i, :) = [x, y, z];
end

% 绘制模型和视点
figure;
pcshow(model);  % 绘制模型
hold on;
plot3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 'ro'); % 绘制视点
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Model and Viewpoints (Spherical Distribution)');
grid on;
% 
% 
% 
% 
% % % 读取 PLY 文件
% % ptCloud = pcread('output_model.ply');
% % vertices = ptCloud.Location;
% % 
% % % 生成四边形网格：此处假设生成一个规则网格，实际应用中需根据数据进行适当处理
% % % 示例：简单规则划分为四边形（实际数据需更复杂的算法处理）
% % % 生成一个简单的二维规则网格进行演示
% % [x, y] = meshgrid(1:10, 1:10);
% % x = x(:);
% % y = y(:);
% % vertices = [x y zeros(size(x))]; % 假设 z=0
% % faces = delaunay(x, y); % 先用三角剖分生成面片
% % 
% % % 合并相邻三角形为四边形（简单示例）
% % quadFaces = [];
% % for i = 1:2:size(faces, 1) - 1
% %     % 假设相邻三角形可以合并为四边形
% %     commonEdge = intersect(faces(i, :), faces(i+1, :));
% %     remainingPoints = setdiff(union(faces(i, :), faces(i+1, :)), commonEdge);
% %     if numel(commonEdge) == 2 && numel(remainingPoints) == 2
% %         quadFaces = [quadFaces; commonEdge remainingPoints];
% %     end
% % end
% % 
% % % 写入 OBJ 文件
% % writeObj('output_quad_model.obj', vertices, quadFaces);
% % 
% % % 自定义函数：将顶点和四边形面片数据写入 OBJ 文件
% % function writeObj(filename, vertices, faces)
% %     fid = fopen(filename, 'w');
% %     % 写入顶点
% %     for i = 1:size(vertices, 1)
% %         fprintf(fid, 'v %f %f %f\n', vertices(i,1), vertices(i,2), vertices(i,3));
% %     end
% %     % 写入四边形面片
% %     for i = 1:size(faces, 1)
% %         fprintf(fid, 'f %d %d %d %d\n', faces(i,1), faces(i,2), faces(i,3), faces(i,4));
% %     end
% %     fclose(fid);
% % end
% clear;
% close all;
% clc;
% 
% % 读取飞机叶片模型
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% model = stlread(stlFile);
% 
% vertices = model.Points; % 提取顶点数据
% faces = model.ConnectivityList; % 提取三角面片索引
% 
% % 可视化 STL 模型
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'k');
% hold on;
% axis equal;
% camlight;
% lighting phong;
% title('Surface-Based Rotating Viewpoints with Limited Density');
% 
% % 参数设置
% viewingDistance = 30; % 视点距离模型表面的距离
% numSlices = 10; % 表面切片数量（基于模型高度）
% overlapRate = 0.2; % 重叠率，控制切片间的表面区域重叠程度
% maxViewpointsPerSlice = 50; % 每层的最大视点数量
% 
% % 计算每个三角形面的法向量和面中心点
% faceNormals = faceNormal(triangulation(faces, vertices)); % 法向量
% faceCenters = (vertices(faces(:,1), :) + vertices(faces(:,2), :) + vertices(faces(:,3), :)) / 3; % 面中心点
% 
% % 获取模型的高度范围
% [minZ, maxZ] = bounds(vertices(:,3));
% sliceHeights = linspace(minZ, maxZ, numSlices); % 切片高度
% 
% % 初始化视点列表
% viewpoints = [];
% 
% % 按表面切片生成视点
% for i = 1:numSlices-1
%     % 当前切片的高度范围
%     zMin = sliceHeights(i);
%     zMax = sliceHeights(i+1) + overlapRate * (sliceHeights(i+1) - sliceHeights(i));
%     
%     % 找到属于该切片的面
%     inSlice = (faceCenters(:,3) >= zMin & faceCenters(:,3) < zMax);
%     sliceCenters = faceCenters(inSlice, :);
%     sliceNormals = faceNormals(inSlice, :);
%     
%     % 限制视点数量（随机选择面）
%     if size(sliceCenters, 1) > maxViewpointsPerSlice
%         selectedIdx = randperm(size(sliceCenters, 1), maxViewpointsPerSlice);
%         sliceCenters = sliceCenters(selectedIdx, :);
%         sliceNormals = sliceNormals(selectedIdx, :);
%     end
%     
%     % 为当前切片的每个面生成视点
%     for j = 1:size(sliceCenters, 1)
%         surfacePoint = sliceCenters(j, :); % 当前面的中心点
%         normalVector = sliceNormals(j, :); % 当前面的法向量
%         
%         % 生成视点（沿法向外扩 viewingDistance）
%         viewpoint = surfacePoint + viewingDistance * normalVector;
%         viewpoints = [viewpoints; viewpoint]; % 保存视点
%         
%         % 可视化视点和方向
%         quiver3(surfacePoint(1), surfacePoint(2), surfacePoint(3), ...
%             normalVector(1), normalVector(2), normalVector(3), ...
%             viewingDistance, 'r'); % 红色箭头表示法向量
%         plot3(viewpoint(1), viewpoint(2), viewpoint(3), 'bo'); % 蓝点表示视点
%     end
% end
% 
% % 完成
% hold off;
% disp('基于表面切片的旋转视点生成完成，视点坐标已保存到变量 viewpoints 中。');
% clear;
% close all;
% clc;
% 
% % 读取飞机叶片模型
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% model = stlread(stlFile);
% 
% vertices = model.Points; % 提取顶点数据
% faces = model.ConnectivityList; % 提取三角面片索引
% 
% % 可视化 STL 模型
% figure;
% trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'k');
% hold on;
% axis equal;
% camlight;
% lighting phong;
% title('Surface-Based Rotating Viewpoints with Limited Density');
% 
% % 参数设置
% viewingDistance = 30; % 视点距离模型表面的距离
% numSlices = 10; % 表面切片数量（基于模型高度）
% overlapRate = 0.2; % 重叠率，控制切片间的表面区域重叠程度
% maxViewpointsPerSlice = 2; % 每层的最大视点数量
% 
% % 计算每个三角形面的法向量和面中心点
% faceNormals = faceNormal(triangulation(faces, vertices)); % 法向量
% faceCenters = (vertices(faces(:,1), :) + vertices(faces(:,2), :) + vertices(faces(:,3), :)) / 3; % 面中心点
% 
% % 获取模型的高度范围
% [minZ, maxZ] = bounds(vertices(:,3));
% sliceHeights = linspace(minZ, maxZ, numSlices); % 切片高度
% 
% % 初始化视点列表
% viewpoints = [];
% 
% % 按表面切片生成视点
% for i = 1:numSlices-1
%     % 当前切片的高度范围
%     zMin = sliceHeights(i);
%     zMax = sliceHeights(i+1) + overlapRate * (sliceHeights(i+1) - sliceHeights(i));
%     
%     % 找到属于该切片的面
%     inSlice = (faceCenters(:,3) >= zMin & faceCenters(:,3) < zMax);
%     sliceCenters = faceCenters(inSlice, :);
%     sliceNormals = faceNormals(inSlice, :);
%     
%     % 限制视点数量（随机选择面）
%     if size(sliceCenters, 1) > maxViewpointsPerSlice
%         selectedIdx = randperm(size(sliceCenters, 1), maxViewpointsPerSlice);
%         sliceCenters = sliceCenters(selectedIdx, :);
%         sliceNormals = sliceNormals(selectedIdx, :);
%     end
%     
%     % 为当前切片的每个面生成视点
%     for j = 1:size(sliceCenters, 1)
%         surfacePoint = sliceCenters(j, :); % 当前面的中心点
%         normalVector = sliceNormals(j, :); % 当前面的法向量
%         
%         % 生成视点（沿法向外扩 viewingDistance）
%         viewpoint = surfacePoint + viewingDistance * normalVector;
%         viewpoints = [viewpoints; viewpoint]; % 保存视点
%         
%         % 可视化视点和方向
%         quiver3(surfacePoint(1), surfacePoint(2), surfacePoint(3), ...
%             normalVector(1), normalVector(2), normalVector(3), ...
%             viewingDistance, 'r'); % 红色箭头表示法向量
%         plot3(viewpoint(1), viewpoint(2), viewpoint(3), 'bo'); % 蓝点表示视点
%         
%         % 标注视点所属的切片层
%         text(viewpoint(1), viewpoint(2), viewpoint(3), ...
%             [' ' num2str(i)], 'FontSize', 10, 'Color', 'black');
%     end
%     
%     % 绘制切片的平面（仅显示当前切片层的区域）
%     slicePlaneZ = sliceHeights(i); % 当前切片层的Z值
%     [X, Y] = meshgrid(min(vertices(:,1)):max(vertices(:,1)), min(vertices(:,2)):max(vertices(:,2))); % 创建平面网格
%     Z = slicePlaneZ * ones(size(X)); % 设置平面高度为当前切片的Z值
%     
%     % 在切片区域绘制平面
%     surf(X, Y, Z, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', 'g'); % 绿色半透明平面
% end
% 
% % 完成
% hold off;
% disp('基于表面切片的旋转视点生成完成，视点坐标已保存到变量 viewpoints 中。');

