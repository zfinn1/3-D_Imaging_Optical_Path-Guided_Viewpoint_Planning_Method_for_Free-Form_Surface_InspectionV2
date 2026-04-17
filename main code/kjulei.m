ptCloud1 = double(ptCloud1);         % 强制类型为 double
ptCloud1 = reshape(ptCloud1, [], 3); % 确保为 N x 3
[viewpoints, directions,box_template] = kmeansViewCoverage(ptCloud1,faces, vertices, 125, 30);
figure;
trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
hold on;
visualizeViewField(box_template(1:4,:), box_template(5:8,:));

% 主函数：基于 K-means 聚类和概率势场法生成视点 + 构建视场域 + 计算覆盖率
function [viewpoints, directions,box_template] = kmeansViewCoverage(ptCloud, model_faces, model_vertices, numViews, radius)
    % 输入：
    %   ptCloud: N×3 点云坐标
    %   model_faces: F×3 STL 三角形面片索引
    %   model_vertices: V×3 STL 模型顶点
    %   numViews: 要生成的视点数量
    %   radius: 每个视点的可视范围（用于势场朝向计算和覆盖判断）

    %% 第一步：计算三角形面片中心点（作为K-means聚类对象）
    tri_centers = (model_vertices(model_faces(:,1),:) + ...
                   model_vertices(model_faces(:,2),:) + ...
                   model_vertices(model_faces(:,3),:)) / 3;

    %% 第二步：K-means 聚类，得到每个视点位置（聚类中心）
    [~, viewpoints] = kmeans(tri_centers, numViews);

    %% 第三步：概率势场法计算每个视点的朝向
    directions = zeros(size(viewpoints));
    for i = 1:numViews
        pv = viewpoints(i,:);
        v = [0, 0, 0];
        for j = 1:size(tri_centers, 1)
            pi = tri_centers(j,:);
            d = norm(pi - pv);
            if d < radius && d > 1e-6  % 设定一个可视范围限制
                v = v + (pi - pv) / (d^3);
            end
        end
        if norm(v) < 1e-6
            directions(i,:) = [0, 0, 1]; % 如果势场为空，默认向上
        else
            directions(i,:) = v / norm(v);
        end
    end

    %% 第四步：构建每个视点的景深长方体并判断覆盖率
    box_template = generateDepthBox(10, 10, 1);  % 宽高为10，深度为1
%     covered_flags = false(size(ptCloud,1), 1);
%     for i = 1:numViews
%         box = transformBox(box_template, viewpoints(i,:), directions(i,:));
%         minB = min(box);
%         maxB = max(box);
%         mask = all(ptCloud >= minB & ptCloud <= maxB, 2);
%         candidates = ptCloud(mask,:);
%         candidate_idx = find(mask);
%        
% % 1. faces_box: 12x3 三角面片定义（三角形顶点索引）
% faces_box = [1 2 3; 1 3 4;
%              5 6 7; 5 7 8;
%              1 2 6; 1 6 5;
%              2 3 7; 2 7 6;
%              3 4 8; 3 8 7;
%              4 1 5; 4 5 8];
% 
% % 2. box: 8x3 顶点数组
% vertices_box = double(box);  % 强制转换为 double
% 
% % 3. candidates: N×3 点云候选点
% candidates = double(candidates);  % 强制转换
% inside = inpolyhedron(double(faces_box), vertices_box, double(candidates)); 
%         covered_flags(candidate_idx(inside)) = true;
%     end
% 
%     coverage_ratio = sum(covered_flags) / size(ptCloud, 1);
end

%% 辅助函数：生成默认景深长方体
function box = generateDepthBox(width, height, depth)
    w = width / 2; h = height / 2;
    box = [
        -w, -h, 0;
         w, -h, 0;
         w,  h, 0;
        -w,  h, 0;
        -w, -h, depth;
         w, -h, depth;
         w,  h, depth;
        -w,  h, depth
    ];
end

%% 辅助函数：将长方体旋转并平移到目标位置和方向
function transformedBox = transformBox(box, position, direction)
    z_axis = [0, 0, 1];
    direction = direction / norm(direction);
    v = cross(z_axis, direction);
    s = norm(v);
    c = dot(z_axis, direction);
    if s == 0
        R = eye(3);
        if c < 0
            R = diag([1, -1, -1]);
        end
    else
        vx = [ 0, -v(3), v(2);
               v(3), 0, -v(1);
              -v(2), v(1), 0];
        R = eye(3) + vx + vx^2 * ((1 - c)/(s^2));
    end
    transformedBox = (R * box')' + position;
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
