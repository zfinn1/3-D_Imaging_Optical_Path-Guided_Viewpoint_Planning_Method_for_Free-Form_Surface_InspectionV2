fv = stlread('C:\Users\86132\Desktop\c\111.stl');
vertices = fv.Points;
xy_vertices = vertices(:, 1:2);

% Step 1: 获取非凸边界
k = boundary(xy_vertices(:, 1), xy_vertices(:, 2), 0.8);
boundary_pts = xy_vertices(k, :);

% Step 2: 稀疏采样
step = 5;
B_sparse = boundary_pts(1:step:end, :);
if norm(B_sparse(1,:) - B_sparse(end,:)) > 1e-5
    B_sparse(end+1,:) = B_sparse(1,:); % 闭合
end

% Step 3: 检测走向突变点
angles = zeros(size(B_sparse,1)-1,1);
for i = 1:length(angles)
    delta = B_sparse(i+1,:) - B_sparse(i,:);
    angles(i) = atan2(delta(2), delta(1));
end

% 计算走向变化量（考虑角度跳变问题）
angle_diff = diff(unwrap(angles));

% Step 4: 提取突变点索引
threshold = 0.4; % 角度阈值（单位：弧度）
turn_idx = find(abs(angle_diff) > threshold) + 1;
turn_pts = B_sparse(turn_idx, :);

% Step 5: 合并距离太近的点
merge_threshold = 2; % 可以根据模型尺度调整，例如单位是 mm 可设为 1~5
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

num_pts = size(merged_pts, 1);
figure; hold on; axis equal;
plot(boundary_pts(:,1), boundary_pts(:,2), 'k-', 'DisplayName', '边界');
plot(merged_pts(:,1), merged_pts(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', '突变点');

% 逐段拟合（可设置为拟合每两点或三点一段）
for i = 1:num_pts
    % 循环连接第 i 和 i+1 个点，注意闭合
    pt1 = merged_pts(i, :);
    pt2 = merged_pts(mod(i, num_pts) + 1, :);  % 闭合
    % 拟合直线段（用线段连接即可，因为只有两点）
    plot([pt1(1), pt2(1)], [pt1(2), pt2(2)], 'b-', 'LineWidth', 2, 'DisplayName', '拟合线段');
end

legend;
title('突变点线段拟合');


plot(boundary_pts(:,1), boundary_pts(:,2), 'k-');
plot(B_sparse(:,1), B_sparse(:,2), 'bo-');
plot(merged_pts(:,1), merged_pts(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
legend('边界线', '稀疏点', '合并后的突变点');
title('优化后的方向突');
