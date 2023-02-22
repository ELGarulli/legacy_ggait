function [GAIT]=PROJECT_LADDER_comp(GAIT, GAIT_INFO, mkr, position, TIME, PATHNAME, FILENAME)

GAIT(:,181:183)= 0;
TIME = TIME(:,2);

end_ladder=30;
while isfield(mkr,(strcat('RS',num2str(end_ladder))))==0,
    end_ladder=end_ladder-1;
    if end_ladder==0
        file_static=strcat(PATHNAME,'static','.c3d');
        [~,~,~,~,~,~,~,~,~,mkr1,~,~,~]=load_VICON_c3d(file_static,1);
        break
    end
end

H_LADDER=mean(mkr.(strcat('RS',num2str(end_ladder))).z);
LENGTH=length(mkr.RS1.y);

%% Figure (562) to select information about ladder performance
figure(562), clf, hold all, grid on
n_cycle=1;
end_cycle=max(find(GAIT_INFO(:,position)~=0));

if position==7, leg='R'; elseif position==2, leg='L'; end
START = find(TIME==GAIT_INFO(n_cycle,position));
STOP = find(TIME==GAIT_INFO(end_cycle,position));


%plot the Ankle marker horizontal
if isfield(mkr,(strcat(leg,'Ankle')))
    plot(mkr.(strcat(leg,'Ankle')).y(START:STOP),'b','LineWidth',1.5)
end
%plot the MTP marker horizontal
if isfield(mkr,(strcat(leg,'MTP')))
    plot(mkr.(strcat(leg,'MTP')).y(START:STOP),'r','LineWidth',1.5)
end
%plot the MTP marker vertical
if isfield(mkr,(strcat(leg,'MTP')))
    vert_MTP=mkr.(strcat(leg,'MTP')).z(START:STOP)*10;
    plot(vert_MTP-mean(vert_MTP)+mean(mkr.(strcat('RS',num2str(end_ladder))).y)+20,'g','LineWidth',1.5)
end


for jj=1:end_cycle,
    a = mean(mkr.(strcat('RS',num2str(1))).y);
    b = mean(mkr.(strcat('RS',num2str(end_ladder))).y);
    if a < b+5, plot_int=[a:2:b+50]; else plot_int=[b:2:a+50]; end
        plot_first_rec=ones(1,length(plot_int))*(find(TIME==GAIT_INFO(jj,position))-START+1);
        plot(plot_first_rec,plot_int,'m')
end

for ii=1:end_ladder,
    if isfield(mkr,(strcat('RS',num2str(ii))))==1,
        line(1:LENGTH,mkr.(strcat('RS',num2str(ii))).y,'color',[100 100 100]./255)
        if ii < 15, H_LADDER=(H_LADDER+mean(mkr.(strcat('RS',num2str(ii))).z))./2; end
    end
    if isfield(mkr,(strcat('LS',num2str(ii))))==1,
        line(1:LENGTH,mkr.(strcat('LS',num2str(ii))).y,'color',[100 100 100]./255)
    end
end
titre={[leg,' LIMB'];'Please select: FOOT (STANCE PHASE) - RUNG BEFORE - RUNG AFTER; FINISH Right button'};
title(titre)
legend('Ankle FW', 'MTP FW', 'MTP VERT', 'FS','location','SouthEast');
xlabel('Frames')
ylabel('Coordinate')
xlim([0 plot_first_rec(1)+200])

n=0;
clic=1;
ii=0;
while clic~=3,
    ii=ii+1;
    [num(ii),xi(ii),clic]=ginput(1);
    n=n+1;
    if clic==2, xi(ii)=0; end
end
n=(n-1)/3;
ij=1;
for ii=1:n,
    posizione_Foot(ii,1)=xi(ij)-xi(ij+1);
    posizione_Foot(ii,2)=mkr.(strcat(leg,'MTP')).z(START+round(num(ij)))-H_LADDER;
    GAIT(ii,182)=mkr.(strcat(leg,'MTP')).z(START+round(num(ij)))-H_LADDER;  %vertical position of the foot during stance phase (close to zero-contact with rung)
    posizione_Foot(ii,3)=(xi(ij)-xi(ij+1))/(xi(ij+2)-xi(ij+1))*100;
    GAIT(ii,181)=xi(ij)-xi(ij+1);                                           %horizontal position of the foot compare to the rung during stance phase
    GAIT(ii,183)=(xi(ij)-xi(ij+1))/(xi(ij+2)-xi(ij+1))*100;                 %percentage of horizontal position 
    ij=ij+3;
end

save(strcat(PATHNAME,FILENAME(1:end-4),'_GAIT_LADDER_',leg,'.mat'),'posizione_Foot')
close(562) 
