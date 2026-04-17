%% 示例：读取 STL 模型并显示，同时计算并显示候选视点与连线
% 读取 STL 模型（请根据实际路径替换 'model.stl'）
model = stlread('C:\Users\86132\Desktop\c\111.stl');  
% 绘制 STL 模型
figure; hold on; grid on; axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('STL 模型、候选视点及连线');
patch('Vertices', model.Points, 'Faces', model.ConnectivityList, ...
      'FaceColor', [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.8);
camlight; lighting gouraud;

% 每个视场域以 8×3 矩阵存储（前4个顶点为近面）。
% 请确保你的 viewFieldLayers 数据结构已加载。

allViewPoints = [];       % 用于存储所有候选视点
candidateDistance = 30;     % 候选视点距离近面中心的距离

numLayers = numel(viewFieldLayers);
for iLayer = 1:numLayers
    ring = viewFieldLayers{iLayer};
    
    % 移除空的视场域
    ring = ring(~cellfun(@isempty, ring));
    
    % 遍历当前层中每个视场域
    for j = 1:numel(ring)
        vertices = ring{j};  % 视场域长方体的 8×3 顶点矩阵
        if isempty(vertices) || size(vertices,2) ~= 3
            continue;
        end
        
        % 假设前4个顶点构成近面，计算近面中心
        faceCenter = mean(vertices(1:4, :), 1);
        
        % 计算近面法向量：利用近面上三个点（例如 P1, P2, P4）构造两个边向量
        P1 = vertices(1, :);
        P2 = vertices(2, :);
        P4 = vertices(4, :);
        v1 = P2 - P1;
        v2 = P4 - P1;
        normal = cross(v1, v2);
        if norm(normal) == 0
            continue;  % 避免零向量
        end
        normal = normal / norm(normal);
        
        % 计算候选视点：从近面中心沿法向量方向 candidateDistance 的位置
        viewpoint = faceCenter + candidateDistance * normal;
             % 判断是否是最后一圈的最后一个视场域
        isLastOne = (iLayer == numLayers) && (j == numel(ring));

        if isLastOne
            % 特殊调整：反转法向量
            viewpoint = faceCenter - candidateDistance * normal;
        else
            % 正常情况
            viewpoint = faceCenter + candidateDistance * normal;
        end

        allViewPoints = [allViewPoints; viewpoint];
        
        % 绘制候选视点（红色）
        scatter3(viewpoint(1), viewpoint(2), viewpoint(3), 50, 'r', 'filled');
%         % 绘制长方体近面中心（蓝色），便于观察连线起点
%         scatter3(faceCenter(1), faceCenter(2), faceCenter(3), 50, 'b', 'filled');
%         
%         % 绘制从近面中心到候选视点的连线（黑色实线）
%         linePoints = [faceCenter; viewpoint];
%         plot3(linePoints(:,1), linePoints(:,2), linePoints(:,3), 'k-', 'LineWidth', 1.5);
    end
end

disp(['共生成候选视点数：', num2str(size(allViewPoints,1))]);
