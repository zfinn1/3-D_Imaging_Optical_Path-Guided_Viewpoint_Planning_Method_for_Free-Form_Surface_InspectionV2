% function Allpts_new=spanviewfield(tol,deltaTheta,numSamples,h_near,h_far,rotationCenter,axis_vec,Allpts,model)
% P1=Allpts(1,:);P2=Allpts(2,:);P3=Allpts(3,:);P4=Allpts(4,:);
% F1=Allpts(5,:);F2=Allpts(6,:);F3=Allpts(7,:);F4=Allpts(8,:);
% % tol = 0.08;           % 距离容差
% max_angle = 360;      % 最大允许旋转角度（度）
% % deltaTheta = 1;       % 每步旋转角度（度）
% currentTheta = 0;     % 累计旋转角度
% 
% 
% 
% % 预先绘制上一帧（可选）
% fill3([P1(1) P2(1) P3(1) P4(1)], [P1(2) P2(2) P3(2) P4(2)], [P1(3) P2(3) P3(3) P4(3)], 'y', 'FaceAlpha', 0.5);
% fill3([F1(1) F2(1) F3(1) F4(1)], [F1(2) F2(2) F3(2) F4(2)], [F1(3) F2(3) F3(3) F4(3)], 'y', 'FaceAlpha', 0.5);
% 
% % 5. 旋转迭代检测
% while currentTheta < max_angle
%     % 计算当前旋转角度（弧度）及旋转矩阵（Rodrigues公式）
%     theta_rad = deg2rad(currentTheta);
%     K = [  0         -axis_vec(3)   axis_vec(2);
%            axis_vec(3)  0         -axis_vec(1);
%           -axis_vec(2) axis_vec(1)   0         ];
%     R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
%     
%     % 对整个长方体所有顶点应用旋转（近面、远面、视点）
%     P1_new = rotationCenter + (R*(P1' - rotationCenter'))';
%     P2_new = rotationCenter + (R*(P2' - rotationCenter'))';
%     P3_new = rotationCenter + (R*(P3' - rotationCenter'))';  % 理论上接近固定
%     P4_new = rotationCenter + (R*(P4' - rotationCenter'))';
%     F1_new = rotationCenter + (R*(F1' - rotationCenter'))';
%     F2_new = rotationCenter + (R*(F2' - rotationCenter'))';
%     F3_new = rotationCenter + (R*(F3' - rotationCenter'))';
%     F4_new = rotationCenter + (R*(F4' - rotationCenter'))';
% %     P_new  = rotationCenter + (R*(P' - rotationCenter'))';
%     Allpts_new=[P1_new;P2_new;P3_new;P4_new;F1_new;F2_new;F3_new;F4_new];
%     % 利用旋转后的近面三个点计算上平面（这里仍使用近面作为检测参考）
%     [n_plane, d_plane] = computePlane(P1_new, P2_new, P3_new);  % n_plane为归一化法向量
%     if currentTheta >= 180
%         n_plane = -n_plane;
%     end
%     
%     % 构造上平面局部坐标系：以近面中心为原点
%     P_center = (P1_new + P2_new + P3_new + P4_new) / 4;
%     u = P2_new - P1_new;
%     u = u - dot(u, n_plane)*n_plane;
%     u = u / norm(u);
%     v = cross(n_plane, u);
%     
%     % 以近面为正方形，其边长 L 由 P2_new 与 P1_new 估计
%     L = norm(P2_new - P1_new);
%     
%     % 在上平面区域内均匀采样，检测采样点与模型表面的距离
%     alphas = linspace(-L/2, L/2, numSamples);
%     betas  = linspace(-L/2, L/2, numSamples);
%     isTangent = false;
%     
%     for a = alphas
%         for b = betas
%             X = P_center + a*u + b*v;
%             dist = min(pdist2(X, model.Points));
%             if dist < tol
%                 n_model = getModelNormalAt(X, model);
%                 if abs(dot(n_plane, n_model)) > 0.99
%                     isTangent = true;
%                     break;
%                 end
%             end
%         end
%         if isTangent
%             break;
%         end
%     end
%     
%     if isTangent
%         fprintf('检测到上平面区域与模型相切，旋转角度 = %f 度\n', currentTheta);
%         break;
%     end
%     
%     % 更新图形：更新近面和远面 patch 对象的顶点
%     newVerticesNear = [P1_new; P2_new; P3_new; P4_new];
%     newVerticesFar  = [F1_new; F2_new; F3_new; F4_new];
%     set(h_near, 'Vertices', newVerticesNear);
%     set(h_far,  'Vertices', newVerticesFar);
%     
%     drawnow;
%     pause(0.05);
%     
%     currentTheta = currentTheta + deltaTheta;
%  end
% end
% function [n, d] = computePlane(P1, P2, P3)
%     % 根据三个点 P1, P2, P3 计算平面法向量 n（归一化）及常数 d
%     v1 = P2 - P1;
%     v2 = P3 - P1;
%     n = cross(v1, v2);
%     n = n / norm(n);
%     d = -dot(n, P1);
% end
% function n = getModelNormalAt(X, model)
%     % 根据模型面片计算，返回与点 X 最近的面片的法向量
%     faces = model.ConnectivityList;
%     vertices = model.Points;
%     numFaces = size(faces,1);
%     centroids = zeros(numFaces,3);
%     normals = zeros(numFaces,3);
%     for i = 1:numFaces
%         v1 = vertices(faces(i,1),:);
%         v2 = vertices(faces(i,2),:);
%         v3 = vertices(faces(i,3),:);
%         centroids(i,:) = (v1+v2+v3)/3;
%         n_i = cross(v2-v1, v3-v1);
%         if norm(n_i) > 0
%             normals(i,:) = n_i / norm(n_i);
%         else
%             normals(i,:) = [0,0,0];
%         end
%     end
%     dists = sqrt(sum((centroids - X).^2,2));
%     [~, idx] = min(dists);
%     n = normals(idx,:)';
% end

