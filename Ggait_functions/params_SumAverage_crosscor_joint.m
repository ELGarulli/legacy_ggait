function SumAverage=params_SumAverage_crosscor_joint(SumAverage, GAIT_LHL, ANGLE_LEFT, GAIT_RHL, ANGLE_RIGHT)

% ANGLE_* contains FRAME, TIME and joint angles: Hip, Knee, Ankle, MTP
PTO = 7; % position of time of gait cycle onset in GAIT matrix

for side=1:2
    
    if side==1
        ANGLE=ANGLE_LEFT(find(ANGLE_LEFT(:,2)==min(GAIT_LHL(:,PTO))):find(ANGLE_LEFT(:,2)==max(GAIT_LHL(:,PTO))),3:6);
        duration=max(GAIT_LHL(:,PTO))-min(GAIT_LHL(:,PTO)); 
    else ANGLE=ANGLE_RIGHT(find(ANGLE_RIGHT(:,2)==min(GAIT_RHL(:,PTO))):find(ANGLE_RIGHT(:,2)==max(GAIT_RHL(:,PTO))),3:6);
        duration=max(GAIT_RHL(:,PTO))-min(GAIT_RHL(:,PTO));
    end
    
    for angle=1:4      
        for subangle=1:4
            [lag, R]=comp_crosscor(ANGLE(:,angle),ANGLE(:,subangle));
            SumAverage(side,69+8*(angle-1)+2*subangle-1:69+8*(angle-1)+2*subangle)=[lag, R];
        end       
    end
    SumAverage(side,102)=duration; % duration between first gait cycle onset and last gait cycle onset
end