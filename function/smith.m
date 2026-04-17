close all; clear all; clc
theta=0:pi/100:2*pi;
% 定义常量
real=20;    % 电阻圆的数量
imag=15;    % 电抗圆的数量
% 绘制参考线：一条从(-1.5,0)到(1.5,0)的直线
x=[-1.5 1.5];
y=[0 0];

plot(x,y,'-') % 绘制直线

% hold on; % 保持图形，以便在同一图上绘制更多曲线
figure(1);
% 电阻圆绘制
for x1=0:1/real:1
    r=(1-x1)/x1; % 计算r值
    x=1/(r+1)*cos(theta)+r/(r+1); % 计算x坐标
    y=1/(r+1)*sin(theta);         % 计算y坐标
    figure(1)                      % 确保在第一个图形窗口绘制
    plot(x,y,'-')                  % 绘制曲线
    hold on;                       % 保持当前图形
    axis equal                     % 设置等轴比例，确保圆形不失真
end  



% 电抗圆绘制，涉及不同的theta1起始和结束条件

for theta1=(pi+pi/(imag+1)):(pi/(imag+1)):(2*pi-pi/(imag+1))
    r=sin(theta1)/(1-cos(theta1));
    x=1/r*cos(theta)+1; % 注意这里的偏移(1, 1/r)
    y=1/r*sin(theta)+1/r;
    figure(1)
    plot(x,y,'-')
    hold on;
    axis([-1 1 -1 1]) % 设置x和y轴的显示范围
end  

% 与上述循环相似，但theta1的范围不同
for theta1=0:(pi/(imag+1)):(pi-pi/(imag+1))
    r=sin(theta1)/(1-cos(theta1));
    x=1/r*cos(theta)+1;
    y=1/r*sin(theta)+1/r;
    figure(1)
    plot(x,y,'-')
    hold on;
    axis([-1 1 -1 1])
end  
title("阻抗Smith圆图"); % 图形标题
figure(2);

% 导纳圆绘制，与第一组类似但参数范围和计算有变化
for x1=-1:1/real:0
    r=(1+x1)/(-x1);
    x=-1/(r+1)*cos(theta)-r/(r+1);
    y=1/(r+1)*sin(theta);
    figure(2)
    plot(x,y,'-')
    hold on;
    axis equal
end  

% 接下来两组循环与前两组类似，但x坐标计算有所不同，导致图形分支位置相反
for theta1=(pi+pi/(imag+1)):(pi/(imag+1)):(2*pi-pi/(imag+1))
    r=sin(theta1)/(1-cos(theta1));
    x=-1/r*cos(theta)-1;
    y=1/r*sin(theta)+1/r;
    figure(2)
    plot(x,y,'-')
    hold on;
    axis([-1 1 -1 1])
end  

for theta1=0:(pi/(imag+1)):(pi-pi/(imag+1))
    r=sin(theta1)/(1-cos(theta1));
    x=-1/r*cos(theta)-1;
    y=1/r*sin(theta)+1/r;
    figure(2)
    plot(x,y,'-')
    hold on;
    axis([-1 1 -1 1])
end   
title("导纳Smith圆图"); % 图形标题