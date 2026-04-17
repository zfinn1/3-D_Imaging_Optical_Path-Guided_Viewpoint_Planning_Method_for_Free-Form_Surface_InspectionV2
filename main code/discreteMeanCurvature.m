function H = discreteMeanCurvature(TR)
% 计算平均曲率 H，输入为 triangulation 对象 TR

V = TR.Points;
F = TR.ConnectivityList;
nv = size(V, 1);

% 初始化邻接矩阵和面积
L = sparse(nv, nv);  % 拉普拉斯矩阵
A = zeros(nv, 1);    % 局部面积

% 遍历所有三角形
for i = 1:size(F, 1)
    ids = F(i, :);
    v1 = V(ids(1), :);
    v2 = V(ids(2), :);
    v3 = V(ids(3), :);

    % 三角形面积（三等分分配）
    area = 0.5 * norm(cross(v2 - v1, v3 - v1));
    A(ids) = A(ids) + area / 3;

    % 构建 cotangent 权重
    for j = 1:3
        i1 = ids(j);
        i2 = ids(mod(j,3)+1);
        i3 = ids(mod(j+1,3)+1);

        u = V(i2,:) - V(i1,:);
        v = V(i3,:) - V(i1,:);
        n = cross(u,v);
        cot_angle = dot(u,v) / max(norm(n), 1e-8);  % 避免除0

        % 对称加权
        L(i2,i3) = L(i2,i3) - cot_angle / 2;
        L(i3,i2) = L(i3,i2) - cot_angle / 2;
        L(i2,i2) = L(i2,i2) + cot_angle / 2;
        L(i3,i3) = L(i3,i3) + cot_angle / 2;
    end
end

% 拉普拉斯-贝尔特拉米向量
Hn = -L * V;

% 曲率大小（向量模长），除以2A是为了归一化
H = sqrt(sum(Hn.^2, 2)) ./ (2 * A);
end
