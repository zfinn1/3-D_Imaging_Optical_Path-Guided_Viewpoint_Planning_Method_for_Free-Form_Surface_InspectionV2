function viewfields = generateViewfieldsAlongContour(contourXY, width, height, spacing)
% 在2D轮廓上布置等间距视场域（长方形底面）
% contourXY: Nx2的点序列，表示轮廓（首尾闭合）
% width: 视场域底面在切线方向的长度
% height: 底面侧向宽度
% spacing: 相邻视场域中心间距
% 返回：M×4×2数组，表示每个视场域的4个角点

    if ~isequal(contourXY(1,:), contourXY(end,:))
        contourXY(end+1,:) = contourXY(1,:);  % 闭合
    end

    diffs = diff(contourXY);
    segLengths = vecnorm(diffs, 2, 2);
    totalLength = sum(segLengths);
    numSamples = floor(totalLength / spacing);

    cumLengths = [0; cumsum(segLengths)];
    sampleDistances = linspace(0, totalLength, numSamples);

    viewfields = zeros(numSamples, 4, 2);  % M×4×2

    for i = 1:numSamples
        d = sampleDistances(i);
        idx = find(cumLengths <= d, 1, 'last');
        if idx >= length(segLengths)
            idx = length(segLengths) - 1;
        end
        t = (d - cumLengths(idx)) / segLengths(idx);
        p1 = contourXY(idx, :);
        p2 = contourXY(idx+1, :);
        center = (1 - t) * p1 + t * p2;
        tangent = (p2 - p1) / norm(p2 - p1);
        ortho = [-tangent(2), tangent(1)];  % 垂直方向

        % 构建底面角点（以中心为原点）
        cornersLocal = [ -0.5 -0.5;
                          0.5 -0.5;
                          0.5  0.5;
                         -0.5  0.5 ] .* [width, height];
        rot = [tangent; ortho];  % 2x2
        transformed = (rot * cornersLocal')' + center;  % 4x2

        viewfields(i,:,:) = transformed;
    end
end