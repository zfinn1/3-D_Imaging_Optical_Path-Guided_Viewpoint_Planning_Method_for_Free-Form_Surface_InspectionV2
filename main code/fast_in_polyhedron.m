function inside = fast_in_polyhedron(faces, vertices, queryPts)
    % 使用射线投射法判断点是否在三角形面片构成的多面体内部
    % 每个点发出一条射线，统计与三角面片的交点数（奇数为内部）

    numPts = size(queryPts, 1);
    numFaces = size(faces, 1);
    inside = false(numPts, 1);

    % 射线方向：统一沿 Z 轴正方向
    ray_dir = repmat([0 0 1], numPts, 1); 

    % 三角形面片顶点
    V0 = vertices(faces(:,1), :);
    V1 = vertices(faces(:,2), :);
    V2 = vertices(faces(:,3), :);

    % Möller–Trumbore 射线-三角形相交算法（向量化批处理）
    for i = 1:numPts
        O = queryPts(i, :);  % 射线起点
        D = ray_dir(i, :);   % 射线方向

        % 构造大小为 [numFaces, 3] 的重复射线方向
        D_rep = repmat(D, numFaces, 1);
        O_rep = repmat(O, numFaces, 1);

        % 计算交点
        e1 = V1 - V0;
        e2 = V2 - V0;
        P = cross(D_rep, e2, 2);
        det = dot(e1, P, 2);

        mask = abs(det) > 1e-8;
        inv_det = zeros(numFaces,1);
        inv_det(mask) = 1 ./ det(mask);

        T = O_rep - V0;
        u = zeros(numFaces,1);
        u(mask) = dot(T(mask,:), P(mask,:), 2) .* inv_det(mask);

        Q = cross(T, e1, 2);
        v = zeros(numFaces,1);
        v(mask) = dot(D_rep(mask,:), Q(mask,:), 2) .* inv_det(mask);

        t = zeros(numFaces,1);
        t(mask) = dot(e2(mask,:), Q(mask,:), 2) .* inv_det(mask);

        % 判断射线是否与三角形相交（u, v >= 0, u+v <= 1, t>0）
        intersect = mask & u >= 0 & v >= 0 & (u + v <= 1) & t > 0;

        % 统计交点数是否为奇数
        if mod(sum(intersect), 2) == 1
            inside(i) = true;
        end
    end
end

