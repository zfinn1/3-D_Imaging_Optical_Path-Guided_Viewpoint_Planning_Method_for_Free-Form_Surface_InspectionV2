
figure;
 trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
% for i=1:10
% AllPts=allSavedViews{1,1}{i,1};
% 
% P=AllPts(1:4,:);
% F=AllPts(5:8,:);
% gw=mean(P,1);
% m=mean(P,1)-mean(F,1);
% m=m/norm(m);
% Pk=mean(P,1)-31*m;
% theta_deg=195;
% % [AllPts_new,P_new, F_new] = applyRotation(AllPts, theta_deg,1);
% 
% 
% visualizeViewField(P, F);
% scatter3(Pk(1), Pk(2), Pk(3), 80, 'm', 'filled');
% for i = 1:4
%     plot3([Pk(1), P(i,1)], [Pk(2), P(i,2)], [Pk(3),P(i,3)], 'b', 'LineWidth', 3);
% end
% plot3([Pk(1), gw(1)], [Pk(2), gw(2)], [Pk(3),gw(3)], 'r','LineStyle', '--', 'LineWidth', 3);
% 
% end


AllPts=allSavedViews{1,1}{1,1};

P=AllPts(1:4,:);
F=AllPts(5:8,:);
gw=mean(P,1);
m=mean(P,1)-mean(F,1);
m=m/norm(m);
Pk=mean(P,1)-31*m;
theta_deg=195;
% [AllPts_new,P_new, F_new] = applyRotation(AllPts, theta_deg,1);


visualizeViewField(P, F);
scatter3(Pk(1), Pk(2), Pk(3), 80, 'm', 'filled');
for i = 1:4
    plot3([Pk(1), F(i,1)], [Pk(2), F(i,2)], [Pk(3),F(i,3)], 'b', 'LineWidth', 3);
end
plot3([Pk(1), gw(1)], [Pk(2), gw(2)], [Pk(3),gw(3)], 'r','LineStyle', '--', 'LineWidth', 3);

axis off;

% axis off;
function visualizeViewField(nearPts, farPts)
    hold on;
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], 'k-', 'LineWidth', 1.5);
    end
    
        % 标注点
%     for i = 1:4
%         text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%         text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
%     end
%     
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end
