function theta = comp_ANGLE_atan2(x1, y1, x2, y2)
%comp_ANGLE_atan2 takes the x,y positions of two points
%and returns the elevation angle between the two points
%
%Inputs:  (x1, y1, x2, y2) and type (foot, leg, thigh, hip, hlimb, flimb)
%Outputs: theta
%
%Note:  (x1, y1) is proximal point;  (x2, y2) is distal point;

diff_x = x2 - x1;
diff_y = y1 - y2;

%theta = 4 quadrant inv tan of diffx, diffy in rads
%theta positive in direction of swing (x positive)
theta = atan2(diff_x, diff_y)*180/pi;