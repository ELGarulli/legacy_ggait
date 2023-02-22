function SumAverage=params_SumAverage_crosscor(SumAverage, ...
    GAITref_left, GAITref_right, GAITref_speed_left, GAITref_speed_right, ...
    GAIT_LHL, GAIT_RHL, GAIT_LHL_speed, GAIT_RHL_speed)

for side=1:2
    
    if side==1;
        GAIT=GAIT_LHL;
        GAIT_speed=GAIT_LHL_speed;
        GAITref=GAITref_left;
        GAITref_speed=GAITref_speed_left;
    else GAIT=GAIT_RHL;
        GAIT_speed=GAIT_RHL_speed;
        GAITref=GAITref_right;
        GAITref_speed=GAITref_speed_right;
    end
    
    for angle=6:10
        [lag, R]=comp_crosscor(GAITref(:,angle),GAIT(:,angle));
        SumAverage(side,47+2*(angle-4)-1:47+2*(angle-4))=[lag, R];
        [lag, R]=comp_crosscor(GAITref_speed(:,angle-4),GAIT_speed(:,angle-4));
        SumAverage(side,57+2*(angle-4)-1:57+2*(angle-4))=[lag, R];
    end
end