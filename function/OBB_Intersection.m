function isIntersect = OBB_Intersection(A_pts, B_pts)
    % 计算 A 盒子的中心和坐标轴
    [A_FCenter, A_FAxis, A_FExtent] = computeOBB(A_pts);
    [B_FCenter, B_FAxis, B_FExtent] = computeOBB(B_pts);

    % 计算相对位移向量
    D = B_FCenter - A_FCenter;
    
    % 存储所有分离轴
    separable = false;
    
    % 计算所有分离轴
    for i = 1:3
        % A 盒子的 3 个轴
        separable = testSeparationAxis(A_FAxis(i,:), A_FAxis, B_FAxis, A_FExtent, B_FExtent, D);
        if separable, isIntersect = false; return; end

        % B 盒子的 3 个轴
        separable = testSeparationAxis(B_FAxis(i,:), A_FAxis, B_FAxis, A_FExtent, B_FExtent, D);
        if separable, isIntersect = false; return; end
    end
    
    % A 盒子轴 × B 盒子轴 叉乘，得到 9 个轴
    for i = 1:3
        for j = 1:3
            crossAxis = cross(A_FAxis(i,:), B_FAxis(j,:));
            if norm(crossAxis) > 1e-6  % 避免零向量
                separable = testSeparationAxis(crossAxis, A_FAxis, B_FAxis, A_FExtent, B_FExtent, D);
                if separable, isIntersect = false; return; end
            end
        end
    end
    
    % 如果没有找到分离轴，则相交
    isIntersect = true;
end

function [FCenter, FAxis, FExtent] = computeOBB(pts)
    % 计算 OBB 中心
    FCenter = mean(pts, 1);
    
    % 计算 OBB 方向（SVD 求主方向）
    [~, ~, V] = svd(pts - FCenter, 0);
    FAxis = V'; % 每一行是一个方向向量
    
    % 计算半长 (Extent)
    localPts = (pts - FCenter) * FAxis'; % 转换到局部坐标
    minVals = min(localPts, [], 1);
    maxVals = max(localPts, [], 1);
    FExtent = (maxVals - minVals) / 2;
end

function separable = testSeparationAxis(axis, A_FAxis, B_FAxis, A_FExtent, B_FExtent, D)
    % 归一化分离轴
    axis = axis / norm(axis);
    
    % 计算投影长度
    R = abs(dot(D, axis));
    R0 = sum(abs(A_FExtent .* (A_FAxis * axis')));
    R1 = sum(abs(B_FExtent .* (B_FAxis * axis')));
    
    % 分离轴定理判定
    separable = (R > R0 + R1);
end
