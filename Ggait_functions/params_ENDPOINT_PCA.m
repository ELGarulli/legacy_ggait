function [GAIT_SUM]=params_ENDPOINT_PCA(GAITLEFT, GAITRIGHT, DATALEFT, DATARIGHT)

% DATALEFT and DATARIGHT contain 3D position of MTP marker (left or right resp.)
PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix

% loop for PCA
for side=1:2
    
    PCAx=[];
    PCAy=[];
    PCAz=[];
    
    if side==1, subGAITin=GAITLEFT; DATA=DATALEFT;
    else      subGAITin=GAITRIGHT; DATA=DATARIGHT;
    end
    
    for nsteps=1:size(subGAITin, 1)
        pos_index = find(DATA(:,1)==subGAITin(nsteps, PTO)):find(DATA(:,1)==subGAITin(nsteps, PTE));
        PCAx(1:100, nsteps)=resample(DATA(pos_index, 2), 100); % X MTP
        PCAy(1:100, nsteps)=resample(DATA(pos_index, 3), 100); % Y MTP
        PCAz(1:100, nsteps)=resample(DATA(pos_index, 4), 100); % Z MTP
    end
    
    % PCA
    GAIT_SUM(side, 1:5)=subGAITin(1, 1:5);
    
    X=comp_PCA(PCAx);
    Y=comp_PCA(PCAy);
    Z=comp_PCA(PCAz);
    GAIT_SUM(side, 6)=X(1,1); 
    GAIT_SUM(side, 7)=Y(1,1);
    GAIT_SUM(side, 8)=Z(1,1);
    GAIT_SUM(side, 9)=mean((GAIT_SUM(side, 6:7)));
    GAIT_SUM(side, 10)=mean((GAIT_SUM(side, 6:8)));
    
end % side loop