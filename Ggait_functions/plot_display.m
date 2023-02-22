function plot_display(TIME, GAIT, DATA_ANGLE, DATA_EMG, DATA_FORCE, TXemg, TXkin, SIDE, ...
    is_EMG, ChN, ChName, is_force, plotsPHASE, legendKIN, plotsKIN, legendEMG, plotsEMG)

Ncycle = size(GAIT,1);
PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix
PSE = 14; % position of time of stance end in GAIT matrix
PDE = 62; % position of time of drag end in GAIT matrix

%% DISPLAY STANCE-SWING PHASES
axes(plotsPHASE); cla(plotsPHASE); hold off
patch([GAIT(1,PTO), GAIT(1,PTO), GAIT(Ncycle,PTE), GAIT(Ncycle,PTE)], [0, 1, 1, 0],[1 1 1]); axis tight

for cycle=1:Ncycle % draw STANCE
    patch([GAIT(cycle,PTO), GAIT(cycle,PTO), GAIT(cycle,PSE), GAIT(cycle,PSE)], [0, 1, 1, 0],[0.5 0.5 0.5]); axis tight
end

if  GAIT(cycle,PDE)~=0 % if DRAG, then draw DRAG
    for cycle=1:Ncycle
        patch([GAIT(cycle,PSE), GAIT(cycle,PSE), GAIT(cycle,PDE), GAIT(cycle,PDE)], [0, 1, 1, 0],[1 0 0]); axis tight
    end
end

for cycle=1:Ncycle
    if GAIT(cycle,111) == 0
        patch([GAIT(cycle,PTO), GAIT(cycle,PTO), GAIT(cycle,PTE), GAIT(cycle,PTE)], [0, 1, 1, 0],[0.2 0.2 0.2]); axis tight
    end
end

%% DISPLAY JOINT ANGLES
if ~isempty(DATA_ANGLE)
    vector_pos = find(TIME==GAIT(1,PTO)):find(TIME==GAIT(Ncycle,PTE));
    joint_angle=DATA_ANGLE(vector_pos,7:10);
    time=TIME(vector_pos);
    PlotJointStart=1;
    PlotJointEnd=4;
    
    for joint=PlotJointStart:PlotJointEnd,
        if SIDE==1 || SIDE==2 || joint<4
            set(legendKIN(joint),'string',TXkin(joint));
            axes(plotsKIN(joint)); cla(plotsKIN(joint)); hold off
            plot(time, joint_angle(:,joint),'LineWidth',2,'Color','black');axis tight; hold on
            axis([GAIT(1,PTO) GAIT(Ncycle,PTE) min(joint_angle(:,joint)) max(joint_angle(:,joint))]);
        else plot_patch_empty(legendKIN(joint), plotsKIN(joint), GAIT(1,PTO), GAIT(Ncycle,PTE))
        end
        plot_cycles(Ncycle, GAIT(:,PTO), GAIT(:,PSE), joint_angle(:,joint))
    end
end

%% DISPLAY EMG
if is_EMG && ChN~=0
    emg_data=DATA_EMG(find(DATA_EMG(:,2)==GAIT(1,PTO)):find(DATA_EMG(:,2)==GAIT(Ncycle,PTE)),:);
    
    for emg=1:ChN
        set(legendEMG(emg),'string',TXemg(ChName(emg)));
        axes(plotsEMG(emg)); cla(plotsEMG(emg)); hold off
        plot(emg_data(:,2), emg_data(:,ChName(emg)+2),'LineWidth',1,'Color','black');
        axis([GAIT(1,PTO) GAIT(Ncycle,PTE) min(emg_data(:,ChName(emg)+2)) max(emg_data(:,ChName(emg)+2))]);hold on
        plot_cycles(Ncycle, GAIT(:,PTO), GAIT(:,PSE), emg_data(:,ChName(emg)+2))
    end
    
    if ChN<11
        for emg=ChN+1:11, plot_patch_empty(legendEMG(emg), plotsEMG(emg), GAIT(1,PTO), GAIT(Ncycle,PTE)), end
    end
else
    for emg=1:11, plot_patch_empty(legendEMG(emg), plotsEMG(emg), GAIT(1,PTO), GAIT(Ncycle,PTE)), end
end

%% DISPLAY FORCE
if is_force
    set(legendEMG(end),'string','FORCE');
    force_data=DATA_FORCE(find(DATA_FORCE(:,2)==GAIT(1,PTO)):find(DATA_FORCE(:,2)==GAIT(Ncycle,PTE)),:);
    axes(plotsEMG(end)); cla(plotsEMG(end)); hold off
    plot(force_data(:,2), force_data(:,5),'LineWidth',1.5,'Color','black'); hold on
    axis([GAIT(1,PTO) GAIT(Ncycle,PTE) min(force_data(:,5)) max(force_data(:,5))]);   
    plot_cycles(Ncycle, GAIT(:,PTO), GAIT(:,PSE), force_data(:,5))
end
