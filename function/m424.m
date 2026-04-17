
analyzeSTL('C:\Users\86132\Desktop\c\111.stl');
function analyzeSTL(stl_file)
    model = stlread(stl_file);
    vertices = model.Points;
    faces = model.ConnectivityList;

    % 1. 模型边界尺寸
    minXYZ = min(vertices);
    maxXYZ = max(vertices);
    dimensions = maxXYZ - minXYZ;
    fprintf('模型尺寸 (X, Y, Z): %.2f × %.2f × %.2f\n', dimensions(1), dimensions(2), dimensions(3));

    % 2. 顶点与面片数量
    fprintf('顶点数量: %d\n', size(vertices, 1));
    fprintf('三角面片数量: %d\n', size(faces, 1));

    % 3. 法向量方向分布
    v1 = vertices(faces(:,2), :) - vertices(faces(:,1), :);
    v2 = vertices(faces(:,3), :) - vertices(faces(:,1), :);
    normals = cross(v1, v2);
    normals = normals ./ vecnorm(normals, 2, 2);
    meanNormal = mean(normals);
    fprintf('平均法向量方向: [%.2f, %.2f, %.2f]\n', meanNormal);

    % 4. 点间距估计
    D = pdist2(vertices, vertices);
    D(D==0) = NaN;
    avg_spacing = nanmean(min(D,[],2));
    fprintf('估计平均点间距: %.4f\n', avg_spacing);
end
