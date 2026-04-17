% 读取 STL 模型并获取投影点
fv = stlread('C:\Users\86132\Desktop\c\111.stl');
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
vertices = fv.Points;
faces = fv.ConnectivityList;


figure;
% 如果有 STL 模型的面数据（例如 fv.ConnectivityList），可以用 trisurf 绘制模型
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
AAA=drawSegmentRays(xy_vertices,2);
start_point=AAA{1}+[2.5,0];

end_point=AAA{2}+[2.5,0];
%   z_surface = (max(vertices(:,3))+min(vertices(:,3)))/2;
 z_surface = min(vertices(:,3));
V2 = [start_point, z_surface];          % 底边起点
V1 = [end_point, z_surface];            % 底边终点
V4 = [end_point, z_surface+line_length];  % 顶边终点（沿 z 方向延伸）
V3 = [start_point,line_length+z_surface ];% 顶边起点

X = [V1(1), V2(1), V3(1), V4(1)];
Y = [V1(2), V2(2), V3(2), V4(2)];
Z = [V1(3), V2(3), V3(3), V4(3)];
start_point1=start_point+[-10,0];
end_point1=end_point+[-10,0];
V22 = [start_point1, z_surface];          % 底边起点
V11 = [end_point1, z_surface];            % 底边终点
V44 = [end_point1, z_surface+line_length];  % 顶边终点（沿 z 方向延伸）
V33= [start_point1,line_length+z_surface ];% 顶边起点


baseVertices=[V1;V2;V3;V4];
baseVertices1=[V11;V22;V33;V44];

verts_prev = generateCuboidVertices(baseVertices, 1);
verts_prev1 = generateCuboidVertices(baseVertices1, 1);
 verts =adjustVdthroughN(verts_prev ,faces,vertices);
 
 
 X=verts(3,:);
[n,idx]= getModelNormalAt(X, fv);
initialface = idx;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);

 verts1=[P1;P2;P3;P4;F1;F2;F3;F4];
%  verts1 =adjustVdthroughN( verts1 ,faces,vertices);
 
 
 
 
 


% [ratioInsideP,ratioInsideF]=caiyang(verts(1:4,:),verts(5:8,:),faces,vertices);
% isIntersections = computeIntersectionsWithKD(verts(1:4,:), fv, 1e-2, kdtree, 8);
%  [verts,~,~] = adjustpos(verts,isIntersections, stl_file, 15, 1, 360);
%             P_final(1,:) = verts(3,:);
%             P_final(2,:) = verts(4,:);
%             P_final(3,:) = verts(1,:);
%             P_final(4,:) = verts(2,:);
%             F_final(1,:) = verts(7,:);
%             F_final(2,:) = verts(8,:);
%             F_final(3,:) = verts(5,:);
%             F_final(4,:) = verts(6,:);
% verts=[P_final;F_final];     
X=verts(2,:);
[n,idx]= getModelNormalAt(X, fv);
initialface = idx;
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);

AllPts_new5=[P1;P2;P3;P4;F1;F2;F3;F4];
AllPts_new5 =adjustVdthroughN(AllPts_new5 ,faces,vertices);
% isIntersections1 = computeIntersectionsWithKD(verts(1:4,:), fv, 1e-2, kdtree, 8);
%  [AllPts_new,~,~] = adjustpos(AllPts_new, isIntersections1, stl_file, 15, 1, 360);
% %  [orderedNear, orderedFar] = orderPts(verts,verts1);
% %  verts=[orderedNear, orderedFar];
% %  [AllPts_new,~, ~] = autoRotateViewfield(verts, stl_file, 0.1, 15, 1, 360, 0.5, 0.1,1);
%  [AllPts_new1,~, ~] = autoRotateViewfield(verts, stl_file, 0.1, 15, 1, 360, 0.5, 0.1,1);
% 
% % 
[AllPts_new,P_new, F_new] = applyRotation(verts_prev,180,1);
            P_final(1,:) = AllPts_new(8,:);
            P_final(2,:) = AllPts_new(7,:);
            P_final(3,:) = AllPts_new(6,:);
            P_final(4,:) = AllPts_new(5,:);
            F_final(1,:) = AllPts_new(4,:);
            F_final(2,:) = AllPts_new(3,:);
            F_final(3,:) = AllPts_new(2,:);
            F_final(4,:) = AllPts_new(1,:);
