function [newSquareVertices,d] = generateSquareFromProjection(PF, P, sideLength)
% generateSquareFromProjection - 生成一个以 PCT 为中心的新正方形
%
% 输入：
%   PF          - 4×3 矩阵，原始正方形的四个顶点，每行为一个点 [x, y, z]
%   P           - 1×3 向量，需要投影的点
%   sideLength  - 标量，生成的正方形的边长
%
% 输出：
%   newSquareVertices - 4×3 矩阵，生成的新正方形顶点，每行为一个点 [x, y, z]

% 计算投影点 PCT
PCT = findProjectionPoint(PF(1,:), PF(2,:), PF(3,:), PF(4,:), P);

% 计算原正方形的两个方向向量
dir1 = PF(2,:) - PF(1,:);
dir2 = PF(3,:) - PF(2,:);

% 确保方向向量正交
if abs(dot(dir1, dir2)) > 1e-6
    error('原正方形的方向向量不正交，请检查顶点坐标。');
end

% 正交化并单位化方向向量
dir1 = dir1 / norm(dir1);
dir2 = dir2 - (dot(dir2, dir1) / norm(dir1)^2) * dir1;
dir2 = dir2 / norm(dir2);

% 计算新正方形的顶点
halfLength = sideLength / 2;
vertex1 = PCT - halfLength * dir1;
vertex2 = PCT + halfLength * dir1;
vertex3 = PCT + halfLength * dir1 + sideLength * dir2;
vertex4 = PCT - halfLength * dir1 + sideLength * dir2;

% 返回新正方形的顶点
newSquareVertices = [vertex1; vertex2; vertex3; vertex4];

n_plane = cross(dir1, dir2);
n_plane = n_plane / norm(n_plane);  % 归一化
half_thickness = 1;  % 上下平移的距离
topFace =newSquareVertices + repmat(half_thickness * n_plane, size(newSquareVertices,1), 1);
bottomFace =newSquareVertices ;


d=[bottomFace;topFace];

end


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
