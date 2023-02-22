function [lag, R, R0]=comp_crosscor_Rmin(X, Y)
%
% Normalized circular cross correlation
% 
% INPUT - X, Y (two signals assumed to be same length)
% OUTPUT:
%    - lag : # indices to shift Y from X to get minimal corr value
%    - R : minimal correlation value
%    - R0: correlation value when no time shift
%

[llag, RR]=comp_cxcov( X', Y');

R0=RR(1,1);
[R Rmin_ind]=min(RR);
lag=llag(Rmin_ind);