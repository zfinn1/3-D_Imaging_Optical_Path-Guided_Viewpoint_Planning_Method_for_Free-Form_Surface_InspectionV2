stl_file = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stl_file);
faces1 = model.ConnectivityList;
vertices1 = model.Points;
% kdtree1 = buildKDTreeForTriangles(faces1, vertices1);

% 参数设置
tolerance = 1e-2;
numRays = 8;
adjustStep = 3;
depthThreshold = 0.8;
enableVisualization = false;  % 如需可视化设为 true

% 初始化结果容器（结构与原始结构相同）
adjustedAllViews = allSavedViews;

for circle = 1:6
    currentCircleViews = allSavedViews{circle};
    numViewsInCircle = length(currentCircleViews);
    
    for t = 1:numViewsInCircle
        if ~isempty(currentCircleViews{t})
            try
                viewField = currentCircleViews{t};  % 8×3
                P = viewField(1:4, :);
                F = viewField(5:8, :);
                
%                 % 判断是否有交点
%                 isIntersections = computeIntersectionsWithKD(P, model, ...
%                     tolerance, kdtree1, numRays);
%                 
%                 % 自动调整
%                 [AllPts_final, P_final, F_final, intersections_final] = ...
%                     autoAdjustViewField(viewField, isIntersections, ...
%                     kdtree1, stl_file, adjustStep, tolerance, ...
%                     numRays, depthThreshold);
%                 
%                 % 顺序对齐
%                 [orderedNear, orderedFar] = orderPts(viewField, AllPts_final);
%                 adjustedField = [orderedNear; orderedFar];
                adjustedField=adjustVdthroughN(viewField,faces,vertices);
                % 存回去
                adjustedAllViews{circle}{t} = adjustedField;

                % 可选可视化
%                 if enableVisualization
%                     figure;
%                     visualizeViewField(orderedNear, orderedFar);
%                     hold on;
%                     trisurf(faces1, vertices1(:,1), vertices1(:,2), vertices1(:,3), ...
%                             'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
%                     title(sprintf('视场域 Circle %d - #%d', circle, t));
%                     axis equal; view(3);
%                 end
            catch ME
                warning('Circle %d - View #%d 出错：%s', circle, t, ME.message);
                adjustedAllViews{circle}{t} = [];  % 或保留原始也可
            end
        end
    end
end

% 可选保存
save('adjustedAllViews.mat', 'adjustedAllViews');
