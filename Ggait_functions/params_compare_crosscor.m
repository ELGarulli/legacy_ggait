function GAIT=params_compare_crosscor(GAIT, GAITref, LIMB, LIMBcontra, FORELIMBipsi, FORELIMBcontra)

% position of "Limb axis angle in XY plane – Crest-MTP" (hindlimb)
% or "Limb axis angle in XY plane – Scap-Wrist" (forelimb) in ANGLE matrices
posAxis = 6;

for i=1:size(GAIT,1)
    
    pos_index = find(LIMB(:,2)==GAIT(i,7)):find(LIMB(:,2)==GAIT(i,8));
    ANGLEtemp=LIMB(pos_index,3:size(LIMB,2));
    ANGLEtemp=resample(ANGLEtemp, 100);
    
    if ~isempty(FORELIMBipsi)
        LIMBtemp=[LIMBcontra(pos_index,posAxis), FORELIMBipsi(pos_index,posAxis), FORELIMBcontra(pos_index,posAxis)];
        nlimb=3;
    else
        LIMBtemp=LIMBcontra(pos_index,posAxis);
        nlimb=1;
    end
    LIMBtemp=resample(LIMBtemp, 100);
    
    for limb=1:nlimb
        
        % Normalized circular cross correlation
        [lag, ~, R0] = comp_crosscor_Rmin(ANGLEtemp(:,posAxis),LIMBtemp(:,limb));
        
        if lag<50,  GAIT(i,73+2*limb-1) = lag;
        else GAIT(i,73+2*limb-1) = lag-100;
        end
        GAIT(i,73+2*limb) = R0;
    end
    
    for angle=6:10 % 6: Limb axis angle in XY plane – Crest-MTP / Scap-Wrist
                % 7-10: Joint angles – Hip, Knee, Ankle, MTP / Scap, Shoulder, Elbow, Wrist

        % Normalized circular cross correlation
        [lag, R] = comp_crosscor_Rmin(GAITref(:,angle),ANGLEtemp(:,angle));
        
        if lag<50, GAIT(i,134+2*(angle-5)-1:134+2*(angle-5)) = [lag, R];
        else GAIT(i,134+2*(angle-5)-1:134+2*(angle-5)) = [lag-100, R];
        end
    end
end