AllPts_new=[P_final;F_final];  
[AllPts_new1,P_new, F_new] = applyRotation(AllPts_new,180,1);

AllPts_new =adjustVdthroughN(AllPts_new ,faces,vertices);
 isIntersections1 = computeIntersectionsWithKD(AllPts_new(1:4,:), fv, 1e-2, kdtree, 8);
  [AllPts_new,~,~] = adjustpos(AllPts_new,isIntersections1, stl_file, 15, 1, 360);
 [AllPts_new2,~, ~] = autoRotateViewfield(AllPts_new, stl_file, 0.1, 15, 1, 360, 0.5, 0.1,2);
     P_final(1,:) = AllPts_new1(8,:);
            P_final(2,:) = AllPts_new1(7,:);
            P_final(3,:) = AllPts_new1(6,:);
            P_final(4,:) = AllPts_new1(5,:);
            F_final(1,:) = AllPts_new1(4,:);
            F_final(2,:) = AllPts_new1(3,:);
            F_final(3,:) = AllPts_new1(2,:);
            F_final(4,:) = AllPts_new1(1,:);
AllPts_new1=[P_final;F_final];     

AllPts_new1 =adjustVdthroughN(AllPts_new1 ,faces,vertices);
 isIntersections2 = computeIntersectionsWithKD(AllPts_new1(1:4,:), fv, 1e-2, kdtree, 8);
  [AllPts_new1,~,~] = adjustpos(AllPts_new1,isIntersections2, stl_file, 15, 1, 360);
  
  
   
% [AllPts_new,P_new, F_new] = applyRotation(verts_prev,180,1);
  
  
  
  
  
  
  
  
visualizeViewField(verts1(1:4,:), verts1(5:8,:));
% visualizeViewField(verts(1:4,:), verts(5:8,:));
visualizeViewField(AllPts_new(1:4,:), AllPts_new(5:8,:));
 visualizeViewField(AllPts_new2(1:4,:), AllPts_new2(5:8,:));
 visualizeViewField(AllPts_new5(1:4,:), AllPts_new5(5:8,:));
% fill3(X, Y, Z, 'cyan', 'FaceAlpha', 0.5); % 半透明填充
% hold on;
% plot3(X, Y, Z, 'k-o', 'LineWidth', 2);    % 边框线条
% grid on; axis equal;
% xlabel('X'); ylabel('Y'); zlabel('Z');
% title('由四个顶点构成的矩形面');

function needPoints=drawSegmentRays(xy_vertices,options)
   needPoints=cell(4, 1);
    %% 获取极值点
    extreme_pts = getExtremePoints(xy_vertices);
    
    % 可视化原始点和极值点
