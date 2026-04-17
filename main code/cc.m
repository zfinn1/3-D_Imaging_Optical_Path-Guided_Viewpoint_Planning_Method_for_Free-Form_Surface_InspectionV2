clear;
clc;
close all;

[objFile, objPath] = uigetfile('model.obj', 'C:\Users\86132\Desktop\本科毕设\');

if objFile == 0
    disp('No file selected.');
    return;
end
[V, F] = readObj(fullfile(objPath, objFile));

% [V,F]=readObj('C:\Users\86132\Desktop\本科毕设\model.obj');
V=V';F=F';
iter=5;
[VV, FF] = CCsub(V, F, iter);
obj_write('torus1.obj',VV',FF');

function [vertices, faces] = readObj(filename)
    % 打开文件
    fid = fopen(filename, 'r');
    if fid == -1
        error('File not found.');
    end
    
    vertices = [];
    faces = [];
    
    while true
        tline = fgetl(fid);
        if ~ischar(tline), break; end
        
        % 读取顶点数据
        if startsWith(tline, 'v ')
            vertex = sscanf(tline, 'v %f %f %f');
            vertices = [vertices; vertex'];
        % 读取面片数据
        elseif startsWith(tline, 'f ')
            face = sscanf(tline, 'f %d %d %d');
            faces = [faces; face'];
        end
    end
    
    fclose(fid);
end
