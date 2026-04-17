% 读取 OBJ 文件
% 
% [vertices, faces,normals] = readObj('C:\Users\86132\Desktop\本科毕设\quad333.obj');
[vertices, faces,normals] = readObj('G:\doctor\2-博一下\2-全覆盖成像模型视点规划\代码\代码\model.obj');

% 可视化
figure;
hold on;
patch('Vertices', vertices, 'Faces', faces(:, 1:4), ...
      'FaceColor', 'cyan', 'FaceAlpha', 0.9, 'EdgeColor', 'black');
axis equal;
xlabel('X');
ylabel('Y');
zlabel('Z');

% figure
% hold on
% patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'cyan', 'FaceAlpha', 0.9, 'EdgeColor', 'black');
% axis equal;

% function [vertices, faces, normals] = readObj(filename)
%     fid = fopen(filename, 'r');
%     if fid == -1
%         error(['Cannot open file ' filename]);
%     end
%     
%     vertices = [];
%     normals = [];
%     faces = [];
% 
%     while ~feof(fid)
%         line = fgetl(fid);
%         if isempty(line) || line(1) == '#' % 忽略空行和注释
%             continue;
%         end
%         
%         tokens = strsplit(line);
%         
%         if strcmp(tokens{1}, 'v')
%             % 读取顶点坐标
%             x = str2double(tokens{2});
%             y = str2double(tokens{3});
%             z = str2double(tokens{4});
%             vertices(end+1,:) = [x y z];
%         elseif strcmp(tokens{1}, 'vn')
%             % 读取法向量
%             x = str2double(tokens{2});
%             y = str2double(tokens{3});
%             z = str2double(tokens{4});
%             normals(end+1,:) = [x y z];
%         elseif strcmp(tokens{1}, 'f')
%             % 读取面
%             v1 = str2double(strsplit(tokens{2}, '/'));
%             v2 = str2double(strsplit(tokens{3}, '/'));
%             v3 = str2double(strsplit(tokens{4}, '/'));
%             
%             faces(end+1,:) = [v1(1) v2(1) v3(1)];
%         end
%     end
%     
%     fclose(fid);
% end
function [vertices, faces, normals] = readObj(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error(['Cannot open file ' filename]);
    end
    
    vertices = [];
    normals = [];
    faces = {};

    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line) || line(1) == '#' % 忽略空行和注释
            continue;
        end
        
        tokens = strsplit(line);
        
        if strcmp(tokens{1}, 'v')
            % 读取顶点坐标
            x = str2double(tokens{2});
            y = str2double(tokens{3});
            z = str2double(tokens{4});
            vertices(end+1,:) = [x y z];
        elseif strcmp(tokens{1}, 'vn')
            % 读取法向量
            x = str2double(tokens{2});
            y = str2double(tokens{3});
            z = str2double(tokens{4});
            normals(end+1,:) = [x y z];
        elseif strcmp(tokens{1}, 'f')
            % 动态读取面，支持任意顶点数量
            face = cellfun(@(x) str2double(strsplit(x, '/')), tokens(2:end), 'UniformOutput', false);
            face = cellfun(@(x) x(1), face); % 仅提取顶点索引
            faces{end+1} = face; % 动态存储面信息为单元数组
        end
    end
    
    fclose(fid);

    % 将 faces 转换为矩阵格式，用 NaN 填充缺失值
    maxVertices = max(cellfun(@numel, faces)); % 最大顶点数
    faces = cellfun(@(f) [f, nan(1, maxVertices - numel(f))], faces, 'UniformOutput', false);
    faces = vertcat(faces{:}); % 转换为矩阵
end



% 提取顶点和面


% 提取顶点坐标
% x = vertices(:, 1);
% y = vertices(:, 2);
% z = vertices(:, 3);
% 
% % 可视化四边形网格
% figure;
% hold on;
% view(3);  % 设置三维视图
% % 绘制每个四边形
% for i = 1:size(faces, 1)
%     quad = faces(i, :);
%     patch(x(quad), y(quad), z(quad), 'FaceColor', 'cyan', 'EdgeColor', 'black');
% end
% 
% % 绘制顶点
% scatter3(x, y, z, 'filled', 'MarkerFaceColor', 'red');
% 
% % 设置图形属性
% hold off;
% axis equal;
% grid on;
% title('四边形网格可视化');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% 
% % 设置三维视图





