Z0=50;
Z_L=[20 20 50 50];
Z_G=[10 50 10 50];
Pin=[0 0 0 0];
beta=2*pi;
k = linspace(0, 1.5, 100);
k1=1.5;
for m=1:length(Z_L)
FL=(Z_L(m)-Z0)/(Z_L(m)+Z0);
Fg=(Z_G(m)-Z0)/(Z_G(m)+Z0);
V_g=1;

U=(V_g*Z0/(Z_G(m)+Z0))*(exp(-1i*beta*k1))/(1-Fg*FL*exp(-1i*beta*k1));

U1=U.*exp(1i*beta*k).*(1+FL*exp(-2i*beta*k));
I1=U.*exp(1i*beta*k).*(1-FL*exp(-2i*beta*k))./Z0;
Pin(m)=1/8*(V_g^2)/Z0*((abs(1-Fg))^2)*((abs(1-FL))^2)/(abs(1-FL*Fg*exp(-2i*beta*1.5))^2);
figure;
subplot(4,1,1);
plot(k,abs(U1));
title("U的幅度分布");
subplot(4,1,2);
plot(k,angle(U1));
title("U的相位分布");
subplot(4,1,3);
plot(k,abs(I1));
title("I的幅度分布");
subplot(4,1,4);
plot(k,angle(I1));
title("I的相位分布");
end