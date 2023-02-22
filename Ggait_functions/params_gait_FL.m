function [GAIT, GAIT_INFO]=params_gait_FL(GAIT_INFO, GAIT_INFO_HL, side, ...
    animal, cond1, cond2, speed, BWS, ...
    MARKER_KIN, WRIST_contra, ...
    ANGLE, TRUNK, ANGLE_SPEED, TRUNK_SPEED, ...
    GAIT_SS)

%% params_gait(...) compute various gait parameters based on KINEMATIC data and experimental conditions specifications when quadrupedal gait
%
% INPUTS:
% - GAIT_INFO       [Sx9 double], times of right and left stance, swing and drag events (forelimbs)
% - GAIT_INFO_HL    [Sx9 double], times of right and left stance, swing and drag events (hindlimbs)
% - side            [double] side of interest (1: left; 2: right)
% - animal          [double] animal iD
% - cond1           [double] index of experimental condition 1 (e.g. post-lesion timing)
% - cond2           [double] index of experimental condition 2 (e.g. testing type)
% - speed           [double] treadmill speed
% - BWS             [double] body weight support (in percent)
% - MARKER_KIN      [Sx17 double] kinematic data (3D position of markers on scap, shoulder, elbow, wrist, Toe)
% - WRIST_contra    [Sx3 double] 3D position of contralateral Wrist
% - ANGLE           [Sx12 double] angle data (elevation, limb axis and joint angles)
% - ANGLE_SPEED     [Sx12 double] angle velocity data (elevation, limb axis and joint angles)
% - TRUNK           [Sx15] angle data about shoulder, crest, hip and trunk (coordinates and elevation)
% - TRUNK_SPEED     [Sx15] angle velocity data about shoulder, crest, hip and trunk (coordinates and elevation)
% - GAIT_SS         [Sx3] time and side when stance happened
%
% OUTPUTS:
% - GAIT            [Sx189 double] various gait parameters
% - GAIT_INFO       [Sx9 double], times of right and left stance, swing and drag events (forelimbs)
%
% S is an undefined number that depends on the experimental setup/recording
%

n_cycle=0;
GAIT=NaN*ones(1,189);

% Cells remaining empty:
% - GAIT(n_cycle,65:176) =NaN;
% - GAIT(n_cycle,32:36)  =NaN;
% - GAIT(n_cycle,184:189)=NaN;

if side==1; position=2; position_contra=7; end % Left side case
if side==2; position=7; position_contra=2; end % Right side case

PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix
Xwrist = 10+2; % position of X coordinate of marker on wrist in MARKER matrix
Xscap = 1+2; % position of X coordinate of marker on scap in MARKER matrix
Xshoulder = 4+2; % position of X coordinate of marker on shoulder in MARKER matrix

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
        GAIT_SStemp=GAIT_SS(find(GAIT_SS(:,1)==GAIT(n_cycle,PTO)):find(GAIT_SS(:,1)==GAIT(n_cycle,PTE)),:);
        temp_vector=find(MARKER_KIN(:,2)==GAIT(n_cycle,PTO)):find(MARKER_KIN(:,2)==GAIT(n_cycle,PTE));
        MKRtemp=MARKER_KIN(temp_vector,:);
        ANGLEtemp=ANGLE(temp_vector,:);
        ANGLE_SPEEDtemp=ANGLE_SPEED(temp_vector,:);
        TRUNKtemp=TRUNK(temp_vector,:);
        TRUNK_SPEEDtemp=TRUNK_SPEED(temp_vector,:);
        WRIST_contra_temp=WRIST_contra(temp_vector,:);
        
        size_gait=size(MKRtemp,1);
        
        % General params
        GAIT(n_cycle,12)=((MKRtemp(1, Xwrist) - MKRtemp(size_gait, Xwrist))^2 ...
            +(MKRtemp(1, Xwrist+1) - MKRtemp(size_gait, Xwrist+1))^2 ...
            +(MKRtemp(1, Xwrist+2)-MKRtemp(size_gait, Xwrist+2))^2)^0.5 ...
            +speed*GAIT(n_cycle,11);% stride length computed from wrist marker; treadmill speed is inclued to correct for animal displacements
        GAIT(n_cycle,13)=GAIT(n_cycle,12)/GAIT(n_cycle,11); % actual animal speed
        
        % Stance and swing params
        [min_limb_axis pos_stance_end]=min(ANGLEtemp(:,6)); % minimal angle amplitude of limb axis
        if pos_stance_end<size(MKRtemp,1)-3
            stance_end=MKRtemp(pos_stance_end,2); % time at stance end
        else
            stance_end=MKRtemp(pos_stance_end-3,2); % enable the occurence of a 10ms swing period for averaging
        end
        
        GAIT(n_cycle,14)=stance_end; % time at stance end (~ swing start) (in seconds)
        GAIT(n_cycle,15)=stance_end-GAIT(n_cycle,PTO); % stance duration (in seconds)
        GAIT(n_cycle,16)=GAIT(n_cycle,PTE)-stance_end; % swing duration (in seconds)
        GAIT(n_cycle,17)=GAIT(n_cycle,15)/GAIT(n_cycle,11)*100; % stance duration (in percent)
        GAIT(n_cycle,18)=((MKRtemp(pos_stance_end,Xwrist)-MKRtemp(size_gait, Xwrist))^2 ...
            +(MKRtemp(pos_stance_end,Xwrist+1)-MKRtemp(size_gait,Xwrist+1))^2 ...
            +(MKRtemp(pos_stance_end,Xwrist+2)-MKRtemp(size_gait,Xwrist+2))^2)^0.5 ...
            +speed*GAIT(n_cycle,16);% step length (swing movement length) computed from wrist marker; treadmill speed is inclued to correct for animal displacements
        GAIT(n_cycle,19)=power(-1,side)*(MKRtemp(pos_stance_end,Xwrist+2)-WRIST_contra_temp(pos_stance_end,3)); % distance between wrist markers on Z axis at stance end
        
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
        GAIT(n_cycle,28)=max(MKRtemp(:,Xwrist+1));% step height (on Y axis)
        GAIT(n_cycle,29)=max(MKRtemp(:,Xwrist+1))-mean(MKRtemp(round(0.1*size_gait):round(0.2*size_gait),Xwrist+1)); % normalized step height
        [min_backward time_min_backward]=min(MKRtemp(:,Xwrist)); % min of ankle marker on X axis
        [max_forward time_max_forward]=max(MKRtemp(:,Xwrist)); % max of ankle marker on X axis
        GAIT(n_cycle,30)=MKRtemp(time_min_backward,Xscap)-min_backward; % X position of scap marker minus X position of wrist marker at gait cycle time when wrist is maximally backward.
        GAIT(n_cycle,31)=MKRtemp(time_max_forward,Xscap)-max_forward;% X position of scap marker minus X position of wrist marker at gait cycle time when wrist is maximally forward.
        GAIT(n_cycle,110)=MKRtemp(size_gait, Xwrist+2)-MKRtemp(pos_stance_end,Xwrist+2);% Lateral movements during swing
        
        % Inter-limbs coordination
        for limb_event=0:1
            for j=2:Nsteps
                % STANCE: if at step j, the contra limb starts stance during the observed gait cycle
                % SWING : if at step j, the contra limb starts swing during the observed gait cycle
                if GAIT(n_cycle,PTO)<GAIT_INFO(j,position_contra+limb_event) && GAIT_INFO(j,position_contra+limb_event)<GAIT(n_cycle,PTE)
                    GAIT(n_cycle,32+limb_event)=(GAIT_INFO(j,position_contra+limb_event)-GAIT(n_cycle,PTO))/(GAIT(n_cycle,PTE)-GAIT(n_cycle,PTO))*100;
                end
            end
        end
        GAIT(n_cycle,108)=size(find(GAIT_SStemp(:,4)==1 & GAIT_SStemp(:,5)==1), 1)./size(GAIT_SStemp, 1)*100; % double stance
        
        % Hindlimbs params
        Nsteps_HL_contra = size(GAIT_INFO_HL(:,position_contra),1); % Total number of steps done by hindlimb
        Nsteps_HL_sameside = size(GAIT_INFO_HL(:,position),1); % Total number of steps done by hindlimb
        
        for limb_event=0:1
            
            % STANCE: if at step j, the hindlimb (on the same side) starts stance during the observed gait cycle
            % SWING : if at step j, the hindlimb (on the same side) starts swing during the observed gait cycle
            for j=2:Nsteps_HL_sameside % Loop over steps performed by hindlimb
                if GAIT(n_cycle,PTO)<GAIT_INFO_HL(j,position_contra+limb_event) && GAIT_INFO_HL(j,position_contra+limb_event)<GAIT(n_cycle,PTE)
                    % STANCE: duration between gait cycle onset (of non-contra limb) and stance start of hindlimb (on the same side) (in percent of gait cycle)
                    % SWING: duration between gait cycle onset (of non-contra limb) and swing start of hindlimb (on the same side) (in percent of gait cycle)
                    GAIT(n_cycle,168+limb_event)=(GAIT_INFO_HL(j,position_contra+limb_event)-GAIT(n_cycle,PTO))/(GAIT(n_cycle,PTE)-GAIT(n_cycle,PTO))*100;
                end
            end
            
            % STANCE: if at step j, the contra hindlimb starts stance during the observed gait cycle
            % SWING : if at step j, the contra hindlimb starts swing during the observed gait cycle
            for j=2:Nsteps_HL_contra % Loop over steps performed by hindlimb
                if GAIT(n_cycle,PTO)<GAIT_INFO_HL(j,position+limb_event) && GAIT_INFO_HL(j,position+limb_event)<GAIT(n_cycle,PTE)
                    % STANCE: duration between gait cycle onset (of non-contra limb) and stance start of contra hindlimb (in percent of gait cycle)
                    % SWING: duration between gait cycle onset (of non-contra limb) and swing start of contra hindlimb (in percent of gait cycle)
                    GAIT(n_cycle,170+limb_event)=(GAIT_INFO_HL(j,position_contra+limb_event)-GAIT(n_cycle,PTO))/(GAIT(n_cycle,PTE)-GAIT(n_cycle,PTO))*100;
                end
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
        
        % PATH LENGTH of wrist marker
        L=0;
        for step_i=pos_stance_end:size_gait-1
            L=L+((MKRtemp(step_i,Xwrist)-MKRtemp(step_i+1, Xwrist))^2 ...
                +(MKRtemp(step_i,Xwrist+1)-MKRtemp(step_i+1,Xwrist+1))^2 ...
                +(MKRtemp(step_i,Xwrist+2)-MKRtemp(step_i+1,Xwrist+2))^2)^0.5;
        end
        GAIT(n_cycle,34)=L;
        
    else % CASE ONLY ONE STANCE (last gait cycle identified)
        GAIT_INFO(step,position+1:position+2)=0; % fill SWING and DRAG events by 0 if there is no stance
        GAIT_INFO(step+1,position+1:position+2)=0; % fill SWING and DRAG events by 0 if there is no stance
    end
    
    % Shoulder vertical motion
    GAIT(n_cycle,126)=max(MKRtemp(:,Xshoulder+1))-mean(MKRtemp(round(0.1*size_gait):round(0.2*size_gait),Xwrist+1)); % normalized maximal position of shoulder marker on Y axis
    GAIT(n_cycle,127)=min(MKRtemp(:,Xshoulder+1))-mean(MKRtemp(round(0.1*size_gait):round(0.2*size_gait),Xwrist+1)); % normalized minimal position of shoulder marker on Y axis
    GAIT(n_cycle,128)=GAIT(n_cycle,126)-GAIT(n_cycle,127); % difference between normalized max and min position of shoulder marker on Y axis
    
    % Params only for HL (virtual COM)
    GAIT(n_cycle,177:180)=zeros(1,4);
    
    
end% NEXT GAIT CYCLE
