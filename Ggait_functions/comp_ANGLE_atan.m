function theta = comp_ANGLE_atan(x1, y1, x2, y2)
%comp_ANGLE_atan takes the x,y positions of two points
%and returns the elevation angle between the two points
%Inputs:  (x1, y1, x2, y2) and type (foot, leg, thigh, hip, hlimb, flimb)
%Outputs: theta
%
%Note:  (x1, y1) is proximal point;  (x2, y2) is distal point;

diff_x = x2 - x1;
diff_y = y1 - y2;

% angle is computed with respect to the vertical
% - positive in the forward direction
theta= atan(diff_x./diff_y)*180/pi;
