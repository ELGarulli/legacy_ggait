function [GAIT_INFO]=create_GAIT_INFO_auto(GAIT_INFO, MARKER, ANGLEleft, ANGLEright)
% GAIT INFO will be (re)built from scratch

TEMPGAIT=[GAIT_INFO(:,2); GAIT_INFO(:,7)];
min_frame=find(MARKER(:,2)==(min(min(TEMPGAIT(find(TEMPGAIT~=0),1)))));
max_frame=find(MARKER(:,2)==(max(max(TEMPGAIT(find(TEMPGAIT~=0),1)))));
GAIT_INFO=[]; 

for side=1:2
    gaitfind=0;
    
    if side==1; ANGLE=ANGLEleft; place=2; end
    if side==2; ANGLE=ANGLEright; place=7; end
    
    i=min_frame;   
    while i< max_frame-1
        i=i+1;
        if ANGLE(i,6)>ANGLE(i-1,6) & ANGLE(i,6)>ANGLE(i+1,6)
            gaitfind=gaitfind+1;
            GAIT_INFO(gaitfind,place)=MARKER(i, 2);
            i=i+80;
        end
    end
    
end

GAIT_INFO(1:size(GAIT_INFO,1),9)=0;