

%  读取 STL 模型并获取投影点
fv = stlread('C:\Users\86132\Desktop\c\111.stl');
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
vertices = fv.Points;
faces = fv.ConnectivityList;
xy_vertices = vertices(:, 1:2);
kdtree = buildKDTreeForTriangles(faces, vertices);
% 计算非凸边界（可以调整因子）
k = boundary(xy_vertices(:,1), xy_vertices(:,2), 0.8);

% 选择一个边界点作为直线起点（这里选 k 中的第一个点）
start_point = xy_vertices(k(14), :);

% 选择另一个边界点确定直线方向（例如这里取 k 中的第 3 个点）
if length(k) > 2
    next_index = k(3);
else
    error('边界点不足以确定方向');
end
next_point = xy_vertices(next_index, :);

% 计算切向量并归一化
tangent = next_point - start_point;
tangent = tangent / norm(tangent);

% 定义直线长度（正方形边长）
line_length = 10;
% 计算直线终点（在 xy 平面上，z=0）
end_point = start_point + line_length * tangent;

% 构造正方形的 4 个顶点（初始在 xy 平面上，即 z=0）
V2 = [start_point, 0];          % 底边起点
V1 = [end_point, 0];            % 底边终点
V4 = [end_point, line_length];  % 顶边终点（沿 z 方向延伸）
V3 = [start_point, line_length];% 顶边起点

% 计算参考点在模型中的 z 坐标
% 这里以正方形底边起点为参考，寻找其在 STL 模型中最近的点
d = sqrt((vertices(:,1) - start_point(1)).^2 + (vertices(:,2) - start_point(2)).^2);
[~, idx] = min(d);
z_surface = vertices(idx, 3);  % 该处的 z 坐标


% 将正方形所有顶点在 z 方向上平移，使得底边位于模型表面附近
V1(3) = z_surface;
V2(3) = z_surface;
% 顶边相对于底边保持相同的高度差（这里为 line_length）
V3(3) = z_surface + line_length;
V4(3) = z_surface + line_length;
X=(V1+V2+V3+V4)/4;
[n_plane,idx]= getModelNormalAt(X, fv);

initialface = idx;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);

maybe=[P1;P2;P3;P4;F1;F2;F3;F4];
maybe=allSavedViews{1,1}{1,1};
P1=maybe(1,:);
P2=maybe(2,:);
P3=maybe(3,:);
P4=maybe(4,:);
F1=maybe(5,:);
F2=maybe(6,:);
F3=maybe(7,:);
F4=maybe(8,:);
% maybe=[3.36550479346950,39.2571645444292,48.8683544588303;
%     2.70598252667300,29.2845345144315,48.5341678876031;
%     4.49904816605798,28.8366223468094,58.3618985668063;
%     5.15857043285448,38.8092523768071,58.6960851380335;
%     2.38392471017290,39.3159884319992,49.0501243417223;
%     1.72440244337640,29.3433584020015,48.7159377704951;
%     3.51746808276138,28.8954462343794,58.5436684496984;
%     4.17699034955787,38.8680762643771,58.8778550209256];
% 
% P1=[3.36550479346950,39.2571645444292,48.8683544588303];
% P2=[2.70598252667300,29.2845345144315,48.5341678876031];
% P3=[4.49904816605798,28.8366223468094,58.3618985668063];
% P4=[5.15857043285448,38.8092523768071,58.6960851380335];
% F1=[2.38392471017290,39.3159884319992,49.0501243417223];
% F2=[1.72440244337640,29.3433584020015,48.7159377704951];
% F3=[3.51746808276138,28.8954462343794,58.5436684496984];
% F4=[4.17699034955787,38.8680762643771,58.8778550209256];
[n, d] = computePlane(P1, P2, P3);

[n8, d8] = computePlane(A, B, C);

% 计算中点
I1 = (P1 + F1) / 2;
I2 = (P2 + F2) / 2;
I3 = (P3 + F3) / 2;
I4 = (P4 + F4) / 2;



P = mean(maybe(:,:),1)+n*28;        % 3×1 或 1×3 向量，来自你的 viewfieldPyrCuboid 输出
n = n'; % 3×1 单位法向量


h_base  = 4;   % 大圆柱高度
r_base  = 1.5;   % 大圆柱底部半径
h_neck  = 2;   % 小圆柱高度
r_neck  = 0.5;   % 小圆柱半径
N       = 40;    % 分辨率

