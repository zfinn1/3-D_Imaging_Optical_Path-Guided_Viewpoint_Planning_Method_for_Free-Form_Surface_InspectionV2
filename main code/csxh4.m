%% 主程序
% clear;
% close all;
% clc;

% 1. 读取 STL 文件及数据
stlFile = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stlFile);
vertices = model.Points;
faces = model.ConnectivityList;

% 2. 选取一个面片生成视场区域（此处取第 initialface 个面）
% initialface = 2478;3418
initialface = 2789;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);

targetFace=[A;B;C];

% 调用视场生成函数（请确保 viewfieldPyrCuboid 函数在路径中）
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);
Allpts=[P1;P2;P3;P4;F1;F2;F3;F4];
Centresquare_prev=mean(Allpts(5:8,:),1);                    



% 3. 绘制初始长方体（近面和远面）
figure;
hold on; axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
h_near_prev=fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
h_far_prev=fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);

for i = 1:4
    plot3([Allpts(i,1), Allpts(i+4,1)], [Allpts(i,2), Allpts(i+4,2)], [Allpts(i,3), Allpts(i+4,3)], 'k-', 'LineWidth',2);
end

scatter3(P(1), P(2), P(3), 120, 'r', 'filled');
for i = 1:4
    plot3([P(1), Allpts(i+4,1)], [P(2), Allpts(i+4,2)], [P(3), Allpts(i+4,3)], 'g', 'LineWidth', 2);
end
% 绘制近面（红色，半透明）
h_near = fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'r', 'FaceAlpha', 0.5);
% 绘制远面（上平面，蓝色，半透明）
h_far = fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'b', 'FaceAlpha', 0.5);
% 绘制整个模型（仅作背景参考）
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.2);
E3 = (P3 + F3)/2;
E4 = (P4 + F4)/2;
rotationCenter = (E3 + E4)/2; % 以边中点为旋转中心
axis_vec = (E4 - E3) / norm(E4 - E3);    
[Allpts_new,ct0]=spanviewfield(0.1,1,15,h_near,h_far,rotationCenter,axis_vec,Allpts,model,2);

P1_new=Allpts_new(7,:);P2_new=Allpts_new(8,:);P3_new=Allpts_new(5,:);P4_new=Allpts_new(6,:);
F1_new=Allpts_new(3,:);F2_new=Allpts_new(4,:);F3_new=Allpts_new(1,:);F4_new=Allpts_new(2,:);

if ct0<180
P1_new=Allpts_new(1,:);P2_new=Allpts_new(2,:);P3_new=Allpts_new(3,:);P4_new=Allpts_new(4,:);
F1_new=Allpts_new(5,:);F2_new=Allpts_new(6,:);F3_new=Allpts_new(7,:);F4_new=Allpts_new(8,:);
end

F_center = (F1_new + F2_new + F3_new + F4_new) / 4;
P_center = (P1_new + P2_new + P3_new + P4_new) / 4;
[n_far, d_far] = computePlane(P1_new, P2_new, P3_new);
P_new=P_center-n_far*30;

PF_new=[P1_new; P2_new; P3_new; P4_new];
FF_new=[F1_new; F2_new; F3_new; F4_new];


[squareVertices, filteredIntersections,topFace ,bottomFace] = generateSquareFromNewFace(PF_new, model, targetFace, 10, 5);


for i = 1:4
    plot3([Allpts_new(i,1), Allpts_new(i+4,1)], [Allpts_new(i,2), Allpts_new(i+4,2)], [Allpts_new(i,3), Allpts_new(i+4,3)], 'k-', 'LineWidth',2);
end

scatter3(P_new(1), P_new(2), P_new(3), 120, 'm', 'filled');
for i = 1:4
    plot3([P_new(1), Allpts_new(i,1)], [P_new(2), Allpts_new(i,2)], [P_new(3),Allpts_new(i,3)], 'b', 'LineWidth', 2);
