function ANGLE=comp_ANGLE(DATA, TRUNK)
%
% INPUT - [Crest, Hip, Knee, Ankle, MTP, TIP], ELEV Trunk
% OUTPUT - ANGLE
%
% Calculate following angles:
%    - ELEVATION ANGLE 1:5, proximal to distal: Crest, Thigh, Leg, Foot, Toe 
%    - LIMB AXIS ANGLE
%    - JOINT ANGLE 7:10, proximal to distal: Hip, Knee, Ankle, MTP
%    - LATERAL ANGLE of limb axis
%    - ROTATIONAL ANGLE of limb axis

ANGLE = zeros(size(DATA,1),12);

for segment=1:5
    % comp_ANGLE_atan2(X val of joint, Y val of joint, X val of next joint, Y val of next joint)
    ANGLE(:,segment)= comp_ANGLE_atan2(DATA(:,3*segment-2), DATA(:,3*segment-1), ...
                                  DATA(:,3*(segment+1)-2), DATA(:,3*(segment+1)-1));
end

% comp_ANGLE_atan2(X val of Crest, Y val of Crest, X val of MTP, Y val of MTP)
ANGLE(:,6)= comp_ANGLE_atan2(DATA(:,1), DATA(:,2), DATA(:,13), DATA(:,14)); % limb axis angle in XY plane

ANGLE(:,7)=180-ANGLE(:,2)+TRUNK(:,1); %HIP (Hip-Knee elevation and Trunk elevation, NOT Crest-Hip)
ANGLE(:,8)=180-ANGLE(:,2)+ANGLE(:,3); % KNEE
ANGLE(:,9)=180-ANGLE(:,4)+ANGLE(:,3); % ANKLE
ANGLE(:,10)=180+ANGLE(:,5)-ANGLE(:,4); % MTP

% comp_ANGLE_atan2(Z val of Crest, Y val of Crest, Z val of MTP, Y val of MTP)
ANGLE(:,11)= comp_ANGLE_atan2(DATA(:,3), DATA(:,2), DATA(:,15), DATA(:,14)); % limb axis angle in YZ plane

% comp_ANGLE_atan2(X val of Ankle, Z val of Ankle, X val of TIP, Z val of TIP)
ANGLE(:,12)= comp_ANGLE_360(DATA(:,10), DATA(:,12), DATA(:,16), DATA(:,18)); % foot angle in XZ plane
