function sum=params_SumAverage_speed(animal, cond1, cond2, speed, dataL, dataR)

for side=1:2
    
    if side==1; 
        data=dataL; 
    else data=dataR;
    end
    
    sum(side,1)=animal; % animal iD
    sum(side,2)=cond1-1; % index of condition 1
    sum(side,3)=cond2-1; % index of condition 2
    sum(side,4)=side; % limb side (left=1; right=2)
    sum(side,5)=speed; % treadmill speed
    
    for joint=1:8     
        sum(side,5+4*joint-3)=min(data(:,joint)); % min of param
        sum(side,5+4*joint-2)=max(data(:,joint)); % max of param
        sum(side,5+4*joint-1)=max(data(:,joint))-min(data(:,joint)); % max amplitude of param
        sum(side,5+4*joint)=mean(abs(data(:,joint))-min(data(:,joint))); % mean amplitude of param
    end
end
