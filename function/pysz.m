%% --- 配置及检查 ---
% 视场域面定义（基于顶点顺序 maybe = [P1; P2; P3; P4; F1; F2; F3; F4]）
faceA_idx = [1 5 4 8];  % 第一圈靠近第二圈的面：P1-F1-P4-F4
faceB_idx = [2 6 3 7];  % 第二圈靠近第一圈的面：P2-F2-P3-F3

% 假设 allSavedViews{5} 和 allSavedViews{6} 存储的是 cell 数组，
% 每个 cell 中存储一个视场域（8×3 或 3×8 的矩阵）
firstGroup = allSavedViews{5};
secondGroup = allSavedViews{6};

% 自动检查并调整数据格式为 8×3
for i = 1:length(firstGroup)
    sz = size(firstGroup{i});
    if isequal(sz, [3,8])
        firstGroup{i} = firstGroup{i}';  % 转置成 8×3
    elseif ~isequal(sz, [8,3])
        warning('firstGroup{%d} 尺寸为 %dx%d，不是 8×3！', i, sz(1), sz(2));
    end
end

for i = 1:length(secondGroup)
    sz = size(secondGroup{i});
    if isequal(sz, [3,8])
        secondGroup{i} = secondGroup{i}';  % 转置成 8×3
    elseif ~isequal(sz, [8,3])
        warning('secondGroup{%d} 尺寸为 %dx%d，不是 8×3！', i, sz(1), sz(2));
    end
end

nA = length(firstGroup);    % 第一圈视场域数量
nB = length(secondGroup);   % 第二圈视场域数量

%% --- 主循环计算 ---
minDist = zeros(nB, 1);         % 存储每个第二圈视场域与最近第一圈视场域的面间最小距离
closestIndex = zeros(nB, 1);    % 存储对应的第一圈视场域索引

for i = 1:nB
    boxB = secondGroup{i};
    % 检查 boxB 是否完整
    if size(boxB,1) < max(faceB_idx)
        warning('第二圈第 %d 个视场域数据不完整！', i);
        continue;
    end
    faceB = boxB(faceB_idx, :);  % 取出第二圈的靠近面
    
    d_min = inf;
    min_idx = -1;
    
    for j = 1:nA
        boxA = firstGroup{j};
        % 检查 boxA 是否完整
        if size(boxA,1) < max(faceA_idx)
            warning('第一圈第 %d 个视场域数据不完整！', j);
            continue;
        end
        faceA = boxA(faceA_idx, :);  % 取出第一圈的靠近面
        
        d = face_to_face_distance(faceA, faceB);
        
        if d < d_min
            d_min = d;
            min_idx = j;
        end
    end
    
    minDist(i) = d_min;
    closestIndex(i) = min_idx;
end

%% --- 输出结果 ---
for i = 1:nB
    fprintf('第二圈视场域 %d 最近的是第一圈的 %d，最小面间距为 %.4f\n', ...
        i, closestIndex(i), minDist(i));
end

%% --- 工具函数 ---
function d = face_to_face_distance(face1, face2)
    % 计算两个四边形面之间的最小距离（基于各自顶点到对面所在平面的距离）
    d = inf;
    for k = 1:4
        d1 = point_to_plane_distance(face1(k,:), face2);
        d2 = point_to_plane_distance(face2(k,:), face1);
        d = min([d, d1, d2]);
    end
end

function d = point_to_plane_distance(p, quad)
    % 计算点 p 到四边形 quad 所在平面的距离
    % 这里通过构造面所在平面的法向量来计算
    v1 = quad(2,:) - quad(1,:);
    v2 = quad(4,:) - quad(1,:);
    n = cross(v1, v2);
    n_norm = norm(n);
    if n_norm == 0
        error('四边形的点不能共线！');
    end
    n = n / n_norm;  % 单位法向量
    d = abs(dot(p - quad(1,:), n));
end
