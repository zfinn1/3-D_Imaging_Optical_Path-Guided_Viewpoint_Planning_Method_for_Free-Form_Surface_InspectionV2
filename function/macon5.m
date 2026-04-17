%  clear; clc; 
stl_file = 'C:\Users\86132\Desktop\c\111.stl';
model = stlread(stl_file);
faces1 = model.ConnectivityList;
vertices1 = model.Points;
kdtree1 = buildKDTreeForTriangles(faces1, vertices1);

% 
% AllPts =[15.1460860254530,46.7665920600135,62.6899553235460;
% 12.9544925362598,37.0099713438603,62.6173593232665;
% 13.3688049784644,36.9912487690037,52.6259632914086;
% 15.5603984676576,46.7478694851569,52.6985592916882;
% 16.1208950486897,46.5473205008381,62.7307885398433;
% 13.9293015594965,36.7906997846849,62.6581925395638;
% 14.3436140017011,36.7719772098283,52.6667965077059;
% 16.5352074908943,46.5285979259815,52.7393925079855];

% AllPts=[15.1457537193278,46.7666070767634,62.6979690874658;
% 12.9541602301346,37.0099863606102,62.6253730871862;
% 13.3684726723392,36.9912637857536,52.6339770553283;
% 15.5600661615324,46.7478845019068,52.7065730556079;
% 16.1205627425645,46.5473355175880,62.7388023037630;
% 13.9289692533713,36.7907148014348,62.6662063034835;
% 14.3432816955759,36.7719922265782,52.6748102716256;
% 16.5348751847691,46.5286129427314,52.7474062719052];
% AllPts = [4.44598066697915,45.4757974915837,38.1088577136775;
% 3.03860076142785,35.5840430432138,37.6935557336617;
% 3.38023034388273,35.1162948890805,47.6767666846883;
% 4.78761024943404,45.0080493374504,48.0920686647040;
% 3.45652338629523,45.6148804020170,38.1492338666268;
% 2.04914348074392,35.7231259536471,37.7339318866110;
% 2.39077306319880,35.2553777995138,47.7171428376376;
% 3.79815296875011,45.1471322478836,48.1324448176533;];


% 定义视场的八个顶点
% AllPts = [0,0,0; 2,0,0; 2,2,0; 0,2,0;  % 近面
%           0,0,2; 2,0,2; 2,2,2; 0,2,2]; % 远面
% 
% AllPts=[12.6478141683673,63.3844003020391,38.6059609175554;
% 7.05116952310188,55.0981302602006,38.4822778210925;
% 8.29477211211601,54.1108174124102,48.3554062989958;
% 13.8914167573814,62.3970874542488,48.4790893954587;
% 11.8284789420086,63.9354260921281,38.7642655779563;
% 6.23183429674322,55.6491560502895,38.6405824814934;
% 7.47543688575736,54.6618432024992,48.5137109593967;
% 13.0720815310228,62.9481132443378,48.6373940558596; ]  ;  
      
% AllPts=[7.10963634882995,55.2147503594304,38.4865754483875;
% 3.82428835445574,45.7846684342363,37.9573841408362;
% 5.06789094346988,44.7973555864459,47.8305126187395;
% 8.35323893784409,54.2274375116401,48.3597039262908;
% 6.17336747101515,55.5325359510597,38.6362848541985;
% 2.88801947664093,46.1024540258655,38.1070935466472;
% 4.13162206565508,45.1151411780752,47.9802220245505;
% 7.41697006002929,54.5452231032693,48.5094133321018];

% AllPts=[8.15904796733124,54.2142635063271,48.4080398326664;
% 13.1705201054759,62.8647247713970,48.6418493921909;
% 12.8288905230210,63.3324729255303,38.6586384411644;
% 7.81741838487636,54.6820116604604,38.4248288816399;
% 7.29436053110360,54.7137705790080,48.4610334357878;
% 12.3058326692483,63.3642318440779,48.6948429953123;
% 11.9642030867934,63.8319799982113,38.7116320442857;
% 6.95273094864872,55.1815187331414,38.4778224847612];


% AllPts=[15.2792902399026,46.7417378831052,62.0089713626745;
% 13.0876967507094,36.9851171669520,61.9363753623950;
% 13.1615533620484,37.0429306679461,51.9368152320660;
% 15.3531468512416,46.7995513840992,52.0094112323455;
% 16.2549513653918,46.5225345573951,62.0149102351930;
% 14.0633578761986,36.7659138412420,61.9423142349134;
% 14.1372144875376,36.8237273422360,51.9427541045845;
% 16.3288079767308,46.5803480583892,52.0153501048640];

