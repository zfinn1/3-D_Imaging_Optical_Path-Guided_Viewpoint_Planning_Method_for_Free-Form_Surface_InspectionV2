tic
% 假设allSavedViews和targetIndex已定义
translation = calculate_translation(allSavedViews, 4);
% 
% 显示结果
fprintf('\n各圈需要平移的距离：\n');
for i = 1:length(translation)
    fprintf('第%d圈: %.4f\n', i, translation(i));
end

for circle=1:6

dirviews = allSavedViews{circle}{4,1};

direction = dirviews(4,:)-dirviews(3,:);  % 自定义方向
dir_unit(circle,:) = direction / norm(direction);

end
stepArray = translation; 
% 初始化保存结果
translatedViews = cell(size(allSavedViews{6}));
tos=cell(size(allSavedViews));
for j=2:6
    views=allSavedViews{j};
     step =stepArray(j);  
    for i = 1:length(views)
        if isempty(views{i}), continue; end
        
        if (2<i)&&(i<9)
         translatedViews{i} = views{i} + step * dir_unit(j,:);
         translatedViews{i}=adjustVdthroughN(translatedViews{i},faces,vertices);
        else
         translatedViews{i} = views{i};
         translatedViews{i}=adjustVdthroughN(translatedViews{i},faces,vertices);
        end
    end
    tos{j}=translatedViews;
    
end
toc
disp(['平滑部分运行时间: ',num2str(toc)]);

figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k');
hold on;
for circle = 2:6
    currentCircleViews = tos{circle};
    for t = 1:length(currentCircleViews)
        if ~isempty(currentCircleViews{t})
            viewField = currentCircleViews{t};
            P_final = viewField(1:4,:);
            F_final = viewField(5:8,:);
            visualizeViewField(P_final, F_final);
          visualizeNormalVector((P_final+F_final)/2, 'k');
        end
    end
end
for circle = 1:1
    currentCircleViews = allSavedViews{circle};
    for t = 1:length(currentCircleViews)
        if ~isempty(currentCircleViews{t})
            viewField = currentCircleViews{t};
            P_final = viewField(1:4,:);
            F_final = viewField(5:8,:);
            visualizeViewField(P_final, F_final);
          visualizeNormalVector((P_final+F_final)/2, 'k');
        end
    end
end
axis off;


function visualizeViewField(nearPts, farPts)
    hold on;
   
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
 
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end

    
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end

%%法向量可视化函数
function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector);
    center = mean(pts, 1);
    points=center+normal_vector *30;
%     scatter3(points(1), points(2), points(3), 48,'r','filled');
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 3, color, 'LineWidth', 2, 'MaxHeadSize', 5);
grid on; axis equal; view(3);
end

