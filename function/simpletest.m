% stl_file = 'C:\Users\86132\Desktop\c\111.stl';
% model = stlread(stl_file);
% vertices = model.Points;%返回所有顶点的坐标
% faces = model.ConnectivityList;
% % 调用 in_polyhedron 函数
% points = [0.5 0.5 0.5;   % 在立方体内部
%           1.5 0.5 0.5;   % 在立方体外部
%           13 60 54;   % 在立方体外部
%           13.23 59.47 55];  % 在立方体外部
% inside = in_polyhedron(faces, vertices, points);
% 
% % 显示结果，inside 为逻辑向量，true 表示该点在多面体内部
% disp('各测试点是否在立方体内：');
% disp(inside);
% 
% 
% % 定义 P3 和 P4
% P3 = [0, 0, 1];
% P4 = [0, 0, 0];
% 
% % 假设 computeIntersectionsWithKD 得到交点集
% intersections = [
%     0, 1, 0;
%     0, 2, 0;
%     0, 3, 0;
% ];
% 
% % 计算夹角
% angle = computeAngleFromIntersectionsAndEdge(P3, P4, intersections);
% 
% % 输出结果
% fprintf('P3P4 线段与交点方向的夹角: %.2f°\n', angle);


P1 = [0; 0; 0];
P2 = [0; 1; 0];
P3 = [0; 1; 1];
P4 = [0; 0; 1];
P  = [0;5; 0.7]; % 一个在长方形上方的点

P_proj = findProjectionPoint(P1, P2, P3, P4, P);
disp('投影点坐标:');
disp(P_proj);


function P_proj = findProjectionPoint(P1, P2, P3, P4, P)
% findProjectionPoint - 计算 P 在 P3P4 中点与整个长方形中心连成的线上的投影坐标
%
% 输入：
%   P1, P2, P3, P4 - 长方形的四个顶点 (3×1 向量)
%   P              - 需要投影的点 (3×1 向量)
%
% 输出：
%   P_proj - P 在 M-C 直线上的投影坐标 (3×1 向量)

% 计算 P3P4 中点 M
M = (P3 + P4) / 2;

% 计算长方形中心 C
C = (P1 + P2 ) / 2;


% 计算 M-C 方向向量
dirVec = C - M;

% 确保方向向量非零
if norm(dirVec) < 1e-10
    error('M 和 C 位置重合，无法计算投影。');
end

% 计算投影点 P_proj
t = dot(P - M, dirVec) / dot(dirVec, dirVec);
P_proj = M + t * dirVec;

end