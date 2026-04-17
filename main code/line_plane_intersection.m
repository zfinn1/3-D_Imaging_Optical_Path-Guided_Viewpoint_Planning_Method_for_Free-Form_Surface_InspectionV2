function intersection_point = line_plane_intersection(P1, P2, plane_coeffs)
    % P1, P2: 两个点的坐标 [x, y, z]，定义直线
    % plane_coeffs: 平面的系数 [A, B, C, D]，平面方程 Ax + By + Cz + D = 0
    
    % 提取平面系数
    A = plane_coeffs(1);
    B = plane_coeffs(2);
    C = plane_coeffs(3);
    D = plane_coeffs(4);
    
    % 直线的参数方程
    % x = x1 + t(x2 - x1)
    % y = y1 + t(y2 - y1)
    % z = z1 + t(z2 - z1)
    x1 = P1(1); y1 = P1(2); z1 = P1(3);
    x2 = P2(1); y2 = P2(2); z2 = P2(3);
    
    % 计算参数 t
    numerator = A*x1 + B*y1 + C*z1 + D;
    denominator = A*(x2 - x1) + B*(y2 - y1) + C*(z2 - z1);
    
    if denominator == 0
        error('直线与平面平行，或者直线在平面内，没有交点。');
    end
    
    t = -numerator / denominator;
    
    % 计算交点坐标
    x = x1 + t * (x2 - x1);
    y = y1 + t * (y2 - y1);
    z = z1 + t * (z2 - z1);
    
    % 输出交点
    intersection_point = [x, y, z];
    
%     % 显示交点
%     disp('棱线与目标面片交点坐标:');
%     disp(intersection_point);
end
