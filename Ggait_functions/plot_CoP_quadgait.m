function success=CoP_QUAD(GAIT_LHL, GAIT_RHL, GAIT_LFL, GAIT_RFL, DATA_KIN_raw, CoP_DATA, maintitle)


front_l=1+2;%shoulder left
rear_l=4+2;%crest left
front_r=22+2;%shoulder right
rear_r=25+2;%crest right

for i=1:3
    CoM(:,i)=mean([DATA_KIN_raw(:,rear_r+i-1), ...
        DATA_KIN_raw(:,rear_l+i-1),...
        DATA_KIN_raw(:,front_r+i-1),...
        DATA_KIN_raw(:,front_l+i-1)],2);
end

FOOT_L=DATA_KIN_raw(:,16+2:18+2);
FOOT_R=DATA_KIN_raw(:,37+2:39+2);
HAND_L=DATA_KIN_raw(:,46+2:48+2);
HAND_R=DATA_KIN_raw(:,52+2:54+2);

color_code(1,1:3)=[1 0 0];
color_code(2,1:3)=[0 0 1];
titre={[maintitle  '/  LEFT STANCE']; [maintitle '/  RIGHT STANCE']};

onset_all=find(CoP_DATA(:,2)==min(GAIT_LHL(1,7),GAIT_RHL(1,7)));
end_all=find(CoP_DATA(:,2)==min(GAIT_LHL(size(GAIT_LHL, 1),8),GAIT_RHL(size(GAIT_RHL, 1),8)));

figure(115);

for side=1:2
    
    if side==1;GAIT=GAIT_LHL;end
    if side==2;GAIT=GAIT_RHL;end
    
    for cycle=1:size(GAIT, 1)
        
        if GAIT(cycle, 111)==1
            
            stance_onset=find(CoP_DATA(:,2)==GAIT(cycle,7));
            stance_end=find(CoP_DATA(:,2)==GAIT(cycle,14));
            subplot(2,1,side);hold on;
            plot(CoP_DATA(stance_onset:stance_end,3), CoP_DATA(stance_onset:stance_end,4), '-', 'linewidth', 2, 'color', [0.5 0.5 0.5]);
            plot(FOOT_L(stance_onset:stance_end, 3),FOOT_L(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(1,:));
            plot(FOOT_R(stance_onset:stance_end, 3),FOOT_R(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(2,:));
            plot(CoM(stance_onset:stance_end, 3),CoM(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', [0 0 0]);
            plot(HAND_L(stance_onset:stance_end, 3),HAND_L(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(2,:));
            plot(HAND_R(stance_onset:stance_end, 3),HAND_R(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(2,:));
            
        end
        
        
    end
    
    xmin=min([FOOT_L(onset_all:end_all, 3); FOOT_R(onset_all:end_all, 3); HAND_L(onset_all:end_all, 3); HAND_R(onset_all:end_all, 3);]);
    xmax=max([FOOT_L(onset_all:end_all, 3); FOOT_R(onset_all:end_all, 3); HAND_L(onset_all:end_all, 3); HAND_R(onset_all:end_all, 3);]);
    zmin=min([FOOT_L(onset_all:end_all, 1); FOOT_R(onset_all:end_all, 1); HAND_L(onset_all:end_all, 1); HAND_R(onset_all:end_all, 1);]);
    zmax=max([FOOT_L(onset_all:end_all, 1); FOOT_R(onset_all:end_all, 1); HAND_L(onset_all:end_all, 1); HAND_R(onset_all:end_all, 1);]);
    
    axis([xmin*0.8 xmax*1.2 zmin*0.8 zmax*1.2]);    
    %title(titre(side, :));
    legend({'CoP' 'LEFT FOOT' 'RIGHT FOOT' 'CoM' }, 'location','EastOutside');        
end

xlabel('LATERAL (cm)')
ylabel('FORWARD (cm)')

success=1;