% function [Allpts_new, currentTheta] = spanviewfield(tol, deltaTheta, numSamples, h_near, h_far, rotationCenter, axis_vec, Allpts, model, faceFlag)
% % spanviewfield - 旋转视场区域直到选定面（上表面或下表面）与模型表面相切
% %
% % 输入参数：
% %   tol           - 距离容差
% %   deltaTheta    - 每步旋转角度（度）
% %   numSamples    - 在选定面内采样数量（每个方向）
% %   h_near, h_far - 近面和远面的 patch 对象句柄
% %   rotationCenter- 旋转中心
% %   axis_vec      - 旋转轴（单位向量）
% %   Allpts        - 初始视场区域所有顶点，前4行为近面（下表面），后4行为远面（上表面）
% %   model         - STL 模型数据结构
% %   faceFlag      - 判断标志，若为1则以远面（上表面）为条件，若为0则以近面与远面正中心的面为条件
% %
% % 输出参数：
% %   Allpts_new    - 旋转后的所有顶点（8×3矩阵）
% 
% % 提取初始正方形（近面和远面）顶点
% P1 = Allpts(1,:); P2 = Allpts(2,:); P3 = Allpts(3,:); P4 = Allpts(4,:);
% F1 = Allpts(5,:); F2 = Allpts(6,:); F3 = Allpts(7,:); F4 = Allpts(8,:);
% 
% max_angle = 360;      % 最大旋转角度（度）
% currentTheta = 0;     % 累计旋转角度
% 
% % 将所有顶点组合为矩阵，前4行为近面，后4行为远面
% allPts = [P1; P2; P3; P4; F1; F2; F3; F4];
% 
% delayTime = 0.05;  % 每帧延时（秒）
% 
% while currentTheta < max_angle
%     theta_rad = deg2rad(currentTheta);
%     K = [ 0, -axis_vec(3), axis_vec(2);
%           axis_vec(3), 0, -axis_vec(1);
%          -axis_vec(2), axis_vec(1), 0];
%     R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
%     
%     % 一次性旋转所有顶点
%     allPts_new = rotationCenter + (R * (allPts' - rotationCenter'))';
%     
%     % 分离近面和远面
%     P_new = allPts_new(1:4, :);
%     F_new = allPts_new(5:8, :);
%     
%     % 根据 faceFlag 选择条件面：
%     if faceFlag == 1
%         % 以远面为条件（保持原来的处理方式）
%         [n_plane, ~] = computePlane(F_new(1,:), F_new(2,:), F_new(3,:));
%         faceCenter = mean(F_new,1);
%         % 构造局部坐标系，采用远面两个顶点确定方向
%         u = F_new(2,:) - F_new(1,:);
%         u = u - dot(u, n_plane)*n_plane;
%         u = u / norm(u);
%         v = cross(n_plane, u);
%         L = norm(F_new(2,:) - F_new(1,:));
%     else
%         % 以近面与远面之间正中心的面为条件
%         % 先计算中心面顶点（每个对应顶点取近面和远面的平均）
%         centerPts = (P_new + F_new) / 2;
%         faceCenter = mean(centerPts, 1);
%         % 计算近面法向量和远面法向量，并取平均作为中心面的法向量
%         [n_near, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
%         [n_far, ~]  = computePlane(F_new(1,:), F_new(2,:), F_new(3,:));
%         n_plane = (n_near + n_far) / 2;
%         n_plane = n_plane / norm(n_plane);
%         % 构造局部坐标系：以中心面上任意一条边确定方向（此处取 centerPts 的前两点）
%         u = centerPts(2,:) - centerPts(1,:);
%         u = u - dot(u, n_plane)*n_plane;
%         u = u / norm(u);
%         v = cross(n_plane, u);
%         L = norm(centerPts(2,:) - centerPts(1,:));
%     end
%     
%     if currentTheta >= 180
%         n_plane = -n_plane;
%     end
%     
%     % 在选定面区域内均匀采样，检测采样点与模型表面的距离
%     alphas = linspace(-L/2, L/2, numSamples);
%     betas  = linspace(-L/2, L/2, numSamples);
%     isTangent = false;
%     for a = alphas
%         for b = betas
%             X = faceCenter + a*u + b*v;
%             if min(pdist2(X, model.Points)) < tol
%                 if abs(dot(n_plane, getModelNormalAt(X, model))) > 0.99
%                     if currentTheta > 60
%                         isTangent = true;
%                         break;
%                     end
%                 end
%             end
%         end
%         if isTangent, break; end
%     end
%     
%     if isTangent
%         fprintf('检测到条件面（faceFlag=%d）与模型相切，旋转角度 = %f 度\n', faceFlag, currentTheta);
%         break;
%     end
%     
%     % 更新图形显示（更新 h_near 和 h_far 的 Vertices）
%     if ~isempty(h_near)
%         set(h_near, 'Vertices', P_new);
%     end
%     if ~isempty(h_far)
%         set(h_far, 'Vertices', F_new);
%     end
%     
%     drawnow;
%     pause(delayTime);
%     currentTheta = currentTheta + deltaTheta;
% end
% 
% Allpts_new = [P_new; F_new];
% 
% end
% 
% function [n, d] = computePlane(P1, P2, P3)
%     % 根据三个点 P1, P2, P3 计算平面法向量 n（归一化）及常数 d
%     v1 = P2 - P1;
%     v2 = P3 - P1;
%     n = cross(v1, v2);
%     n = n / norm(n);
%     d = -dot(n, P1);
% end
% 
% function n = getModelNormalAt(X, model)
%     % 根据模型面片计算，返回与点 X 最近的面片的法向量
%     faces = model.ConnectivityList;
%     vertices = model.Points;
%     numFaces = size(faces,1);
%     centroids = zeros(numFaces,3);
%     normals = zeros(numFaces,3);
%     for i = 1:numFaces
%         v1 = vertices(faces(i,1),:);
%         v2 = vertices(faces(i,2),:);
%         v3 = vertices(faces(i,3),:);
%         centroids(i,:) = (v1 + v2 + v3) / 3;
%         n_i = cross(v2 - v1, v3 - v1);
%         if norm(n_i) > 0
%             normals(i,:) = n_i / norm(n_i);
%         else
%             normals(i,:) = [0, 0, 0];
%         end
%     end
%     dists = sqrt(sum((centroids - X).^2,2));
%     [~, idx] = min(dists);
%     n = normals(idx,:)';
% end




function [Allpts_new, P_new,F_new] = spanviewfield(tol, deltaTheta, numSamples, h_near, h_far, rotationCenter, axis_vec, Allpts, model, faceFlag)
% spanviewfield - 旋转视场区域直到选定面（上表面或下表面）与模型表面相切，
% 并保证近面与远面分布在模型表面的两侧（一个内部，一个外部）
%
% 输入参数：
%   tol           - 距离容差
%   deltaTheta    - 每步旋转角度（度）
%   numSamples    - 在选定面内采样数量（每个方向）
%   h_near, h_far - 近面和远面的 patch 对象句柄
%   rotationCenter- 旋转中心
%   axis_vec      - 旋转轴（单位向量）
%   Allpts        - 初始视场区域所有顶点，前4行为近面（下表面），后4行为远面（上表面）
%   model         - STL 模型数据结构
%   faceFlag      - 判断标志，若为1则以远面（上表面）为条件，
%                   若为0则以近面与远面之间正中心的面为条件
%
% 输出参数：
%   Allpts_new    - 旋转后的所有顶点（8×3矩阵）

% 提取初始正方形（近面和远面）顶点
P1 = Allpts(1,:); P2 = Allpts(2,:); P3 = Allpts(3,:); P4 = Allpts(4,:);
F1 = Allpts(5,:); F2 = Allpts(6,:); F3 = Allpts(7,:); F4 = Allpts(8,:);

max_angle = 360;      % 最大旋转角度（度）
currentTheta = 0;     % 累计旋转角度

% 将所有顶点组合为矩阵，前4行为近面，后4行为远面
allPts = [P1; P2; P3; P4; F1; F2; F3; F4];

delayTime = 0.05;  % 每帧延时（秒）

while currentTheta < max_angle
    theta_rad = deg2rad(currentTheta);
    K = [ 0, -axis_vec(3), axis_vec(2);
          axis_vec(3), 0, -axis_vec(1);
         -axis_vec(2), axis_vec(1), 0];
    R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
    
    % 旋转所有顶点
    allPts_new = rotationCenter + (R * (allPts' - rotationCenter'))';
    
    % 分离近面和远面
    P_new = allPts_new(1:4, :);
    F_new = allPts_new(5:8, :);
    
    % 根据 faceFlag 选择条件面
    if faceFlag == 1
        % 以远面为条件（原有方式）
        [n_plane, ~] = computePlane(F_new(1,:), F_new(2,:), F_new(3,:));
        faceCenter = mean(F_new,1);
    elseif faceFlag == 2
        % 以远面为条件（原有方式）
        [n_plane, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
        faceCenter = mean(P_new,1);
    else
        % 以近面与远面之间正中心的面为条件
        centerPts = (P_new + F_new) / 2;
        faceCenter = mean(centerPts, 1);
        % 分别计算近面和远面的法向量，取平均后归一化
        [n_near, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
        [n_far, ~]  = computePlane(F_new(1,:), F_new(2,:), F_new(3,:));
        n_plane = (n_near + n_far) / 2;
        n_plane = n_plane / norm(n_plane);
    end
    
    % 当旋转角度大于180度时，翻转条件面法向量
    if currentTheta >= 180
        n_plane = -n_plane;
    end
    
    % 构造局部坐标系：以条件面中心 faceCenter 为原点
    if faceFlag == 1
        u = F_new(2,:) - F_new(1,:);
    elseif     faceFlag == 2
        u =  P_new(2,:) - P_new(1,:);  
    else
        u = centerPts(2,:) - centerPts(1,:);
    end
    u = u - dot(u, n_plane)*n_plane;
    u = u / norm(u);
    v = cross(n_plane, u);
    
    % 估计选定面正方形边长 L
    if faceFlag == 1
        L = norm(F_new(2,:) - F_new(1,:));
    elseif     faceFlag == 2
        L = norm(P_new(2,:) - P_new(1,:));
    else
        L = norm(centerPts(2,:) - centerPts(1,:));
    end
    
    % 向量化生成所有采样点 X_all (numSamples^2 x 3)
    alphas = linspace(-L/2, L/2, numSamples);
    betas  = linspace(-L/2, L/2, numSamples);
    [Agrid, Bgrid] = meshgrid(alphas, betas);
    Agrid = Agrid(:);
    Bgrid = Bgrid(:);
    X_all = faceCenter + Agrid * u + Bgrid * v;
    
    % 向量化计算每个采样点与模型所有点的最小距离
    dists = min(pdist2(X_all, model.Points), [], 2);
    
    % 找出距离小于 tol 的候选点
    idxCandidates = find(dists < tol);
    isTangent = false;
    if ~isempty(idxCandidates)
        % 对候选点逐一检查法向匹配
        for i = 1:length(idxCandidates)
            X = X_all(idxCandidates(i), :);
           if abs(dot(n_plane, getModelNormalAt(X, model))) > 0.99 && currentTheta > 5
                isTangent = true;
                break;
            end
        end
    end
    
    %检查近面与远面是否分布在条件面两侧（保证一个在内部，一个在外部）
    if isTangent
        nearCenter = mean(P_new,1);
        farCenter  = mean(F_new,1);
        modelNormal = getModelNormalAt(faceCenter, model);
        % 如果近面与远面都在模型法向同一侧，则不满足要求
        if dot(modelNormal, farCenter - faceCenter) * dot(modelNormal, nearCenter - faceCenter) > 0
            % 不满足内部/外部条件，继续旋转
            isTangent = false;
        end
    end
    
    if isTangent
        fprintf('检测到条件面（faceFlag=%d）与模型相切，旋转角度 = %f 度\n', faceFlag, currentTheta);
        break;
    end
    
    % 更新图形显示（更新 h_near 和 h_far 的 Vertices，如有句柄）
    if ~isempty(h_near)
        set(h_near, 'Vertices', P_new);
    end
    if ~isempty(h_far)
        set(h_far, 'Vertices', F_new);
    end
    
    drawnow;
    pause(delayTime);
    currentTheta = currentTheta + deltaTheta;
end


if  currentTheta> 90
    C=F_new;
    F_new=P_new;
    P_new=C;
end

Allpts_new = [P_new; F_new];

end

function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点 P1, P2, P3 计算平面法向量 n（归一化）及常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end

function n = getModelNormalAt(X, model)
    % 根据模型面片计算，返回与点 X 最近的面片的法向量
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    centroids = zeros(numFaces,3);
    normals = zeros(numFaces,3);
    for i = 1:numFaces
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        centroids(i,:) = (v1 + v2 + v3) / 3;
        n_i = cross(v2 - v1, v3 - v1);
        if norm(n_i) > 0
            normals(i,:) = n_i / norm(n_i);
        else
            normals(i,:) = [0, 0, 0];
        end
    end
    dists = sqrt(sum((centroids - X).^2,2));
    [~, idx] = min(dists);
    n = normals(idx,:)';
end



% 
% 
% 
% 
% 
% 
% 
% 
% 
% function Allpts_new = spanviewfield(tol, deltaTheta, numSamples, h_near, h_far, rotationCenter, axis_vec, Allpts, model, faceFlag)
% % spanviewfield - 旋转视场区域直到选定面（上表面或下表面）与模型表面相切
% %
% % 输入参数：
% %   tol           - 距离容差
% %   deltaTheta    - 每步旋转角度（度）
% %   numSamples    - 在选定面内采样数量（每个方向）
% %   h_near, h_far - 近面和远面的 patch 对象句柄
% %   rotationCenter- 旋转中心
% %   axis_vec      - 旋转轴（单位向量）
% %   Allpts        - 初始视场区域所有顶点，前4行为近面（下表面），后4行为远面（上表面）
% %   model         - STL 模型数据结构
% %   faceFlag      - 判断标志，若为1则以远面（上表面）为条件，若为0则以近面（下表面）为条件
% %
% % 输出参数：
% %   Allpts_new    - 旋转后的所有顶点（8×3矩阵）
% 
% P1 = Allpts(1,:); P2 = Allpts(2,:); P3 = Allpts(3,:); P4 = Allpts(4,:);
% F1 = Allpts(5,:); F2 = Allpts(6,:); F3 = Allpts(7,:); F4 = Allpts(8,:);
% 
% max_angle = 360;      % 最大旋转角度（度）
% currentTheta = 0;     % 累计旋转角度
% 
% % 可选预先绘制上一帧
% 
% 
% % 将所有顶点组合为矩阵，前4行为近面，后4行为远面
% allPts = [P1; P2; P3; P4; F1; F2; F3; F4];
% 
% while currentTheta < max_angle
%     theta_rad = deg2rad(currentTheta);
%     K = [ 0, -axis_vec(3), axis_vec(2);
%           axis_vec(3), 0, -axis_vec(1);
%          -axis_vec(2), axis_vec(1), 0];
%     R = eye(3) + sin(theta_rad)*K + (1-cos(theta_rad))*(K*K);
%     
%     % 一次性旋转所有顶点
%     allPts_new = rotationCenter + (R * (allPts' - rotationCenter'))';
%     % 分离近面和远面
%     P_new = allPts_new(1:4, :);
%     F_new = allPts_new(5:8, :);
%     
%     % 根据标志选择条件面
%     if faceFlag == 1
%         % 使用远面（上表面）作为条件判断
%         [n_plane, ~] = computePlane(F_new(1,:), F_new(2,:), F_new(3,:));
%         faceCenter = mean(F_new,1);
%     else
%         % 使用近面（下表面）作为条件判断
%         [n_plane, ~] = computePlane(P_new(1,:), P_new(2,:), P_new(3,:));
%         faceCenter = mean(P_new,1);
%     end
%     % 若旋转角超过180度，可根据需要反转法向量
%     if currentTheta >= 180
%         n_plane = -n_plane;
%     end
%     
%     % 构造局部坐标系：以选定面中心为原点，u取该面一边方向，v为叉积得到
%     u = P_new(2,:) - P_new(1,:);
%     u = u - dot(u, n_plane)*n_plane; u = u/norm(u);
%     v = cross(n_plane, u);
%     
%     % 以选定面为正方形，其边长 L 由 P_new 的一边估计
%     L = norm(P_new(2,:) - P_new(1,:));
%     
%     % 在选定面区域内均匀采样，检测采样点与模型表面的距离
%     alphas = linspace(-L/2, L/2, numSamples);
%     betas  = linspace(-L/2, L/2, numSamples);
%     isTangent = false;
%     for a = alphas
%         for b = betas
%             X = faceCenter + a*u + b*v;
%             if min(pdist2(X, model.Points)) < tol
%                 if abs(dot(n_plane, getModelNormalAt(X, model))) > 0.99
%                     isTangent = true;
%                     break;
%                 end
%             end
%         end
%         if isTangent, break; end
%     end
%     
%     if isTangent
%         fprintf('检测到条件面（faceFlag=%d）与模型相切，旋转角度 = %f 度\n', faceFlag, currentTheta);
%         break;
%     end
%     
%     % 更新图形（假设 h_near 和 h_far 用于显示近面和远面）
%     set(h_near, 'Vertices', P_new);
%     set(h_far,  'Vertices', F_new);
%     
%     drawnow;
%     pause(0.05);
%     currentTheta = currentTheta + deltaTheta;
% end
% 
% Allpts_new = [P_new; F_new];
% 
% end
% 
% %% 辅助函数
% function [n, d] = computePlane(P1, P2, P3)
%     v1 = P2 - P1; v2 = P3 - P1;
%     n = cross(v1, v2); n = n/norm(n);
%     d = -dot(n, P1);
% end
% 
% function n = getModelNormalAt(X, model)
%     faces = model.ConnectivityList; vertices = model.Points;
%     numFaces = size(faces,1);
%     centroids = zeros(numFaces,3); normals = zeros(numFaces,3);
%     for i = 1:numFaces
%         v1 = vertices(faces(i,1),:);
%         v2 = vertices(faces(i,2),:);
%         v3 = vertices(faces(i,3),:);
%         centroids(i,:) = (v1+v2+v3)/3;
%         n_i = cross(v2-v1, v3-v1);
%         if norm(n_i) > 0
%             normals(i,:) = n_i / norm(n_i);
%         else
%             normals(i,:) = [0,0,0];
%         end
%     end
%     dists = sqrt(sum((centroids - X).^2,2));
%     [~, idx] = min(dists);
%     n = normals(idx,:)';
% end
% 
% 
% 
% 





