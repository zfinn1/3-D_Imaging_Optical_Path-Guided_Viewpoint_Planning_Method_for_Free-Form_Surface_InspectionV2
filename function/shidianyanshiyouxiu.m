%  maybe=allSavedViews{2,1}{2,1};
%   maybe =[15.1460860254530,46.7665920600135,62.6899553235460;
% 12.9544925362598,37.0099713438603,62.6173593232665;
% 13.3688049784644,36.9912487690037,52.6259632914086;
% 15.5603984676576,46.7478694851569,52.6985592916882;
% 16.1208950486897,46.5473205008381,62.7307885398433;
% 13.9293015594965,36.7906997846849,62.6581925395638;
% 14.3436140017011,36.7719772098283,52.6667965077059;
% 16.5352074908943,46.5285979259815,52.7393925079855];
% 
maybe = [4.44598066697915,45.4757974915837,38.1088577136775;
3.03860076142785,35.5840430432138,37.6935557336617;
3.38023034388273,35.1162948890805,47.6767666846883;
4.78761024943404,45.0080493374504,48.0920686647040;
3.45652338629523,45.6148804020170,38.1492338666268;
2.04914348074392,35.7231259536471,37.7339318866110;
2.39077306319880,35.2553777995138,47.7171428376376;
3.79815296875011,45.1471322478836,48.1324448176533;];




% maybe=[12.6478141683673,63.3844003020391,38.6059609175554;
% 7.05116952310188,55.0981302602006,38.4822778210925;
% 8.29477211211601,54.1108174124102,48.3554062989958;
% 13.8914167573814,62.3970874542488,48.4790893954587;
% 11.8284789420086,63.9354260921281,38.7642655779563;
% 6.23183429674322,55.6491560502895,38.6405824814934;
% 7.47543688575736,54.6618432024992,48.5137109593967;
% 13.0720815310228,62.9481132443378,48.6373940558596; ]  ;  


%       
% maybe=[7.10963634882995,55.2147503594304,38.4865754483875;
% 3.82428835445574,45.7846684342363,37.9573841408362;
% 5.06789094346988,44.7973555864459,47.8305126187395;
% 8.35323893784409,54.2274375116401,48.3597039262908;
% 6.17336747101515,55.5325359510597,38.6362848541985;
% 2.88801947664093,46.1024540258655,38.1070935466472;
% 4.13162206565508,45.1151411780752,47.9802220245505;
% 7.41697006002929,54.5452231032693,48.5094133321018];
% 
% 
% 
% maybe(:,3)=maybe(:,3)+0.56;
%maybe=[36.4562159789945,75.2874032421145,62.7880058507002;33.3347698089348,65.8032963310229,62.2327672475712;25.2362692822308,68.1540445569548,67.6075483591378;28.3577154522905,77.6381514680464,68.1627869622667;35.9595182537491,75.5001401424695,61.9465580620861;32.8380720836894,66.0160332313779,61.3913194589572;24.7395715569854,68.3667814573098,66.7661005705237;27.8610177270451,77.8508883684013,67.3213391736527];
% maybe = flipud(maybe); % 对矩阵 maybe 进行行倒序
%maybe=[24.2921502077203,79.5325516655595,58.6601138518546;21.1707040376606,70.0484447544679,58.1048752487257;25.4129496135503,68.1340522398911,66.9557765459934;28.5343957836100,77.6181591509826,67.5110151491224;23.4420918198359,79.7852732000420,59.1222096895292;20.3206456497762,70.3011662889504,58.5669710864002;24.5628912256658,68.3867737743735,67.4178723836681;27.6843373957256,77.8708806854651,67.9731109867970];




 P_new=maybe(1:4,:);
 F_new=maybe(5:8,:);
 P1=maybe(1,:);
P2=maybe(2,:);
P3=maybe(3,:);
P4=maybe(4,:);
F1=maybe(5,:);
F2=maybe(6,:);
F3=maybe(7,:);
F4=maybe(8,:);
[n, d] = computePlane(P1, P2, P3);

