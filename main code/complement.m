
K       = 20;        % 聚类数（即想找几个补充视点）
maxIter = 200;      % kmedoids 最大迭代次数
uncovered_points1=uncovered_points;

% uncovered_pts: N×3 single 数组
XYZ = double(uncovered_points);    % kmedoids 要求输入为 double


opts = statset('MaxIter', maxIter);
[idx, medoids] = kmedoids(XYZ, K, 'Options', opts, 'Distance', 'euclidean');

[triIdx, D] = knnsearch(kdtree, medoids);

% triIdx 是长度为 K 的向量，triIdx(k) 即表示第 k 个 medoid
% 最近的三角形索引。D 给出了距离（可选）。
additionalViews = cell(numel(triIdx), 1); 
% 2. 输出结果
for k = 1:numel(triIdx)
    fprintf('Medoid %2d 位于三角片 %4d (距离 %.4f)\n', ...
            k, triIdx(k), D(k));
    
initialface = triIdx(k);
A = vertices(faces(initialface,1),:);
B = vertices(faces(initialface,2),:);
C = vertices(faces(initialface,3),:);
[P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, 10, 0.5, 30);

maybe=[P1;P2;P3;P4;F1;F2;F3;F4];
additionalViews{k}=maybe;
end
allSavedViews{10} =additionalViews;
figure;
% 所有未覆盖点（蓝色小点）
scatter3(XYZ(:,1), XYZ(:,2), XYZ(:,3), 10, 'b', 'filled');
hold on;

% 聚类中心（medoids，对应原始点，绿色大点）
scatter3(...
    medoids(:,1),medoids(:,2),medoids(:,3), ...
    100, 'g', 'filled' ...
);

xlabel('X'); ylabel('Y'); zlabel('Z');
legend('未覆盖点','聚类中心');
title(sprintf('K-medoids 聚类（K = %d）', K));
axis equal;
grid on;
