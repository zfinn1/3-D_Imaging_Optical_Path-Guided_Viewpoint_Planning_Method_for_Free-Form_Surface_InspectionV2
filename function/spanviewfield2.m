
function [Allpts_new, P_new,F_new] = spanviewfield2(tol, deltaTheta, numSamples, h_near, h_far, rotationCenter, axis_vec, Allpts, model, faceFlag)
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
           if abs(dot(n_plane, getModelNormalAt(X, model))) > 0.99 
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




