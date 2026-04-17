% % 输入网格数据
% % 示例数据：定义一个三角形网格
% mesh.vertices = [0, 0, 0; 1, 0, 0; 0, 1, 0; 1, 1, 0; 0.5, 0.5, 0];
% mesh.faces = [1, 2, 5; 2, 4, 5; 4, 3, 5; 3, 1, 5];
% 
% % 处理边界，如果三角形数量为奇数，增加一个虚拟三角形
% if mod(size(mesh.faces, 1), 2) == 1
%     % 查找边界边
%     edges = sort(nchoosek(1:size(mesh.vertices, 1), 2), 2);
%     edgeUsage = zeros(size(edges, 1), 1);
%     for i = 1:size(mesh.faces, 1)
%         faceEdges = nchoosek(mesh.faces(i, :), 2);
%         for j = 1:size(faceEdges, 1)
%             edgeIdx = find(ismember(edges, sort(faceEdges(j, :), 2), 'rows'));
%             edgeUsage(edgeIdx) = edgeUsage(edgeIdx) + 1;
%         end
%     end
%     borderEdge = edges(edgeUsage == 1, :);
% 
%     if ~isempty(borderEdge)
%         % 获取与边界边相邻的面
%         faceToDivide = find(any(ismember(mesh.faces, borderEdge(:)), 2), 1);
%         opposedVert = setdiff(mesh.faces(faceToDivide, :), borderEdge);
% 
%         % 创建新顶点（中点）
%         middle = (mesh.vertices(borderEdge(1), :) + mesh.vertices(borderEdge(2), :)) / 2;
%         mesh.vertices(end + 1, :) = middle; % 添加新顶点
% 
%         % 创建两个新三角形面
%         newFace1 = [size(mesh.vertices, 1), borderEdge(1), opposedVert];
%         newFace2 = [size(mesh.vertices, 1), borderEdge(2), opposedVert];
%         mesh.faces = [mesh.faces; newFace1; newFace2];
% 
%         % 删除原三角形面
%         mesh.faces(faceToDivide, :) = [];
%     end
% end
% 
% % 初始化边评分
% edges = sort(nchoosek(1:size(mesh.vertices, 1), 2), 2);
% edgeScores = Inf(size(edges, 1), 1);
% for i = 1:size(edges, 1)
%     edge = edges(i, :);
%     adjacentFaces = find(sum(ismember(mesh.faces, edge), 2) == 2);
%     if length(adjacentFaces) ~= 2
%         continue; % 只处理内部边
%     end
%     face1 = mesh.faces(adjacentFaces(1), :);
%     face2 = mesh.faces(adjacentFaces(2), :);
%     commonEdge = intersect(face1, face2);
%     vert_t0 = setdiff(face1, commonEdge);
%     vert_t1 = setdiff(face2, commonEdge);
%     quadVerts = [vert_t0, commonEdge(1), vert_t1, commonEdge(2)];
%     v01 = normalize(mesh.vertices(quadVerts(2), :) - mesh.vertices(quadVerts(1), :));
%     v03 = normalize(mesh.vertices(quadVerts(4), :) - mesh.vertices(quadVerts(1), :));
%     v21 = normalize(mesh.vertices(quadVerts(2), :) - mesh.vertices(quadVerts(3), :));
%     v23 = normalize(mesh.vertices(quadVerts(4), :) - mesh.vertices(quadVerts(3), :));
%     edgeScores(i) = abs(dot(v01, v03)) + abs(dot(v21, v23));
% end
% 
% % 转换为四边形网格
% while any(size(mesh.faces, 2) == 3)
%     % 找到最优边
%     [~, bestEdgeIdx] = min(edgeScores);
%     bestEdge = edges(bestEdgeIdx, :);
% 
%     % 获取与该边相邻的两个三角形
%     adjacentFaces = find(sum(ismember(mesh.faces, bestEdge), 2) == 2);
%     face1 = mesh.faces(adjacentFaces(1), :);
%     face2 = mesh.faces(adjacentFaces(2), :);
% 
%     % 合并两个三角形
%     commonEdge = intersect(face1, face2);
%     vert_t0 = setdiff(face1, commonEdge);
%     vert_t1 = setdiff(face2, commonEdge);
%     quadVerts = [vert_t0, commonEdge(1), vert_t1, commonEdge(2)];
% 
%     % 更新网格
%     mesh.faces(adjacentFaces, :) = [];
%     mesh.faces(end + 1, :) = quadVerts;
% 
%     % 更新边评分
%     edgeScores = Inf(size(edges, 1), 1);
%     for i = 1:size(edges, 1)
%         edge = edges(i, :);
%         adjacentFaces = find(sum(ismember(mesh.faces, edge), 2) == 2);
%         if length(adjacentFaces) ~= 2
%             continue;
%         end
%         face1 = mesh.faces(adjacentFaces(1), :);
%         face2 = mesh.faces(adjacentFaces(2), :);
%         commonEdge = intersect(face1, face2);
%         vert_t0 = setdiff(face1, commonEdge);
%         vert_t1 = setdiff(face2, commonEdge);
%         quadVerts = [vert_t0, commonEdge(1), vert_t1, commonEdge(2)];
%         v01 = normalize(mesh.vertices(quadVerts(2), :) - mesh.vertices(quadVerts(1), :));
%         v03 = normalize(mesh.vertices(quadVerts(4), :) - mesh.vertices(quadVerts(1), :));
%         v21 = normalize(mesh.vertices(quadVerts(2), :) - mesh.vertices(quadVerts(3), :));
%         v23 = normalize(mesh.vertices(quadVerts(4), :) - mesh.vertices(quadVerts(3), :));
%         edgeScores(i) = abs(dot(v01, v03)) + abs(dot(v21, v23));
%     end
% end
% 
% % 显示结果
% disp('转换后的四边形网格：');
% disp(mesh.faces);
% 
% % 辅助函数：归一化向量
% function normalizedVec = normalize(vec)
%     normalizedVec = vec / norm(vec);
% end
clear;
clc;
close all;

% 选择 .obj 文件
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
numSubdivisions = 1; % 细分次数
for i = 1:numSubdivisions
    [objVertices, objFaces] = catmullClark(objVertices, objFaces);
end

% 将三角形面片转换为四边形
[quadVertices, quadFaces] = triToQuad(objVertices, objFaces);



% 可视化四边形网格
figure;
patch('Faces', quadFaces, 'Vertices', quadVertices, 'FaceColor', 'magenta', 'EdgeColor', 'k');
title('Subdivided Mesh with Quads');
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
        newFaces = [newFaces; [face(1), size(vertices, 1) + i, size(vertices, 1) + i + 1]]; % 注意更新这里的面片
    end
    vertices = [vertices; newVertices];
    faces = newFaces;
end

% 函数：将三角形面片转换为四边形面片
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
        % 获取三角形面片的三个顶点索引
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
                
                % 获取共享边的两个顶点和相邻三角形的其他两个顶点，形成四边形
                newQuadFace = [sharedEdge, otherFace];
                
                % 将新的四边形面片添加到 quadFaces 中
                quadFaces = [quadFaces; newQuadFace];
                break;
            end
        end
    end
end
