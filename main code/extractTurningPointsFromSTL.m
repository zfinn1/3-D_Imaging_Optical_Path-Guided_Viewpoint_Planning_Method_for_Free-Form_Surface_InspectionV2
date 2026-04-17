function turning_points = extractTurningPointsFromSTL(stl_file, shrink_factor, step, angle_threshold, merge_threshold)
% 提取 STL 模型在 XY 投影平面上的边界走向突变点
% 输入参数：
% - stl_file: STL 文件路径（例如 'model.stl'）
% - shrink_factor: boundary 函数的非凸包参数（通常为 0.8 左右）
% - step: 边界稀疏采样步长（建议 3~10）
% - angle_threshold: 突变角度阈值（单位：弧度，例如 0.4）
% - merge_threshold: 合并突变点距离阈值（与模型单位一致）

    fv = stlread(stl_file);
    vertices = fv.Points;
    xy_vertices = vertices(:, 1:2);

    % Step 1: 计算边界线（非凸包）
    k = boundary(xy_vertices(:, 1), xy_vertices(:, 2), shrink_factor);
    boundary_pts = xy_vertices(k, :);

    % Step 2: 稀疏采样
    B_sparse = boundary_pts(1:step:end, :);
    if norm(B_sparse(1,:) - B_sparse(end,:)) > 1e-5
        B_sparse(end+1,:) = B_sparse(1,:); % 闭合
    end

    % Step 3: 计算稀疏点走向角度
    angles = zeros(size(B_sparse,1)-1,1);
    for i = 1:length(angles)
        delta = B_sparse(i+1,:) - B_sparse(i,:);
        angles(i) = atan2(delta(2), delta(1));
    end

    % Step 4: 计算角度变化并提取突变点
    angle_diff = diff(unwrap(angles));
    turn_idx = find(abs(angle_diff) > angle_threshold) + 1;
    turn_pts = B_sparse(turn_idx, :);

    % Step 5: 合并距离太近的突变点
    merged_pts = [];
    used = false(size(turn_pts, 1), 1);
    for i = 1:size(turn_pts,1)
        if used(i), continue; end
        close_group = turn_pts(i, :);
        used(i) = true;
        for j = i+1:size(turn_pts,1)
            if ~used(j) && norm(turn_pts(i,:) - turn_pts(j,:)) < merge_threshold
                close_group = [close_group; turn_pts(j,:)];
                used(j) = true;
            end
        end
        merged_pts(end+1, :) = mean(close_group, 1);
    end

    turning_points = merged_pts;
end
