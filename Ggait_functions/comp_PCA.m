function [variance]=comp_PCA(matrice)

X = matrice(:,:);

Y = X-(ones(size(X,1),1)*mean(X)); % center data, i.e. remove mean 
covX = cov(Y); % compute covariance matrix
trace_matrice = trace(covX); % compute trace of covX

[V,L] = eigen(covX); % compute eigenvectors V and eigenvalues L
variance=[L./trace_matrice.*100]'; % normalized eigenvalues