function [GAIT, GAIT_INFO]=params_gait(GAIT_INFO, GAIT_INFO_FL, side, ...
                                animal, cond1, cond2, speed, BWS, ...
                                MARKER_KIN, MTP_contra, ...
                                ANGLE,  TRUNK, ANGLE_SPEED, TRUNK_SPEED, ...
                                GAIT_SS, FORCE, FORCE_SS, ...
                                is_swing)
%% params_gait(...) compute various gait parameters based on KINEMATIC data and experimental conditions specifications
%
% INPUTS:
% - GAIT_INFO       [Sx9 double], times of right and left stance, swing and drag events (hindlimbs)
% - GAIT_INFO_FL	[Sx9 double], times of right and left stance, swing and drag events (forelimbs)
% - side            [double] side of interest (1: left; 2: right)
% - animal          [double] animal iD
% - cond1           [double] index of experimental condition 1 (e.g. post-lesion timing)
% - cond2           [double] index of experimental condition 2 (e.g. testing type)
% - speed           [double] treadmill speed
% - BWS             [double] body weight support (in percent)
% - MARKER_KIN      [Sx20 double] kinematic data (3D position of markers on crest, hip, knee, ankle, MTP, TIP)
% - MTP_contra      [Sx3 double] 3D position of contralateral MTP
% - ANGLE           [Sx12 double] angle data (elevation, limb axis and joint angles)
% - ANGLE_SPEED     [Sx12 double] angle velocity data (elevation, limb axis and joint angles)
% - TRUNK           [Sx15] angle data about shoulder, crest, hip and trunk (coordinates and elevation)
% - TRUNK_SPEED     [Sx15] angle velocity data about shoulder, crest, hip and trunk (coordinates and elevation)
% - GAIT_SS         [Sx3] time and side when stance happened
% - FORCE           [Sx8] time, forces and moments on X, Y, Z axes
% - FORCE_SS        [Sx3] time and side when force is applied
% - is_swing        bool, true if swing params are in GAIT_INFO
%
% OUTPUTS:
% - GAIT            [Sx189 double] various gait parameters
% - GAIT_INFO       [Sx9 double], times of right and left stance, swing and drag events (hindlimbs)
%
% S is an undefined number that depends on the experimental setup/recording
%
n_cycle=0;
GAIT=NaN*ones(1,189);

% Cells remaining empty:
% - GAIT(n_cycle,35:36) =NaN;
% - GAIT(n_cycle,65:107)=NaN;
% - GAIT(n_cycle,109)   =NaN;
% - GAIT(n_cycle,111:113)=NaN;
% - GAIT(n_cycle,135:152)=NaN;
% - GAIT(n_cycle,181:183)=NaN;

PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix
PSO = 14; % position of time of swing onset in GAIT matrix
XLE = 13+2; % position of X coordinate of marker on ankle (NOT on TIP) in MARKER matrix
Xcrest = 1+2; % position of X coordinate of marker on crest in MARKER matrix
Xhip = 4+2;  % position of X coordinate of marker on hip in MARKER matrix

switch side
    case 1, position=2; position_contra=7; % Left side case
    case 2, position=7; position_contra=2; % Right side case
end 

Nsteps = size(GAIT_INFO,1); % Total number of steps

