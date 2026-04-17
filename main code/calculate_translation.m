function translation = calculate_translation(allSavedViews, targetIndex)
% 计算各圈需要平移的距离，使相邻圈之间的距离达到10
% 输入：allSavedViews - 所有圈的视场域数据，格式为cell数组
%       targetIndex - 目标视场域的索引
% 输出：translation - 各圈需要平移的距离数组

numCircles = length(allSavedViews);  % 总圈数

% 提取目标视场域的中心点
validCircles = false(1, numCircles);
coordinateDim = 0;  % 坐标维度，自动检测

% 第一遍循环：检测坐标维度
for circle = 1:numCircles
    if ~isempty(allSavedViews{circle}) && ~isempty(allSavedViews{circle}{targetIndex})
        currView = allSavedViews{circle}{targetIndex};
        coordinateDim = size(currView, 2);  % 获取坐标维度
        break;
    end
end

if coordinateDim == 0
    warning('未找到有效的视场域数据');
    translation = zeros(1, numCircles);
    return;
end

% 初始化中心点数组
centers = zeros(numCircles, coordinateDim);

% 第二遍循环：计算中心点
for circle = 1:numCircles
    if ~isempty(allSavedViews{circle}) && ~isempty(allSavedViews{circle}{targetIndex})
        currView = allSavedViews{circle}{targetIndex};
        centers(circle, :) = mean(currView, 1);
        validCircles(circle) = true;
    end
end

% 计算相邻圈之间的距离
validIndices = find(validCircles);
n = length(validIndices);
original_distances = zeros(1, n-1);

for i = 1:n-1
    original_distances(i) = norm(centers(validIndices(i+1), :) - centers(validIndices(i), :));
end

% 计算理想位置和平移距离
ideal_positions = 0:10:(n-1)*10;
original_positions = zeros(1, n);
for i = 2:n
    original_positions(i) = original_positions(i-1) + original_distances(i-1);
end

translation = zeros(1, numCircles);  % 初始化所有圈的平移距离为0
translation(validIndices) = ideal_positions - original_positions;
end


