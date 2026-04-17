function [angle_deg,P_far,P_c] = computeAngleFromIntersectionsAndEdge(P3, P4, intersections)
    % 计算 P3P4 的方向向量
    v_P3P4 = P4 - P3;
    v_P3P4 = v_P3P4 / norm(v_P3P4); % 归一化

    if isempty(intersections)
        warning('交点集为空，返回 NaN');
        angle_deg = NaN;
        return;
    end

    % 找到最远的交点
    max_dist = -Inf;
    P_far = intersections(1, :);
    for i = 1:size(intersections, 1)
        pt = intersections(i, :);
        dist = pointToLineDistance(pt, P3, P4);
        if dist > max_dist
            max_dist = dist;
            P_far = pt;
        end
    end

    % 找到最近的交点
    min_dist = Inf;
    P_near = intersections(1, :);
    for i = 1:size(intersections, 1)
        pt = intersections(i, :);
        dist = pointToLineDistance(pt, P3, P4);
        if dist < min_dist
            min_dist = dist;
            P_near = pt;
        end
    end

    P_c=mean(intersections,1);
    % 构造通过 P_near 和 P_far 的直线方向向量
    v_line = P_far - P_c;
    v_line = v_line / norm(v_line); % 归一化

    % 计算 P3P4 方向向量与 v_line 之间的夹角
    cos_theta = dot(v_P3P4, v_line);
    theta_rad = acos(cos_theta);  % 角度制
    angle_deg = rad2deg(theta_rad); 
    if angle_deg>90
        angle_deg=180-angle_deg;
    end
    
end
%% 辅助函数：计算点到线段的最小距离
function d = pointToLineDistance(P, A, B)
    AB = B - A;
    AP = P - A;
    t = dot(AP, AB) / dot(AB, AB); % 计算投影系数
    if t < 0
        P_proj = A; % 落在线段外，最近点为 A
    elseif t > 1
        P_proj = B; % 落在线段外，最近点为 B
    else
        P_proj = A + t * AB; % 投影在线段内部
    end
    d = norm(P - P_proj); % 计算距离
end
