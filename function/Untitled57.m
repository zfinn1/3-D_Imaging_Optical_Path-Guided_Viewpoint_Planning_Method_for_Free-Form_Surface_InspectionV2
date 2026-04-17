%% 示例主程序


%  trisurf(faces1, vertices1(:,1), vertices1(:,2), vertices1(:,3), ...
%         'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
%     hold on;
% 原始未矫正前的视场域（8个顶点），其中前4行为 P 面，后4行为 F 面
% AllPts = [8.15904796733124,54.2142635063271,48.4080398326664;
%           13.1705201054759,62.8647247713970,48.6418493921909;
%           12.8288905230210,63.3324729255303,38.6586384411644;
%           7.81741838487636,54.6820116604604,38.4248288816399;
%           7.29436053110360,54.7137705790080,48.4610334357878;
%           12.3058326692483,63.3642318440779,48.6948429953123;
%           11.9642030867934,63.8319799982113,38.7116320442857;
%           6.95273094864872,55.1815187331414,38.4778224847612];
% AllPts=[7.10963634882995,55.2147503594304,38.4865754483875;
% 3.82428835445574,45.7846684342363,37.9573841408362;
% 5.06789094346988,44.7973555864459,47.8305126187395;
% 8.35323893784409,54.2274375116401,48.3597039262908;
% 6.17336747101515,55.5325359510597,38.6362848541985;
% 2.88801947664093,46.1024540258655,38.1070935466472;
% 4.13162206565508,45.1151411780752,47.9802220245505;
% 7.41697006002929,54.5452231032693,48.5094133321018];
figure;
AllPts=[8.15904796733124,54.2142635063271,48.4080398326664;
13.1705201054759,62.8647247713970,48.6418493921909;
12.8288905230210,63.3324729255303,38.6586384411644;
7.81741838487636,54.6820116604604,38.4248288816399;
7.29436053110360,54.7137705790080,48.4610334357878;
12.3058326692483,63.3642318440779,48.6948429953123;
11.9642030867934,63.8319799982113,38.7116320442857;
6.95273094864872,55.1815187331414,38.4778224847612];
P = AllPts(1:4, :);  % 近面
F = AllPts(5:8, :);  % 远面
normal_vector = cross(P(2,:) - P(1,:), P(3,:) - P(1,:));
normal_vector = normal_vector / norm(normal_vector);
center=mean(AllPts, 1);
 

refPoint = mean(AllPts, 1)+normal_vector*28;
E1= (P(1,:) + F(1,:)+P(2,:) + F(2,:)) / 4;%P1P2F1F2面中心
E2= (P(3,:) + F(3,:)+P(2,:) + F(2,:)) / 4;%P2P3F2F3面中心
E3= (P(3,:) + F(3,:)+P(4,:) + F(4,:)) / 4;%P3P4F3F4面中心
E4= (P(1,:) + F(1,:)+P(4,:) + F(4,:)) / 4;%P4P1F4F1面中心
rotationCenter= mean(AllPts,1);
some_reference_direction1=(E4- E2) / norm(E4 - E2);
some_reference_direction2=(E1- E3) / norm(E1 - E3);
% long_vec 和 wide_vec 分别为视场域长向量和宽向量
long_vec = (E1- E3) / norm(E1 - E3);
wide_vec =(E4- E2) / norm(E4 - E2);
[AllPts_rot,P_new, F_new] = applyRotation(AllPts, 195,mean(AllPts(:,:),1),long_vec);

[newNearPts, newFarPts] = classifyCuboidFaces(AllPts_rot, refPoint);
orderedNear =  orderNewFaceByReference(P, newNearPts);
orderedFar =  orderNewFaceByReference(F, newFarPts);
% orderedNear = newNearPts;
% orderedFar  = newFarPts;

 subplot(1,2,1)

 quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 3, 'b', 'LineWidth', 2, 'MaxHeadSize', 5);
hold on;
scatter3(refPoint(1), refPoint(2), refPoint(3), 120, 'r', 'filled');
 visualizeViewField(P, F);
