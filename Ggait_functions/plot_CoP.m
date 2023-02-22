function success=plot_CoP(GAIT_LHL, GAIT_RHL, DATA_KIN, DATA_CoP, maintitle)

% X, Y, Z order for DATA_KIN and DATA_CoM
% Frame, Time, Z, X for DATA_CoP

front_l=4+2;% X crest left
rear_l=7+2;% X hip left
front_r=25+2;% X crest right
rear_r=28+2;% X hip right

for i=1:3
    DATA_CoM(:,i)=mean([DATA_KIN(:,rear_r+i-1), DATA_KIN(:,rear_l+i-1),...
        DATA_KIN(:,front_r+i-1), DATA_KIN(:,front_l+i-1)],2);
end

MTP_L=DATA_KIN(:,16+2:18+2); % XYZ MTP left
MTP_R=DATA_KIN(:,37+2:39+2); % XYZ MTP right

color_code(1,:)=[0 0 0.4]; % left MTP
color_code(2,:)=[0.4 0 0]; % right MTP
color_code(3,:)=[0 0.4 0.75]; % CoP during left stance
color_code(4,:)=[0.75 0.4 0]; % CoP during right stance
color_code(5,:)=[0.2 0.2 0.2]; % CoP
color_code(6,:)=[0 0 0]; % CoM

titre={[maintitle  ' /  LEFT STANCE']; [maintitle ' /  RIGHT STANCE']};

onset_all=find(DATA_CoP(:,2)==min(GAIT_LHL(1,7),GAIT_RHL(1,7)));
end_all=find(DATA_CoP(:,2)==min(GAIT_LHL(end,8),GAIT_RHL(end,8)));

combined_CoPL=[];
combined_CoPR=[];
combined_CoM=[];

figure(111);
set_myFig(figure(111),560,420,0,50)
for side=1:2
    
    if side==1, GAIT=GAIT_LHL;
    else      GAIT=GAIT_RHL; end
    
    subplot(2,1,side); hold on;
    
    for cycle=1:size(GAIT, 1)
        if GAIT(cycle, 111)==1
            
            stance_onset=find(DATA_CoP(:,2)==GAIT(cycle,7));
            stance_end=find(DATA_CoP(:,2)==GAIT(cycle,14));
            
            plot(DATA_CoP(stance_onset:stance_end,3), DATA_CoP(stance_onset:stance_end,4), '-', 'linewidth', 2, 'color', color_code(5,:));
            plot(MTP_L(stance_onset:stance_end, 3),MTP_L(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(1,:));
            plot(MTP_R(stance_onset:stance_end, 3),MTP_R(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(2,:));
            
            combined_CoM=[combined_CoM; DATA_CoM(stance_onset:stance_end, 1:3)];
            
            switch side
                case 1, combined_CoPL=[combined_CoPL; DATA_CoP(stance_onset:stance_end,3:4)];
                case 2, combined_CoPR=[combined_CoPR; DATA_CoP(stance_onset:stance_end,3:4)];
            end
        end
    end
    
    xmin=min([MTP_L(onset_all:end_all, 3); MTP_R(onset_all:end_all, 3)]);
    xmax=max([MTP_L(onset_all:end_all, 3); MTP_R(onset_all:end_all, 3)]);
    ymin=min([MTP_L(onset_all:end_all, 1); MTP_R(onset_all:end_all, 1)]);
    ymax=max([MTP_L(onset_all:end_all, 1); MTP_R(onset_all:end_all, 1)]);
    
    axis([xmin*0.9 xmax*1.1 ymin*0.9 ymax*1.1]);grid on
    legend({'CoP' 'LEFT FOOT' 'RIGHT FOOT'}, 'location','EastOutside');
    title(titre(side, :)), xlabel('LATERAL (cm)'), ylabel('FORWARD (cm)')
end


figure(112), hold on, grid on
set_myFig(figure(112),560,420,560+15,50)
plot([0 0],[0 0],'linewidth', 2,'color',color_code(1,:))
plot([0 0],[0 0],'linewidth', 2,'color',color_code(2,:))
plot([0 0],[0 0],'linewidth', 2,'color',color_code(3,:))
plot([0 0],[0 0],'linewidth', 2,'color',color_code(4,:))
plot([0 0],[0 0],'linewidth', 2,'color',color_code(6,:))
legend({'LEFT MTP' 'RIGHT MTP' 'CoP' 'CoP' 'CoM'}, 'location','EastOutside');

for side=1:2    
    if side==1, GAIT=GAIT_LHL; else GAIT=GAIT_RHL; end   
    for cycle=1:size(GAIT, 1)
        if GAIT(cycle, 111)==1            
            stance_onset=find(DATA_CoP(:,2)==GAIT(cycle,7));
            stance_end=find(DATA_CoP(:,2)==GAIT(cycle,14));           
            plot(DATA_CoP(stance_onset:stance_end,3), DATA_CoP(stance_onset:stance_end,4), '-', 'linewidth', 2, 'color', color_code(side+2,:));
            plot(DATA_CoM(stance_onset:stance_end,3), DATA_CoM(stance_onset:stance_end,1), '-', 'linewidth', 2, 'color', color_code(6,:));
            switch side
                case 1
                    plot(MTP_L(stance_onset:stance_end, 3),MTP_L(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(1,:));
                case 2
                    plot(MTP_R(stance_onset:stance_end, 3),MTP_R(stance_onset:stance_end, 1), '-', 'linewidth', 2, 'color', color_code(2,:));
            end
        end
    end
end
axis([min(min(MTP_L(:,3)),min(MTP_R(:,3)))*0.9 max(max(MTP_L(:,3)),max(MTP_R(:,3)))*1.1 ...
      min(min(MTP_L(:,1)),min(MTP_R(:,1)))*0.9 max(max(MTP_L(:,1)),max(MTP_R(:,1)))*1.1])

title(maintitle), xlabel('LATERAL (cm)'), ylabel('FORWARD (cm)')

distribution = CoP_Color_representation(combined_CoPL, combined_CoPR, 64);

success=1;
