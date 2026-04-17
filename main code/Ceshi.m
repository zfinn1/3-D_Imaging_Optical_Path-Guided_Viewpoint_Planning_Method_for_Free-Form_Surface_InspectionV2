clear;
close all;
clc;

stlFile = 'E:\111.stl';
model = stlread(stlFile); % 加载 STL 文件，获取模型的几何数据
vertices = model.Points;  % 模型顶点
faces = model.ConnectivityList; % 三角面片索引

% 选取一个面片生成视场区域（你已有的 viewfield 函数）
tp1 = vertices(faces(2500,1),:);
tp2 = vertices(faces(2500,2),:);
tp3 = vertices(faces(2500,3),:);
% viewfield 生成正四棱锥的底面四角和顶点 P（视点）
[P1, P2, P3, P4, P] = viewfield(tp1, tp2, tp3);

% 设定用于候选筛选的棱线，这里选择 P 到 P4 对应的棱线
d = (P4 - P);
d = d / norm(d);  % 单位化

%% 1. 计算每个面片的中心点
faceCenters = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) / 3;

%% 2. 筛选候选面片：计算每个面片中心到棱线的距离
vecs = faceCenters - repmat(P, size(faceCenters,1), 1);
projLengths = dot(vecs, repmat(d, size(vecs,1), 1), 2);
projPoints = repmat(P, size(faceCenters,1), 1) + projLengths .* repmat(d, size(vecs,1), 1);
distances = sqrt(sum((faceCenters - projPoints).^2, 2));

% 根据模型尺度设置阈值（阈值可以根据实际情况调整）
threshold = 2;  
candidateIdx = find(distances < threshold);
fprintf('候选面片数量：%d\n', numel(candidateIdx));

%% 3. 遍历候选面片，记录所有有效交点并选择距离视点最近的
% 这里以从 P 到 P2 为射线进行求交
v = (P4 - P);
v = v / norm(v);  % 射线方向（单位向量）

best_t = inf;               % 初始化一个较大的 t 值
visibleFace = -1;           % 最终选中的面片索引
visibleIntersection = [];   % 对应的交点
i=0;
for idx = candidateIdx'
    % 取出候选面片的三个顶点
    a = vertices(faces(idx,1),:);
    b = vertices(faces(idx,2),:);
    c = vertices(faces(idx,3),:);
    i=i+1;
    if i>1
        break;
    end
    % 计算候选面片的平面方程系数（假设 compute_plane_coeffs 输出 [A, B, C, D]）
    [A, B, C, D] = compute_plane_coeffs(a, b, c);
    
    % 求射线与该面平面的交点
    % 这里假设 line_plane_intersection 的接口为：
    %   intersection_point = line_plane_intersection(P, P2, [A, B, C, D]);
    intersection_point = line_plane_intersection(P, P4, [A, B, C, D]);
%     if isempty(intersection_point)
%         continue;  % 若射线与平面平行或无交点，则跳过
%     end
    
    flag(i)=isPointInTriangle3D(a, b, c, intersection_point);
    % 用重心坐标或你的函数判断交点是否在三角形内部
    if ~isPointInTriangle3D(a, b, c, intersection_point)
        continue;
    end
    
    % 计算该候选面片的法向量（注意：顶点顺序决定法向量方向）
    normal = cross(b - a, c - a);
    if norm(normal) == 0
        continue;  % 退化三角形
    end
    normal = normal / norm(normal);
    
    % 计算视线方向：从交点指向视点 P
    viewDir = P - intersection_point;
    viewDir = viewDir / norm(viewDir);
    
    % 判断面是否正面：依据面片的法向量与视线方向的点乘
    if dot(normal, viewDir) <= 0
        continue;  % 面片背向视点
    end
    
    % 计算交点对应的射线参数 t
    % 由于射线表达式为 R(t) = P + t * v,
    % 可以利用任一坐标分量来计算 t，例如：
    % 注意：为了更稳健，最好利用最不接近零的分量
    t = norm(intersection_point - P);  % 这里直接用距离代替 t
    
    % 如果该交点离视点更近，则更新最佳结果
    
        
        visibleFace = idx;
        visibleIntersection = intersection_point;
    
end

if visibleFace == -1
    fprintf('未找到符合条件的正面候选面片。\n');
else
    fprintf('找到正面候选面片，索引：%d, 距离：%.3f\n', visibleFace, best_t);
    
    % 获取最终选中面片的三个顶点（用于可视化）
    tricoordinate1 = vertices(faces(visibleFace,1),:);
    tricoordinate2 = vertices(faces(visibleFace,2),:);
    tricoordinate3 = vertices(faces(visibleFace,3),:);
    
    % 绘图：显示选中的面片、交点以及视场区域
    figure;
    % 绘制选中的三角形面片（红色填充）
    fill3([tricoordinate1(1) tricoordinate2(1) tricoordinate3(1)], ...
          [tricoordinate1(2) tricoordinate2(2) tricoordinate3(2)], ...
          [tricoordinate1(3) tricoordinate2(3) tricoordinate3(3)], ...
          'r', 'FaceAlpha', 0.8);
    hold on;
    
    % 绘制交点
    scatter3(visibleIntersection(1), visibleIntersection(2), visibleIntersection(3), 50, 'b', 'filled');
    
    % 绘制正四棱锥的底面与各侧面
    fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'g', 'FaceAlpha', 0.5);
    fill3([P1(1) P2(1) P(1)], [P1(2) P2(2) P(2)], [P1(3) P2(3) P(3)], 'g', 'FaceAlpha', 0.5);
    fill3([P2(1) P3(1) P(1)], [P2(2) P3(2) P(2)], [P2(3) P3(3) P(3)], 'b', 'FaceAlpha', 0.5);
    fill3([P3(1) P4(1) P(1)], [P3(2) P4(2) P(2)], [P3(3) P4(3) P(3)], 'y', 'FaceAlpha', 0.5);
    fill3([P4(1) P1(1) P(1)], [P4(2) P1(2) P(2)], [P4(3) P1(3) P(3)], 'k', 'FaceAlpha', 0.5);
    
    % 绘制视点与视场顶点
    scatter3(P(1), P(2), P(3), 100, 'm', 'filled');
    text(P(1), P(2), P(3), '  P','FontSize',12);
    
    % 绘制整个模型（半透明显示）
    trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.3);
    axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('视场区域及最优正面候选面片');
    hold off;
end