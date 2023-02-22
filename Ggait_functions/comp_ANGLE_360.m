function cANGLE=comp_ANGLE_360(xp, yp, xd, yd)

for i=1:size(xp, 1)
    
    if xp(i,1) < xd(i,1)
        cANGLE(i,1)= 180*(atan((-yp(i,1)+yd(i,1))/(xd(i,1)-xp(i,1))))/pi;
        
    elseif xp(i,1) > xd(i,1)& yp(i,1) < yd(i,1)
        cANGLE(i,1)=180*(pi+atan((-yp(i,1)+yd(i,1))/(xd(i,1)-xp(i,1))))/pi;
        
    elseif xp(i,1) > xd(i,1)& yp(i,1) > yd(i,1)
        cANGLE(i,1)=180*(-pi+atan((-yp(i,1)+yd(i,1))/(xd(i,1)-xp(i,1))))/pi;        
    end
    
end