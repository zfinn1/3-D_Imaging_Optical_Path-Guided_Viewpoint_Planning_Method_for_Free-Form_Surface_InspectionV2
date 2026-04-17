function [vertices, quads] = delaunayTriangulationToQuads(points)
    % Convert Delaunay triangulation to quads
    dt = delaunayTriangulation(points);
    triangles = dt.ConnectivityList;

    % Merge triangles into quads (simple example, not optimal)
    quads = [];
    usedTriangles = false(size(triangles, 1), 1);

    for i = 1:size(triangles, 1)
        if ~usedTriangles(i)
            % Find a neighboring triangle
            tri = triangles(i, :);
            neighbors = edgeAttachments(dt, tri);
            if ~isempty(neighbors)
                for n = neighbors{1}
                    if ~usedTriangles(n)
                        % Merge triangles into a quad
                        commonEdge = intersect(tri, triangles(n, :));
                        if length(commonEdge) == 2
                            otherVertices = setdiff([triangles(i, :) triangles(n, :)], commonEdge);
                            quad = [commonEdge otherVertices];
                            quads = [quads; quad];
                            usedTriangles(i) = true;
                            usedTriangles(n) = true;
                            break;
                        end
                    end
                end
            end
        end
    end

    vertices = dt.Points;
end