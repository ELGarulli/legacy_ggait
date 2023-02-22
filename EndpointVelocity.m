%% Notes
% X axis = forward axis
% Y axis = vertical axis
% MTP pos = MTP marker position in space
% dMTP = time derivation of MTP pos
% PSO = swing onset
% posPSO = position in the matrix corresponding to swing onset

%% To calculate endpoint velocity:
% compute time derivative of MTP pos (dMTP)
% find time of swing onset (posPSO)
% choose the time window size (in Ggait = 5% of gait cycle)
% range = PSO:(PSO + window size)
% velocity at swing onset is simply: mean(sqrt(dMTP(range,X).^2+dMTP(range,Y).^2)))

% -> cf line 71 in params_ENDPOINT.m

%% To draw black arrow
% Xdata = [MTP pos on X axis at PSO, MTP pos on X axis at PSO + dMTP on X axis at PSO]
% Ydata = [MTP pos on Y axis at PSO, MTP pos on Y axis at PSO + dMTP on Y axis at PSO]

% -> cf line 97-98 in params_ENPOINT.m