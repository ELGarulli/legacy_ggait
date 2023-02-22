%% Batch calculation of firing rates over time
%   All extracted/ reported times are on the TDT internal clock.

% Run next line once then comment out
%mex bin_genV.c
% !! bin_genV.c should be rewritten with better security and more straightforward output. 2/4/10

%%              Variables
% spikeTimes:   matrix of firing times. Each column is one 'unit'. Times 
%               are recorded down the rows in ascending order. To map 
%               columns to units, use the 'index' variable.
% t1, t2:       times used to extract data from TDT tank. 
% vicon:        index of start (row 2 = 1) and stop (row 2 = 0) times. 

%%              Outputs
% x:    matrix of spike bins. Each column is a unit. Each row is average
%       firing rate during one binSize.^
% t:    time index of each row. Averaging is done in the 'binSize' seconds
%       before the time index

%%              Bin size parameter
binSize = 0.1; % Bin size in seconds. MUST BE < 1

%%              Convert spikeTimes to binned FR
x = making_bins(spikeTimes, t1, t2, binSize);
t = [0: binSize : (t2-t1)] + t1;