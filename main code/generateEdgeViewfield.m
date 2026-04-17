function savedEdgeViews=generateEdgeViewfield(stl_file,shrink_factor,step,angle_threshold, merge_threshold,h,numViewsFirstRing,k)
% 输入参数：
% - stl_file: STL 文件路径
% - shrink_factor: boundary 函数的非凸包参数
% - step: 边界稀疏采样步长
% - angle_threshold: 突变角度阈值（单位：弧度）
% - merge_threshold: 合并突变点距离阈值
% - h:  拉伸高度
% - numViewsFirstRing:  生成视场的步数
% - k:  边缘几(就两个边缘可选 1 或 2)
savedEdgeViews = cell(numViewsFirstRing+1, 1); 
fv = stlread(stl_file);
vertices = fv.Points;
turning_points = extractTurningPointsFromSTL(stl_file, shrink_factor, step, angle_threshold, merge_threshold);

line_length = 10;
y_threshold = 8;  % y坐标差值在8以内就认为是“一组”

squares = generateSquaresByYGroup(turning_points, vertices, line_length, y_threshold);

 
[verts, ~] = generatePrismFromSquare(squares{k}, h);
verts=adjustVdthroughN(verts,faces,vertices);
savedEdgeViews{1}=verts;
AllPts_prev=verts;

for i = 2:numViewsFirstRing
[AllPts_new,~, ~] = autoRotateViewfield(AllPts_prev, stl_file, 0.1, 15, 1, 360, 0.5, 0.1,1);

if AllPts_new==AllPts_prev
    disp('边缘生成完了');
    AllPts_new=[];
    savedEdgeViews{i}=AllPts_new;
    break;
end
savedEdgeViews{i}=AllPts_new;
AllPts_prev=AllPts_new;

end

end



function [vertices, faces] = generatePrismFromSquare(square, h)
% 输入:
%   square: 4x3 矩阵，表示底面正方形的4个顶点（顺时针或逆时针）
%   h     : 拉伸高度（沿正 z 方向）
% 输出:
%   vertices: 8x3 所有长方体顶点
%   faces   : 6x4 每一行一个面，由4个顶点组成的索引

    if size(square,1) ~= 4 || size(square,2) ~= 3
        error('输入 square 必须是 4x3 的顶点矩阵');
    end

    % 底面顶点（原正方形）
    V1 = square(1,:);
    V2 = square(2,:);
    V3 = square(3,:);
    V4 = square(4,:);
    
    AB = V1 - V2;
    
    AC = V3 - V2;
    n = cross(AB, AC);
    n=n/norm(n);
    % 顶面顶点（在 z 上抬高 h）
    AB=AB/norm(AB);
    V_c1=(V1+V2)/2;
    V_c2=(V3+V4)/2;
    
    V1=V_c1+AB*5;
    V2=V_c1-AB*5;
    V3=V_c2-AB*5;
    V4=V_c2+AB*5;
    
    V5 = V1 + h*n;
    V6 = V2 + h*n;
    V7 = V3 + h*n;
    V8 = V4 + h*n;

    % 顶点集合（顺序为底面4点 + 顶面4点）
    vertices = [V2; V1; V4; V3; V6; V5; V8; V7];

    % 面定义（6 个面，每面用 4 个顶点索引）
    faces = [...
        1 2 3 4;  % 底面
        5 6 7 8;  % 顶面
        1 2 6 5;  % 前面
        2 3 7 6;  % 右面
        3 4 8 7;  % 后面
        4 1 5 8]; % 左面
end

function squares = generateSquaresByYGroup(turning_points, vertices, line_length, y_threshold)
% 根据 y 坐标相近的 turning_points 配对生成正方形（朝 z 拉伸）

    n = size(turning_points, 1);
    used = false(n, 1);
    squares = {};
    
    for i = 1:n
        if used(i), continue; end
        for j = i+1:n
            if ~used(j) && abs(turning_points(i,2) - turning_points(j,2)) < y_threshold
                % 点 i 和 j 可配对
                pt1 = turning_points(i, :);
                pt2 = turning_points(j, :);
           
               start_point= pt1;
               end_point =pt2;
               
               
                z_surface = min(vertices(:,3));

                % 构造正方形四个顶点（底边 + 向 z 拉伸）
                V2 = [start_point, z_surface];                     % 起点底边
                V1 = [end_point, z_surface];                       % 终点底边
                V3 = [start_point, z_surface + line_length];       % 起点顶边
                V4 = [end_point, z_surface + line_length];         % 终点顶边

                squares{end+1} = [V1; V2; V3; V4];
                used(i) = true;
                used(j) = true;
                break;
            end
        end
    end
    squares=squares.';
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

function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
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