for step=1:Nsteps-1
    
    if isnan(GAIT_INFO(step,position))~=1 && isnan(GAIT_INFO(step+1,position))~=1 ...
           && GAIT_INFO(step,position)~=0 && GAIT_INFO(step+1,position)~=0
        
        % Initialization
        n_cycle=n_cycle+1;
        GAIT(n_cycle,:)=NaN*ones(1,189);
        
        % General params
        GAIT(n_cycle,1)=animal;% animal name
        GAIT(n_cycle,2)=cond1;% index of cond1
        GAIT(n_cycle,3)=cond2;% index of cond2
        GAIT(n_cycle,4)=side;% side (left=1; right=2)
        GAIT(n_cycle,5)=speed;% treadmill speed
        GAIT(n_cycle,37)=BWS;% BWS (bod weight support in percent)
        GAIT(n_cycle,6)=n_cycle;% cycle reported
        GAIT(n_cycle,7)=GAIT_INFO(step,position);% gait cycle time onset (in seconds)
        GAIT(n_cycle,8)=GAIT_INFO(step+1,position);% gait cycle time end (in seconds)
        GAIT(n_cycle,9)=MARKER_KIN(find(MARKER_KIN(:,2)==GAIT_INFO(step,position)),1);% frame # at onset
        GAIT(n_cycle,10)=MARKER_KIN(find(MARKER_KIN(:,2)==GAIT_INFO(step+1,position)),1);% frame # at end
        GAIT(n_cycle,11)=GAIT(n_cycle,PTE)-GAIT(n_cycle,PTO);% duration (in seconds)
        
        
        % Extract gait cycle
        MKRtemp=[];
        ANGLEtemp=[];
        TRUNKtemp=[];       
        if ~isempty(FORCE_SS)
            FORCE_SStemp=FORCE_SS(find(FORCE_SS(:,1)==GAIT(n_cycle,PTO)):find(FORCE_SS(:,1)==GAIT(n_cycle,PTE)),:);
            FORCEtemp=FORCE(find(FORCE(:,2)==GAIT(n_cycle,PTO)):find(FORCE(:,2)==GAIT(n_cycle,PTE)),:);
        end       
        GAIT_SStemp=GAIT_SS(find(GAIT_SS(:,1)==GAIT(n_cycle,PTO)):find(GAIT_SS(:,1)==GAIT(n_cycle,PTE)),:);
        temp_vector=find(MARKER_KIN(:,2)==GAIT(n_cycle,PTO)):find(MARKER_KIN(:,2)==GAIT(n_cycle,PTE));
        MKRtemp=MARKER_KIN(temp_vector,:);
        ANGLE_SPEEDtemp=ANGLE_SPEED(temp_vector,:);
        ANGLEtemp=ANGLE(temp_vector,:);
        TRUNKtemp=TRUNK(temp_vector,:);
        TRUNK_SPEEDtemp=TRUNK_SPEED(temp_vector,:);
        MTP_contra_temp=MTP_contra(temp_vector,:);
        size_gait=length(temp_vector);
        
        if isnan(ANGLE)~=1, % CASE KINEMATIC DATA EXIST
            
            % General params
            GAIT(n_cycle,12)=((MKRtemp(1, XLE) - MKRtemp(end, XLE))^2 ...
                +(MKRtemp(1, XLE+1) - MKRtemp(end, XLE+1))^2 ...
                +(MKRtemp(1, XLE+2) - MKRtemp(end, XLE+2))^2)^0.5 ...
                +speed*GAIT(n_cycle,11);% stride length computed from ankle marker; treadmill speed is inclued to correct for animal displacements
            GAIT(n_cycle,13)=GAIT(n_cycle,12)/GAIT(n_cycle,11); % actual animal speed
            
            % Stance and swing params
            if is_swing==0
                [min_limb_axis, pos_stance_end]=min(ANGLEtemp(:,6)); % minimal angle amplitude of limb axis
                if pos_stance_end<size(MKRtemp,1)-3
                    stance_end=MKRtemp(pos_stance_end,2); % time at stance end
                else
                    stance_end=MKRtemp(pos_stance_end-3,2); % enable the occurence of a 10ms swing period for averaging
                end
            else
                stance_end=GAIT_INFO(step,position+1); % time at stance end
                pos_stance_end=find(MKRtemp(:,2)==stance_end); % frame at stance end
            end
            GAIT(n_cycle,14)=stance_end; % time at stance end (~ swing start) (in seconds)
            GAIT(n_cycle,15)=stance_end-GAIT(n_cycle,PTO); % stance duration (in seconds)
            GAIT(n_cycle,16)=GAIT(n_cycle,PTE)-stance_end; % swing duration (in seconds)
            GAIT(n_cycle,17)=GAIT(n_cycle,15)/GAIT(n_cycle,11)*100; % stance duration (in percent)
            GAIT(n_cycle,18)=((MKRtemp(pos_stance_end,XLE)-MKRtemp(end,XLE))^2 ...
                +(MKRtemp(pos_stance_end,XLE+1)-MKRtemp(end,XLE+1))^2 ...
                +(MKRtemp(pos_stance_end,XLE+2)-MKRtemp(end,XLE+2))^2)^0.5 ...
                +speed*GAIT(n_cycle,16); % step length (swing movement length) computed from ankle marker; treadmill speed is inclued to correct for animal displacements
            GAIT(n_cycle,19)=power(-1,side)*(MKRtemp(pos_stance_end,XLE+2)-MTP_contra_temp(pos_stance_end,3)); % distance between MTP markers of the two hindlimbs on Z axis at stance end
            
            % Body movement oscillations params
            GAIT(n_cycle,20)=std(TRUNKtemp(:,2),1);% SD MidShoulder_Y vertical
            GAIT(n_cycle,21)=std(TRUNKtemp(:,3),1);% SD MidShoulder_Z medio-lateral
            GAIT(n_cycle,22)=std(TRUNKtemp(:,5),1);% SD MidHip_Y vertical
            GAIT(n_cycle,23)=std(TRUNKtemp(:,6),1);% SD MidHip_Z medio-lateral
            GAIT(n_cycle,24)=std(TRUNKtemp(:,7),1);% SD TRUNK_SAG
            GAIT(n_cycle,25)=std(TRUNK_SPEEDtemp(:,7),1);% SD TRUNK_SPEED
            GAIT(n_cycle,26)=std(TRUNKtemp(:,11),1);% SD Shoulders
            GAIT(n_cycle,27)=std(TRUNKtemp(:,12),1);% SD HIPS
            
            % Step features params
            GAIT(n_cycle,28)=max(MKRtemp(:,XLE+1));% step height (on Y axis)
            GAIT(n_cycle,29)=max(MKRtemp(:,XLE+1))-mean(MKRtemp(round(0.1*size_gait):round(0.2*size_gait),XLE+1)); % normalized step height
            [min_backward, pos_min_backward]=min(MKRtemp(:,XLE)); % min of ankle marker on X axis
            [max_forward, pos_max_forward]=max(MKRtemp(:,XLE)); % max of ankle marker on X axis
            GAIT(n_cycle,30)=MKRtemp(pos_min_backward,Xcrest)-min_backward;% X position of crest marker minus X position of ankle marker at gait cycle time when ankle is maximally backward.
            GAIT(n_cycle,31)=MKRtemp(pos_max_forward,Xcrest)-max_forward;% X position of crest marker minus X position of ankle marker at gait cycle time when ankle is maximally forward.
            GAIT(n_cycle,110)=MKRtemp(end,XLE+2)-MKRtemp(pos_stance_end,XLE+2);% Lateral movements during swing
            
            % Inter-limbs coordination
            for limb_event=0:1 % stance=0; swing=1;
                for j=2:Nsteps
                    % STANCE: if at step j, the contra limb starts stance during the observed gait cycle
                    % SWING : if at step j, the contra limb starts swing during the observed gait cycle
                    if GAIT(n_cycle,PTO)<GAIT_INFO(j,position_contra+limb_event) && GAIT_INFO(j,position_contra+limb_event)<GAIT(n_cycle,PTE)
                        % STANCE: duration between gait cycle onset (of non-contra limb) and stance start of contra limb (in percent of gait cycle)
                        % SWING: duration between gait cycle onset (of non-contra limb) and swing start of contra limb (in percent of gait cycle)
                        GAIT(n_cycle,32+limb_event)=(GAIT_INFO(j,position_contra+limb_event)-GAIT(n_cycle,PTO))/(GAIT(n_cycle,PTE)-GAIT(n_cycle,PTO))*100;
                    end
                end
            end          
            GAIT(n_cycle,108)=size(find(GAIT_SStemp(:,2)==1 & GAIT_SStemp(:,3)==1), 1)./size(GAIT_SStemp,1)*100; % double stance
            

            % Forelimb params
            if ~isempty(GAIT_INFO_FL)
                Nsteps_FL_contra = size(GAIT_INFO_FL(:,position_contra),1); % Total number of steps done by forelimb
                Nsteps_FL_sameside = size(GAIT_INFO_FL(:,position),1); % Total number of steps done by forelimb
                
                for limb_event=0:1 % stance=0; swing=1;
                    
                    % STANCE: if at step j, the forelimb (on the same side) starts stance during the observed gait cycle
                    % SWING : if at step j, the forelimb (on the same side) starts swing during the observed gait cycle
                    for j=2:Nsteps_FL_sameside % Loop over steps performed by forelimb
                        if GAIT(n_cycle,PTO)<GAIT_INFO_FL(j,position+limb_event) && GAIT_INFO_FL(j,position+limb_event)<GAIT(n_cycle,PTE)
                            % STANCE: duration between gait cycle onset (of non-contra limb) and stance start of forelimb (on the same side) (in percent of gait cycle)
                            % SWING: duration between gait cycle onset (of non-contra limb) and swing start of forelimb (on the same side) (in percent of gait cycle)
                            GAIT(n_cycle,168+limb_event)=(GAIT_INFO_FL(j,position+limb_event)-GAIT(n_cycle,PTO))/(GAIT(n_cycle,PTE)-GAIT(n_cycle,PTO))*100;
                        end
                    end

                    % STANCE: if at step j, the contra forelimb starts stance during the observed gait cycle
                    % SWING : if at step j, the contra forelimb starts swing during the observed gait cycle
                    for j=2:Nsteps_FL_contra % Loop over steps performed by forelimb
                        if GAIT(n_cycle,PTO)<GAIT_INFO_FL(j,position_contra+limb_event) && GAIT_INFO_FL(j,position_contra+limb_event)<GAIT(n_cycle,PTE)
                            % STANCE: duration between gait cycle onset (of non-contra limb) and stance start of contra forelimb (in percent of gait cycle)
                            % SWING: duration between gait cycle onset (of non-contra limb) and swing start of contra forelimb (in percent of gait cycle)
                            GAIT(n_cycle,170+limb_event)=(GAIT_INFO_FL(j,position_contra+limb_event)-GAIT(n_cycle,PTO))/(GAIT(n_cycle,PTE)-GAIT(n_cycle,PTO))*100;
                        end
                    end
                end
                
                % limb in stance
                GAIT_SStemp(:,6)=sum(GAIT_SStemp(:,2:5),2);
                for j=0:4
                    % Percent of no stance, single stance, double stance,
                    % triple stance, quadruple stance during the full gait cycle
                    GAIT(n_cycle,172+j)=size(find(GAIT_SStemp(:,6)==j),1)./size(GAIT_SStemp,1).*100;
                end              
            end
            
            % ANGULAR EXCURSION
            for angle=1:12
                GAIT(n_cycle,37+2*angle-1)=max(ANGLEtemp(:,angle));
                GAIT(n_cycle,37+2*angle)=min(ANGLEtemp(:,angle));
                GAIT(n_cycle,113+angle)=GAIT(n_cycle,37+2*angle-1)-GAIT(n_cycle,37+2*angle);
            end
            
            % ANGULAR VELOCITY EXCURSION
            for angle=6:10
                GAIT(n_cycle,152+3*(angle-5)-2)=max(ANGLE_SPEEDtemp(:,angle));
                GAIT(n_cycle,152+3*(angle-5)-1)=min(ANGLE_SPEEDtemp(:,angle));
                GAIT(n_cycle,152+3*(angle-5))=max(ANGLE_SPEEDtemp(:,angle))-min(ANGLE_SPEEDtemp(:,angle));
            end
            
            % FOOT DRAGGING
            if ~isnan(GAIT_INFO(step,position+2)) && GAIT_INFO(step,position+2)~=0
                GAIT(n_cycle,62)=GAIT_INFO(step,position+2); % report time of DRAG end
                GAIT(n_cycle,63)=GAIT_INFO(step,position+2)-GAIT_INFO(step,position+1); % drag duration
                if GAIT(n_cycle,63) <0
                   GAIT(n_cycle,63)=0; 
                end
                GAIT(n_cycle,64)=GAIT(n_cycle,63)/GAIT(n_cycle,16)*100;% drag duration in percent of SWING duration    
            else
                GAIT(n_cycle,62:64)=0;
                GAIT_INFO(step,position+2)=0;
            end
            
            % PATH LENGTH of ankle marker
            L=0;
            for step_i=pos_stance_end:size_gait-1
                L=L+((MKRtemp(step_i,XLE)-MKRtemp(step_i+1, XLE))^2 ...
                     +(MKRtemp(step_i,XLE+1)-MKRtemp(step_i+1,XLE+1))^2 ...
                     +(MKRtemp(step_i,XLE+2)-MKRtemp(step_i+1,XLE+2))^2)^0.5;
            end
            GAIT(n_cycle,34)=L;
            
        else % CASE NO KIN DATA
            stance_end=GAIT_INFO(step,position+1);
            pos_stance_end=find(MKRtemp(:,2)==stance_end);
            GAIT(n_cycle,14)=stance_end;
            GAIT(n_cycle,15)=stance_end-GAIT(n_cycle,PTO); % stance duration
            GAIT(n_cycle,16)=GAIT(n_cycle,PTE)-stance_end; % swing duration
            GAIT(n_cycle,17)=GAIT(n_cycle,15)/GAIT(n_cycle,11)*100; % stance duration in percent of full gait cycle
        end
        
    else % CASE ONLY ONE STANCE (last gait cycle identified)      
        GAIT_INFO(step,position+1:position+2)=0; % fill SWING and DRAG events by 0 if there is no stance
        GAIT_INFO(step+1,position+1:position+2)=0; % fill SWING and DRAG events by 0 if there is no stance    
    end
    
    % Hip vertical motion
    GAIT(n_cycle,126)=max(MKRtemp(:,Xhip+1))-mean(MKRtemp(round(0.1*size_gait):round(0.2*size_gait),XLE+1)); % normalized maximal position of hip marker on Y axis
    GAIT(n_cycle,127)=min(MKRtemp(:,Xhip+1))-mean(MKRtemp(round(0.1*size_gait):round(0.2*size_gait),XLE+1)); % normalized minimal position of hip marker on Y axis
    GAIT(n_cycle,128)=GAIT(n_cycle,126)-GAIT(n_cycle,127); % difference between normalized max and min position of hip marker on Y axis
    

    % FORCE PARAMS
    if ~isempty(FORCE)
        % Mean force during STANCE on X, Y and Z axis
        GAIT(n_cycle,129)=mean(FORCEtemp(find(FORCEtemp(:,2)==GAIT(n_cycle,PTO)):find(FORCEtemp(:,2)==GAIT(n_cycle,PSO)), 3), 1);
        GAIT(n_cycle,130)=mean(FORCEtemp(find(FORCEtemp(:,2)==GAIT(n_cycle,PTO)):find(FORCEtemp(:,2)==GAIT(n_cycle,PSO)), 4), 1);
        GAIT(n_cycle,131)=mean(FORCEtemp(find(FORCEtemp(:,2)==GAIT(n_cycle,PTO)):find(FORCEtemp(:,2)==GAIT(n_cycle,PSO)), 5), 1);
        
        % Mean force during single support STANCE on X, Y and Z axis
        switch side
            case 1, contra_side=3;
            case 2, contra_side=2;
        end
        GAIT(n_cycle,132)=mean(FORCEtemp(find(FORCE_SStemp(:,side+1)==1 & FORCE_SStemp(:,contra_side)==0), 3), 1);
        GAIT(n_cycle,133)=mean(FORCEtemp(find(FORCE_SStemp(:,side+1)==1 & FORCE_SStemp(:,contra_side)==0), 4), 1);
        GAIT(n_cycle,134)=mean(FORCEtemp(find(FORCE_SStemp(:,side+1)==1 & FORCE_SStemp(:,contra_side)==0), 5), 1);        
    end
    
    % VirtualCOM path
    VirtualCOM.x=(TRUNKtemp(:,4)+TRUNKtemp(:,13))./2; % Mean between Mid-Hip and Mid-Crest markers position on X axis
    VirtualCOM.y=(TRUNKtemp(:,5)+TRUNKtemp(:,14))./2; % Mean between Mid-Hip and Mid-Crest markers position on Y axis
    VirtualCOM.z=(TRUNKtemp(:,6)+TRUNKtemp(:,15))./2; % Mean between Mid-Hip and Mid-Crest markers position on Z axis
    GAIT(n_cycle,177)=max(VirtualCOM.x)-min(VirtualCOM.x); %peak to peak virtual COM horizontal movement
    GAIT(n_cycle,178)=max(VirtualCOM.z)-min(VirtualCOM.z); %peak to peak virtual COM lateral movement
    GAIT(n_cycle,179)=max(VirtualCOM.y)-min(VirtualCOM.y); %peak to peak virtual COM vertical movement
    L=0;
    for ih=1:length(VirtualCOM.x)-1,
        L=L+((VirtualCOM.x(ih)-VirtualCOM.x(ih+1))^2 ...
            +(VirtualCOM.y(ih)-VirtualCOM.y(ih+1))^2 ...
            +(VirtualCOM.z(ih)-VirtualCOM.z(ih+1))^2)^0.5;
    end
    GAIT(n_cycle,180)=L; % path length of virtual COM during the full gait cycle
    
    % Joint angle trunk (TRUNKtemp(:,16))
    if size(TRUNKtemp,2)==16,
        GAIT(n_cycle,184)=max(TRUNKtemp(:,16)); % Max of joint angle - Trunk
        GAIT(n_cycle,185)=min(TRUNKtemp(:,16));
        GAIT(n_cycle,186)=GAIT(n_cycle,184)-GAIT(n_cycle,185);
        
        GAIT(n_cycle,187)=max(TRUNK_SPEEDtemp(:,16));
        GAIT(n_cycle,188)=min(TRUNK_SPEEDtemp(:,16));
        GAIT(n_cycle,189)=GAIT(n_cycle,187)-GAIT(n_cycle,188);
    end
    
end% NEXT GAIT CYCLE
