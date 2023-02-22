function SumAverage=params_SumAverage_crosscor_interlimb(SumAverage, GAIT_LHL, ANGLE_LEFT, GAIT_RHL, ANGLE_RIGHT)

% ANGLE_* contains FRAME, TIME, Limb axis angle in XY plane (Crest-MTP) of limb and
% Limb axis angle in XY plane (Crest-MTP) of contra limb
PTO = 7; % position of time of gait cycle onset in GAIT matrix

for side=1:2
    
    if side==1
        ANGLE=ANGLE_LEFT(find(ANGLE_LEFT(:,2)==min(GAIT_LHL(:,PTO))):find(ANGLE_LEFT(:,2)==max(GAIT_LHL(:,PTO))),3:4);
        duration=max(GAIT_LHL(:,PTO))-min(GAIT_LHL(:,PTO));
    else ANGLE=ANGLE_RIGHT(find(ANGLE_RIGHT(:,2)==min(GAIT_RHL(:,PTO))):find(ANGLE_RIGHT(:,2)==max(GAIT_RHL(:,PTO))),3:4);
        duration=max(GAIT_RHL(:,PTO))-min(GAIT_RHL(:,PTO));
    end
    
    [lag, Rmin, R0]=comp_crosscor_Rmin(ANGLE(:,1),ANGLE(:,2));
    SumAverage(side,103:104)=[lag, Rmin];
    SumAverage(side, 105)=duration; % duration between first gait cycle onset and last gait cycle onset
    SumAverage(side, 106)=R0; % correlation (no time shift)
    
    limb1=mean(comp_fourier(ANGLE(:,1), 100, 3))/pi*180; % mean phase of limb axis angle
    limb2=mean(comp_fourier(ANGLE(:,2), 100, 3))/pi*180; % mean phase of limb axis angle
    
    SumAverage(side, 107)=abs(limb1-limb2); % absolute diff between mean phases
end