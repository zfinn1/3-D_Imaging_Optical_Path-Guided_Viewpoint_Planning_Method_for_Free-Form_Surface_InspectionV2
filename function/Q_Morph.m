function Q_Morph(stlFile)
    % Q_Morph: Converts a triangular mesh from an STL file into a quadrilateral mesh using the Q-Morph algorithm.
    %
    % Input:
    %   - stlFile: Path to the STL file containing the triangular mesh.
    % Outputs:
    %   Visualizes the generated quadrilateral mesh.

    % Step 1: Load STL file and extract vertices and faces
    fv = stlread(stlFile);
    vertices = fv.Points;
    faces = fv.ConnectivityList;
    
    % Step 2: Generate quadrilateral mesh by morphing triangles
    [quadVertices, quads] = iterativeQmorph(vertices, faces);
    
    % Step 3: Visualize the quadrilateral mesh
    visualizeQuadMesh(quadVertices, quads);
end

% Step 1: Morph Triangles to Quads
function [quadVertices, quads] = morphTrianglesToQuads(vertices, faces)
    % morphTrianglesToQuads: Merge adjacent triangles into quadrilaterals
    % This function merges neighboring triangles that share an edge into a quadrilateral
    % Inputs:
    %   - vertices: Vertex coordinates
    %   - faces: Connectivity list of triangles
    % Outputs:
    %   - quadVertices: New vertices after merging
    %   - quads: List of quadrilateral faces formed
    
    % Initialize
    quads = [];
    quadVertices = vertices;
    
    % Temporary triangle list
    triangles = faces;
    
    % Iterate through triangles to merge adjacent triangles into quads
    for i = 1:size(triangles, 1)
        for j = i+1:size(triangles, 1)
            % Check if two triangles share an edge
            sharedEdge = intersect(triangles(i, :), triangles(j, :));
            
            % If they share exactly two vertices (an edge), they can be merged
            if numel(sharedEdge) == 2
                % Generate new quadrilateral by merging the triangles
                newQuad = [sharedEdge, setdiff(union(triangles(i, :), triangles(j, :)), sharedEdge)];
                
                % Append new quadrilateral
                quads = [quads; newQuad];
                
                % Remove the triangles that were merged
                triangles(i, :) = [];
                triangles(j, :) = [];
                
                break;
            end
        end
    end
    
    % Update vertices list
    quadVertices = unique(quadVertices, 'rows');
end

% Step 2: Iterative Q-morph algorithm to continue merging triangles into quads
function [quadVertices, quads] = iterativeQmorph(vertices, faces)
    % iterativeQmorph: Continue morphing triangles into quads until no more triangles can be merged
    % Inputs:
    %   - vertices: Vertex coordinates
    %   - faces: Connectivity list of triangles
    % Outputs:
    %   - quadVertices: New vertices after iterative merging
    %   - quads: List of quadrilateral faces formed
    
    % Initialize
    quads = [];
    triangles = faces;
    quadVertices = vertices;
    
    % Continue merging triangles until no more can be merged
    while ~isempty(triangles)
        [quadVertices, newQuads] = morphTrianglesToQuads(quadVertices, triangles);
        quads = [quads; newQuads];
        
        % Update the triangle list by removing merged triangles
        triangles = setdiff(triangles, newQuads, 'rows');
    end
end

% Step 3: Visualize the quadrilateral mesh
function visualizeQuadMesh(quadVertices, quads)
    % visualizeQuadMesh: Plot the quadrilateral mesh
    % Inputs:
    %   - quadVertices: The new quadrilateral mesh vertex coordinates
    %   - quads: The list of quadrilateral faces formed
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
