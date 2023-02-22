function [DATAresample]=resample(DATA,n)

[n_sample,col]=size(DATA);

X=linspace(0,100,n_sample);
XX=linspace(0,100,n);
for i=1:col
DATAresample(:,i)= spline(X',DATA(:,i),XX');
end