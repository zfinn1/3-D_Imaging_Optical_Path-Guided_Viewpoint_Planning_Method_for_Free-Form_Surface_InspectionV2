fv = stlread('C:\Users\86132\Desktop\c\111.stl');
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
vertices = fv.Points;
faces = fv.ConnectivityList;

% kdtree = buildKDTreeForTriangles(faces, vertices);
AllPts=allSavedViews{3,1}{3,1};
P_new=AllPts(1:4,:);
F_new=AllPts(5:8,:);
uniqueFilteredIntersections = computeIntersectionsWithKD(P_new, fv, 1e-3, kdtree, 8);
% figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
visualizeViewField(P_new, F_new);
% 绘制交点
    if ~isempty(uniqueFilteredIntersections)
        scatter3(uniqueFilteredIntersections(:,1), uniqueFilteredIntersections(:,2), uniqueFilteredIntersections(:,3), 'r', 'filled');
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