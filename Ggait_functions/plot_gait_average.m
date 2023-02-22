function  [output]=plot_gait_average(GAITL, DATAANGLEL, DATAEMGL, DATAFORL, NemgChLeft, ...
                           GAITR, DATAANGLER, DATAEMGR, DATAFORR, NemgChRight, ...
                           name, freq, emgChLeft, emgChRight, DATA_EMG_HEADING, limb, LABEL)

switch limb
    case 'FL', offset=8;
    case 'HL', offset=0;
end

if ~isempty(DATAEMGL)
    NPLOTleft=5+NemgChLeft;

    DATAEMGL=comp_filter(DATAEMGL, 80, [], freq, 5, 1);
    
    DATAEMGL=resample(DATAEMGL,100);
    EMG_label_L=DATA_EMG_HEADING(emgChLeft(1:NemgChLeft));
else
    NPLOTleft=5;
    EMG_label_L=[];
end 


if ~isempty(DATAEMGR)
    NPLOTright=5+NemgChRight;
    
    DATAEMGR=comp_filter(DATAEMGR, 80, [], freq, 5, 1);
    
    DATAEMGR=resample(DATAEMGR,100);
    EMG_label_R=DATA_EMG_HEADING(emgChRight(1:NemgChRight));
else
    NPLOTright=5;
    EMG_label_R=[];
end

if ~isempty(DATAFORL)
    DATAFORR=resample(DATAFORR(:,:), 100);
    DATAFORL=resample(DATAFORL(:,:), 100);
    
    NPLOTright=NPLOTright+2;
    NPLOTleft=NPLOTleft+2;
    force_label={'X (N)' 'Y (N)' 'Z (N)'};
end

%% Plot JOINT, EMG and FORCE
for side=1:2
    
    figure(120+side+offset);hold on
    
    if side==1; 
        NPLOT=NPLOTleft;
        NemgChperside=NemgChLeft;
        GAIT=GAITL;
        DATAFOR=DATAFORL;
        DATAANGLE=DATAANGLEL; 
        DATAEMG=DATAEMGL;
        emg_label=EMG_label_L;
        set_myFig(figure(120+side+offset),275,650,0,300)
    else % side==2
        NPLOT=NPLOTright;
        NemgChperside=NemgChRight;
        GAIT=GAITR;
        DATAFOR=DATAFORR; 
        DATAANGLE=DATAANGLER; 
        DATAEMG=DATAEMGR;
        emg_label=EMG_label_R;
        set_myFig(figure(120+side+offset),275,650,275+15,300)
    end
    
    if isempty(DATAEMG); NemgChperside=0; end
    
    subplot(NPLOT,1,1);hold on
    patch([0, 0, 100, 100], [0, 1, 1, 0],[1 1 1]);
    offet=0;    
    patch_StanceDragSwing(GAIT, offet)
    axis([0 100 0 1]);axis off
    
    if side==1; nameplot=[name ' LEFT ' limb]; else nameplot=[name ' RIGHT ' limb]; end
    title(['\fontsize{8}' nameplot]);
    ylabel('\fontsize{8}GAIT');
    
    for joint=7:10
        subplot(NPLOT,1,joint-5);hold on
        
        for i=1:size(DATAANGLE, 1)-1
            x=[i, i, i+1, i+1];
            y=[DATAANGLE(i,joint+24), DATAANGLE(i,joint+12), DATAANGLE(i+1,joint+12), DATAANGLE(i+1,joint+24)];
            patch(x, y, [0.5 0.5 0.5], 'edgecolor', [0.5 0.5 0.5]);hold on
        end
        
        plot(DATAANGLE(:,joint+12),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
        plot(DATAANGLE(:,joint+24),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
        plot(DATAANGLE(:,joint),'LineWidth',2,'Color',[0 0 0]);hold on
        ylabel(LABEL(joint-6));
        
    end % end plot angles

    % plot EMG  
    if ~isempty(DATAEMG)       
        for emg=1:NemgChperside           
            subplot(NPLOT,1,emg+5);hold on
            
            for i=1:size(DATAEMG, 1)-1
                x=[i, i, i+1, i+1];
                y=[DATAEMG(i,emg+2*size(DATAEMG,2)/3), DATAEMG(i,emg+size(DATAEMG,2)/3), DATAEMG(i+1,emg+size(DATAEMG,2)/3), DATAEMG(i,emg+2*size(DATAEMG,2)/3)];
                patch(x, y, [0.5 0.5 0.5], 'edgecolor', [0.5 0.5 0.5]);hold on
            end
            
            plot(DATAEMG(:,emg+1*size(DATAEMG,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(DATAEMG(:,emg+2*size(DATAEMG,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(DATAEMG(:,emg),'LineWidth',2,'Color',[0 0 0]);hold on
            ylabel(emg_label(emg));
        end       
    end
    
    % plot FORCES    
    if ~isempty(DATAFOR)       
        for force=2:3          
            subplot(NPLOT,1,force+NemgChperside+5-1);hold on
            
            for i=1:size(DATAFOR, 1)-1
                x=[i, i, i+1, i+1];
                y=[DATAFOR(i,force+2*size(DATAFOR,2)/3), DATAFOR(i,force+size(DATAFOR,2)/3), DATAFOR(i+1,force+size(DATAFOR,2)/3), DATAFOR(i,force+2*size(DATAFOR,2)/3)];
                patch(x, y, [0.5 0.5 0.5], 'edgecolor', [0.5 0.5 0.5]);hold on
            end
            
            plot(DATAFOR(:,force+1*size(DATAFOR,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(DATAFOR(:,force+2*size(DATAFOR,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(DATAFOR(:,force),'LineWidth',2,'Color',[0 0 0]);hold on
            ylabel(force_label(force));
        end        
    end
    
end %SIDE

output='Ggraph created';