%  trisurf(faces1, vertices1(:,1), vertices1(:,2), vertices1(:,3), ...
%         'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
 subplot(1,2,2)
 scatter3(refPoint(1), refPoint(2), refPoint(3), 120, 'r', 'filled');
 hold on
visualizeViewField(orderedNear, orderedFar);
    hold on;
    
function visualizeViewField(nearPts, farPts)
    % 对近面和远面的顶点分别排序
%     orderedNear = orderFaceVertices(nearPts);
%     orderedFar  = orderFaceVertices(farPts);
    orderedNear = nearPts;
    orderedFar  = farPts;
    hold on;
    % 绘制近面和远面
    patch('Faces', [1 2 3 4], 'Vertices', orderedNear, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', orderedFar, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    % 连接近面和远面对应顶点
    for i = 1:4
        plot3([orderedNear(i,1), orderedFar(i,1)], [orderedNear(i,2), orderedFar(i,2)], [orderedNear(i,3), orderedFar(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
    % 标注点：近面标记 P1~P4，远面标记 F1~F4
    for i = 1:4
        text(orderedNear(i,1), orderedNear(i,2), orderedNear(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
        text(orderedFar(i,1), orderedFar(i,2), orderedFar(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
    end

    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
    hold off;
end



function rotatedPts = rotatePoints(pts, center, axis_vec, theta_deg)
    theta_rad = deg2rad(theta_deg); % 角度转换为弧度
    K = [0, -axis_vec(3), axis_vec(2);
         axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1 - cos(theta_rad))*(K*K);
    rotatedPts = (R * (pts - center)')' + center; 
end

%%旋转函数
function [AllPts_new,P_new, F_new] = applyRotation(AllPts, theta_deg,rotationCenter,axis_vec)
 
    AllPts_new = rotatePoints(AllPts, rotationCenter, axis_vec, theta_deg);
    P_new = AllPts_new(1:4, :);
    F_new = AllPts_new(5:8, :);
    
end

function [nearPts, farPts] = classifyCuboidFaces(vertices, refPoint)
    % vertices: 8x3矩阵，长方体所有顶点
    % refPoint: 1x3向量，参考点（例如原始远面中心）
    %
    % 计算每个顶点与参考点的距离
    nearPts=vertices(1:4,:);
    farPts=vertices(5:8,:);
    dists1 = point2plane(nearPts, refPoint);
    dists2= point2plane(farPts, refPoint);
    if dists1<dists2
     nearPts=vertices(5:8,:);
     farPts=vertices(1:4,:);
    end
end

function dist = point2plane(planePts, point)
    % 输入:
    %   planePts - 4x3矩阵，每一行是平面上一个点的坐标（假设共面）
    %   point    - 1x3向量，待计算距离的点坐标
    %
    % 输出:
    %   dist     - 点到平面的距离

    % 取前三个点计算法向量
    p1 = planePts(1, :);
    p2 = planePts(2, :);
    p3 = planePts(3, :);
    
    % 计算平面上的两个向量
    v1 = p2 - p1;
    v2 = p3 - p1;
    
    % 计算法向量（叉积）
    normal = cross(v1, v2);
    
    % 确保法向量不为零向量
    if norm(normal) == 0
        error('输入的前三个点不能共线！');
    end
    
    % 计算点到平面的距离：|normal · (point-p1)| / ||normal||
    dist = abs(dot(normal, point - p1)) / norm(normal);
end

function newOrderedPts = orderNewFaceByReference(originalPts, newPts)
    % originalPts: 4x3矩阵，原长方形面顶点，已排好顺序（例如 P1, P2, P3, P4）
    % newPts:      4x3矩阵，当前长方形面顶点，顺序待确定
    % 输出:
    %   newOrderedPts: 4x3矩阵，新长方形面顶点顺序，
    %                  其中 newOrderedPts(i,:) 对应原面的 P{i}，即与 originalPts(i,:) 最接近的点

    numPts = size(originalPts, 1);
    newOrderedPts = zeros(size(newPts));
    
    % 为防止重复选取，将所有新面顶点的索引保存在 remainingIdx 中
    remainingIdx = 1:numPts;
    
    for i = 1:numPts
        origP = originalPts(i, :);
        % 计算当前所有未匹配的新面顶点与原参考点之间的欧氏距离
        distances = vecnorm(newPts(remainingIdx, :) - origP, 2, 2);
        % 找到距离最小的点
        [~, minIdx] = min(distances);
        selectedIdx = remainingIdx(minIdx);
        
        % 将选中的点赋给新的顺序
        newOrderedPts(i, :) = newPts(selectedIdx, :);
        % 从剩余索引中去掉已匹配的点
        remainingIdx(minIdx) = [];
    end
end


