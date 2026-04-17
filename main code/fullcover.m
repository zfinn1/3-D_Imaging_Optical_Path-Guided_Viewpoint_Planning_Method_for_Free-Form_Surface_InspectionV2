% 
% fileName = 'C:\Users\86132\Desktop\本科毕设\Entirepointscloud2.ply';
% 
% % 读取点云
% ptCloud = pcread(fileName);
% figure;
% % 显示点云
% pcshow(ptCloud);
% title('Loaded Point Cloud from PLY');

% 包装成 computeCoverage 所需格式
% FOVs_all = {viewBoxes};   % 一层 ring
FOVs_all =allSavedViews;   % 一层 ring
% 使用模型面中心作为点云
% ptCloud1 = faceCenters;
ptCloud1=ptCloud.Location;
% 计算覆盖率
[coverage_ratio, covered_flags,uncovered_points] = computeCoverage(FOVs_all, ptCloud1);
fprintf('模型覆盖率为 %.2f%%\n', coverage_ratio * 100);
ptCloud1=ptCloud.Location;

%   [coverage_ratio, covered_flags] = computeCoverage(allSavedViews, ptCloud1);

%  figure;
%  scatter3(ptCloud1(:,1), ptCloud1(:,2), ptCloud1(:,3), 5, 'g', 'filled');  % 点云
% % 绘制某个视场域框
% %  pcshow(ptCloud); 
% hold on;
% 然后画一个视场域中心点
function [coverage_ratio, covered_flags,uncovered_points] = computeCoverage(FOVs_all, pointCloud)
% computeCoverage 计算点云在所有视场域内的覆盖率
%
% 输入参数：
%   FOVs_all   - 一个 cell 数组，每个 cell 存储一组视场域，
%                每个视场域以 8×3 的矩阵表示（定义一个长方体）。
%                例如：FOVs_all = {ring1, ring2, ..., ringN}，
%                每一圈 ring 是一个 cell 数组，包含多个视场域长方体。
%
%   pointCloud - 点云数据，格式为 N×3 的矩阵，每行为 [x, y, z] 坐标。
%
% 输出参数：
%   coverage_ratio - 点云中被至少一个视场域覆盖的比例。
%   covered_flags  - N×1 的逻辑向量，标记每个点是否被覆盖。
%
% 注：本函数借鉴了你已有的 in_polyhedron 函数，用于精细判断候选点是否在多面体内。

    numPoints = size(pointCloud, 1);
    covered_flags = false(numPoints, 1);
    tolerance = 1e-6; % 用于浮点误差修正

    % 定义长方体的面，对于一个 8 点长方体（假设顶点顺序固定）
    % 这里按 drawBoundingBox 中定义的顺序：
    %
    % V1: [minX, minY, minZ]
    % V2: [maxX, minY, minZ]
    % V3: [maxX, maxY, minZ]
    % V4: [minX, maxY, minZ]
    % V5: [minX, minY, maxZ]
    % V6: [maxX, minY, maxZ]
    % V7: [maxX, maxY, maxZ]
    % V8: [minX, maxY, maxZ]
    %
    % 定义面：
faces_box_tri = [1 2 3; 1 3 4;    % 底面
                 5 6 7; 5 7 8;    % 顶面
                 1 2 6; 1 6 5;    % 侧面1
                 2 3 7; 2 7 6;    % 侧面2
                 3 4 8; 3 8 7;    % 侧面3
                 4 1 5; 4 5 8];   % 侧面4

    % 建立图形显示（可选，用于调试）
    figure; hold on; grid on; axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('点云、视场域及候选点');
       scatter3(pointCloud(:,1), pointCloud(:,2), pointCloud(:,3), 5, [0.7, 0.7, 0.7], 'filled');

    % 遍历所有视场域
    for i = 1:length(FOVs_all)
        ring = FOVs_all{i};
        if isempty(ring)
            continue;
        end
        for j = 1:length(ring)
            box = ring{j};
            if isempty(box)
                continue;
            end
            
            % 计算当前视场域长方体的最小外接框
            minB = min(box, [], 1);
            maxB = max(box, [], 1);
            
            % 绘制外接框用于调试（蓝色边框）
            drawBoundingBox(minB, maxB, 'b');
            
            % 候选点筛选：先用包围盒粗筛选
            mask = all(pointCloud >= (minB - tolerance) & pointCloud <= (maxB + tolerance), 2);
            if ~any(mask)
                continue;
            end
            candidateIndices = find(mask);
            candidatePoints = pointCloud(candidateIndices, :);
            
            % 利用 in_polyhedron 精细判断这些候选点是否在当前视场域长方体内
            % 这里将当前长方体（box）视为一个凸多面体，其顶点顺序应与 faces_box 中定义对应
            inside_flags = in_polyhedron(faces_box_tri, box, candidatePoints); 
            % 注意：in_polyhedron 应返回一个逻辑数组，长度与 candidateIndices 相同
            for k = 1:length(candidateIndices)
                if inside_flags(k)
                    covered_flags(candidateIndices(k)) = true;
                end
            end
        end
    end
    
    coverage_ratio = sum(covered_flags) / numPoints;
    disp(['覆盖率为：', num2str(coverage_ratio * 100), '%']);
    uncovered_points = pointCloud(~covered_flags, :); % 没被覆盖的点
covered_points =pointCloud(covered_flags, :);   % 被覆盖的点

figure;
scatter3(covered_points(:,1), covered_points(:,2), covered_points(:,3), 5, [0.5 0.5 0.5], 'filled'); hold on;
scatter3(uncovered_points(:,1), uncovered_points(:,2), uncovered_points(:,3), 8, 'r', 'filled');
legend('已覆盖点', '未覆盖点');
title('点云覆盖可视化');
axis equal; grid on;
end

%% 辅助函数：绘制外接框
function drawBoundingBox(minB, maxB, color)
    % drawBoundingBox 根据 minB 和 maxB 绘制长方体外接框
    V = [minB;
         maxB(1), minB(2), minB(3);
         maxB(1), maxB(2), minB(3);
         minB(1), maxB(2), minB(3);
         minB(1), minB(2), maxB(3);
         maxB(1), minB(2), maxB(3);
         maxB(1), maxB(2), maxB(3);
         minB(1), maxB(2), maxB(3)];
    edges = [1 2; 2 3; 3 4; 4 1;  % 底面
             5 6; 6 7; 7 8; 8 5;  % 顶面
             1 5; 2 6; 3 7; 4 8]; % 竖边
    for i = 1:size(edges, 1)
        p1 = V(edges(i, 1), :);
        p2 = V(edges(i, 2), :);
        plot3([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], color, 'LineWidth', 2);
    end
end
