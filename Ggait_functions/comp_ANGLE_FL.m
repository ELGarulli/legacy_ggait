function ANGLE=comp_ANGLE_FL(DATA, TRUNK)
%
% INPUT - [Scap, Shoulder, Elbow, Wrist, Toe], ELEV Trunk
% OUTPUT - ANGLE
%
% Calculate following angles:
%    - ELEVATION ANGLE 1:4 proximal to distal: Scapula, Arm, Forearm, Hand
%    - LIMB AXIS ANGLE
%    - JOINT ANGLE 7:10 proximal to distal: Scap, Shoulder, Elbow, Wrist
%    - LATERAL angle of limb axis Forelimb_LAT

ANGLE = zeros(size(DATA,1),12);

for segment=1:4
    % comp_ANGLE_atan2(X val of joint, Y val of joint, X val of next joint, Y val of next joint)
    ANGLE(:,segment)= comp_ANGLE_atan2(DATA(:,3*segment-2), DATA(:,3*segment-1), ...
        DATA(:,3*(segment+1)-2), DATA(:,3*(segment+1)-1));
end

% comp_ANGLE_atan2(X val of Scap, Y val of Scap, X val of Wrist, Y val of Wrist)
ANGLE(:,6)= comp_ANGLE_atan2(DATA(:,1), DATA(:,2), DATA(:,10), DATA(:,11)); % limb axis angle in XY plane

ANGLE(:,7)=180-ANGLE(:,1)+TRUNK(:,1); % SCAP (Scap-Shoulder elevation and Trunk elevation)
ANGLE(:,8)=180-(ANGLE(:,1)-ANGLE(:,2)); % SHOULDER
ANGLE(:,9)=180-(ANGLE(:,2)-ANGLE(:,3)); % ELBOW
ANGLE(:,10)=180-(ANGLE(:,3)-ANGLE(:,4)); % WRIST

% comp_ANGLE_atan2(Z val of Scap, Y val of Scap, Z val of Elbow, Y val of Elbow)
ANGLE(:,11)= comp_ANGLE_atan2(DATA(:,3), DATA(:,2), DATA(:,9), DATA(:,8)); % limb axis angle in YZ plane
