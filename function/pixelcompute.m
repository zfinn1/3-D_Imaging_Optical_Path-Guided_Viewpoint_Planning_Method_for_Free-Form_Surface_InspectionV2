
syms a l w c h  b d   S        ... % 用于 P0
     dx dy dz               ... % 直线方向向量
     T               ... % 平面法向量
     real


P0 = [ a/2 + l;
       w/2;
       c/2 + h ];           % 直线过点
d  = [ a/2; w/2; c/2 ];        % 方向向量
A  = [ 0;  0;  0 ];         % 平面上一点（重心原点）
n  = [ l; 0; h ];        % 平面法向量

% P0 = [ a/2 + l;
%        -w/2;
%        c/2 + h ];           % 直线过点
% d  = [ a/2; -w/2; c/2 ];        % 方向向量
% A  = [ 0;  0;  0 ];         % 平面上一点（重心原点）
% n  = [ -l; 0; -h ];        % 平面法向量

% P0 = [ b/2 + l;
%        -w/2;
%        d/2 + h ];           % 直线过点
% d  = [ b/2; -w/2; d/2 ];        % 方向向量
% A  = [ 0;  0;  0 ];         % 平面上一点（重心原点）
% n  = [ -l; 0; -h ];        % 平面法向量
% 
% P0 = [ b/2 + l;
%        w/2;
%        d/2 + h ];           % 直线过点
% d  = [ b/2; w/2; d/2 ];        % 方向向量
% A  = [ 0;  0;  0 ];         % 平面上一点（重心原点）
% n  = [ -l; 0; -h ];        % 平面法向量



t = simplify( dot(n, A - P0) / dot(n, d) );


P_int = simplify( P0 + t * d );
% P_int = simplify( P_int+(S/2)*n );
Px = P_int(1);
Py = P_int(2);
Pz = P_int(3);
% peyz=simplify( -S*l*(a*l+c*h)-2*h*(a*h-c*l) );

disp('参数 t =');
disp(t);
disp('交点 P = [Px; Py; Pz] =');
disp(P_int);
% disp(peyz);