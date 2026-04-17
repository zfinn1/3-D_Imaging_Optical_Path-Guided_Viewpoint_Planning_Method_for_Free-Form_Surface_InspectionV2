% clear; 
% close all; 
% clc;
% 
% % 读取飞机叶片模型
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; % 替换为你的 STL 文件路径
% 
% model = stlread(stlFile);
% 
% % 可视化 STL 模型
% figure;
% trisurf(model.ConnectivityList, model.Points(:, 1), model.Points(:, 2), model.Points(:, 3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'none');
% axis equal;
% hold on;
% camlight;
% lighting phong;
% title('STL Model with Generated Viewpoints');
% 
% % 参数设置
% viewingDistance = 30; % 视点与模型表面的距离
% slices = 10; % 垂直方向的切片数量
% overlapRate = 0.5; % 重叠率
% viewAngleConstraint = 45; % 视角约束 (度数)
% 
% % 计算每个三角形面的法向量
% vertices = model.Points;
% faces = model.ConnectivityList;
% faceNormals = zeros(size(faces, 1), 3);
% 
% for i = 1:size(faces, 1)
%     % 提取当前面的三个顶点
%     v1 = vertices(faces(i, 1), :);
%     v2 = vertices(faces(i, 2), :);
%     v3 = vertices(faces(i, 3), :);
%     
%     % 计算法向量（单位化）
%     normal = cross(v2 - v1, v3 - v1);
%     faceNormals(i, :) = normal / norm(normal);
% end
% 
% % 获取模型的边界框
% [minCoord, maxCoord] = bounds(vertices);
% zLevels = linspace(minCoord(3), maxCoord(3), slices);
% 
% viewpoints = [];
% for z = zLevels
%     % 提取在当前高度的面
%     faceCenters = (vertices(faces(:, 1), :) + vertices(faces(:, 2), :) + vertices(faces(:, 3), :)) / 3;
%     sliceIndices = faceCenters(:, 3) >= z - overlapRate & faceCenters(:, 3) <= z + overlapRate;
%     
%     sliceCenters = faceCenters(sliceIndices, :);
%     sliceNormals = faceNormals(sliceIndices, :);
%     
% %     沿法向量生成视点
%     for i = 1:size(sliceCenters, 1)
%         surfacePoint = sliceCenters(i, :);
%         normalVector = sliceNormals(i, :);
%         
%         % 确保视角约束
% %         if acosd(dot(normalVector, [0, 0, -1])) <= viewAngleConstraint
%              viewpoint = surfacePoint + viewingDistance * normalVector;
%              viewpoints = [viewpoints; viewpoint];
%             
%             % 可视化视点
% %             quiver3(surfacePoint(1), surfacePoint(2), surfacePoint(3), ...
% %                 normalVector(1), normalVector(2), normalVector(3), ...
% %                 viewingDistance, 'r');
%             
%               scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3),5 ,'r', 'filled');
% %         end
%     end
% end
% 
% % 完成
% hold off;
% disp('视点生成完成，视点坐标已保存到变量 viewpoints 中。');
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
    'FaceColor', 'cyan', 'EdgeColor', 'k');
hold on;
axis equal;
camlight;
lighting phong;
title('Surface-Based Rotating Viewpoints');

% 参数设置
viewingDistance = 30; % 视点距离模型表面的距离
numSlices = 10; % 表面切片数量（基于模型高度）
overlapRate = 0.2; % 重叠率，控制切片间的表面区域重叠程度

% 计算每个三角形面的法向量和面中心点
faceNormals = faceNormal(triangulation(faces, vertices)); % 法向量
faceCenters = (vertices(faces(:,1), :) + vertices(faces(:,2), :) + vertices(faces(:,3), :)) / 3; % 面中心点

% 获取模型的高度范围
[minZ, maxZ] = bounds(vertices(:,3));
sliceHeights = linspace(minZ, maxZ, numSlices); % 切片高度

% 初始化视点列表
viewpoints = [];

% 按表面切片生成视点
for i = 1:numSlices-1
    % 当前切片的高度范围
    zMin = sliceHeights(i);
    zMax = sliceHeights(i+1) + overlapRate * (sliceHeights(i+1) - sliceHeights(i));
    
    % 找到属于该切片的面
    inSlice = (faceCenters(:,3) >= zMin & faceCenters(:,3) < zMax);
    sliceCenters = faceCenters(inSlice, :);
    sliceNormals = faceNormals(inSlice, :);
    
    % 为当前切片的每个面生成视点
    for j = 1:size(sliceCenters, 1)
        surfacePoint = sliceCenters(j, :); % 当前面的中心点
        normalVector = sliceNormals(j, :); % 当前面的法向量
        
        % 生成视点（沿法向外扩 viewingDistance）
        viewpoint = surfacePoint + viewingDistance * normalVector;
        viewpoints = [viewpoints; viewpoint]; % 保存视点
        
%         % 可视化视点和方向
%         quiver3(surfacePoint(1), surfacePoint(2), surfacePoint(3), ...
%             normalVector(1), normalVector(2), normalVector(3), ...
%             viewingDistance, 'r'); % 红色箭头表示法向量
         scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3),5 ,'r', 'filled');
    end
end

% 完成
hold off;
disp('基于表面切片的旋转视点生成完成，视点坐标已保存到变量 viewpoints 中。');

