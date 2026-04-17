function [A, B, C, D] = compute_plane_coeffs(a, b, c)
    % a, b, c: 三角形顶点的坐标 [x, y, z]

    % 向量 AB 和 AC
    AB = b - a;
    AC = c - a;

    % 计算法向量 n = [A, B, C]，通过叉积获得
    n = cross(AB, AC);
    
    % 提取法向量的分量 A, B, C
    A = n(1);
    B = n(2);
    C = n(3);

    % 使用点 A 的坐标代入平面方程 Ax + By + Cz + D = 0，求 D
    D = -(A * a(1) + B * a(2) + C * a(3));

    % 显示结果
%     fprintf('平面方程: %fx + %fy + %fz + %f = 0\n', A, B, C, D);
end
 
 
