clc;
clear all;
close all;
% syms  R_be C_be   C_bc     g_m    R_ce   y l L Z C f
%Rbe   b=Cbe m=Cbc g=gm k=Rce  L=L  C=C
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

N=100;
% fmin=1e4;
% fmax=1e9;
% f=fmin*((fmax/fmin).^((0:N)/N));
f=logspace(4,8.5,100);

w=2*pi*f;

base=1+1i*w*(C_be+C_bc)*R_be;
h11=R_be./base;
h12=1i*w*R_be*C_bc./base;
h21=R_be.*(g_m-1i*w*C_bc)./base;
h22=1/R_ce+1i*w.*C_bc.*(1+g_m.*R_be+1i*w*C_be*R_be)./base;
feedback=[1e-4 1e-3 2*1e-3 1/300 1/200]; %

for k=1:length(feedback)
y=feedback(k);
Y11=1./h11+y;
Y12=-h12./h11-y;
Y21=h21./h11-y;
Y22=(h11.*h22-h12.*h21)./h11+y;
exper2=[Y11 Y12;Y21 Y22];

% exper3=[y -y;-y y];%电阻的y矩阵
% exper4=exper2;
% % exper4=exper2+exper3;  %将BJT的Y矩阵与电阻的Y矩阵相加
% y11=exper2(1,1);
% y12=exper2(1,2);
% y21=exper2(2,1);
% y22=exper2(2,2);
% 
% A=-y22./y21;
% B=-1./y21;
% C=-(y11.*y22-y21.*y12)./y21;
% D=-y11./y21;
% exper6=[A;B;C;D];  

exper6=[-Y22./Y21;-1./Y21;-(Y11.*Y22-Y12.*Y21)./Y21;-Y11./Y21];
% exper6=[-Y22./Y21 -1./Y21;-(Y11.*Y22-Y12.*Y21)./Y21 -Y11./Y21];
P=w/v;

exper5=[cos(P*l);1i*Z*sin(P*l);1i*sin(P*l)/Z;cos(P*l)];%输入矩阵
% exper5=[cos(P*l) 1i*Z*sin(P*l);1i*sin(P*l)/Z cos(P*l)];%输入矩阵

exper7=[1-(w.^2).*L.*C;2i.*w.*L-1i.*(w.^3).*(L.^2).*C;1i.*w.*C;1-(w.^2).*L.*C];%输出矩阵
% exper7=[1-(w.^2).*L.*C 2i.*w.*L-1i.*(w.^3).*(L.^2).*C;1i.*w.*C 1-(w.^2).*L.*C];%输出矩阵

[ABCD_temp11,ABCD_temp12,ABCD_temp21,ABCD_temp22]=special_multiply(exper5,exper6);
ABCD_temp=[ABCD_temp11;ABCD_temp12;ABCD_temp21;ABCD_temp22];
[ABCD_11,ABCD_12,ABCD_21,ABCD_22]=special_multiply(ABCD_temp,exper7);
% experall=exper5*exper6*exper7;
% ABCD_22=experall(2,2);
semilogx(f,-20*log10(abs(ABCD_22)));
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



function [c11,c12,c21,c22]=special_multiply(a,b)
c11=a(1,:).*b(1,:)+a(2,:).*b(3,:);
c12=a(1,:).*b(2,:)+a(2,:).*b(4,:);
c21=a(3,:).*b(1,:)+a(4,:).*b(3,:);
c22=a(3,:).*b(2,:)+a(4,:).*b(4,:);
end
