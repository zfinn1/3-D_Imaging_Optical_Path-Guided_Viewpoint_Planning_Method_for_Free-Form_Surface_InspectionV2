function [quadVertices, quads] = stlToQuadMesh(h, maxLayers)
    % 读取 STL 文件
    fv = stlread('C:\Users\86132\Desktop\本科毕设\叶片模型.stl');
    vertices = fv.Points;
    faces = fv.ConnectivityList;

    % 修复重复顶点并提取边界
    vertices = unique(vertices, 'rows', 'stable');
    edges = [faces(:, [1, 2]); faces(:, [2, 3]); faces(:, [3, 1])];
    sortedEdges = sort(edges, 2);
    [uniqueEdges, ~, idx] = unique(sortedEdges, 'rows');
    edgeCounts = accumarray(idx, 1);
    boundaryEdges = uniqueEdges(edgeCounts == 1, :);

    if isempty(boundaryEdges)
        error('No valid boundary edges found in the STL file. Check if the STL is closed or valid.');
    end

    % 提取边界点并插值增加密度
    interpPoints = [];
    for i = 1:size(boundaryEdges, 1)
        p1 = vertices(boundaryEdges(i, 1), :);
        p2 = vertices(boundaryEdges(i, 2), :);
        t = linspace(0, 1, 10); % 插值 10 个点
        newPoints = (1 - t') * p1 + t' * p2;
        interpPoints = [interpPoints; newPoints];
    end
    boundaryPoints = unique(interpPoints, 'rows');

    if size(boundaryPoints, 1) < 3
        error('Insufficient boundary points for triangulation. Verify the STL file integrity.');
    end

    % 生成四边形网格
    [quadVertices, quads] = generateQuadMesh(boundaryPoints, h, maxLayers);

    % 可视化
    figure;
    hold on;
    for i = 1:size(quads, 1)
        quad = quads(i, :);
        fill(quadVertices(quad, 1), quadVertices(quad, 2), 'cyan', 'EdgeColor', 'black');
    end
    scatter(quadVertices(:, 1), quadVertices(:, 2), 'r.');
    hold off;
    axis equal;
    title('Quadrilateral Mesh from STL');
end
