
function  bestFaceIdx = findNewBasefaces(P_edge1, P_edge2,faces,vertices)
% 假设 M 是已知的中点
M = (P_edge1 + P_edge2) / 2;  % 1x3

targetDistance = 28.3862;  % 目标距离
givenDistance = 28;        % 沿法向偏移的给定距离

minDiff = inf;
bestFaceIdx = -1;
bestViewpoint = [];

numFaces = size(faces,1);
for i = 1:numFaces
    % 取出当前面片的三个顶点
    tri = vertices(faces(i,:), :);
    % 计算面片重心
    centroid = mean(tri, 1);
    % 计算法向量（确保非退化）
    n = cross(tri(2,:) - tri(1,:), tri(3,:) - tri(1,:));
    if norm(n) < 1e-6
        continue;
    end
    n = n / norm(n);
    
    % 计算候选视点：沿法向量偏移 givenDistance
    candidateViewpoint = centroid + givenDistance * n;
    
    % 计算候选视点与 M 的距离
    d = norm(candidateViewpoint - M);
    
    % 计算与目标距离的差值
    diff = abs(d - targetDistance);
    
    % 如果更接近目标，则记录
    if diff < minDiff
        minDiff = diff;
        bestFaceIdx = i;
        bestViewpoint = candidateViewpoint;
    end
end

if bestFaceIdx == -1
    error('没有找到合适的候选面片。');
end

fprintf('最佳候选面片索引: %d\n', bestFaceIdx);
fprintf('对应视点: [%.2f, %.2f, %.2f]\n', bestViewpoint);
end
