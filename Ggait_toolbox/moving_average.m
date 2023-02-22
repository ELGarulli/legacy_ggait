function [ y ] = moving_average(x, M)

% apply a moving average filter - window width = m  

B = ones(M,1)/M;
y = filter(B,1,x);