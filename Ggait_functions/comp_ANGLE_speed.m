function anglespeed=comp_ANGLE_speed(angle, fe)

for i=1:size(angle,2)    
    anglespeed(:,i)=comp_derivedt(angle(:,i), fe);
end