% 计算中点
I1 = (P1 + F1) / 2;
I2 = (P2 + F2) / 2;
I3 = (P3 + F3) / 2;
I4 = (P4 + F4) / 2;



P = mean(maybe(:,:),1)+n*28;        % 3×1 或 1×3 向量，来自你的 viewfieldPyrCuboid 输出
n = n'; % 3×1 单位法向量


h_base  = 4;   % 大圆柱高度
r_base  = 1.5;   % 大圆柱底部半径
h_neck  = 2;   % 小圆柱高度
r_neck  = 0.5;   % 小圆柱半径
N       = 40;    % 分辨率

% 大圆柱
[XB0,YB0,ZB0] = cylinder([r_base r_base], N);
ZB0 = ZB0 * h_base;

% 小圆柱
[XN0,YN0,ZN0] = cylinder([r_neck r_neck], N);
ZN0 = ZN0 * h_neck;
 

v = [0;0;-1];
% 旋转轴为 v × n，角度为 arccos(v·n)
axis_rot = cross(v, n);
if norm(axis_rot)<1e-6
    R = eye(3);
else
    axis_rot = axis_rot / norm(axis_rot);
    theta = acos(dot(v,n));
    K = [      0, -axis_rot(3),  axis_rot(2);
         axis_rot(3),       0, -axis_rot(1);
        -axis_rot(2),  axis_rot(1),       0 ];
    R = eye(3) + sin(theta)*K + (1-cos(theta))*(K*K);
end


% 合并顶点
VB = [XB0(:), YB0(:), ZB0(:)];  % base cylinder verts
VN = [XN0(:), YN0(:), ZN0(:)+h_base]; % neck verts, 平移到大圆柱顶端

% 旋转
VB_rot = (R * VB')';
VN_rot = (R * VN')';

% % 平移到 P
% VB_rot = VB_rot + P(:)';
% VN_rot = VN_rot + P(:)';

optical_center_local = R * [0; 0; h_base];  % 小圆柱底部旋转后的真实位置

% 计算将 optical_center_local 移动到 P 所需的平移向量
T = P(:) - optical_center_local;

% 执行平移
VB_rot = VB_rot + T';
VN_rot = VN_rot + T';
% 重塑为 surface 所需格式
XB = reshape(VB_rot(:,1), size(XB0));
YB = reshape(VB_rot(:,2), size(YB0));
ZB = reshape(VB_rot(:,3), size(ZB0));
XN = reshape(VN_rot(:,1), size(XN0));
YN = reshape(VN_rot(:,2), size(YN0));
ZN = reshape(VN_rot(:,3), size(ZN0));


model = stlread('G:\\111.stl');
stl_file = 'G:\\111.stl';
Intersections = computeIntersectionsWithKD(P_new, model, 1e-2, kdtree, 8);
% figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
surf(XB,YB,ZB, 'FaceColor',[0.5 0.5 0.5],'EdgeColor','none','FaceAlpha',0.8);
plot3(P(1),P(2),P(3),'ro','MarkerSize',8,'LineWidth',2);
if ~isempty(Intersections)
visualizePoints(Intersections);
end
visualizeViewField(P_new,  F_new);
plot3([P(1), F1(1)], [P(2), F1(2)], [P(3), F1(3)], 'b-');
plot3([P(1), F2(1)], [P(2), F2(2)], [P(3), F2(3)], 'b-');
plot3([P(1), F3(1)], [P(2), F3(2)], [P(3), F3(3)], 'b-');
plot3([P(1), F4(1)], [P(2), F4(2)], [P(3), F4(3)], 'b-');
function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
        % 标注点
    for i = 1:4
        text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
        text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
    end
    
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end

function visualizePoints(points)
% visualizePoints 绘制三维点集
%   points: N×3 矩阵，每行表示一个点的 [x, y, z] 坐标
%     figure; hold on; axis equal;
    plot3(points(:,1), points(:,2), points(:,3), 'ro', 'MarkerFaceColor', 'r');
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('三维点集可视化'); grid on; view(3);
    hold off;
end

function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量 n（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end