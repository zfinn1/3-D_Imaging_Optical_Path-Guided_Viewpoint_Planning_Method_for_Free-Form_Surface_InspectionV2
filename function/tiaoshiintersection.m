mn=[25.7912,77.5474,62.5310];

intersections=[30.4339,78.7273,66.2573;
30.4441,78.9547,66.2478;
30.3497,77.5853,66.2776;
30.4107,78.4107,66.2630;
30.5326,80.4452,66.2035;
30.2926,76.9844,66.2779;
30.5457,80.8229,66.1846;
30.2494,76.5592,66.2758;
30.1243,75.5680,66.2507;
30.2015,76.1775,66.2663;
30.0577,75.0978,66.2328;
30.0665,75.1594,66.2352;
30.5809,81.3408,66.1729;
30.0242,74.8820,66.2222;
30.6681,82.6311,66.1433;
27.2035,80.7828,63.4387;
26.9708,80.1582,63.2962;
27.4689,82.3568,63.5334;
27.3252,81.5064,63.4819;
29.9063,74.2138,66.1777;
29.8165,73.7566,66.1397;
30.7246,83.1931,66.1457;
27.4396,83.0827,63.4523;
27.4074,83.8703,63.3639;];
P1=[26.7077203799141,84.2048442983173,62.7621073936451];
P2=[34.3181765161268,82.9289652029665,69.1223817535158];
distances = zeros(size(intersections, 1), 1);

% 计算每个点到直线的距离
for i = 1:size(intersections, 1)
    distances(i) = point_to_line_distance(intersections(i,:), P1, P2);
end

% 显示结果
disp('点到直线的距离：');
disp(distances);

visualizeIntersections(intersections);
function visualizeIntersections(intersections, varargin)
% visualizeIntersections 可视化 3D 空间中的交点集
%
% 输入：
%   intersections: N x 3 数组，表示交点坐标
% 可选输入参数（通过名称-值对）：
%   'Color'      - 点的颜色，默认 'r'
%   'Size'       - 散点大小，默认 80
%   'ShowIndex'  - 是否显示编号标签，默认 false
%   'TagPrefix'  - 标签前缀字符串，默认 ''
%
% 示例：
%   visualizeIntersections(isIntersections, 'Color', 'g', 'ShowIndex', true)

    % 默认参数
    color = 'r';
    sz = 80;
    showIndex = false;
    tagPrefix = '';

    % 解析可选参数
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case 'color'
                color = varargin{i+1};
            case 'size'
                sz = varargin{i+1};
            case 'showindex'
                showIndex = varargin{i+1};
            case 'tagprefix'
                tagPrefix = varargin{i+1};
        end
    end

    % 可视化交点
    scatter3(intersections(:,1), intersections(:,2), intersections(:,3), ...
        sz, color, 'filled');

    % 添加编号标签（如果启用）
    if showIndex
        for i = 1:size(intersections, 1)
            text(intersections(i,1), intersections(i,2), intersections(i,3), ...
                sprintf('%s%d', tagPrefix, i), ...
                'FontSize', 8, 'Color', 'k', 'VerticalAlignment', 'bottom');
        end
    end

    % 画图设置
    axis equal;
    grid on;
    rotate3d on;
end
   function dist = point_to_line_distance(Q, P1, P2)
% 计算点Q到由P1和P2确定的直线的距离
% 输入:
%   Q  = [x, y, z]，待计算的点坐标
%   P1 = [x1, y1, z1]，直线上的第一个点
%   P2 = [x2, y2, z2]，直线上的第二个点
% 输出:
%   dist = 点Q到直线的距离

    % 计算直线的方向向量
    v = P2 - P1;
    
    % 计算从P1到Q的向量
    w = Q - P1;
    
    % 计算叉积的模长
    cross_product = cross(w, v);
    cross_norm = norm(cross_product);
    
    % 计算方向向量的模长
    v_norm = norm(v);
    
    % 计算距离
    dist = cross_norm / v_norm;
end
