figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
for circle = 1:8
    currentCircleViews = allSavedViews{circle};
    
    for t = 1:length(currentCircleViews)
        if ~isempty(currentCircleViews{t}) 
            viewField = currentCircleViews{t};
           
%            viewField =allSavedViews{2,1}{2,1};
          if circle<7
            viewField=adjustVdthroughN1(viewField,faces,vertices);
          end
             if circle==2 && t==2
             maybe_new=viewField;
             AB = maybe_new(1,:) - maybe_new(2,:);
             AC = maybe_new(3,:) - maybe_new(2,:);
             n = cross(AB, AC);
             n=n/norm(n);
             maybe_new = maybe_new-0.02* n;
             viewField=maybe_new;
            end
            P_final = viewField(1:4,:);
            F_final = viewField(5:8,:);
            visualizeViewField(P_final, F_final);
            visualizeNormalVector((P_final+F_final)/2, 'k');
        end
    end
end



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
% 
%%法向量可视化函数
function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector);
    center = mean(pts, 1);
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 3, color, 'LineWidth', 2, 'MaxHeadSize', 5);
end
