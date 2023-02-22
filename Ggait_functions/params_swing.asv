function [GAIT_INFO]=params_swing(GAIT_INFO, TIME, ANGLEleft, ANGLEright)
% SWING is defined as starting when limb axis angle is minimal

n_cycle=0;
GAIT=[];
n=size(GAIT_INFO, 1);

for side=1:2
    
    if side==1;
        position=2; % LEFT STANCE in GAIT_INFO      
        ANGLE=ANGLEleft;
    end
    if side==2;
        position=7; % RIGHT STANCE in GAIT_INFO
        ANGLE=ANGLEright;
    end
    var=6; % limb axis in ANGLE
    
    for i=1:n-1
        
        if   isnan(GAIT_INFO(i,position))~=1 & GAIT_INFO(i,position)~=0 ...
                & isnan(GAIT_INFO(i+1,position))~=1 & GAIT_INFO(i+1,position)~=0
            
            onset=find(TIME(:,2)==GAIT_INFO(i,position));% frame of stance onset
            fin=find(TIME(:,2)==GAIT_INFO(i+1,position)); % frame of next stance onset
            
            % extract gait cycle
            TIMEtemp=[]; ANGLEtemp=[];
            TIMEtemp=TIME(onset:fin,:);
            ANGLEtemp=ANGLE(onset:fin,:);
            [min_angle time_stance]=min(ANGLEtemp(:,var)); 
            if time_stance<size(TIMEtemp,1)-6
                GAIT_INFO(i,position+1)=TIMEtemp(time_stance,2); %frame of forward movement onset
            else
                GAIT_INFO(i,position+1)=TIMEtemp(time_stance-6,2); %frame of forward movement onset
            end
        end
    end
end
