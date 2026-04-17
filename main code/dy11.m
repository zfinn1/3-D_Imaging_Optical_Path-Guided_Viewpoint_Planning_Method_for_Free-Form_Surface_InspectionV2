% clear;
% close all;
% clc;
% 
% stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; 
% % 读取 STL 文件
% model= stlread(stlFile);
% vertices = model.Points; % 提取模型的顶点坐标（点云数据）
% faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）
% % 可视化原始网格
% figure;
% trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'k');
% title('Original Triangular Mesh');
% axis equal;
% camlight;
% lighting phong;



clear;
close all;
clc;
stlFile = 'C:\Users\86132\Desktop\本科毕设\叶片模型.stl'; 
% 读取 STL 文件
model= stlread(stlFile);
vertices = model.Points; % 提取模型的顶点坐标（点云数据）
faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成


[simplifiedFaces, simplifiedVertices] = reducepatch(faces, vertices, 0.1);
% 可视化叶片模型的三角形面片
figure;
trisurf(simplifiedFaces,  simplifiedVertices(:,1),  simplifiedVertices(:,2),  simplifiedVertices(:,3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k'); % 'FaceColor' 为面片的颜色，'EdgeColor' 为边缘的颜色
axis equal; % 设置坐标轴比例，使各轴单位长度相等
title('飞机叶片三角形面片分布');
xlabel('X'); ylabel('Y'); zlabel('Z');


% 进行 Catmull-Clark 细分
numSubdivisions = 8; % 细分次数
for i = 1:numSubdivisions
    [vertices, faces] = catmullClark(simplifiedVertices, simplifiedFaces);
end

% 可视化细分后的网格
figure;
trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
    'FaceColor', 'magenta', 'EdgeColor', 'k');
title('Subdivided Mesh');
axis equal;
camlight;
lighting phong;

disp('Subdivision completed.');

% 函数：读取 STL 文件


% 函数：Catmull-Clark 细分
function [vertices, faces] = catmullClark(vertices, faces)
    % 初始化新顶点数组
    newVertices = vertices;
    faceMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    % 生成新顶点
    edgeMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    for i = 1:size(faces, 1)
        face = faces(i, :);
        newFaceVertices = [];
        for j = 1:3
            v1 = face(j);
            v2 = face(mod(j, 3) + 1);
            key = sprintf('%d-%d', min(v1, v2), max(v1, v2));
            if isKey(edgeMap, key)
                edgeVertex = edgeMap(key);
            else
                edgeVertex = mean([vertices(v1, :); vertices(v2, :)], 1);
                edgeMap(key) = edgeVertex;
            end
            newFaceVertices = [newFaceVertices; edgeVertex];
        end
        
        newVertex = mean(vertices(face, :), 1);
        newVertices = [newVertices; newVertex];
        faceMap(sprintf('%d', i)) = newFaceVertices;
    end
    
    % 更新顶点和面片
    newFaces = [];
    for i = 1:size(faces, 1)
        face = faces(i, :);
        newFaces = [newFaces; [face(1), size(vertices, 1) + i, size(vertices, 1) + i + 1]];
    end
    vertices = [vertices; newVertices];
    faces = newFaces;
end
