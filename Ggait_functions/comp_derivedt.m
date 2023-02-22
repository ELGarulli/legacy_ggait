function [xd]=comp_derivedt(x, fe)

n=length(x);
dt=1/fe;

xd(1,1)=(x(2,1)-x(1,1))/(dt);
for i=2:n-1  
    xd(1,i)=(x(i+1,1)-x(i-1,1))/(2*dt);
end
xd(1,n)=(x(n,1)-x(n-1,1))/(dt);


