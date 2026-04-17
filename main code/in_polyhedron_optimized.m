function inside = in_polyhedron_optimized(varargin)
% Optimized version of in_polyhedron with faster computation

% === Input Parsing ===
if isa(varargin{1}, 'triangulation')
    [faces, vertices] = freeBoundary(varargin{1});
    points = varargin{2};
elseif isstruct(varargin{1})
    faces = varargin{1}.faces;
    vertices = varargin{1}.vertices;
    points = varargin{2};
else
    faces = varargin{1};
    vertices = varargin{2};
    points = varargin{3};
end

% === Ensure correct orientation ===
if size(points,2) ~= 3
    points = points';
end
if size(vertices,2) ~= 3
    vertices = vertices';
end
if size(faces,2) ~= 3
    faces = faces';
end

% === Precompute face data ===
vert0 = vertices(faces(:,1), :);
edge1 = vertices(faces(:,2), :) - vert0;
edge2 = vertices(faces(:,3), :) - vert0;
N = size(vert0,1);
eps_val = 1e-10;

% === Initialize output ===
numPts = size(points,1);
inside = false(numPts,1);
unresolved = true(numPts,1);  % unresolved points

% === Main loop ===
while any(unresolved)
    % 生成射线方向，使用 randn 更快，分布更广
    dir = randn(1,3); 
    dir = dir / norm(dir); % 单位化
    dirMat = repmat(dir, N, 1);

    % Möller–Trumbore
    pvec = cross(dirMat, edge2, 2);
    det = sum(edge1 .* pvec, 2);
    angleOK = abs(det) > eps_val;

    % 只处理还没判断的点
    idxs = find(unresolved);
    for i = 1:length(idxs)
        ip = idxs(i);
        pt = points(ip, :);
        tvec = vert0 - pt;  % 向量化
        u = sum(tvec .* pvec, 2) ./ det;

        % 初步筛选
        valid = angleOK & u > -eps_val & u < 1.0 + eps_val;
        if ~any(valid)
            inside(ip) = false;
            unresolved(ip) = false;
            continue;
        end

        tvec_valid = tvec(valid, :);
        edge1_valid = edge1(valid, :);
        edge2_valid = edge2(valid, :);
        det_valid = det(valid);
        dir_valid = dirMat(valid, :);

        qvec = cross(tvec_valid, edge1_valid, 2);
        v = sum(dir_valid .* qvec, 2) ./ det_valid;
        t = sum(edge2_valid .* qvec, 2) ./ det_valid;
        u_valid = u(valid);

        bary = [u_valid, v, 1 - u_valid - v, t];
        intersect = all(bary > -eps_val, 2);

        if any(intersect)
            bary_i = bary(intersect, :);
            if all(min(abs(bary_i), [], 2) > eps_val)
                n_inter = sum(intersect);
                inside(ip) = mod(n_inter, 2) > 0;
                unresolved(ip) = false;
                continue;
            end
        end

        % check if it’s on surface
        if any(max(bary,[],2) < 1 + eps_val & abs(t) < eps_val)
            inside(ip) = true;
            unresolved(ip) = false;
        end
    end
end
end