% 大圆柱
[XB0,YB0,ZB0] = cylinder([r_base r_base], N);
ZB0 = ZB0 * h_base;

% 小圆柱
[XN0,YN0,ZN0] = cylinder([r_neck r_neck], N);
ZN0 = ZN0 * h_neck;
 

v = [0;0;-1];
% 旋转轴为 v × n，角度为 arccos(v·n)
axis_rot = cross(v, n);
if norm(axis_rot)<1e-6
    R = eye(3);
else
    axis_rot = axis_rot / norm(axis_rot);
    theta = acos(dot(v,n));
    K = [      0, -axis_rot(3),  axis_rot(2);
         axis_rot(3),       0, -axis_rot(1);
        -axis_rot(2),  axis_rot(1),       0 ];
    R = eye(3) + sin(theta)*K + (1-cos(theta))*(K*K);
end


% 合并顶点
VB = [XB0(:), YB0(:), ZB0(:)];  % base cylinder verts
VN = [XN0(:), YN0(:), ZN0(:)+h_base]; % neck verts, 平移到大圆柱顶端

% 旋转
VB_rot = (R * VB')';
VN_rot = (R * VN')';

% % 平移到 P
% VB_rot = VB_rot + P(:)';
% VN_rot = VN_rot + P(:)';

optical_center_local = R * [0; 0; h_base];  % 小圆柱底部旋转后的真实位置

% 计算将 optical_center_local 移动到 P 所需的平移向量
T = P(:) - optical_center_local;

% 执行平移
VB_rot = VB_rot + T';
VN_rot = VN_rot + T';
% 重塑为 surface 所需格式
XB = reshape(VB_rot(:,1), size(XB0));
YB = reshape(VB_rot(:,2), size(YB0));
ZB = reshape(VB_rot(:,3), size(ZB0));
XN = reshape(VN_rot(:,1), size(XN0));
YN = reshape(VN_rot(:,2), size(YN0));
ZN = reshape(VN_rot(:,3), size(ZN0));





figure; hold on; axis equal; grid on; view(3);

trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('相机光心在 P，光轴对准面片法向');
% 提取坐标
X = [A(1), B(1), C(1)];
Y = [A(2), B(2), C(2)];
Z = [A(3), B(3), C(3)];

% 绘图

fill3(X, Y, Z, 'r'); % 面片颜色为青色
% 绘制相机“大瓶身”和“颈部”
surf(XB,YB,ZB, 'FaceColor',[0.5 0.5 0.5],'EdgeColor','none','FaceAlpha',0.8);
% surf(XN,YN,ZN, 'FaceColor',[0.3 0.3 0.3],'EdgeColor','none','FaceAlpha',0.9);

centroid = (A + B + C)/3;
P_e=[P(1),P(2),centroid(3)];
 HH=-centroid+P_e;
 ZZ=[0,0,1];
 HH1= -cross(HH, ZZ);

% 绘制光心 P 和法向量
plot3(I1(1),I1(2),I1(3),'ro','MarkerSize',8,'LineWidth',2);
plot3(P(1),P(2),P(3),'ro','MarkerSize',8,'LineWidth',2);
% plot3(P(1),P(2),centroid(3),'ro','MarkerSize',8,'LineWidth',2);
quiver3(P(1),P(2),P(3),- n(1),-n(2),-n(3), 28, 'r', 'LineWidth',2);

legend({'Camera Body','Camera Neck','Optical Center','Optical Axis'},'Location','best');
light; lighting gouraud;
visualizeViewField(maybe(1:4,:), maybe(5:8,:));
plot3(centroid(1),centroid(2),centroid(3),'ro','MarkerSize',8,'LineWidth',2);
text(centroid(1),centroid(2),centroid(3),'  Origin','FontSize',12,'Color','r');

axisLen = 30;
quiver3(centroid(1),centroid(2),centroid(3), HH1(1),HH1(2),0,'g','LineWidth',3);
quiver3(centroid(1),centroid(2),centroid(3), HH(1),HH(2),0,'g','LineWidth',3);
quiver3(centroid(1),centroid(2),centroid(3), 0,0,axisLen,'g','LineWidth',3);
% 
% quiver3(centroid(1),centroid(2),centroid(3), -axisLen,0,0,'r','LineWidth',2);
% quiver3(centroid(1),centroid(2),centroid(3), 0,-axisLen,0,'r','LineWidth',2);
% quiver3(centroid(1),centroid(2),centroid(3), 0,0,axisLen,'r','LineWidth',2);
text(centroid(1)+axisLen,centroid(2),centroid(3),'X_w','FontSize',15,'Color','g');
text(centroid(1),centroid(2)+axisLen,centroid(3),'Y_w','FontSize',15,'Color','g');
text(centroid(1),centroid(2),centroid(3)+axisLen,'Z_w','FontSize',15,'Color','g');

% 画顶点到底面各点的棱线
plot3([P(1), F1(1)], [P(2), F1(2)], [P(3), F1(3)], 'b-');
plot3([P(1), F2(1)], [P(2), F2(2)], [P(3), F2(3)], 'b-');
plot3([P(1), F3(1)], [P(2), F3(2)], [P(3), F3(3)], 'b-');
plot3([P(1), F4(1)], [P(2), F4(2)], [P(3), F4(3)], 'b-');

plot3([F4(1), F1(1)], [F4(2), F1(2)], [F4(3), F1(3)], 'r-');
plot3([F1(1), F2(1)], [F1(2), F2(2)], [F1(3), F2(3)], 'r-');
plot3([F4(1), F3(1)], [F4(2), F3(2)], [F4(3), F3(3)], 'r-');
plot3([F2(1), F3(1)], [F2(2), F3(2)], [F2(3), F3(3)], 'r-');

plot3([P4(1), P1(1)], [P4(2), P1(2)], [P4(3), P1(3)], 'r-');
plot3([P1(1), P2(1)], [P1(2), P2(2)], [P1(3), P2(3)], 'r-');
plot3([P4(1), P3(1)], [P4(2), P3(2)], [P4(3), P3(3)], 'r-');
plot3([P2(1), P3(1)], [P2(2), P3(2)], [P2(3), P3(3)], 'r-');

plot3([P4(1), F4(1)], [P4(2), F4(2)], [P4(3), F4(3)], 'r-');
plot3([P3(1), F3(1)], [P3(2), F3(2)], [P3(3), F3(3)], 'r-');
plot3([P2(1), F2(1)], [P2(2), F2(2)], [P2(3), F2(3)], 'r-');
plot3([P1(1), F1(1)], [P1(2), F1(2)], [P1(3), F1(3)], 'r-');
% plot3([P(1), F4(1)], [P(2), F4(2)], [P(3), F4(3)], 'k-');
axis off;







function [n,idx]= getModelNormalAt(X, model)
    % 根据模型面片计算，返回与点 X 最近的面片的法向量和索引
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    centroids = zeros(numFaces,3);
    normals = zeros(numFaces,3);
    
    % 计算每个面片的重心和法向量
    for i = 1:numFaces
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        centroids(i,:) = (v1 + v2 + v3) / 3;
        n_i = cross(v2 - v1, v3 - v1);
        
        if norm(n_i) > 0
            normals(i,:) = n_i / norm(n_i);
        else
            normals(i,:) = [0, 0, 0];
        end
    end

    % 找到最近的面片索引
    dists = sqrt(sum((centroids - X).^2, 2));
    [~, idx] = min(dists);
    
    % 返回对应的法向量
    n = normals(idx,:)';
end


function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
        % 标注点
    for i = 1:4
        text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
        text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
    end
    
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end
% 
%%法向量可视化函数
function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector);
    center = mean(pts, 1);
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 3, color, 'LineWidth', 2, 'MaxHeadSize', 5);
end

