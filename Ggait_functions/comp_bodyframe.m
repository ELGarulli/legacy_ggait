function [body_frame_g base_point_g success] = comp_bodyframe(body_points)
% 
% Calculate the transformation frame for a 4-point body in the global reference frame
%
% USAGE:
%   [body_frame_g base_point_g success] = comp_bodyframe(body_points)
% INPUTS:
%    body_points: a row vector with 3-element points: [rear_point_1_g rear_point_2_g front_point_1_g front_point_2_g]
% OUTPUTS:
%    body_frame_g: a 4x4 transformation matrix corresponding to the body in the reference (most likely global) coordinate frame
%    base_point_g: the base point in the reference (most likely global) coordinate frame
%    success: whether there were no errors and the transformation is likely to be valid (1 = no errors, < 1 = errors)

success = 0;
body_frame_g = eye(4);
base_point_g = [0;0;0];
rear_point_1_g = body_points(1,1:3)';
rear_point_2_g = body_points(1,4:6)';
front_point_1_g = body_points(1,7:9)';
front_point_2_g = body_points(1,10:12)';

if (sum(abs(rear_point_1_g)) ~= 0) & (sum(abs(rear_point_2_g))  ~= 0)...
       & (sum(abs(front_point_1_g)) ~= 0) & (sum(abs(front_point_2_g)) ~= 0)
    base_point_g = (rear_point_1_g+rear_point_2_g)/2;
    term_point_g = (front_point_1_g+front_point_2_g)/2;
    side1_vector_g = front_point_1_g - base_point_g;
    side2_vector_g = front_point_2_g - base_point_g;
    base_term_g = term_point_g - base_point_g;
    if ~(norm(cross(side1_vector_g,side2_vector_g)) == 0)
        normal_Z = cross(side1_vector_g,side2_vector_g)/norm(cross(side1_vector_g,side2_vector_g));
        normal_Y = cross(normal_Z,base_term_g)/norm(cross(normal_Z,base_term_g));
        normal_X = cross(normal_Y,normal_Z);
        body_frame_g = [normal_X normal_Y normal_Z];
        body_frame_g = [body_frame_g base_point_g(1:3);0 0 0 1];
        success = 1;
    else
        success = -1;
    end
else
    success = -2;
end