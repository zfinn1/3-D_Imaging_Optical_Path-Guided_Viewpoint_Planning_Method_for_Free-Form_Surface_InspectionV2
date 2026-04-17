function [AllPts_new,P_new,F_new]=adjustpos2(AllPts,stl_file, numSamples, step_size, max_rotation)




P = AllPts(1:4, :);  % 近面
F = AllPts(5:8, :);  % 远面

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

[AllPts_new, P_new, F_new] = autoRotateViewfield(AllPts, stl_file, numSamples, step_size, max_rotation,rotationCenter,1,wide_vec);
[AllPts_new, P_new, F_new] = autoRotateViewfield(AllPts_new, stl_file, numSamples, step_size, max_rotation,rotationCenter,1,long_vec);
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



function [AllPts_new, P_final, F_final] = autoRotateViewfield(AllPts, stl_file,  numSamples, step_size, max_rotation, rotationCenter,rotation_direction,axis_vec)
    theta_deg = 0;
    % 用于记录最佳旋转角度及对应的视场
    best_theta = NaN;
    best_ratioInsideF = -inf;  % 记录最佳时刻远面内部采样点数
    best_view = AllPts;         % 存储最佳时刻的视场
    found_valid = false;        % 标志是否已有满足条件的候选

    model = stlread(stl_file);
    faces = model.ConnectivityList;
    vertices = model.Points;
    
    while theta_deg <= max_rotation
        [AllPts_rot,P_new, F_new] = applyRotation(AllPts, theta_deg,rotationCenter,rotation_direction* axis_vec);
%         kdtree = buildKDTreeForTriangles(faces, vertices);
        
        % 先检测当前视场是否满足 isValidTangent（此处仍要求基本相切条件）
        
            % 对近面进行采样，保证 ratioInsideP = 0
            ptsP = sampleFace(P_new, numSamples);
            insideP = in_polyhedron(faces, vertices, ptsP);
            count_insideP = sum(insideP);
            if count_insideP < 20
                % 近面基本没有采样点进入模型内部，继续检测远面
                ptsF = sampleFace(F_new, numSamples);
                insideF = in_polyhedron(faces, vertices, ptsF);
                count_insideF = sum(insideF);  % 远面内部采样点数，越大表示相切得越好
                fprintf('角度 %d 度: 远面内部采样点数 = %d, 近面采样点数 = %d\n', theta_deg, count_insideF, count_insideP);
                
                % 如果是首次满足条件，或比之前更优，则更新最佳记录
                if ~found_valid || (count_insideF > best_ratioInsideF)
                    best_theta = theta_deg;
                    best_ratioInsideF = count_insideF;
                    best_view = AllPts_rot;
                    found_valid = true;
                end
            else
                % 若近面有采样点进入模型，则不考虑当前候选
%                 fprintf('角度 %.2f 度: 近面内部采样点数 = %d，不符合要求（应为0），跳过此候选。\n', theta_deg, count_insideP);
            end
       
        
        theta_deg = theta_deg + step_size;
    end
    
    if ~found_valid
        fprintf('未找到满足相切且近面无穿透的旋转角度。\n');
    else
        fprintf('选定最佳旋转角度为 %d 度, 远面采样点数 = %d\n', best_theta, best_ratioInsideF);
    end
    
    % 最终选取最佳视场
    AllPts_new = best_view;
    P_final = best_view(1:4, :);
    F_final = best_view(5:8, :);
    
    if (best_theta > 90 && best_theta < 345)
        
           P_final(1,:) = AllPts_new(8,:);
            P_final(2,:) = AllPts_new(7,:);
            P_final(3,:) = AllPts_new(6,:);
            P_final(4,:) = AllPts_new(5,:);
            F_final(1,:) = AllPts_new(4,:);
            F_final(2,:) = AllPts_new(3,:);
            F_final(3,:) = AllPts_new(2,:);
            F_final(4,:) = AllPts_new(1,:);
        
       
    end
    AllPts_new = [P_final; F_final];
    
end

%%采样某个面内的点（面由 4 个顶点组成） 采样函数为下一步限制相切做铺垫
function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
end


