figure
for circle = 1:4
    currentCircleViews = allSavedViews{circle};
   prevViews = allSavedViews{circle};
%    nonEmptyIdx = find(~cellfun(@isempty, prevViews));
%    if isempty(nonEmptyIdx)
%     error('上一圈中没有非空的视场数据。');
%    else
    previousViewField = prevViews{1};
%    end
    viewField =previousViewField;
    visualizeViewField(viewField(1:4,:), viewField(5:8,:));
    centrepoint=mean(viewField(:,:),1);
    disp(centrepoint(3));
end
for circle = 1:4
    currentCircleViews = allSavedViews{circle};
   prevViews = allSavedViews{circle};
   nonEmptyIdx = find(~cellfun(@isempty, prevViews));
   if isempty(nonEmptyIdx)
    error('上一圈中没有非空的视场数据。');
   else
    previousViewField = prevViews{nonEmptyIdx(end)};
   end
    viewField =previousViewField;
    visualizeViewField(viewField(1:4,:), viewField(5:8,:));
    centrepoint=mean(viewField(:,:),1);
    disp(centrepoint(3));
end
view=allSavedViews{2,1}{1,1};
[normal, d] = computePlane(view(1,:), view(2,:), view(3,:));
[closest_idx, closest_view] = findClosestViewByZ(allSavedViews{1}, 50,normal);
 
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

% function [closest_idx, closest_view] = findClosestViewByZ_fast(viewField, target_z)
% % 输入：viewField - N×1的cell数组，每个元素是8×3的矩阵
% %       target_z - 目标Z坐标（默认50）
% % 输出：closest_idx - 最接近的视场域索引
% %       closest_view - 最接近的视场域矩阵
% 
%     if nargin < 2
%         target_z = 50;  % 默认目标Z坐标为50
%     end
%     
%     % 预分配内存存储每个视场域的中心Z坐标
%     num_views = length(viewField);
%     center_z = zeros(num_views, 1);
%     
%     % 并行计算所有视场域的中心Z坐标
%     parfor i = 1:num_views
%         center_z(i) = mean(viewField{i}(:,3));
%     end
%     
%     % 计算差值并找到最小差值的索引
%     [~, closest_idx] = min(abs(center_z - target_z));
%     
%     % 返回结果
%     closest_view = viewField{closest_idx};
% end
function [closest_idx, closest_view] = findClosestViewByZ(viewField, target_z, normal_vector)
% 输入：viewField - N×1的cell数组，每个元素是8×3的矩阵
%       target_z - 目标Z坐标（默认50）
%       normal_vector - 参考法向量（3×1向量），用于方向约束
% 输出：closest_idx - 最接近的视场域索引（原始viewField中的索引）
%       closest_view - 最接近的视场域矩阵

    if nargin < 2
        target_z = 50;  % 默认目标Z坐标为50
    end
    
    if nargin < 3 || isempty(normal_vector)
        error('请提供参考法向量normal_vector（3×1向量）');
    end
    
    % 过滤空视场域
    [filtered_viewField, valid_indices] = filterEmptyViews(viewField);
    
    min_diff = inf;
    closest_idx = 0;
    
    % 遍历所有有效视场域
    for i = 1:length(filtered_viewField)
        view = filtered_viewField{i};
        
        % 1. 计算当前视场域的中心Z坐标
        center = mean(view, 1);  % 按行求平均，得到1×3的中心坐标
        center_z = center(3);    % 提取Z坐标
        
       [normal, d] = computePlane(view(1,:), view(2,:), view(3,:));
       
%         % 确保法向量方向一致性（取与Z轴正方向点积为正的方向）
%         if dot(normal, [0; 0; 1]) < 0
%             normal = -normal;
%         end
        
        % 3. 检查法向量方向约束（与参考向量点积大于0）
        if dot(normal, normal_vector) > 0
            % 计算与目标Z的差值
            diff = abs(center_z - target_z);
            
            % 更新最小差值和索引
            if diff < min_diff
                min_diff = diff;
                closest_idx = i;
            end
        end
    end
    
    % 返回结果（映射回原始viewField中的索引）
    if closest_idx > 0
        closest_view = filtered_viewField{closest_idx};
        closest_idx = valid_indices(closest_idx);  % 转换为原始索引
    else
        closest_view = [];
        closest_idx = [];
    end
end

function [filtered_viewField, valid_indices] = filterEmptyViews(viewField)
% 输入：viewField - N×1的cell数组，可能包含空矩阵
% 输出：filtered_viewField - 过滤后的非空cell数组（N_valid×1）
%       valid_indices - 有效数据的原始索引

    valid_indices = [];
    filtered_viewField = {};
    
    for i = 1:length(viewField)
        % 检查当前元素是否为非空的8×3矩阵
        if ~isempty(viewField{i}) && size(viewField{i},1)==8 && size(viewField{i},2)==3
            filtered_viewField{end+1} = viewField{i};
            valid_indices(end+1) = i;
        else
            disp(['警告：第', num2str(i), '个视场域为空或尺寸不符，已排除']);
        end
    end
end

function [n, d] = computePlane(P1, P2, P3)
    % 根据三个点计算平面法向量 n（归一化）及平面常数 d
    v1 = P2 - P1;
    v2 = P3 - P1;
    n = cross(v1, v2);
    n = n / norm(n);
    d = -dot(n, P1);
end