end


top1=topFace(1,:);top2=topFace(2,:);top3=topFace(3,:);top4=topFace(4,:);
bottom1=bottomFace(1,:);bottom2=bottomFace(2,:);bottom3=bottomFace(3,:);bottom4=bottomFace(4,:);

h_far1_prev = fill3([top1(1) top2(1) top3(1) top4(1)], [top1(2) top2(2) top3(2) top4(2)], [top1(3) top2(3) top3(3) top4(3)], 'y', 'FaceAlpha', 0.5);
% 绘制远面（上平面，蓝色，半透明）
h_near1_prev = fill3([bottom1(1) bottom2(1) bottom3(1) bottom4(1)], [bottom1(2) bottom2(2) bottom3(2) bottom4(2)], [bottom1(3) bottom2(3) bottom3(3) bottom4(3)], 'y', 'FaceAlpha', 0.5);  

h_far1 = fill3([top1(1) top2(1) top3(1) top4(1)], [top1(2) top2(2) top3(2) top4(2)], [top1(3) top2(3) top3(3) top4(3)], 'b', 'FaceAlpha', 0.5);
% 绘制远面（上平面，蓝色，半透明）
h_near1 = fill3([bottom1(1) bottom2(1) bottom3(1) bottom4(1)], [bottom1(2) bottom2(2) bottom3(2) bottom4(2)], [bottom1(3) bottom2(3) bottom3(3) bottom4(3)], 'r', 'FaceAlpha', 0.5);

% 整个立体（长方体）的顶点（顶面在前，底面在后）
cuboidVertices = [topFace; bottomFace];

rotationCenter1 = (squareVertices(1,:) + squareVertices(2,:) )/2; % 以边中点为旋转中心
axis_vec1 = -(squareVertices(1,:) - squareVertices(2,:) ) / norm(squareVertices(1,:) - squareVertices(2,:));  


[cuboidVertices_new,ct1]=spanviewfield(0.23,0.5,15,h_near1,h_far1,rotationCenter1 ,axis_vec1,cuboidVertices,model,1);


topFace_new=cuboidVertices_new(1:4,:);
bottomFace_new=cuboidVertices_new(5:8,:);



hold on; grid on; axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('翻越后的视场域');

bottomFace_new_centre = mean(bottomFace_new, 1);
[s, ~] = computePlane(bottomFace_new(1,:), bottomFace_new(2,:), bottomFace_new(3,:));
P_new1 = bottomFace_new_centre - 28 * s;
scatter3(P_new1(1), P_new1(2), P_new1(3), 120, 'k', 'filled');
for i = 1:4
    plot3([P_new1(1), bottomFace_new(i,1)], [P_new1(2), bottomFace_new(i,2)], [P_new1(3), bottomFace_new(i,3)], 'm', 'LineWidth', 2);
end
% 绘制顶面和底面

% 绘制边界
plot3(topFace_new(:,1), topFace_new(:,2), topFace_new(:,3), 'ro-', 'LineWidth',2);
plot3(bottomFace_new(:,1), bottomFace_new(:,2), bottomFace_new(:,3), 'bo-', 'LineWidth',2);
for i = 1:4
    plot3([topFace_new(i,1), bottomFace_new(i,1)], [topFace_new(i,2), bottomFace_new(i,2)], [topFace_new(i,3), bottomFace_new(i,3)], 'k-', 'LineWidth',2);
end
drawnow;


%%【辅助函数】

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
        centroids(i,:) = (v1+v2+v3)/3;
        n_i = cross(v2-v1, v3-v1);
        if norm(n_i) > 0
            normals(i,:) = n_i / norm(n_i);
        else
            normals(i,:) = [0,0,0];
        end
    end
    dists = sqrt(sum((centroids - X).^2,2));
    [~, idx] = min(dists);
    n = normals(idx,:)';
end

  