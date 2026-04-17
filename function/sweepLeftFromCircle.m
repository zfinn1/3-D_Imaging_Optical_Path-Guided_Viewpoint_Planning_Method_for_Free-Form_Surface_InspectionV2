function leftCircle = sweepLeftFromCircle(savedViewsCurrent, stl_file, faces, vertices)
% 从当前一圈的视场向左旋转，生成新一圈补丁视场
%
% 输入：
%   savedViewsCurrent : 当前一圈的cell数组（例如 allSavedViews{6}）
%   stl_file          : STL 文件路径（autoRotateViewfield 用）
%   faces, vertices   : 模型面和点（用于修正）
%
% 输出：
%   leftCircle        : 新一圈cell数组（未成功生成的用 []）

% 固定参数（可按需调整）
epsilon       = 0.1;
numSamples    = 15;
coarseStep    = 1;
maxRotation   = 360;
threshold     = 0.7;
minThreshold  = 0.1;
direction     = 2;  % 左转

nViews = numel(savedViewsCurrent);
leftCircle = cell(nViews, 1);

for i = 1:nViews
    AllPts = savedViewsCurrent{i};
    fprintf('---------------------\nStep %d:\n', i);
    if isempty(AllPts), continue; end

    [AllPts_new, ~, ~] = autoRotateViewfield( ...
        AllPts, stl_file, ...
        epsilon, numSamples, ...
        coarseStep, maxRotation, ...
        threshold, minThreshold, ...
        direction);

    if isequal(AllPts_new, AllPts)
        leftCircle{i} = [];  % 无新视场
    else
        leftCircle{i} = adjustVdthroughN(AllPts_new, faces, vertices);
    end
end
end
