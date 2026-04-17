function newBasePoints = generateNewBasePoints(P, intersections, delta)
    % 功能：根据当前视点和交点生成新的底面顶点
    % 输入：
    %   - P: 当前视点坐标（1x3向量）
    %   - intersections: 结构体数组，包含四条射线的交点信息
    %     每个结构体需包含字段 `visibleIntersection`（交点坐标，1x3向量）
    %   - delta: 沿射线方向延伸的距离（单位需与模型坐标一致）
    % 输出：
    %   - newBasePoints: 新底面顶点（4x3矩阵，每行为一个顶点坐标）

    % 从 intersections 中提取四个交点 E, F, G, H
    % 假设 intersections 顺序对应原底面顶点 [P1, P2, P3, P4]
    E = intersections(1).visibleIntersection; % 第一条射线的交点（P1方向）
    F = intersections(2).visibleIntersection; % 第二条射线的交点（P2方向）
    G = intersections(3).visibleIntersection; % 第三条射线的交点（P3方向）
    H = intersections(4).visibleIntersection; % 第四条射线的交点（P4方向）

    % 计算视点 P 到 F 和 H 的原始距离
    d_F = norm(F - P); % ||F - P||
    d_H = norm(H - P); % ||H - P||

    % 沿射线方向延伸 F 和 H
    % F' = P + (F - P) * (1 + delta/d_F)
    if d_F > 0
        F_prime = P + (F - P) * (1 + delta/d_F);
    else
        error('视点 P 与交点 F 重合，无法延伸');
    end

    % H' = P + (H - P) * (1 + delta/d_H)
    if d_H > 0
        H_prime = P + (H - P) * (1 + delta/d_H);
    else
        error('视点 P 与交点 H 重合，无法延伸');
    end

    % 保留 E 和 G，生成新底面顶点 [E; F_prime; G; H_prime]
    newBasePoints = [E; F_prime; G; H_prime];
end