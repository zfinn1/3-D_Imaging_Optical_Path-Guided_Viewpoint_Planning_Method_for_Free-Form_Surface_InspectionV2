function [P, P1, P2, P3, P4, F1, F2, F3, F4] = viewfieldPyrCuboid(A, B, C, nearSide, depth, extra)
% viewfieldPyrCuboid - 构造视场模型，包含一个长方体和一个四棱锥
%
%  输入参数：
%    A, B, C  : 定义参考平面的三角形顶点（3×1或1×3向量）
%    nearSide : 长方体近面正方形的边长（例如 10 cm）
%    depth    : 长方体的深度（例如 1 cm）
%    extra    : 视点距离长方体远面的额外距离（决定四棱锥高度）
%
%  输出参数：
%    P        : 视点（四棱锥锥顶），不在参考平面上
%    P1,P2,P3,P4 : 长方体近面正方形的四个顶点（位于参考平面上）
%    F1,F2,F3,F4 : 长方体远面正方形的四个顶点（由 P1～P4 沿平面法向平移 depth 得到）
%
% 算法：
%   1. 计算参考平面的法向量 n 及归一化 n_unit；
%   2. 计算平面重心 P_c = (A+B+C)/3；
%   3. 在平面内构造一组正交基 u 和 v（u, v 均在参考平面内）；
%   4. 以 P_c 为中心构造边长 nearSide 的正方形，其顶点为：
%         P1 = P_c + (nearSide/2)*(u+v)
%         P2 = P_c + (nearSide/2)*(-u+v)
%         P3 = P_c + (nearSide/2)*(-u-v)
%         P4 = P_c + (nearSide/2)*(u-v)
%   5. 远面顶点：F_i = P_i + depth*n_unit, i=1,2,3,4；
%   6. 视点 P：P = P_c + (depth+extra)*n_unit;
%

    % 将 A, B, C 转为行向量（如有需要）
    A = A(:)'; B = B(:)'; C = C(:)';
    
    % 1. 计算平面法向量
    AB = B - A;
    AC = C - A;
    n = cross(AB, AC);
    if norm(n) < 1e-6
        error('三角形顶点共线，无法确定唯一平面。');
    end
    n_unit = n / norm(n);
    
    % 2. 计算平面重心
    P_c = (A + B + C) / 3;
    
    % 3. 构造平面内正交基
    % 选择一个不平行于 n_unit 的候选向量
    if abs(n_unit(1)) < 1e-6 && abs(n_unit(2)) < 1e-6
        u = [0.1, 1, 0];  % 若 n_unit 近似指向 Z 轴
    else
        u = [0, 1, 0.1];
    end
    % 去除 u 中与 n_unit 的平行分量，使 u 完全在平面内
    u = u - dot(u, n_unit) * n_unit;
    u = u / norm(u);
    % v 为 n_unit 与 u 的叉积
    v = cross(n_unit, u);
    v = v / norm(v);
    
    % 4. 构造近面正方形顶点（位于参考平面内）
    half = nearSide / 2;
    P1 = P_c + half * (u + v)-depth * n_unit;
    P2 = P_c + half * (-u + v)-depth * n_unit;
    P3 = P_c + half * (-u - v)-depth * n_unit;
    P4 = P_c + half * (u - v)-depth * n_unit;
%     P1 = P_c + half * (u + v);
%     P2 = P_c + half * (-u + v);
%     P3 = P_c + half * (-u - v);
%     P4 = P_c + half * (u - v);
    % 5. 构造远面顶点：沿 n_unit 平移 depth
    F1 = P1 + 2*depth * n_unit;
    F2 = P2 + 2*depth * n_unit;
    F3 = P3 + 2*depth * n_unit;
    F4 = P4 + 2*depth * n_unit;
    
    % 6. 计算视点 P：平移 (depth+extra) 个单位
    P = P_c + (depth + extra) * n_unit;
end


