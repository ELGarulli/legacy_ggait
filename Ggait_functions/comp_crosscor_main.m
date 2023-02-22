function [GAIT]=comp_crosscor_main(ANGLE)
%
% Compute Rmax and lag for each ANGLE param using comp_crosscor
%
% INPUT - ANGLE
% OUTPUT - GAIT
%


% ANGLE:
% 1-5: Elevation angles – Crest-Hip; Hip-Knee; Knee-Ankle; Ankle-MTP; MTP-TIP
% (6: Limb axis angle in XY plane – Crest-MTP)
% 7-10: Joint angles – Hip; Knee; Ankle; MTP

if isnan(ANGLE)~=1   
    ANGLE=resample(ANGLE, 100);
    
    for angle=1:4        
        [lag, R]=comp_crosscor(ANGLE(:,angle),ANGLE(:,angle+1));       
        if lag>50; lag=lag-100;end        
        GAIT(1,2*angle-1:2*angle)=[lag, R];        
    end
    
    for angle=7:9        
        [lag, R]=comp_crosscor(ANGLE(:,angle),ANGLE(:,angle+1));        
        if lag>50; lag=lag-100;end       
        GAIT(1,2*(angle-2)-1:2*(angle-2))=[lag, R];       
    end
    
else
    GAIT(1,1:14)=NaN;
end

