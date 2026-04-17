function [AllPts_final, P_final, F_final, intersections_final] = ...
    autoAdjustViewField(AllPts, isIntersections, kdtree, stl_file, ...
                         max_rot_iter, dist_thresh, k, tol)
% 输入参数说明：
%   AllPts           - 原始视场域的 8 个角点坐标，8×3 数组
%   isIntersections  - 初始计算得到的交点集合（可能为空）
%   model            - STL 模型结构体，用于法向计算
%   kdtree           - 模型点构建的 KD 树，用于快速最近邻查询
%   stl_file         - STL 文件路径，供 adjustpos 使用
%   faces, vertices  - STL 模型三角面片和顶点，用于 adjustVdthroughN
%   max_rot_iter     - 最多进行旋转微调的次数
%   dist_thresh      - KD 树交点搜索的容差（如 1e-2）
%   k                - KD 树搜索的近邻数量（如 8）
%   tol              - 判断交点是否靠近参考边的距离容差（如 0.8）
model = stlread(stl_file);
vertices = model.Points;
faces = model.ConnectivityList;
    P0 = AllPts(1:4,:);
    F0 = AllPts(5:8,:);

    if isempty(isIntersections)
        fprintf('[无需调整] 无交点，跳过所有操作。\n');
        AllPts_final = AllPts;
        P_final = P0;
        F_final = F0;
        intersections_final = [];
        return;
    end

    if needAdjustmentByProximity(isIntersections, P0, tol)
        fprintf('[触发旋转] 有交点且靠近参考边，开始旋转微调...\n');

        [AllPts_rot, P_rot, F_rot, intersections_rot] = ...
            adjustUntilNoIntersection(AllPts, model, kdtree, stl_file, max_rot_iter, dist_thresh, k);

        if needAdjustmentByProximity(intersections_rot, P_rot, tol)
            fprintf('[触发法向移动] 旋转后仍靠近，执行 adjustVdthroughN...\n');

            AllPts_moved = adjustVdthroughN([P_rot; F_rot], faces, vertices);
            AllPts_moved = adjustVdthroughN(AllPts_moved, faces, vertices);  % 可连做两次以保证充分调整

            AllPts_final = AllPts_moved;
            P_final = AllPts_moved(1:4,:);
            F_final = AllPts_moved(5:8,:);
            intersections_final = computeIntersectionsWithKD(P_final, model, dist_thresh, kdtree, k);
%               AllPts_final = AllPts_rot;
%                P_final = AllPts_final(1:4,:);
%               F_final = AllPts_final(5:8,:);
%               intersections_final = intersections_rot;
        else
            fprintf('[微调完成] 旋转已解决问题，无需法向移动。\n');
            AllPts_final = AllPts_rot;
            P_final = P_rot;
            F_final = F_rot;
            intersections_final = intersections_rot;
        end
    else
        fprintf('[仅有交点但位置合理] 不靠近参考边，无需调整。\n');
        AllPts_final = AllPts;
        P_final = P0;
        F_final = F0;
        intersections_final = isIntersections;
    end
end

function needAdjust = needAdjustmentByProximity(intersections, P, tol)
    % 检查是否存在交点距离参考直线太近
    % tol: 距离容差
    
    if nargin < 3
        tol = 0.8;
    end

    P1 = P(1,:);
    P2 = P(2,:);
    lineVec = P2 - P1;
    lineNorm = norm(lineVec);
    
    if lineNorm < eps
        needAdjust = false;
        return;
    end
    
    for i = 1:size(intersections,1)
        pt = intersections(i,:);
        dist = norm(cross(pt - P1, lineVec)) / lineNorm;
        if dist < tol
            needAdjust = true;
            return;
        end
    end
    
    needAdjust = false;
end


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

