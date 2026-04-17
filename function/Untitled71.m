%%就是可视化视场域的函数
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k');
hold on;
for circle = 1:7
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

% maybe=[15.2361,46.7503,62.1625;
%    13.0445,36.9937,62.0899;
%    15.6411,36.4822,52.4465;
%    17.8326,46.2388,52.5191;
%    16.1766,46.5371,62.4271;
%    13.9850,36.7804,62.3545;
%    16.5816,36.2689,52.7110;
%    18.7732,46.0256,52.7836];

%  maybe2=[13.7506,47.0537,66.2327
%    11.5590,37.2971,66.1601
%    20.9641,35.1648,68.8055
%    23.1557,44.9214,68.8781
%    13.4910,47.1048,67.1970
%    11.2994,37.3482,67.1244
%    20.7044,35.2159,69.7699
%    22.8960,44.9725,69.8425];
% 
%  viewField =allSavedViews{2,1}{4,1};
% P_final = viewField(1:4,:);
% F_final = viewField(5:8,:);
% visualizeViewField(P_final, F_final,0);
% visualizeViewField(maybe2(1:4,:),maybe2(5:8,:),1);
% 
% 
% 
%  viewField =allSavedViews{2,1}{3,1};
% P_final = viewField(1:4,:);
% F_final = viewField(5:8,:);
% normal_vector = cross(P_final(2,:) - P_final(1,:), P_final(3,:) - P_final(1,:));
% normal_vector = normal_vector / norm(normal_vector);
% viewField=viewField+normal_vector*0.08;
% P_final = viewField(1:4,:);
% F_final = viewField(5:8,:);
% visualizeViewField(P_final, F_final,0);
% 
%  points=allSavedIntersections{2,1}{3,1}(1,:);
%   scatter3(points(1), points(2), points(3), 48,'r','filled');


function visualizeViewField(nearPts, farPts)
    hold on;
   
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
 
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
%         % 标注点
%     for i = 1:4
%         text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%         text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%     end
    
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end
% 
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

