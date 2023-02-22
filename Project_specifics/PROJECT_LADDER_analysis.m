function [GAIT_RHL, GAIT_LHL]=PROJECT_LADDER_analysis(mkr, GAIT_INFO, GAIT_LHL, GAIT_RHL, ...
    TIME, PATHNAME, FILENAME, right)

filename=strcat(PATHNAME,FILENAME);

if exist(strcat(filename(1:end-4),'_GAIT_LADDER_R','.mat'),'file')==2
    load(strcat(filename(1:end-4),'_GAIT_LADDER_R','.mat'))
    GAIT_RHL(1:size(posizione_Foot,1),181:183)=posizione_Foot(:,1:3);
    clear posizione_Foot;
else
    [GAIT_RHL]=PROJECT_LADDER_comp(GAIT_RHL, GAIT_INFO, mkr, 7, TIME, PATHNAME, FILENAME);
end

if ~right %markers also on left side
    if exist(strcat(filename(1:end-4),'_GAIT_LADDER_L','.mat'),'file')==2,
        load(strcat(filename(1:end-4),'_GAIT_LADDER_L','.mat'))
        GAIT_LHL(1:size(posizione_Foot,1),181:183)=posizione_Foot(:,1:3);
        clear posizione_Foot;
    else
        [GAIT_LHL]=PROJECT_LADDER_comp(GAIT_LHL, GAIT_INFO, mkr, 2, TIME, PATHNAME, FILENAME);
    end
else
    GAIT_LHL(:,181:183)=NaN;
end

