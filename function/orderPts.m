function [orderedNear,orderedFar]=orderPts(AllPts,AllPts_new)
center=mean(AllPts, 1);

P = AllPts(1:4, :);  % 近面
F = AllPts(5:8, :);  % 远面
normal_vector = cross(P(2,:) - P(1,:), P(3,:) - P(1,:));
normal_vector = normal_vector / norm(normal_vector);
refPoint = center+normal_vector*28;
[newNearPts, newFarPts] = classifyCuboidFaces(AllPts_new, refPoint);
orderedNear =  orderNewFaceByReference(P, newNearPts);
orderedFar =  orderNewFaceByReference(F, newFarPts);
end

function [nearPts, farPts] = classifyCuboidFaces(vertices, refPoint)
    % vertices: 8x3矩阵，长方体所有顶点
    % refPoint: 1x3向量，参考点（例如原始远面中心）
    %
    % 计算每个顶点与参考点的距离
    nearPts=vertices(1:4,:);
    farPts=vertices(5:8,:);
    dists1 = point2plane(nearPts, refPoint);
    dists2= point2plane(farPts, refPoint);
    if dists1<dists2
     nearPts=vertices(5:8,:);
     farPts=vertices(1:4,:);
    end
end

function dist = point2plane(planePts, point)
    % 输入:
    %   planePts - 4x3矩阵，每一行是平面上一个点的坐标（假设共面）
    %   point    - 1x3向量，待计算距离的点坐标
    %
    % 输出:
    %   dist     - 点到平面的距离

    % 取前三个点计算法向量
    p1 = planePts(1, :);
    p2 = planePts(2, :);
    p3 = planePts(3, :);
    
    % 计算平面上的两个向量
    v1 = p2 - p1;
    v2 = p3 - p1;
    
    % 计算法向量（叉积）
    normal = cross(v1, v2);
    
    % 确保法向量不为零向量
    if norm(normal) == 0
        error('输入的前三个点不能共线！');
    end
    
    % 计算点到平面的距离：|normal · (point-p1)| / ||normal||
    dist = abs(dot(normal, point - p1)) / norm(normal);
end

function newOrderedPts = orderNewFaceByReference(originalPts, newPts)
    % originalPts: 4x3矩阵，原长方形面顶点，已排好顺序（例如 P1, P2, P3, P4）
    % newPts:      4x3矩阵，当前长方形面顶点，顺序待确定
    % 输出:
    %   newOrderedPts: 4x3矩阵，新长方形面顶点顺序，
    %                  其中 newOrderedPts(i,:) 对应原面的 P{i}，即与 originalPts(i,:) 最接近的点

    numPts = size(originalPts, 1);
    newOrderedPts = zeros(size(newPts));
    
    % 为防止重复选取，将所有新面顶点的索引保存在 remainingIdx 中
    remainingIdx = 1:numPts;
    
    for i = 1:numPts
        origP = originalPts(i, :);
        % 计算当前所有未匹配的新面顶点与原参考点之间的欧氏距离
        distances = vecnorm(newPts(remainingIdx, :) - origP, 2, 2);
        % 找到距离最小的点
        [~, minIdx] = min(distances);
        selectedIdx = remainingIdx(minIdx);
        
        % 将选中的点赋给新的顺序
        newOrderedPts(i, :) = newPts(selectedIdx, :);
        % 从剩余索引中去掉已匹配的点
        remainingIdx(minIdx) = [];
    end
end