function kdTree = buildKDTreeForTriangles(faces, vertices)
    % 计算每个三角形的质心
    numTri = size(faces,1);
    centroids = zeros(numTri, 3);
    for i = 1:numTri
        tri = vertices(faces(i,:), :);
        centroids(i,:) = mean(tri, 1);
    end
    % 使用 MATLAB 内置的 createns 构建 KD-Tree
    kdTree = createns(centroids, 'NSMethod', 'kdtree');
end


function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    % 1) 轴向量归一化，确保 ‖axis_vec‖ = 1
    axis_vec = axis_vec(:) / norm(axis_vec);

    % 2) 角度转弧度
    theta = deg2rad(theta_deg);

    % 3) Rodrigues 公式
    K = [     0, -axis_vec(3),  axis_vec(2);
         axis_vec(3),      0, -axis_vec(1);
        -axis_vec(2), axis_vec(1),      0 ];
    R = eye(3) + sin(theta)*K + (1 - cos(theta))*(K*K);

    % 4) 执行旋转和平移
    %    (pts-center) 先减去中心，再 R 旋转，最后加回中心
    rotated = (R * (pts - center)')' + center;

    % 5) 去除数值误差产生的极小虚数
    rotatedPts = real(rotated);
end




%%计算平面法向量的函数
function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量 n（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end


