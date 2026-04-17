function viewpoint = getViewpointsFromFovCell(fovCell, move_dist)
% 输入:
%   fovCell - N×1 cell，每个cell包含 N×1 个8×3矩阵（每个8×3矩阵为一个长方体顶点）
%   move_dist - 视点沿法向量移动距离
% 输出:
%   viewpoint - M×6矩阵，M是所有视场域数量，每行是 [视点(x,y,z), 朝向(x,y,z)]

viewpoint = [];

for i = 1:length(fovCell)
    innerCell = fovCell{i};
    for j = 1:length(innerCell)
        verts = innerCell{j};
        
        if isempty(verts)
            % 跳过空视场域
            continue;
        end
        
        center = mean(verts, 1);

        % 取两个边向量计算法向量（根据顶点顺序调整）
        v1 = verts(2,:) - verts(1,:);
        v2 = verts(4,:) - verts(1,:);

        normal = cross(v1, v2);
        norm_val = norm(normal);
        if norm_val < 1e-6
            % 法向量近似零，跳过异常数据
            continue;
        end
        normal = normal / norm_val;

        vp = center + move_dist * normal;
        dir = -normal;

        viewpoint = [viewpoint; vp dir];
    end
end

end
