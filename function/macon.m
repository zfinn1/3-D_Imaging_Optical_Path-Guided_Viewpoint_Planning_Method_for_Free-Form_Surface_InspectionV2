clear; clc; 
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stl_file);
faces1 = model.ConnectivityList;
vertices1 = model.Points;

% 定义视场的八个顶点
% AllPts = [0,0,0; 2,0,0; 2,2,0; 0,2,0;  % 近面
%           0,0,2; 2,0,2; 2,2,2; 0,2,2]; % 远面
% 
% AllPts=[12.6478141683673,63.3844003020391,38.6059609175554;
% 7.05116952310188,55.0981302602006,38.4822778210925;
% 8.29477211211601,54.1108174124102,48.3554062989958;
% 13.8914167573814,62.3970874542488,48.4790893954587;
% 11.8284789420086,63.9354260921281,38.7642655779563;
% 6.23183429674322,55.6491560502895,38.6405824814934;
% 7.47543688575736,54.6618432024992,48.5137109593967;
% 13.0720815310228,62.9481132443378,48.6373940558596; ]  ;  
 AllPts=[10.3772954712801,57.6741176529429,45.8659290322353;5.61863530690132,48.8877116959134,46.2586424114727;7.24011850806017,48.4501339314249,56.1165994984347;11.9987786724389,57.2365398884543,55.7238861191973;9.51285376897556,58.1495921113347,46.0292219675810;4.75419360459680,49.3631861543053,46.4219353468185;6.37567680575564,48.9256083898167,56.2798924337805;11.1343369701344,57.7120143468462,55.8871790545431];
      
P = AllPts(1:4, :);  % 近面
F = AllPts(5:8, :);  % 远面
E=(P+F)/2;
% 初始可视化
figure;

% visualizeViewField(P, F);
% visualizeNormalVector(E, 'm');

% 旋转计算
theta_deg = 5;  % 旋转角度（度）
E3 = (P(3,:) + F(3,:)+P(2,:) + F(2,:)) / 4;
E4 = (P(1,:) + F(1,:)+P(4,:) + F(4,:)) / 4;
rotationCenter =mean(AllPts,1);
axis_vec = (E4 - E3) / norm(E4 - E3);

% 旋转所有顶点
AllPts_new = rotatePoints(AllPts, rotationCenter, -axis_vec, theta_deg);

% 分离近面和远面
P_new = AllPts_new(1:4, :);
F_new = AllPts_new(5:8, :);
if  (270>theta_deg)&&(theta_deg>90)
P_new(1,:) =AllPts_new(8,:); P_new(2,:) =AllPts_new(7,:);P_new(3,:) =AllPts_new(6,:);P_new(4,:) =AllPts_new(5,:);
F_new(1,:) =AllPts_new(4,:); F_new(2,:) =AllPts_new(3,:);F_new(3,:) =AllPts_new(2,:);F_new(4,:) =AllPts_new(1,:);
end

AllPts_new=[P_new;F_new];

E_new=(P_new+F_new)/2;
% 可视化旋转后的视场

% visualizeViewField(P_new, F_new);
% 
% visualizeNormalVector(E_new, 'm');

theta_deg1 =3.1;  % 旋转角度（度）
% E3_new= (P_new(3,:) + F_new(3,:)) / 2;
% E2_new = (P_new(2,:) +F_new(2,:)) / 2;
% rotationCenter_new= (E3_new + E2_new) / 2;
% axis_vec_new = (E3_new - E2_new) / norm(E3_new - E2_new);
E3_new= (P(3,:) + F(3,:)+P(4,:) + F(4,:)) / 4;
E2_new= (P(1,:) + F(1,:)+P(2,:) + F(2,:)) / 4;
rotationCenter_new= mean(AllPts,1);
axis_vec_new = (E3_new - E2_new) / norm(E3_new - E2_new);

 
AllPts_new_new = rotatePoints(AllPts_new, rotationCenter_new,axis_vec_new, theta_deg1);
P_new_new = AllPts_new_new(1:4, :);
F_new_new = AllPts_new_new(5:8, :);


% % 
if  (270>theta_deg1)&&(theta_deg1>90)
P_new_new(1,:) =AllPts_new_new(6,:); 
P_new_new(2,:) =AllPts_new_new(5,:); 
P_new_new(3,:) =AllPts_new_new(8,:); 
P_new_new(4,:) =AllPts_new_new(7,:); 
F_new_new(1,:) =AllPts_new_new(2,:); 
F_new_new(2,:) =AllPts_new_new(1,:); 
F_new_new(3,:) =AllPts_new_new(4,:); 
F_new_new(4,:) =AllPts_new_new(3,:); 
end
visualizeViewField(P_new_new, F_new_new);


E_new_new=(P_new_new+F_new_new)/2;
% 可视化旋转后的视场



    trisurf(faces1, vertices1(:,1), vertices1(:,2), vertices1(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
    hold on;
% visualizeNormalVector(E_new_new, 'm');
% 统一设置
title(sprintf('旋转的度数: %d°', theta_deg));
  
xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
grid on; axis equal; rotate3d on;


%% 旋转函数
function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    theta_rad = deg2rad(theta_deg); % 角度转换为弧度
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1 - cos(theta_rad))*(K*K);
    rotatedPts = (R * (pts - center)')' + center; 
end

%% 视场可视化函数
function visualizeViewField(nearPts, farPts)
    hold on;
    % 绘制近面和远面
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    % 连接近面和远面顶点
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], ...
              'k-', 'LineWidth', 1.5);
    end
    
    % 标注点
    for i = 1:4
        text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
        text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
    end
    
  
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end

function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector); % 归一化
    center = mean(pts, 1); % 计算中心点
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 1, color, 'LineWidth', 2, 'MaxHeadSize', 2);
end
