% 读取STL文件
fv = stlread('C:\Users\86132\Desktop\c\111.stl');
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
V = fv.Points;
F = fv.ConnectivityList;
% % === 读取 STL 模型 ===
% [F, V] = stlread('your_model.stl');  % 读取面和点

% === 构造三角剖分 ===
% 读取 STL
% [F,V] = stlread('your_model.stl');
TR = triangulation(F, V);
faceNormals = faceNormal(TR);

% === 区域一：叶根、叶尖（按Z坐标） ===
Zcentroid = mean(reshape(V(F',:), 3, [], 3), 1);  % 每个面顶点Z平均
Zcentroid = squeeze(Zcentroid(:,:,3));
zMin = min(Zcentroid);
zMax = max(Zcentroid);

leafTipThresh = zMax - 0.1*(zMax - zMin);
leafRootThresh = zMin + 0.1*(zMax - zMin);

isTip = Zcentroid > leafTipThresh;
isRoot = Zcentroid < leafRootThresh;

% === 区域二：前缘、后缘（用法向X方向） ===
Xn = faceNormals(:,1);  % 法向X分量

isLeadingEdge = Xn > 0.5;   % 正X方向为前缘（可按需要调整）
isTrailingEdge = Xn < -0.5; % 负X方向为后缘

% === 区域三：主表面（不属于其他区域的面） ===
isMainBody = ~(isTip | isRoot | isLeadingEdge | isTrailingEdge);

% === 给每类区域赋不同颜色 ===
colors = zeros(size(F,1), 3);  % RGB初始化
colors(isRoot,:)         = repmat([0.8 0.2 0.2], sum(isRoot), 1);      % 红色：叶根
colors(isTip,:)          = repmat([0.2 0.2 0.8], sum(isTip), 1);       % 蓝色：叶尖
colors(isLeadingEdge,:)  = repmat([0.2 0.8 0.2], sum(isLeadingEdge), 1); % 绿色：前缘
colors(isTrailingEdge,:) = repmat([0.9 0.7 0.1], sum(isTrailingEdge), 1); % 黄：后缘
% colors(isMainBody,:) = repmat([0.5 0.5 0.5], round(sum(isMainBody)), 1);
n = sum(isMainBody);
if n > 0
    colors(isMainBody,:) = repmat([0.5 0.5 0.5], n, 1);
end
unassignedFaces = all(colors == 0, 2);  % 查找颜色全为0的面
fprintf('未被分类的面数: %d\n', sum(unassignedFaces));
colors(unassignedFaces,:) = repmat([0.6 0.2 0.8], sum(unassignedFaces), 1);  % 紫色
% === 可视化 ===
figure;
patch('Faces',F,'Vertices',V,...
      'FaceVertexCData',colors,...
      'FaceColor','flat',...
      'EdgeColor','none');
axis equal;
camlight; lighting gouraud;
title('基于高度与法向方向的五区域划分');
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);
facesRoot         = find(isRoot);         % 叶根
facesTip          = find(isTip);          % 叶尖
facesLeadingEdge  = find(isLeadingEdge);  % 前缘
facesTrailingEdge = find(isTrailingEdge); % 后缘
facesMainBody     = find(isMainBody);     % 主体

% 可以打包为结构体
regions.faces.Root         = facesRoot;
regions.faces.Tip          = facesTip;
regions.faces.LeadingEdge  = facesLeadingEdge;
regions.faces.TrailingEdge = facesTrailingEdge;
regions.faces.MainBody     = facesMainBody;