%     figure;
%     scatter(xy_vertices(:,1), xy_vertices(:,2), 10, 'k', 'filled'); hold on;
%     plot(extreme_pts(:,1), extreme_pts(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%     text(extreme_pts(:,1), extreme_pts(:,2), {'minX', 'maxX', 'minY', 'maxY'}, ...
%         'FontSize', 12, 'Color', 'b', 'HorizontalAlignment', 'center');
%     axis equal; grid on;
%     title('二维投影点的极值点');
    
    %% 准备参数
    min_x_pt = extreme_pts(1, :);
    max_x_pt = extreme_pts(2, :);
    min_y_pt = extreme_pts(3, :);
    max_y_pt = extreme_pts(4, :);

    x_range = max_x_pt(1) - min_x_pt(1);
    y_range = max_y_pt(2) - min_y_pt(2);
    
    fprintf('X 方向差值: %.4f\n', x_range);
    fprintf('Y 方向差值: %.4f\n', y_range);
    
    segment_length = 10;
    if options==1
    center_x = min_y_pt(1);  % 以 max_y 点为中心
    else
    center_x = max_y_pt(1);  % 以 max_y 点为中心
    end
    num_lines = round(x_range / segment_length);
    half_N = ceil(num_lines / 2);
    
    %% 生成中心对称线段
    lines = cell(2 * half_N + 1, 1);
    for i = -half_N:half_N
        start_x = center_x + i * segment_length;
        end_x = start_x + segment_length;
        if options==1
     y_val = min_y_pt(2); 
    else
     y_val = max_y_pt(2); 
    end
        
        % 固定 Y 坐标

        start_pt = [start_x, y_val, 0];
        end_pt = [end_x, y_val, 0];

        lines{i + half_N + 1} = [start_pt; end_pt];
    end
    
    %% 提取所有线段的端点
    all_endpoints = [];
    for i = 1:length(lines)
        all_endpoints = [all_endpoints; lines{i}(1, :); lines{i}(2, :)];
    end

    %% 去掉重复的端点
    all_endpoints = unique(all_endpoints, 'rows');
    
%     %% 绘制线段及端点
%     for i = 1:length(lines)
%         pts = lines{i};
%         plot3(pts(:,1), pts(:,2), pts(:,3), 'r-', 'LineWidth', 2);
%         plot3(pts(:,1), pts(:,2), pts(:,3), 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'g');
%     end
%     plot3(extreme_pts(:,1), extreme_pts(:,2), zeros(4,1), 'bo', 'MarkerSize', 8);
%     xlabel('X'); ylabel('Y'); zlabel('Z');
%     title('沿 X 方向划分的线段（标记端点）');
%     legend;

    %% 判断每个端点是否穿越区域
    
    max_ray_distance = 10; % 设置最大射线判断距离
      g=0;
    % 遍历所有端点
    for i = 1:size(all_endpoints, 1)
        
        ray_start = all_endpoints(i, 1:2);  % 当前端点
        % 判断射线方向（向上或向下）
        if ray_start(2) < mean([min_y_pt(2), max_y_pt(2)])  % 如果端点处于下端，向上打
            ray_end = ray_start + [0, y_range];  % 向上打
        else  % 如果端点处于上端，向下打
            ray_end = ray_start - [0, y_range];  % 向下打
        end
        
        % 计算区域边界（用 boundary）
        xys = xy_vertices(:,1:2);
        k = boundary(xys(:,1), xys(:,2));
        x_boundary = xys(k,1);
        y_boundary = xys(k,2);

        % 判断射线是否穿越区域
        num_samples = 100;
        ray_line = [linspace(ray_start(1), ray_end(1), num_samples)', ...
                    linspace(ray_start(2), ray_end(2), num_samples)'];

        % 使用 polyxpoly 计算交点
        [xi, yi] = polyxpoly(ray_line(:,1), ray_line(:,2), x_boundary, y_boundary);

        if ~isempty(xi)
            % 计算交点的y坐标与射线端点的y坐标的距离
            if ray_start(2) < mean([min_y_pt(2), max_y_pt(2)])  % 如果端点处于下端，向上打
            dist_to_intersection = abs(min(yi) - ray_start(2));
            else  % 如果端点处于上端，向下打
           dist_to_intersection = abs(max(yi) - ray_start(2));
            end
            

            disp(dist_to_intersection);
            % 判断射线是否穿越区域
            if dist_to_intersection < max_ray_distance
                g=g+1;
                needPoints{g} = ray_start;
%                 plot3(ray_start(1), ray_start(2), 0, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
            else
%                 plot3(ray_start(1), ray_start(2), 0, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
            end
            
            % 绘制交点
%             plot3(xi, yi, zeros(size(xi)), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        else
%             plot3(ray_start(1), ray_start(2), 0, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
        end

        % 可视化射线
%         plot3([ray_start(1), ray_end(1)], [ray_start(2), ray_end(2)], [0,0], 'b--');

        % 在终端输出检测状态
        disp(['端点 ' num2str(i) ' 已检测完']);
    end
end

%% 辅助函数：获取极值点
function extreme_points = getExtremePoints(xy)
    [~, idx_min_x] = min(xy(:,1));
    [~, idx_max_x] = max(xy(:,1));
    [~, idx_min_y] = min(xy(:,2));
    [~, idx_max_y] = max(xy(:,2));
    extreme_points = [ xy(idx_min_x, :);
                       xy(idx_max_x, :);
                       xy(idx_min_y, :);
                       xy(idx_max_y, :) ];
end

function vertices = generateCuboidVertices(baseVertices, h)
% generateCuboidVertices 根据一个三维底面（4个顶点）生成一个长方体的顶点集合
%
% 输入:
%   baseVertices: 4x3 矩阵，表示底面四个顶点的三维坐标（顺时针或逆时针顺序排列）
%   h: 拉伸高度（沿全局 z 轴正方向）
%
% 输出:
%   vertices: 8x3 矩阵，包含生成的长方体所有顶点的三维坐标
%
% 说明:
%   顶面为底面所有顶点加上 [0, 0, h]

    % 检查输入
    if size(baseVertices,1) ~= 4 || size(baseVertices,2) ~= 3
        error('baseVertices 必须是一个 4x3 矩阵');
    end

    % 底面顶点
    V1 = baseVertices(1,:);
    V2 = baseVertices(2,:);
    V3 = baseVertices(3,:);
    V4 = baseVertices(4,:);

    AB = V1-V2;
    AC =V3-V2;
    n = cross(AB, AC);
    n=n/norm(n);
    % 顶面顶点（底面顶点加上 [0,0,h]）
    V5 = V1 -n*h;
    V6 = V2 -n*h;
    V7 = V3 -n*h;
    V8 = V4 -n*h;

    % 组合所有顶点
    vertices = [V1; V2; V3; V4; V5; V6; V7; V8];

    % 可选：绘制结果（如果需要可取消注释）
%     figure;
%     patch('Faces', [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8],...
%           'Vertices', vertices, 'FaceColor', 'cyan', 'FaceAlpha', 0.5, 'EdgeColor', 'k');
%     hold on;
%     for i = 1:8
%         text(vertices(i,1), vertices(i,2), vertices(i,3), ['  ' num2str(i)], 'FontSize', 10, 'Color', 'k');
%     end
%     grid on; axis equal;
%     xlabel('X'); ylabel('Y'); zlabel('Z');
%     title('生成的长方体顶点');
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



function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    theta_rad = deg2rad(theta_deg); % 角度转换为弧度
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1 - cos(theta_rad))*(K*K);
    rotatedPts = (R * (pts - center)')' + center; 
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
function [ratioInsideP,ratioInsideF]=caiyang(P_new,F_new,faces,vertices)
ptsP = sampleFace(P_new, 20);
ptsF = sampleFace(F_new, 20);
% 利用 inpolyhedron 判断采样点是否在模型内部（返回 true 表示在内部）
    insideP = in_polyhedron(faces, vertices, ptsP);
    insideF = in_polyhedron(faces, vertices, ptsF);
 % 计算内部点的比例
    ratioInsideP = sum(insideP) / 400;  % 近面内部点占比
    ratioInsideF = sum(insideF) / 400;  % 远面内部点占比
disp( ratioInsideP);
disp( ratioInsideF);
end


%%采样某个面内的点（面由 4 个顶点组成） 采样函数为下一步限制相切做铺垫
function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
end


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