% AllPts=[19.3788986902447,85.8235112927123,40.0898311749191;18.2204194139719,75.8917422113621,39.9560826004122;20.3905189390919,75.5072573505689,49.7102017017404;21.5489982153647,85.4390264319191,49.8439502762472;18.4096278621604,85.9336082639040,40.3098146260222;17.2511485858876,76.0018391825538,40.1760660515154;19.4212481110076,75.6173543217605,49.9301851528435;20.5797273872804,85.5491234031107,50.0639337273503]; 
% AllPts=[18.4331432356311,75.5875988528408,36.4304622348260;14.2926526370020,66.4905921554932,36.7479630239245;15.1504194771533,66.4479079478283,46.7110154731668;19.2909100757824,75.5449146451759,46.3935146840683;17.5269392097594,76.0028415193243,36.5102606773277;13.3864486111303,66.9058348219767,36.8277614664262;14.2442154512817,66.8631506143118,46.7908139156685;18.3847060499107,75.9601573116593,46.4733131265700];
%  AllPts=[10.3772954712801,57.6741176529429,45.8659290322353;5.61863530690132,48.8877116959134,46.2586424114727;7.24011850806017,48.4501339314249,56.1165994984347;11.9987786724389,57.2365398884543,55.7238861191973;9.51285376897556,58.1495921113347,46.0292219675810;4.75419360459680,49.3631861543053,46.4219353468185;6.37567680575564,48.9256083898167,56.2798924337805;11.1343369701344,57.7120143468462,55.8871790545431];
% AllPts=[17.9731634732171,53.3611249622183,45.8301974918158;13.0565168618087,44.6611760517464,46.2009737770666;10.5676917636625,45.6571148527089,36.5669789911238;15.4843383750709,54.3570637631808,36.1962027058729;18.8076233927421,52.8782275107867,45.5647041884968;13.8909767813337,44.1782786003148,45.9354804737477;11.4021516831874,45.1742174012773,36.3014856878048;16.3187982945959,53.8741663117492,35.9307094025539];
% AllPts=[18.2215402181277,53.2864920629805,47.3055467286478;
% 13.3309975338491,44.5795584808617,47.8269868976236;
% 11.2266734078463,45.1771485302644,38.0691845781678;
% 16.1172160921248,53.8840821123831,37.5477444091919;
% 19.0680295105937,52.7983097842216,47.0930992282011;
% 14.1774868263152,44.0913762021028,47.6145393971770;
% 12.0731627003124,44.6889662515054,37.8567370777212;
% 16.9637053845909,53.3958998336242,37.3352969087453];
%  AllPts=[24.8724017308122,61.8431769775218,62.7795680074656;20.1063452716368,53.0587857996759,63.1247888969471;19.8738261087407,52.7921937585497,53.1310476794403;24.6398825679161,61.5765849363957,52.7858267899588;25.7512113840753,61.3660669239892,62.7718485418291;20.9851549248999,52.5816757461432,63.1170694313106;20.7526357620038,52.3150837050171,53.1233282138038;25.5186922211792,61.0994748828631,52.7781073243223];
AllPts=rotatedPts;
% AllPts=allSavedViews{3,1}{3,1};
isIntersections = computeIntersectionsWithKD(AllPts(1:4,:), model, 1e-2, kdtree1, 8);
 [AllPts_final, P_final, F_final, intersections_final] = ...
    autoAdjustViewField(AllPts, isIntersections, kdtree, stl_file, ...
                         3, 1e-2, 8, 0.8);
[orderedNear,orderedFar]=orderPts(AllPts,AllPts_final);
 AllPts_final= [orderedNear;orderedFar];
