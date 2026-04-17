% clear;
% close all;
% clc;
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; 
% % 读取 STL 文件
% model= stlread(stlFile);
% vertices = model.Points; % 提取模型的顶点坐标（点云数据）
% faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）
clear;
close all;
clc;
stlFile = '111.stl'; 
% 读取 STL 文件
model= stlread(stlFile);
vertices = model.Points; % 提取模型的顶点坐标（点云数据）
faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成


[simplifiedFaces, simplifiedVertices] = reducepatch(faces, vertices, 0.2);
triToQuad(simplifiedVertices, simplifiedFaces);
function [quadVertices, quadFaces] = triToQuad(vertices, faces)
    % vertices: 顶点坐标 (N x 3)
    % faces: 面片索引 (M x 3)
    % quadVertices: 四边形顶点坐标
    % quadFaces: 四边形面片索引
    
    % 初始化顶点和面片
    quadVertices = vertices;
    quadFaces = [];
    
    % 遍历所有三角形面片
    for i = 1:size(faces, 1)
        % 获取三角形面片的三个顶点
        face = faces(i, :);
        v1 = face(1);
        v2 = face(2);
        v3 = face(3);
        
        % 找到与当前三角形共享边的相邻三角形
        for j = i+1:size(faces, 1)
            % 检查相邻三角形
            sharedEdge = intersect(faces(i, :), faces(j, :));
            if numel(sharedEdge) == 2  % 两个三角形共享一条边
                % 获取相邻三角形的剩余顶点
                otherFace = setdiff(faces(j, :), sharedEdge);
                % 合并两个三角形生成四边形
                quadFaces = [quadFaces; [sharedEdge, otherFace]];
                break;
            end
        end
    end
    
    % 可视化生成的四边形网格
    figure;
    trisurf(quadFaces, quadVertices(:, 1), quadVertices(:, 2), quadVertices(:, 3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k');
    title('Tri-to-Quad Converted Mesh');
    axis equal;
    camlight;
    lighting phong;
end



% 
% clear;
% close all;
% clc;
% 
% % 设置 STL 文件路径
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl';
% 
% % 读取 STL 文件
% model = stlread(stlFile);
% vertices = model.Points; % 提取模型的顶点坐标（点云数据）
% faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）
% 
% % 执行三角形到四边形的转换
% [quadVertices, quadFaces] = triToQuad(vertices, faces);
% 
% % 可视化四边形网格
% figure;
% patch('Faces', quadFaces, 'Vertices', quadVertices, 'FaceColor', 'cyan', 'EdgeColor', 'k');
% title('Tri-to-Quad Converted Mesh');
% axis equal;
% camlight;
% lighting phong;
% 
% function [quadVertices, quadFaces] = triToQuad(vertices, faces)
%     % vertices: 顶点坐标 (N x 3)
%     % faces: 面片索引 (M x 3)
%     % quadVertices: 四边形顶点坐标
%     % quadFaces: 四边形面片索引
%     
%     % 初始化顶点和面片
%     quadVertices = vertices; % 复制原始顶点
%     quadFaces = [];
%     
%     % 遍历所有三角形面片
%     for i = 1:size(faces, 1)
%         % 获取三角形面片的三个顶点索引
%         face = faces(i, :);
%         v1 = face(1);
%         v2 = face(2);
%         v3 = face(3);
%         
%         % 找到与当前三角形共享边的相邻三角形
%         for j = i+1:size(faces, 1)
%             % 检查相邻三角形
%             sharedEdge = intersect(faces(i, :), faces(j, :));
%             if numel(sharedEdge) == 2  % 两个三角形共享一条边
%                 % 获取相邻三角形的剩余顶点
%                 otherFace = setdiff(faces(j, :), sharedEdge);
%                 
%                 % 获取共享边的两个顶点和相邻三角形的其他两个顶点，形成四边形
%                 newQuadFace = [sharedEdge, otherFace];
%                 
%                 % 将新的四边形面片添加到 quadFaces 中
%                 quadFaces = [quadFaces; newQuadFace];
%                 break;
%             end
%         end
%     end
% end

