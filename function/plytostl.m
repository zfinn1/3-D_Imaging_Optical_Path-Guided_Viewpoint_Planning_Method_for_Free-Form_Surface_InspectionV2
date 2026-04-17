% clear;
% clc;
% close all;
% % 读取 STL 文件
% model = stlread('C:\Users\86132\Desktop\本科毕设\叶片模型.stl');
% 
% % 提取顶点数据
% vertices = model.Points;
% 
% % 将顶点转换为点云对象
% ptCloud = pointCloud(vertices);
% 
% % 可视化点云
% figure;
% pcshow(ptCloud);
% title('Point Cloud from STL');
% 
% % 将点云保存为 PLY 文件
% pcwrite(ptCloud, 'output_model.ply');
% % 读取点云数据
% ptCloud = pcread('output_model.ply'); % PLY文件读取
% points = ptCloud.Location; % 获取点坐标
% 
% % 对点进行Delaunay三角剖分
% tri = delaunay(points(:,1), points(:,2));  % 对2D点进行三角剖分
% % 对于3D点，使用类似的函数：tri = delaunay(points(:,1), points(:,2), points(:,3));
% 
% % 可视化三角形网格
% trisurf(tri, points(:,1), points(:,2), points(:,3), 'FaceColor', 'cyan');
% 
% % 导出STL文件
% stlwrite('output_model.stl', tri, points);
% 
% % 辅助函数：保存STL文件
% function stlwrite(filename, faces, vertices)
%     % 创建STL文件
%     fid = fopen(filename, 'w');
%     fprintf(fid, 'solid 3d_model\n');
%     for i = 1:size(faces, 1)
%         v1 = vertices(faces(i, 1), :);
%         v2 = vertices(faces(i, 2), :);
%         v3 = vertices(faces(i, 3), :);
%         normal = cross(v2 - v1, v3 - v1);
%         normal = normal / norm(normal); % 单位法向量
%         fprintf(fid, '  facet normal %f %f %f\n', normal);
%         fprintf(fid, '    outer loop\n');
%         fprintf(fid, '      vertex %f %f %f\n', v1);
%         fprintf(fid, '      vertex %f %f %f\n', v2);
%         fprintf(fid, '      vertex %f %f %f\n', v3);
%         fprintf(fid, '    endloop\n');
%         fprintf(fid, '  endfacet\n');
%     end
%     fprintf(fid, 'endsolid 3d_model\n');
%     fclose(fid);
% end
% clear;
% clc;
% close all;
% 
% % 读取 STL 文件
% model = stlread('C:\Users\86132\Desktop\本科毕设\叶片模型.stl');
% 
% % 提取顶点数据
% vertices = model.Points;
% faces = model.ConnectivityList;
% % 将顶点转换为点云对象
% ptCloud = pointCloud(vertices);
% 
% % 可视化点云
% figure;
% pcshow(ptCloud);
% title('Point Cloud from STL');
% figure;
% trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'k');
% title('Original Triangular Mesh');
% axis equal;
% camlight;
% lighting phong;
% % 将点云保存为 PLY 文件
% pcwrite(ptCloud, 'output_model.ply');
% 
% % 读取点云数据
% ptCloud = pcread('output_model.ply'); % 读取PLY文件
% points = ptCloud.Location; % 获取点坐标
% 
% % 对3D点进行 Delaunay 三角剖分
% tri = delaunay(points(:, 1), points(:, 2), points(:, 3));  % 对3D点进行三角剖分
% 
% % 可视化三角形网格
% figure;
% trisurf(tri, points(:,1), points(:,2), points(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k');
% title('Delaunay Triangulation');
% axis equal;
% camlight;
% lighting phong;
% 
% % 导出STL文件
% stlwrite('output_model.stl', tri, points);
% 
% % 辅助函数：保存STL文件
% function stlwrite(filename, faces, vertices)
%     % 创建STL文件
%     fid = fopen(filename, 'w');
%     fprintf(fid, 'solid 3d_model\n');
%     
%     for i = 1:size(faces, 1)
%         v1 = vertices(faces(i, 1), :);
%         v2 = vertices(faces(i, 2), :);
%         v3 = vertices(faces(i, 3), :);
%         
%         % 计算法向量
%         normal = cross(v2 - v1, v3 - v1);
%         normal = normal / norm(normal); % 单位法向量
%         
%         % 写入STL面片数据
%         fprintf(fid, '  facet normal %f %f %f\n', normal);
%         fprintf(fid, '    outer loop\n');
%         fprintf(fid, '      vertex %f %f %f\n', v1);
%         fprintf(fid, '      vertex %f %f %f\n', v2);
%         fprintf(fid, '      vertex %f %f %f\n', v3);
%         fprintf(fid, '    endloop\n');
%         fprintf(fid, '  endfacet\n');
%     end
%     
%     fprintf(fid, 'endsolid 3d_model\n');
%     fclose(fid);
% end
clear;
clc;
close all;

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

% 读取点云数据
ptCloud = pcread('output_model.ply'); % 读取PLY文件
points = ptCloud.Location; % 获取点坐标

% 对3D点进行 Delaunay 三角剖分
tri = delaunay(points(:,1), points(:,2), points(:,3));  % 对3D点进行三角剖分

% 可视化原始三角形网格
figure;
trisurf(tri, points(:,1), points(:,2), points(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k');
title('Original Delaunay Triangulation');
axis equal;
camlight;
lighting phong;

% 进行三角形到四边形的转换
quadFaces = triToQuad(points, tri);

% 可视化四边形网格
figure;
patch('Faces', quadFaces, 'Vertices', points, 'FaceColor', 'magenta', 'EdgeColor', 'k');
title('Quad Mesh');
axis equal;
camlight;
lighting phong;

% 导出STL文件
stlwrite('output_model_quads.stl', quadFaces, points);

% 辅助函数：将三角形网格转换为四边形网格
function quadFaces = triToQuad(vertices, faces)
    % quadFaces 用来存储四边形面片
    quadFaces = [];
    
    % 遍历所有三角形
    for i = 1:size(faces, 1)
        % 获取三角形的三个顶点
        v1 = faces(i, 1);
        v2 = faces(i, 2);
        v3 = faces(i, 3);
        
        % 寻找与当前三角形共享边的其他三角形
        for j = i+1:size(faces, 1)
            sharedEdge = intersect(faces(i, :), faces(j, :));
            if numel(sharedEdge) == 2  % 两个三角形共享一条边
                % 获取相邻三角形的剩余顶点
                otherFace = setdiff(faces(j, :), sharedEdge);
                % 合并成四边形
                quadFaces = [quadFaces; sharedEdge, otherFace];
                break;
            end
        end
    end
end

% 辅助函数：保存STL文件
function stlwrite(filename, faces, vertices)
    % 创建STL文件
    fid = fopen(filename, 'w');
    fprintf(fid, 'solid 3d_model\n');
    
    for i = 1:size(faces, 1)
        v1 = vertices(faces(i, 1), :);
        v2 = vertices(faces(i, 2), :);
        v3 = vertices(faces(i, 3), :);
        
        % 计算法向量
        normal = cross(v2 - v1, v3 - v1);
        normal = normal / norm(normal); % 单位法向量
        
        % 写入STL面片数据
        fprintf(fid, '  facet normal %f %f %f\n', normal);
        fprintf(fid, '    outer loop\n');
        fprintf(fid, '      vertex %f %f %f\n', v1);
        fprintf(fid, '      vertex %f %f %f\n', v2);
        fprintf(fid, '      vertex %f %f %f\n', v3);
        fprintf(fid, '    endloop\n');
        fprintf(fid, '  endfacet\n');
    end
    
    fprintf(fid, 'endsolid 3d_model\n');
    fclose(fid);
end
