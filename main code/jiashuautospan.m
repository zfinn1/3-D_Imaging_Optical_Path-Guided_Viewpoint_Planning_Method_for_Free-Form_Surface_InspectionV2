epsilon = 0.3;                   % 接触误差容忍阈值
numSamples = 15;                 % 采样密度（建议 10~25）
step_size = 2;                   % 每次旋转的角度步长（度）
max_rotation =360;             % 最大旋转角度
threshold = 0.5;                 % 内部点比例阈值
direction = 2;                   % 旋转方向（1:上下, 2:左右, 3:斜对角）
AllPts=allSavedViews{2,1}{4,1};
   AllPts=[11.4338,37.3241,66.3050;
   13.6254,47.0807,66.3776;
    4.5433,49.1479,62.7386;
    2.3517,39.3913,62.6660;
   11.0773,37.3973,67.2364;
   13.2689,47.1539,67.3090;
    4.1868,49.2211,63.6700;
    1.9952,39.4644,63.5974];

P=AllPts(1:4,:);
F=AllPts(5:8,:);
% tic
% [AllPts_new, P_final, F_final] = autoRotateViewfield2(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation, threshold, 0.1,direction);
% toc
% disp(['更新版运行时间: ',num2str(toc)]);
tic
[AllPts_new, P_final, F_final] = autoRotateViewfield(AllPts, stl_file, epsilon, numSamples, step_size, max_rotation, threshold, 0.1,direction);
toc
disp(['原版运行时间: ',num2str(toc)]);
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
visualizeViewField(P_final, F_final);
visualizeViewField(P, F);




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










