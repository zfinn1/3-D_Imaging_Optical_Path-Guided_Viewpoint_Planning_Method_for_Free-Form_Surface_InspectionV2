% 清理环境
% 
% % 加载三角形网格（OBJ 文件读取）
% [objFile, objPath] = uigetfile('model.obj', 'C:\Users\86132\Desktop\本科毕设\');
% [objVertices, objFaces] = readObj(fullfile(objPath, objFile));
% 
% % 显示原始三角形网格
% figure;
% trisurf(objFaces, objVertices(:, 1), objVertices(:, 2), objVertices(:, 3), ...
%     'FaceColor', 'cyan', 'EdgeColor', 'k');
% title('Original Triangular Mesh');
% axis equal;
% camlight;
% lighting phong;
% 
% % 执行 Catmull-Clark 算法进行一次细分
% [newVertices, newFaces] = catmullClark(objVertices, objFaces);
% 
% % 显示细分后的四边形网格
% figure;
% trisurf(newFaces, newVertices(:, 1), newVertices(:, 2), newVertices(:, 3), ...
%     'FaceColor', 'magenta', 'EdgeColor', 'k');
% title('Catmull-Clark Subdivided Mesh (Quadrilateral)');
% axis equal;
% camlight;
% lighting phong;
% 
% disp('Catmull-Clark subdivision completed.');

% 加载三角形网格
 clear;
 clc;
 close all;

[objFile, objPath] = uigetfile('model.obj', 'C:\Users\86132\Desktop\本科毕设\');

if objFile == 0
    disp('No file selected.');
    return;
end
[objVertices, objFaces] = readObj(fullfile(objPath, objFile));

% 可视化原始网格
figure;
trisurf(objFaces, objVertices(:, 1), objVertices(:, 2), objVertices(:, 3), ...
    'FaceColor', 'cyan', 'EdgeColor', 'k');
title('Original Triangular Mesh');
axis equal;
camlight;
lighting phong;

% 进行 Catmull-Clark 细分
numSubdivisions = 5; % 细分次数
for i = 1:numSubdivisions
    [objVertices, objFaces] = catmullClark(objVertices, objFaces);
end

% 可视化细分后的网格
figure;
trisurf(objFaces, objVertices(:, 1), objVertices(:, 2), objVertices(:, 3), ...
    'FaceColor', 'magenta', 'EdgeColor', 'k');
title('Subdivided Mesh');
axis equal;
camlight;
lighting phong;

disp('Subdivision completed.');

% 函数：读取 OBJ 文件
function [vertices, faces] = readObj(filename)
    % 打开文件
    fid = fopen(filename, 'r');
    if fid == -1
        error('File not found.');
    end
    
    vertices = [];
    faces = [];
    
    while true
        tline = fgetl(fid);
        if ~ischar(tline), break; end
        
        % 读取顶点数据
        if startsWith(tline, 'v ')
            vertex = sscanf(tline, 'v %f %f %f');
            vertices = [vertices; vertex'];
        % 读取面片数据
        elseif startsWith(tline, 'f ')
            face = sscanf(tline, 'f %d %d %d');
            faces = [faces; face'];
        end
    end
    
    fclose(fid);
end

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