%%旋转函数
function [AllPts_new,P_new, F_new] = applyRotation(AllPts, theta_deg,direction)
    P = AllPts(1:4, :);
    F = AllPts(5:8, :);
  if direction==1 
    E3 = (P(3,:) + F(3,:)) / 2;
    E4 = (P(4,:) + F(4,:)) / 2;
    rotationCenter = (E3 + E4) / 2;
    axis_vec = (E4 - E3) / norm(E4 - E3);
  elseif direction==2
    E3= (P(4,:) + F(4,:)) / 2;
    E1 = (P(1,:) +F(1,:)) / 2;
    rotationCenter= (E3 + E1) / 2;
    axis_vec = (E1 - E3) / norm(E1 - E3);
  else  
    E3= (P(3,:) + F(3,:)) / 2;
    E2 = (P(2,:) +F(2,:)) / 2;
    rotationCenter= (E3 + E2) / 2;
    axis_vec = (E3 - E2) / norm(E3 - E2);
  end  

    AllPts_new = rotatePoints(AllPts, rotationCenter, axis_vec, theta_deg);
    P_new = AllPts_new(1:4, :);
    F_new = AllPts_new(5:8, :);
    
end

%%自动旋转生成视点函数
function [AllPts_new,P_final, F_final] = autoRotateViewfield(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation,threshold,direction)
    theta_deg = 0;
    P_final = AllPts(1:4, :);
    F_final = AllPts(5:8, :);
    
     model = stlread(stl_file);
     faces = model.ConnectivityList;
     vertices = model.Points;
    
    
    while theta_deg <= max_rotation
        [~,P_new, F_new] = applyRotation(AllPts, theta_deg,direction);
%         C_new=(P_new+ F_new)/2;
        kdtree = buildKDTreeForTriangles(faces, vertices);
      if isValidTangent(P_new, F_new, faces, vertices, epsilon, numSamples,threshold,kdtree)&&(theta_deg>30)
         
            P_final = P_new;
            F_final = F_new;
            fprintf('相切检测在旋转 %d 度时触发。\n', theta_deg);
            break;
      end
        
        theta_deg = theta_deg + step_size;
    end
    if (theta_deg > 359)
        
        fprintf('那就是没找到咯。\n');
    end
    AllPts_new=[P_final;F_final];
     if (345> theta_deg) && (theta_deg > 90)
      if direction==1  
P_final(1,:) = AllPts_new(8,:);
P_final(2,:) = AllPts_new(7,:);
P_final(3,:) = AllPts_new(6,:);
P_final(4,:) = AllPts_new(5,:);
F_final(1,:) = AllPts_new(4,:);
F_final(2,:) = AllPts_new(3,:);
F_final(3,:) = AllPts_new(2,:);
F_final(4,:) = AllPts_new(1,:);
      else
P_final(1,:) = AllPts_new(6,:);
P_final(2,:) = AllPts_new(5,:);
P_final(3,:) = AllPts_new(8,:);
P_final(4,:) = AllPts_new(7,:);
F_final(1,:) = AllPts_new(2,:);
F_final(2,:) = AllPts_new(1,:);
F_final(3,:) = AllPts_new(4,:);
F_final(4,:) = AllPts_new(3,:);
      end  


    end
    AllPts_new=[P_final;F_final];
    
end


