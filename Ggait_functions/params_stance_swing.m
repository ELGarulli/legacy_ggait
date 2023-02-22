function [matrix_stance_swing, matrix_stance_swing_force]=params_stance_swing(GAIT_INFO, GAIT_INFO_FORELIMB, time, FORCE)

matrix_stance_swing(:,1)=time(find(time(:, 2)==min(min(GAIT_INFO(find(GAIT_INFO(:,2)~=0),2)), min( GAIT_INFO(find(GAIT_INFO(:,7)~=0),7)))):...
    find(time(:, 2)==max(max(GAIT_INFO(:,2)),max(GAIT_INFO(:,7)))),2);
matrix_stance_swing(:,2:3)=0;


if isempty(FORCE)
    matrix_stance_swing_force=[];
else
    matrix_stance_swing_force(:,1)=FORCE(find(FORCE(:, 2)==min(min(GAIT_INFO(find(GAIT_INFO(:,2)~=0),2)), min( GAIT_INFO(find(GAIT_INFO(:,7)~=0),7)))):...
        find(FORCE(:, 2)==max(max(GAIT_INFO(:,2)), max(GAIT_INFO(:,7)))), 2);
    matrix_stance_swing_force(:,2:3)=0;
end


for side=1:2
    
    if side==1;position=2;end % LEFT STANCE in GAIT_INFO
    if side==2;position=7;end % RIGHT STANCE in GAIT_INFO
    
    for cycle=1:size(GAIT_INFO, 1)-1
        
        if    isnan(GAIT_INFO(cycle,position))~=1 & GAIT_INFO(cycle,position)~=0 ...
                & isnan(GAIT_INFO(cycle+1,position))~=1 & GAIT_INFO(cycle+1,position)~=0
            
            i=find(matrix_stance_swing(:,1)==GAIT_INFO(cycle,position));
            while  matrix_stance_swing(i,1)<=GAIT_INFO(cycle, position+1)
                matrix_stance_swing(i,1+side)=1;
                i=i+1;
            end
            
            if ~isempty(FORCE)
                j=find(matrix_stance_swing_force(:,1)==GAIT_INFO(cycle,position));
                while  matrix_stance_swing_force(j,1)<=GAIT_INFO(cycle, position+1)
                    matrix_stance_swing_force(j,1+side)=1;
                    j=j+1;
                end
            end
        end
    end
end

if ~isempty(GAIT_INFO_FORELIMB)    
    for side=1:2
        if side==1;position=2;end  % LEFT STANCE in GAIT_INFO
        if side==2;position=7;end  % RIGHT STANCE in GAIT_INFO
        
        for cycle=1:size(GAIT_INFO_FORELIMB, 1)-1
            if isnan(GAIT_INFO_FORELIMB(cycle,position))~=1 & GAIT_INFO_FORELIMB(cycle,position)~=0 ...
                    & isnan(GAIT_INFO_FORELIMB(cycle+1,position))~=1 & GAIT_INFO_FORELIMB(cycle+1,position)~=0
                
                i=find(matrix_stance_swing(:,1)==GAIT_INFO_FORELIMB(cycle,position));
                while  matrix_stance_swing(i,1)<=GAIT_INFO_FORELIMB(cycle, position+1)
                    matrix_stance_swing(i,3+side)=1;
                    i=i+1;
                end
            end
        end
    end
end
