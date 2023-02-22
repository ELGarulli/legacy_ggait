%% Plot STANCE / DRAG / SWING ratio
function patch_StanceDragSwing(GAIT, offet)

PSD = 17; % position of stance duration (in percent of gait cycle duration) in GAIT matrix
PDD = 64; % position of drag duration (in percent of gait cycle duration) in GAIT matrix

patch([offet+0, offet+0, offet+mean(GAIT(:,PSD)), offet+mean(GAIT(:,PSD))], [0, 1, 1, 0],[0.5 0.5 0.5]);axis tight
patch([offet+mean(GAIT(:,PSD))-std(GAIT(:,PSD)), offet+mean(GAIT(:,PSD))-std(GAIT(:,PSD)), offet+mean(GAIT(:,PSD)), offet+mean(GAIT(:,PSD))], [0.5, 0.5, 0.5, 0.5],[0 0 0]);axis tight
patch([offet+mean(GAIT(:,PSD)), offet+mean(GAIT(:,PSD)), offet+mean(GAIT(:,PSD))+(100-mean(GAIT(:,PSD)))*mean(GAIT(:,PDD))/100, offet+mean(GAIT(:,PSD))+(100-mean(GAIT(:,PSD)))*mean(GAIT(:,PDD))/100], [0, 1, 1, 0],[1 0 0]);axis tight
patch([offet+mean(GAIT(:,PSD))+(100-mean(GAIT(:,PSD)))*mean(GAIT(:,PDD))/100, offet+mean(GAIT(:,PSD))+(100-mean(GAIT(:,PSD)))*mean(GAIT(:,PDD))/100,offet+mean(GAIT(:,PSD))+(100-mean(GAIT(:,PSD)))*mean(GAIT(:,PDD))/100+(100-mean(GAIT(:,PSD)))*std(GAIT(:,PDD))/100, offet+mean(GAIT(:,PSD))+(100-mean(GAIT(:,PSD)))*mean(GAIT(:,PDD))/100+(100-mean(GAIT(:,PSD)))*std(GAIT(:,PDD))/100], [0.5, 0.5, 0.5, 0.5],[0.2 0.2 0.2]);axis tight
