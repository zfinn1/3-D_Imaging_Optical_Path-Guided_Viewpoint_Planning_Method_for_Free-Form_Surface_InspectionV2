
function [AllPts_final, P_final, F_final, finalIntersections] = adjustUntilNoIntersection(AllPts, model, kdtree,stl_file,max_iterations, distance_thresh, max_k)

    % 初始化
    AllPts_current = AllPts;
    finalIntersections = computeIntersectionsWithKD(AllPts_current(1:4,:), model, distance_thresh, kdtree, max_k);

    iteration = 0;
    while ~isempty(finalIntersections) && iteration < max_iterations
        [AllPts_current, ~, ~] = adjustpos(AllPts_current, finalIntersections, stl_file, 15, 1, 360);
        finalIntersections = computeIntersectionsWithKD(AllPts_current(1:4,:), model, distance_thresh, kdtree, max_k);
        iteration = iteration + 1;
    end

    % 最终点集
    [P_final, F_final] = deal(AllPts_current(1:4,:), AllPts_current(5:8,:));
    AllPts_final = AllPts_current;
end