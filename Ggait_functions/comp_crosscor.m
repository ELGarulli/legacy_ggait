function [lag, R]=comp_crosscor(X, Y)
%
% Normalized circular cross correlation
% 
% INPUT - X, Y (two signals assumed to be same length)
% OUTPUT:
%    - lag : # indices to shift Y from X to get maximal absolute corr value
%    - R : maximal absolute correlation value
%

[llag, RR]=comp_cxcov(X', Y');

[R R_index] = max(abs(RR));
lag = llag(R_index);