clear all
syms  a b m g w k y P l L Z C
%a=Rbe b=Cbe m=Cbc g=gm k=Rce P=β L=L  C=C

base=1+1i*w*(b+m)*a;
h11=a/base;
h12=1i*w*a*m/base;
h21=a*(g-1i*w*m)/base;
h22=1/k+1i*w*m*a*g/base+1i*w*m*(1+1i*w*a*b)/base;
exper1=[h11 h12;h21 h22]; %BJT的H矩阵

y11=1/h11;
y12=-h12/h11;
y21=h21/h11;
y22=(h11*h22-h12*h21)/h11;
simplified_y22 = simplify(y22);%简化y22
exper2=[y11 y12;y21 simplified_y22]; %将BJT的H矩阵转换为Y矩阵

exper3=[y -y;-y y];%电阻的y矩阵

exper4=exper2+exper3;  %将BJT的Y矩阵与电阻的Y矩阵相加
Y11=exper4(1,1);
Y12=exper4(1,2);
Y21=exper4(2,1);
Y22=exper4(2,2);

A=-Y22/Y21;
B=-1/Y21;
C=-(Y11*Y22-Y21*Y12)/Y21;
D=-Y11/Y21;
exper6=[A B;C D];  %将BJT与电阻并联的Y矩阵转换为A参量矩阵
% simplified_C = simplify(C);

%exper1p=transpose(exper1);
% disp(simplified_C);

exper5=[cos(P*l) 1i*Z*sin(P*l);1i*sin(P*l)/Z cos(P*l)];%输入矩阵

exper7=[1-(w^2)*L*C 2i*w*L-1i*(w^3)*(L^2)*C;1i*w*C 1-(w^2)*L*C];%输出矩阵

experall=exper5*exper6*exper7;
Handlap(1,1)= simplify(experall(1,1));%简化总A参量矩阵
Handlap(1,2)= simplify(experall(1,2));
Handlap(2,1)= simplify(experall(2,1));
Handlap(2,2)= simplify(experall(2,2));

% syms  a b m g w k y P l L Z C
% %a=Rbe b=Cbe m=Cbc g=gm w=2*pi*f k=Rce y=1/R P=βl为线长 L=L Z=Z0 C=C
f=10^6;%HZ

Handlap_numeric= subs(Handlap, {a,b,m,g,w,k,y,P,l,L,Z,C}, {520, 10*(10^(-12)), 1*(10^(-12)),0.192,2*pi*f,80*10^3,1*(10^(-3)),2*pi*f/(0.65*3*10^8),0.05,1*(10^(-9)),50,10*(10^(-12))});
result_vpa = vpa(Handlap_numeric(2,2)^(-1),3);
% 尝试简化表达式  
 % 显示简化后的表达式




