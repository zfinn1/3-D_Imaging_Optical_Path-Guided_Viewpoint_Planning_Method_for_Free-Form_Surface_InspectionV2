function [vertices, quads] = generateQuadMesh(boundaryPoints, h, maxLayers)
    % generateQuadMesh: Generates a quadrilateral mesh based on boundary-first
    % advancing layer technique combined with coring.
    %
    % Inputs:
    %   - boundaryPoints: Nx2 array of boundary points in parametric domain.
    %   - h: Global mesh size.
    %   - maxLayers: Maximum number of advancing layers.
    % Outputs:
    %   - vertices: Mx2 array of mesh vertex coordinates.
    %   - quads: Px4 array of quadrilateral connectivity.

    %% Initialize Delaunay background grid
    delaunayMesh = delaunayTriangulation(boundaryPoints);
    [tri, verts] = freeBoundary(delaunayMesh);
    vertices = verts;

    %% Advancing Layer Technique
    layerCount = 0;
    advancingFront = tri; % Initial front is the boundary
    quads = [];

    while layerCount < maxLayers && ~isempty(advancingFront)
        % Compute advancing directions for each front edge
        nextPoints = [];
        for i = 1:size(advancingFront, 1)
            % Extract edge
            edge = advancingFront(i, :);
            p1 = vertices(edge(1), :);
            p2 = vertices(edge(2), :);

            % Compute edge midpoint and normal
            midpoint = (p1 + p2) / 2;
            tangent = p2 - p1;
            normal = [-tangent(2), tangent(1)];
            normal = normal / norm(normal);

            % Determine target point for next layer
            nextPoint = midpoint + h * normal;

            % Append to next layer points
            nextPoints = [nextPoints; nextPoint];
        end

        % Add new points to vertices
        n = size(vertices, 1);
        vertices = [vertices; nextPoints];

        % Form quadrilaterals from current front and new layer
        for i = 1:size(advancingFront, 1)
            edge = advancingFront(i, :);
            nextEdge = n + i;
            quads = [quads; edge(1), edge(2), nextEdge, nextEdge + 1];
        end

        % Update advancing front
        advancingFront = [(n+1):(n+size(nextPoints, 1)-1); (n+2):(n+size(nextPoints, 1))]';

        % Increment layer count
        layerCount = layerCount + 1;
    end

    %% Coring technique for interior mesh generation
    remainingRegion = polyshape(vertices(:, 1), vertices(:, 2));
    interiorGrid = generateUniformGrid(remainingRegion, h);
    vertices = [vertices; interiorGrid];

    % Triangulate and merge into quads
    [~, interiorQuads] = delaunayTriangulationToQuads(interiorGrid);
    quads = [quads; interiorQuads];