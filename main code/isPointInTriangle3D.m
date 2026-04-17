
function isInside = isPointInTriangle3D(A, B, C, P)
    % 输入：A, B, C为三角形顶点（三维坐标），P为待判断点（三维坐标）
    % 输出：isInside为布尔值，true表示在内部

    % 计算法向量
    normal = cross(B - A, C - A);
    
    % 计算边和对应从顶点指向点P的向量
    edge0 = B - A;   vp0 = P - A;
    edge1 = C - B;   vp1 = P - B;
    edge2 = A - C;   vp2 = P - C;
    
    % 计算三个叉积的点积
    d0 = dot(cross(edge0, vp0), normal);
    d1 = dot(cross(edge1, vp1), normal);
    d2 = dot(cross(edge2, vp2), normal);
    
    % 考虑数值误差
    epsilon = 1e-6;
    isInside = (d0 >= -epsilon) && (d1 >= -epsilon) && (d2 >= -epsilon);
    
%     if isInside
%         disp('交点在三角形内');
%     else
%         disp('交点不在三角形内');
%     end
end
