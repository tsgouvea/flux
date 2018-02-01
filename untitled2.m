clear all
close all
clc

% tau = log(.1)/10;

m0 = 35; mN = 10;
% m0 = 76; mN = 3;
mZ = 5;

x = [0:2*mN-1];

% gamma = exp(log(mZ/m0)/(mN-1));
% y = m0 .* exp(x * log(gamma));
y = round(m0 * (mZ/m0).^(x/(mN-1)));

figure('windowstyle','docked'), plot(5*(1+x),y,'o')
hold on
plot(5*(1+x),cumsum(y),'or')
% axis([0 1.1*5*mN 0 1.1*(max(y))])
axis([0 1.1*5*mN 0 1.1*(sum(y))])

round(y)
sum(round(y))
% round(sum(y))