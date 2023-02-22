function TRUNK = comp_KIN_trunk(ShoulderL,ShoulderR,HipL,HipR,CrestL,CrestR)

% return mid-shoulder coordinate, mid-hip coordinate, mid trunk elevation XZ,
% trunk elevation RIGHT,trunk elevation LEFT, shoulder elevation XY, hip_elevation XY

TRUNK(:,1:3)=(ShoulderR + ShoulderL)/2;
TRUNK(:,4:6)=(HipR + HipL)/2;

TRUNK(:,7)= comp_ANGLE_atan2(TRUNK(:,1), TRUNK(:,2),TRUNK(:,4), TRUNK(:,5));
TRUNK(:,8)= comp_ANGLE_atan2(ShoulderR(:,1), ShoulderR(:,2), HipR(:,1), HipR(:,2));
TRUNK(:,9)= comp_ANGLE_atan2(ShoulderL(:,1), ShoulderL(:,2), HipL(:,1), HipL(:,2));
TRUNK(:,10)= 90-comp_ANGLE_atan2(TRUNK(:,4), TRUNK(:,5), TRUNK(:,1), TRUNK(:,2));
TRUNK(:,11)= comp_ANGLE_atan(ShoulderR(:,1), ShoulderR(:,3), ShoulderL(:,1), ShoulderL(:,3));
TRUNK(:,12)= comp_ANGLE_atan(HipR(:,1), HipR(:,3), HipL(:,1), HipL(:,3));
TRUNK(:,13:15)=(CrestR + CrestL)/2;
