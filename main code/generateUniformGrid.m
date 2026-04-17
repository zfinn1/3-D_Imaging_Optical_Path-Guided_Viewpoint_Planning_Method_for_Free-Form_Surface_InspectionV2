function gridPoints = generateUniformGrid(region, h)
    % Generate uniform grid points within a given region
    [xMin, xMax] = bounds(region.Vertices(:, 1));
    [yMin, yMax] = bounds(region.Vertices(:, 2));
    [X, Y] = meshgrid(xMin:h:xMax, yMin:h:yMax);
    gridPoints = [X(:), Y(:)];

    % Filter points inside the region
    in = isinterior(region, gridPoints(:, 1), gridPoints(:, 2));
    gridPoints = gridPoints(in, :);
end