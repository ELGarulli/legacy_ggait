function SumAverage=params_SumAverage_variability(SumAverage, gaitL, gaitR)

for side=1:2
    
    if side==1;
        gait=gaitL(:,13:24)-gaitL(:,1:12); % retrieve SD alone
    else gait=gaitR(:,13:24)-gaitR(:,1:12); % retrieve SD alone
    end
    
    for angle=1:12
        SumAverage(side,37+angle)=mean(gait(:,angle));
    end    
end
