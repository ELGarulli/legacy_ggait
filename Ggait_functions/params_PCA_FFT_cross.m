function [GAIT] = params_PCA_FFT_cross(GAIT, TIME, ANGLE, angle_R, angle_L, fe)

%PCA - Principal Component Analysis (centered and scaled data).
cycle_n=size(GAIT,1);

for i=1:cycle_n
    
    Ponset = find(TIME==GAIT(i,7)); % position of gait cycle n onset
    Pend = find(TIME==GAIT(i,8)); % position of gait cycle n end
    
    % PCA applied on main set of elevation angles
    temp1=ANGLE(Ponset:Pend,1:5); % select elevation angles
    if isempty(find(isnan(temp1)==1))
        variances=comp_PCA(temp1); % compute PCA and return normalized variances
        GAIT(i,65:65+length(variances)-1)=variances;
    end
    
    % PCA applied on the two limbs
    temp2=angle_R(Ponset:Pend,1:5); % select elevation angles from right limb
    temp3=angle_L(Ponset:Pend,1:5); % select elevation angles from left limb
    if isempty(find(isnan(temp2)==1)) && isempty(find(isnan(temp3)==1))
        variances=comp_PCA([temp2, temp3]);
        GAIT(i,70:73)=variances(1:4);
    end
    
    % FFT applied on elevation angles
    [GAIT(i,80:89), GAIT(i,90:93)]=comp_FFT(ANGLE(Ponset:Pend,1:5), fe);
    
    % Cross correlation on elevation angles and joint angles
    % (circular cross covariance - see comp_cxcov.m)
    [GAIT(i,94:107)]=comp_crosscor_main(ANGLE(Ponset:Pend,1:10));
    
end

