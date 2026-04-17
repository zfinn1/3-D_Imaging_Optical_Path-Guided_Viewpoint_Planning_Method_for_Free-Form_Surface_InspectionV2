clc;
clear all;
close all;

syms f;
v=0.65*3e8;
R_be=520;
R_ce=80000;
C_be=10e-12;
C_bc=1e-12;
g_m=0.192;
l=0.05;
L=1e-9;
C=10e-12;
Z=50;

w=2*pi*f;

base=1+1i*w*(C_be+C_bc)*R_be;
h11=R_be./base;
h12=1i*w*R_be*C_bc./base;
h21=R_be.*(g_m-1i*w*C_bc)./base;
h22=1/R_ce+1i*w.*C_bc.*(1+g_m.*R_be+1i*w*C_be*R_be)./base;
feedback=[1e-4 1e-3 2*1e-3 1/300 1/200]; %反馈电导

for k=1:length(feedback)
y=feedback(k);
Y11=1./h11+y;
Y12=-h12./h11-y;
Y21=h21./h11-y;
Y22=(h11.*h22-h12.*h21)./h11+y;
exper2=[Y11 Y12;Y21 Y22];

exper6=[-Y22./Y21 -1./Y21;-(Y11.*Y22-Y12.*Y21)./Y21 -Y11./Y21];%BJT与反馈的A参量矩阵
P=w/v;
exper5=[cos(P*l) 1i*Z*sin(P*l);1i*sin(P*l)/Z cos(P*l)];%输入矩阵


exper7=[1-(w.^2).*L.*C 2i.*w.*L-1i.*(w.^3).*(L.^2).*C;1i.*w.*C 1-(w.^2).*L.*C];%输出矩阵


experall=exper5*exper6*exper7;%将三个A参量矩阵相乘
ABCD_22=experall(2,2);%取D

ABCD_22=subs(ABCD_22,f,logspace(4,8.5,100));%将f的值赋回去
f1=logspace(4,8.5,100);%便于画图
semilogx(f1,-20*log10(abs(ABCD_22)));
hold on;
text(10^6, 38, 'R=10K', 'Color', 'b');  
text(10^6, 35.4, 'R=1K', 'Color', 'r');
text(10^6, 33, 'R=500', 'Color', 'black');
text(10^6, 30, 'R=300', 'Color', 'm');
text(10^6, 27, 'R=200', 'Color', 'g');
title('小信号电流增益随频率变化图像');  
xlabel('频率f/HZ');  
ylabel('小信号电流增益，dB');  
  
end



