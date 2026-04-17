function tos = smoothTranslateViews(allSavedViews, faces, vertices, targetIndex)
% 平移视场以平滑过渡
% 输入：
%   - allSavedViews：所有圈的视场数据
%   - faces, vertices：模型三角面和顶点数据
%   - targetIndex：用于计算方向的视点索引（如 4）
% 输出：
%   - tos：平移后的视场集合

    

    % 计算各圈的平移量
    translation = calculate_translation(allSavedViews, targetIndex);
    fprintf('\n各圈需要平移的距离：\n');
    for i = 1:length(translation)
        fprintf('第%d圈: %.4f\n', i, translation(i));
    end

    % 计算每圈的平移方向（以第4视点方向为准）
    for circle = 1:6
        dirviews = allSavedViews{circle}{targetIndex,1};
        direction = dirviews(4,:) - dirviews(3,:);
        dir_unit(circle,:) = direction / norm(direction);
    end

    % 平移
    stepArray = translation;
    translatedViews = cell(size(allSavedViews{6}));
    tos = cell(size(allSavedViews));
    for j = 1:6
        views = allSavedViews{j};
        step = stepArray(j);  
        for i = 1:length(views)
            if isempty(views{i}), continue; end

            if (2<i)&&(i<9)
                translatedViews{i} = views{i} + step * dir_unit(j,:);
                translatedViews{i} = adjustVdthroughN(translatedViews{i}, faces, vertices);
            else
                translatedViews{i} = views{i};
                translatedViews{i} = adjustVdthroughN(translatedViews{i}, faces, vertices);
            end
        end
        tos{j} = translatedViews;
    end


    


end

%% ================= 子函数 =================

function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    xlabel('X'); ylabel('Y'); zlabel('Z');
    grid on; axis equal; view(3);
end

function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector);
    center = mean(pts, 1);
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 3, color, 'LineWidth', 2, 'MaxHeadSize', 5);
end
