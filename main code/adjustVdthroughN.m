
function maybe_new=adjustVdthroughN(maybe_new,faces,vertices)
[vp1,vf1]=caiyang(maybe_new(1:4,:),maybe_new(5:8,:),faces,vertices);
AB = maybe_new(1,:) - maybe_new(2,:);
AC = maybe_new(3,:) - maybe_new(2,:);
n = cross(AB, AC);
n=n/norm(n);
m=0;
while vf1>0.01
    disp('分割符儿');
    maybe_new = maybe_new-m* n;
    [vp1,vf1]=caiyang(maybe_new(1:4,:),maybe_new(5:8,:),faces,vertices);
    m=m+0.01;
end  

while vp1<0.99 &&  vf1<0.01
    disp('分割符儿');
    maybe_new = maybe_new+m* n;
    [vp1,vf1]=caiyang(maybe_new(1:4,:),maybe_new(5:8,:),faces,vertices);
    m=m+0.02;
end   
while vf1>0.01
    disp('分割符儿');
    maybe_new = maybe_new-m* n;
    [vp1,vf1]=caiyang(maybe_new(1:4,:),maybe_new(5:8,:),faces,vertices);
    m=m+0.01;
end  

end



%%采样某个面内的点（面由 4 个顶点组成） 采样函数为下一步限制相切做铺垫
function samplePts = sampleFace(facePts, numSamples)
    % facePts 的顺序假定为 [P1; P2; P3; P4]（形成一个矩形）
    v1 = facePts(2,:) - facePts(1,:);
    v2 = facePts(4,:) - facePts(1,:);
    [A, B] = meshgrid(linspace(0,1,numSamples), linspace(0,1,numSamples));
    samplePts = facePts(1,:) + A(:)*v1 + B(:)*v2;
end


function [ratioInsideP,ratioInsideF]=caiyang(P_new,F_new,faces,vertices)
ptsP = sampleFace(P_new, 20);
ptsF = sampleFace(F_new, 20);
% 利用 inpolyhedron 判断采样点是否在模型内部（返回 true 表示在内部）
    insideP = in_polyhedron(faces, vertices, ptsP);
    insideF = in_polyhedron(faces, vertices, ptsF);
 % 计算内部点的比例
    ratioInsideP = sum(insideP) / 400;  % 近面内部点占比
    ratioInsideF = sum(insideF) / 400;  % 远面内部点占比
disp( ratioInsideP);
disp( ratioInsideF);
end



