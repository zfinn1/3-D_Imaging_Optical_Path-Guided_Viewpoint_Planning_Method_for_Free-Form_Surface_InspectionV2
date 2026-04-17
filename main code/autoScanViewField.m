function autoScanViewField()
    %% 自动扫描视场域
    % 本函数读取 STL 模型，生成初始视场域，
    % 然后循环更新生成多个视场域，并将所有结果可视化。
    
    %% 读取 STL 数据
    stlFile = 'C:\Users\86132\Desktop\c\111.stl';
    model = stlread(stlFile);
    vertices = model.Points;
    faces = model.ConnectivityList;
    
      %% 参数设置
    side = 10;       % 正方形边长（单位 cm）
    d_offset = 28;   % 新视点沿候选面法向偏移距离（单位 cm）
    threshold = 2;   % 求交候选筛选阈值
    numRegions = 6;  % 总共更新区域数
    
    %% 生成初始视场域（随机选取一个面片）
    initialface = 2478;
    tp1 = vertices(faces(initialface,1),:);
    tp2 = vertices(faces(initialface,2),:);
    tp3 = vertices(faces(initialface,3),:);
    % viewfield 返回初始视场的四个底面交点、视点以及面片法向量 n
    [P1, P2, P3, P4, P, n] = viewfield(tp1, tp2, tp3);
   
    basePoints = [P1; P2; P3; P4];
    currentintersections = computeAllRayIntersections(P, basePoints, vertices, faces, threshold);
    P_edge1 = currentintersections(1,:).visibleIntersection;
    P_edge2 = currentintersections(2,:).visibleIntersection;
    P_edge3 = currentintersections(3,:).visibleIntersection;
    P_edge4 = currentintersections(4,:).visibleIntersection;
    currentIntersections=[P_edge1;P_edge2;P_edge3;P_edge4];

    currentViewpoint = P;
    
  
    
    % 用于保存每次迭代结果
    viewpoints = zeros(numRegions, 3);
    baseSets = cell(numRegions, 1);
    candidateTriangles = cell(numRegions, 1);
    
    viewpoints(1,:) = currentViewpoint;
    baseSets{1} = currentIntersections;
    candidateTriangles{1} = [];  % 初始区域没有更新候选
    

    
    %% 循环更新生成新视场域
    for k = 2:numRegions
        
           [newViewpoint, a1,b1,c1, newCandidateTriangle] = generateNextViewFieldFromEdge(P_edge3, P_edge4, side, d_offset, vertices, faces); 
        
           [p1, p2, p3, p4, p, N] = viewfield(a1, b1, c1);

        newbasePoints=[p1;p2;p3;p4];
        nextIntersections = computeAllRayIntersections(p, newbasePoints, vertices, faces, threshold);

        New_P_edge1 = nextIntersections(1,:).visibleIntersection;
        New_P_edge2 = nextIntersections(2,:).visibleIntersection;
        New_P_edge3 = nextIntersections(3,:).visibleIntersection;
        New_P_edge4= nextIntersections(4,:).visibleIntersection;
        newcurrentintsections=[New_P_edge1;New_P_edge2;New_P_edge3;New_P_edge4];
        
     
        viewpoints(k,:) = newViewpoint;
        baseSets{k} = newcurrentintsections;
        candidateTriangles{k} = newCandidateTriangle;
       
       
        % 更新作为下一次基础的交点，选取新底面的第3和第4个交点
         
        
        
             P_edge3 = newcurrentintsections(3,:);
             P_edge4 = newcurrentintsections(4,:);
       
        % 可视化当前区域更新
        figure;
        trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        hold on;
        scatter3(newViewpoint(1), newViewpoint(2), newViewpoint(3), 100, 'm', 'filled');
        text(newViewpoint(1), newViewpoint(2), newViewpoint(3), sprintf('  V_{%d}', k), 'FontSize', 12);
        scatter3(newcurrentintsections(:,1), newcurrentintsections(:,2), newcurrentintsections(:,3), 100, 'r', 'filled');
%         fill3(newcurrentintsections(:,1), newcurrentintsections(:,2),newcurrentintsections(:,3), 'r', 'FaceAlpha', 0.5);
        if ~isempty(newCandidateTriangle)
            fill3(newCandidateTriangle(:,1), newCandidateTriangle(:,2), newCandidateTriangle(:,3), 'y', 'FaceAlpha', 0.5);
        end
        for j = 1:4
            plot3([newViewpoint(1), newcurrentintsections(j,1)], [newViewpoint(2), newcurrentintsections(j,2)], [newViewpoint(3), newcurrentintsections(j,3)], 'k-', 'LineWidth', 2);
        end
        axis equal;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title(sprintf('第 %d 个视场域', k));
        hold off;
        pause(1);
    end
    
    %% 全局可视化所有区域
    figure;
    trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;
    scatter3(viewpoints(:,1), viewpoints(:,2), viewpoints(:,3), 100, 'm', 'filled');
    for k = 1:numRegions
        base = baseSets{k};
        fill3(base(:,1), base(:,2), base(:,3), 'r', 'FaceAlpha', 0.5);
        for j = 1:4
            plot3([viewpoints(k,1), base(j,1)], [viewpoints(k,2), base(j,2)], [viewpoints(k,3), base(j,3)], 'k-', 'LineWidth', 2);
        end
    end
    axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('所有生成的视场域');
    hold off;
   
end