% 提取顶点坐标


% % 可视化四边形网格
% figure;
% hold on;
% for i = 1:size(faces, 1)
%     quad = faces(i, :);
%     patch(x(quad), y(quad), z(quad), 'FaceColor', 'cyan', 'EdgeColor', 'black');
% end
% scatter3(x, y, z, 'filled', 'MarkerFaceColor', 'red');
% hold off;
% axis equal;
% grid on;
% title('四边形网格可视化');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');


% 
% function [vertices, faces] = readObj(filename)
%     % 打开文件
%     fid = fopen(filename, 'r');
%     if fid == -1
%         error('File not found.');
%     end
%     
%     vertices = [];
%     faces = [];
%     
%     while true
%         tline = fgetl(fid);
%         if ~ischar(tline), break; end
%         
%         % 读取顶点数据
%         if startsWith(tline, 'v ')
%             vertex = sscanf(tline, 'v %f %f %f');
%             vertices = [vertices; vertex'];
%         % 读取面片数据
%         elseif startsWith(tline, 'f ')
%             face = sscanf(tline, 'f %d %d %d');
%             faces = [faces; face'];
%         end
%     end
%     
%     fclose(fid);
% end

% 
% clear;
% close all;
% clc;
% stlFile = 'C:\Users\86132\Desktop\c\111.stl';
% model = stlread(stlFile); % 使用 stlread 函数加载 STL 文件，获取模型的几何数据
% vertices = model.Points; % 提取模型的顶点坐标（点云数据）
% faces = model.ConnectivityList; % 提取模型的三角面片索引（每个三角形由 3 个顶点组成）
% 
% % 提取顶点和面
% 
% 
% % 提取顶点坐标
% x = vertices(:, 1);
% y = vertices(:, 2);
% z = vertices(:, 3);
% 
% % 可视化四边形网格
% figure;
% hold on;
% view(3);  % 设置三维视图
% % 绘制每个四边形
% for i = 1:size(faces, 1)
%     quad = faces(i, :);
%     patch(x(quad), y(quad), z(quad), 'FaceColor', 'cyan', 'EdgeColor', 'black');
% end
% 
% % 绘制顶点
% scatter3(x, y, z, 'filled', 'MarkerFaceColor', 'red');
% 
% % 设置图形属性
% hold off;
% axis equal;
% grid on;
% title('四边形网格可视化');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% 
% % 设置三维视图
% 
% 
% 
% 
% 
% % 提取顶点坐标
% 
% 
% % % 可视化四边形网格
% % figure;
% % hold on;
% % for i = 1:size(faces, 1)
% %     quad = faces(i, :);
% %     patch(x(quad), y(quad), z(quad), 'FaceColor', 'cyan', 'EdgeColor', 'black');
% % end
% % scatter3(x, y, z, 'filled', 'MarkerFaceColor', 'red');
% % hold off;
% % axis equal;
% % grid on;
% % title('四边形网格可视化');
% % xlabel('X');
% % ylabel('Y');
% % zlabel('Z');
% 
% 
% % 
% % function [vertices, faces] = readObj(filename)
% %     % 打开文件
% %     fid = fopen(filename, 'r');
% %     if fid == -1
% %         error('File not found.');
% %     end
% %     
% %     vertices = [];
% %     faces = [];
% %     
% %     while true
% %         tline = fgetl(fid);
% %         if ~ischar(tline), break; end
% %         
% %         % 读取顶点数据
% %         if startsWith(tline, 'v ')
% %             vertex = sscanf(tline, 'v %f %f %f');
% %             vertices = [vertices; vertex'];
% %         % 读取面片数据
% %         elseif startsWith(tline, 'f ')
% %             face = sscanf(tline, 'f %d %d %d');
% %             faces = [faces; face'];
% %         end
% %     end
% %     
% %     fclose(fid);
% % end

