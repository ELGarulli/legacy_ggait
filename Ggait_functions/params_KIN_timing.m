function GAIT=params_KIN_timing(GAIT, TIME, ANGLE)

PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix

for n_cycle=1:size(GAIT,1)
    
    % extract elevation angles (Crest-Hip; Hip-Knee; Knee-Ankle; Ankle-MTP; MTP-TIP) during gait cycle n  
    ANGLEtemp=[];
    ANGLEtemp=ANGLE(find(TIME==GAIT(n_cycle,PTO)):find(TIME==GAIT(n_cycle,PTE)),1:5);
    size_angle = size(ANGLEtemp,1);
    
    [noneed posMAX]=max(ANGLEtemp);
    [noneed posMIN]=min(ANGLEtemp);
    
    for angle=1:4  
        
        param= 145+(angle-1)*2;
        
        diffMIN = (posMIN(angle)-posMIN(angle+1))/size_angle*100;
        
        if    diffMIN >  50,  GAIT(n_cycle, param)=100-diffMIN;          
        elseif diffMIN < -50,  GAIT(n_cycle, param)=-100-diffMIN;            
        else               GAIT(n_cycle, param)=diffMIN;
        end
        
        diffMAX = (posMAX(angle)-posMAX(angle+1))/size_angle*100;
        
        if    diffMAX >  50,  GAIT(n_cycle, param+1)=100-diffMAX;           
        elseif diffMAX < -50,  GAIT(n_cycle, param+1)=-100-diffMAX;            
        else                GAIT(n_cycle, param+1)=diffMAX;
        end
        
    end
end