% if needAdjustmentByProximity(isIntersections, AllPts(1:4,:), 0.8)
%     disp('存在靠近参考边的交点，触发视场调整...');
% [AllPts_final, P_final, F_final, finalIntersections]=adjustUntilNoIntersection(AllPts, model, kdtree,stl_file,3,0.01, 8);
%  [orderedNear,orderedFar]=orderPts(AllPts,AllPts_final);
%  AllPts_final= [orderedNear;orderedFar];
% end
% [AllPts_final, P_final, F_final, finalIntersections]=adjustUntilNoIntersection(AllPts, model, kdtree,stl_file,3,0.01, 8);
P = AllPts_final(1:4, :);  % 近面
F = AllPts_final(5:8, :);  % 远面
figure;
% subplot(1,2,1)
visualizeIntersections(isIntersections);
visualizeViewField(P, F);
 trisurf(faces1, vertices1(:,1), vertices1(:,2), vertices1(:,3), ...
        'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.6);
    hold on;
    

    
    
    


%% 视场可视化函数
function visualizeViewField(nearPts, farPts)
    hold on;
    % 绘制近面和远面
    patch('Faces', [1 2 3 4], 'Vertices', nearPts, 'FaceColor', 'r', 'FaceAlpha', 0.4);
    patch('Faces', [1 2 3 4], 'Vertices', farPts, 'FaceColor', 'b', 'FaceAlpha', 0.4);
    
    % 连接近面和远面顶点
    for i = 1:4
        plot3([nearPts(i,1), farPts(i,1)], [nearPts(i,2), farPts(i,2)], [nearPts(i,3), farPts(i,3)], ...
              'k-', 'LineWidth', 1.5);
    end
    
    % 标注点
    for i = 1:4
        text(nearPts(i,1), nearPts(i,2), nearPts(i,3), sprintf('P%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
        text(farPts(i,1), farPts(i,2), farPts(i,3), sprintf('F%d', i), 'FontSize', 12, 'Color', 'b', 'FontWeight', 'bold');
    end
    
  
    xlabel('X 轴'); ylabel('Y 轴'); zlabel('Z 轴');
    grid on; axis equal; view(3);
end

function visualizeNormalVector(pts, color)
    normal_vector = cross(pts(2,:) - pts(1,:), pts(3,:) - pts(1,:));
    normal_vector = normal_vector / norm(normal_vector); % 归一化
    center = mean(pts, 1); % 计算中心点
    quiver3(center(1), center(2), center(3), normal_vector(1), normal_vector(2), normal_vector(3), 1, color, 'LineWidth', 2, 'MaxHeadSize', 2);
end
function kdTree = buildKDTreeForTriangles(faces, vertices)
    % 计算每个三角形的质心
    numTri = size(faces,1);
    centroids = zeros(numTri, 3);
    for i = 1:numTri
        tri = vertices(faces(i,:), :);
        centroids(i,:) = mean(tri, 1);
    end
    % 使用 MATLAB 内置的 createns 构建 KD-Tree
    kdTree = createns(centroids, 'NSMethod', 'kdtree');
end

function n = getModelNormalAt(X, model)
    % 根据模型中离点 X 最近的面片，返回该面片的法向量（列向量）
    faces = model.ConnectivityList;
    vertices = model.Points;
    numFaces = size(faces,1);
    centroids = zeros(numFaces,3);
    normals = zeros(numFaces,3);
    for i = 1:numFaces
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        centroids(i,:) = (v1 + v2 + v3) / 3;
        n_i = cross(v2 - v1, v3 - v1);
        if norm(n_i) > 0
            normals(i,:) = n_i / norm(n_i);
        else
            normals(i,:) = [0, 0, 0];
        end
    end
    dists = sqrt(sum((centroids - X).^2,2));
    [~, idx] = min(dists);
    n = normals(idx,:)';
    
end


function filteredIntersections = filterIntersectionsByZ(intersections, threshold)
    % 计算所有交点的 z 坐标的中位数
    z_values = intersections(:,3);
    medianZ = median(z_values);
    
    % 计算每个交点与中位数的差值
    diffZ = abs(z_values - medianZ);
    
    % 保留那些差值在阈值内的交点
    mask = diffZ <= threshold;
    filteredIntersections = intersections(mask,:);
end

function needAdjust = needAdjustmentByProximity(intersections, P, tol)
    % 检查是否存在交点距离参考直线太近
    % tol: 距离容差
    
    if nargin < 3
        tol = 0.8;
    end

    P1 = P(1,:);
    P2 = P(2,:);
    lineVec = P2 - P1;
    lineNorm = norm(lineVec);
    
    if lineNorm < eps
        needAdjust = false;
        return;
    end
    
    for i = 1:size(intersections,1)
        pt = intersections(i,:);
        dist = norm(cross(pt - P1, lineVec)) / lineNorm;
        if dist < tol
            needAdjust = true;
            return;
        end
    end
    
    needAdjust = false;
end


function visualizeIntersections(intersections, varargin)
% visualizeIntersections 可视化 3D 空间中的交点集
%
% 输入：
%   intersections: N x 3 数组，表示交点坐标
% 可选输入参数（通过名称-值对）：
%   'Color'      - 点的颜色，默认 'r'
%   'Size'       - 散点大小，默认 80
%   'ShowIndex'  - 是否显示编号标签，默认 false
%   'TagPrefix'  - 标签前缀字符串，默认 ''
%
% 示例：
%   visualizeIntersections(isIntersections, 'Color', 'g', 'ShowIndex', true)

    % 默认参数
    color = 'r';
    sz = 80;
    showIndex = false;
    tagPrefix = '';

    % 解析可选参数
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case 'color'
                color = varargin{i+1};
            case 'size'
                sz = varargin{i+1};
            case 'showindex'
                showIndex = varargin{i+1};
            case 'tagprefix'
                tagPrefix = varargin{i+1};
        end
    end

    % 可视化交点
    scatter3(intersections(:,1), intersections(:,2), intersections(:,3), ...
        sz, color, 'filled');

    % 添加编号标签（如果启用）
    if showIndex
        for i = 1:size(intersections, 1)
            text(intersections(i,1), intersections(i,2), intersections(i,3), ...
                sprintf('%s%d', tagPrefix, i), ...
                'FontSize', 8, 'Color', 'k', 'VerticalAlignment', 'bottom');
        end
    end

    % 画图设置
    axis equal;
    grid on;
    rotate3d on;
end

