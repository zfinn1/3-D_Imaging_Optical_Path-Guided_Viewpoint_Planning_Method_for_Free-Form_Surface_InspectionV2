close all;
clear all;

f=logspace(5,12,1000);%将f在10^5~10^12范围内将其分为1000点的等比数列
w=2*pi.*f;%转换为角频率
C=5/(10^12);%寄生电容5pf
L_ex=52/(10^9);%外部电感52nh
R=2000;%电阻2k欧姆

Z1=complex(1/R,C.*w);%模拟电荷分布与电阻并联的导纳
Z2=1./Z1; 

z1=complex(0,L_ex.*w);%引线电感
z=z1+Z2;

y=abs(z);
y1=10*log(y);
h=angle(z);
figure;
subplot(2,1,1);
loglog(f,y); 
xlabel('f');  
ylabel('|Z|');
title("幅频响应");
subplot(2,1,2);
semilogx(f,h); 
xlabel('f');  
ylabel('angle');
title("相频响应");
% subplot(2,1,1);
% semilogx(f,y1); 
% xlabel('f');  
% ylabel('|Z|');
% title("幅频响应");