%%判断相切条件函数
function result = isValidTangent(P, F, faces, vertices, epsilon, numSamples,threshold,kdtree)
    % 先检查近面是否与模型接触（距离小于阈值）
    resultNear = isTangentToSurface(P, faces, vertices, epsilon, numSamples,kdtree);
    if ~resultNear
        result = false;
        return;
    end
    
    % 对 P 面（近面）和 F 面（远面）各自采样
    ptsP = sampleFace(P, numSamples);
    ptsF = sampleFace(F, numSamples);
    
    % 利用 inpolyhedron 判断采样点是否在模型内部（返回 true 表示在内部）
    insideP = in_polyhedron(faces, vertices, ptsP);
    insideF = in_polyhedron(faces, vertices, ptsF);
    
   % 计算内部点的比例
    ratioInsideP = sum(insideP) / 225;  % 近面内部点占比
    ratioInsideF = sum(insideF) / 225;  % 远面内部点占比
     
    % 设置合理的阈值
%     threshold = 0.3;
    if  (ratioInsideF>threshold) && (ratioInsideP < (1-threshold))
        fprintf('ratioInsideF=%d 。\n',sum(insideF));
        fprintf('ratioInsideP=%d 。\n',sum(insideP));
        result = true;
    else
        result = false;
    end
end

%%采样某个面内的点（面由 4 个顶点组成） 采样函数为下一步限制相切做铺垫
function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
end


%限制相切函数
function result = isTangentToSurface(P, faces, vertices, epsilon, numSamples, kdTree)
    result = false;
    
    % 构建 P 面的局部坐标系（以 P(1,:) 为原点，v1 = P(2,:)-P(1,:) ，v2 = P(4,:)-P(1,:)）
    v1 = P(2,:) - P(1,:);
    v2 = P(4,:) - P(1,:);
    
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePoints = P(1,:) + A(:)*v1 + B(:)*v2;
    
    for i = 1:size(samplePoints,1)
        pt = samplePoints(i,:);
        % 使用 KD-Tree 加速的点到模型距离查询
        d = pointToMeshDistance(pt, faces, vertices, kdTree, 10);
        if d < epsilon
            result = true;
            return;
        end
    end
end




%%计算一个点到 STL 模型（所有三角形）的最小距离
function d = pointToMeshDistance(pt, faces, vertices, kdTree, k)
    % k 为查询最近邻三角形的数量（例如 10）
    if nargin < 5
        k = 10;
    end
    % 使用 knnsearch 查询距离 pt 最近的 k 个三角形（质心）
    [idx, ~] = knnsearch(kdTree, pt, 'K', k);
    d = inf;
    % 对候选的每个三角形计算精确的点-三角形距离
    for i = 1:length(idx)
        tri = vertices(faces(idx(i),:), :);
        d_tri = pointTriangleDistance(pt, tri);
        if d_tri < d
            d = d_tri;
        end
    end
end

%%计算点到三角形的距离（参考 Real-Time Collision Detection 算法）
function d = pointTriangleDistance(P, tri)
    A = tri(1,:);
    B = tri(2,:);
    C = tri(3,:);
    
    % 边向量
    AB = B - A;
    AC = C - A;
    AP = P - A;
    
    d1 = dot(AB, AP);
    d2 = dot(AC, AP);
    if d1 <= 0 && d2 <= 0
        d = norm(P - A);
        return;
    end
    
    BP = P - B;
    d3 = dot(AB, BP);
    d4 = dot(AC, BP);
    if d3 >= 0 && d4 <= d3
        d = norm(P - B);
        return;
    end
    
    CP = P - C;
    d5 = dot(AB, CP);
    d6 = dot(AC, CP);
    if d6 >= 0 && d5 <= d6
        d = norm(P - C);
        return;
    end
    
    vc = d1 * d4 - d3 * d2;
    if vc <= 0 && d1 >= 0 && d3 <= 0
        v = d1 / (d1 - d3);
        proj = A + v * AB;
        d = norm(P - proj);
        return;
    end
    
    vb = d5 * d2 - d1 * d6;
    if vb <= 0 && d2 >= 0 && d6 <= 0
        w = d2 / (d2 - d6);
        proj = A + w * AC;
        d = norm(P - proj);
        return;
    end
    
    va = d3 * d6 - d5 * d4;
    if va <= 0 && (d4 - d3) >= 0 && (d5 - d6) >= 0
        w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
        proj = B + w * (C - B);
        d = norm(P - proj);
        return;
    end
    
    % 如果点在三角形内部，则计算到平面的距离
    N = cross(AB, AC);
    d = abs(dot(P - A, N)) / norm(N);
end


