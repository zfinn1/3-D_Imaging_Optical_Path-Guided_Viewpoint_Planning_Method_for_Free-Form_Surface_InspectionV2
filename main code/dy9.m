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
%         % 确保视点生成在两个切片的区域之间
%         if i == 1
%             viewpoint = surfacePoint + (zMin - surfacePoint(3)) * normalVector; % 从最底层切片生成视点
%         else
%             viewpoint = surfacePoint + (zMax - surfacePoint(3)) * normalVector; % 从最顶层切片生成视点
%         end
%         
%         viewpoints = [viewpoints; viewpoint]; % 保存视点
%         
%         % 可视化视点和方向
% %         quiver3(surfacePoint(1), surfacePoint(2), surfacePoint(3), ...
% %             normalVector(1), normalVector(2), normalVector(3), ...
% %             viewingDistance, 'r'); % 红色箭头表示法向量
%         plot3(viewpoint(1), viewpoint(2), viewpoint(3), 'bo'); % 蓝点表示视点
%     end
% end
% 
% % 完成
% hold off;
% disp('基于表面切片的旋转视点生成完成，视点坐标已保存到变量 viewpoints 中。');
clear;
close all;
clc;

% 设置文件路径
objFile = 'C:\Users\86132\Desktop\本科毕设\model2.obj';  % 替换为实际的 OBJ 文件路径

% 读取 OBJ 文件中的顶点和面
[vertices, faces] = readObjFile(objFile);

% 可视化 3D 四边形模型
figure;
hold on;
axis equal;
camlight;
lighting phong;
view(3);  % 设置为3D视角
title('Visualizing 3D Quad OBJ Model');

% 绘制每个四边形面
for i = 1:size(faces, 1)
    % 获取四个顶点的坐标
    v1 = vertices(faces(i, 1), :);
    v2 = vertices(faces(i, 2), :);
    v3 = vertices(faces(i, 3), :);
    v4 = vertices(faces(i, 4), :);
    
    % 创建一个四边形面
    fill3([v1(1), v2(1), v3(1), v4(1)], ...
          [v1(2), v2(2), v3(2), v4(2)], ...
          [v1(3), v2(3), v3(3), v4(3)], 'cyan'); % 'cyan' 为面颜色
end

% 读取 OBJ 文件的函数
function [vertices, faces] = readObjFile(filename)
    % 打开 OBJ 文件
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件: %s', filename);
    end
    
    vertices = [];
    faces = [];
    
    % 逐行读取 OBJ 文件内容
    while ~feof(fid)
        line = fgetl(fid);
        
        % 如果是顶点数据
        if strncmp(line, 'v ', 2)
            data = sscanf(line, 'v %f %f %f');
            vertices = [vertices; data'];
            
        % 如果是面数据（四边形面）
        elseif strncmp(line, 'f ', 2)
            data = sscanf(line, 'f %d %d %d %d');
            faces = [faces; data'];
        end
    end
    
    % 关闭文件
    fclose(fid);
end


