function varargout = REPRESENTATION_SEQUENCE(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @REPRESENTATION_SEQUENCE_OpeningFcn, ...
    'gui_OutputFcn',  @REPRESENTATION_SEQUENCE_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function REPRESENTATION_SEQUENCE_OpeningFcn(hObject, eventdata, handles, varargin)

handles.name=varargin{1};
handles.gait_info_L=varargin{2};
handles.gait_info_R=varargin{3};
handles.kinematic_L=varargin{4};
handles.kinematic_R=varargin{5};
handles.emg=varargin{6};
handles.force=varargin{7};
handles.labelEMG=varargin{8};
handles.nEMG=varargin{9};
handles.nFORCE=varargin{10};
handles.time_kinematic=varargin{11};
handles.GAIT_INFO=varargin{12};
handles.DATA_CoP=varargin{13};
handles.GAIT_INFO_FORELIMB=varargin{14};
handles.gait_info_LFL=varargin{15};
handles.gait_info_RFL=varargin{16};
handles.kinematic_LFL=varargin{17};
handles.kinematic_RFL=varargin{18};
handles.FORCE_LEFT=varargin{19};
handles.FORCE_RIGHT=varargin{20};
handles.kinematic=varargin{21};
handles.DATA_NEU=varargin{22};
handles.fe_NEU=varargin{23};
handles.CoM=varargin{24};
handles.nNEU=size(handles.DATA_NEU,2)-2;
handles.FORELIMB=~isempty(handles.GAIT_INFO_FORELIMB);

handles.kin_L_label={'L LIMB', 'L HIP', 'L KNEE', 'L ANKLE', 'L MTP', 'L LIMB Abb', 'L FOOT Rot'};
handles.kin_R_label={'R LIMB', 'R HIP', 'R KNEE', 'R ANKLE', 'R MTP', 'R LIMB Abb', 'R FOOT Rot'};
handles.kin_LFL_label={'L FORELIMB', 'L SHOULDER', 'L ELBOW', 'L WRIST', 'L MCP', 'L FLIMB Abb', 'L HAND Rot'};
handles.kin_RFL_label={'R FORELIMB', 'R SHOULDER', 'R ELBOW', 'R WRIST', 'R MCP', 'R FLIMB Abb', 'R HAND Rot'};
handles.labelFORCE={'X (N)' 'Y (N)' 'Z (N)'};
handles.labelCoP={'CoP LAT (mm)' 'CoP FOR(mm)'};
handles.labelCoM={'CoM X (cm)' 'CoM Y (cm)' 'CoM Z (cm)'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up KINEMATIC
handles.KINEMATIC_LHL_menu=[handles.limbL_menu, handles.hipL_menu, handles.kneeL_menu,handles.ankleL_menu,handles.MTPL_menu,handles.limb_abbL_menu, handles.foot_rotL_menu];
handles.KINEMATIC_RHL_menu=[handles.limbR_menu, handles.hipR_menu, handles.kneeR_menu,handles.ankleR_menu,handles.MTPR_menu,handles.limb_abbR_menu, handles.foot_rotR_menu];
handles.KINEMATIC_LFL_menu=[handles.LimbFL_menu, handles.ShoulderL_menu, handles.ElbowL_menu,handles.WristL_menu,handles.MCPL_menu,handles.limb_abbFL_menu, handles.Hand_rotFL_menu];
handles.KINEMATIC_RFL_menu=[handles.LimbFR_menu, handles.ShoulderR_menu, handles.ElbowR_menu,handles.WristR_menu,handles.MCPR_menu,handles.limb_abbFR_menu, handles.Hand_rotFR_menu];

set(handles.KINEMATIC_LHL_menu, 'value', 0);
set(handles.KINEMATIC_RHL_menu, 'value', 0);
set(handles.KINEMATIC_LFL_menu, 'value', 0);
set(handles.KINEMATIC_RFL_menu, 'value', 0);
set(handles.limbL_menu, 'value', 1);
set(handles.limbR_menu, 'value', 1);

handles.min_KINEMATIC=[handles.limb_min, handles.hip_min, handles.knee_min, handles.ankle_min, handles.MTP_min, handles.limb_abb_min, handles.foot_rot_min];
handles.max_KINEMATIC=[handles.limb_max, handles.hip_max, handles.knee_max, handles.ankle_max, handles.MTP_max, handles.limb_abb_max, handles.foot_rot_max];
handles.min_KINEMATIC_FORELIMB=[handles.LimbFL_min, handles.Shoulder_min, handles.Elbow_min, handles.Wrist_min, handles.MCP_min, handles.limbFL_abb_min, handles.Hand_rot_min];
handles.max_KINEMATIC_FORELIMB=[handles.LimbFL_max, handles.Shoulder_max, handles.Elbow_max, handles.Wrist_max, handles.MCP_max, handles.limbFL_abb_max, handles.Hand_rot_max];

if handles.FORELIMB == 0
    set(handles.KINEMATIC_LFL_menu,'Enable','off');
    set(handles.KINEMATIC_RFL_menu,'Enable','off');
    set(handles.min_KINEMATIC_FORELIMB,'Enable','off');
    set(handles.max_KINEMATIC_FORELIMB,'Enable','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up EMG
handles.EMG_menu=[handles.EMG1_menu, handles.EMG2_menu,handles.EMG3_menu,handles.EMG4_menu,handles.EMG5_menu,handles.EMG6_menu,handles.EMG7_menu,handles.EMG8_menu...
    handles.EMG9_menu, handles.EMG10_menu,handles.EMG11_menu,handles.EMG12_menu,handles.EMG13_menu,handles.EMG14_menu];
handles.min_EMG=[handles.emg1min, handles.emg2min, handles.emg3min, handles.emg4min, handles.emg5min, handles.emg6min, handles.emg7min, handles.emg8min...
    handles.emg9min, handles.emg10min, handles.emg11min, handles.emg12min, handles.emg13min, handles.emg14min];
handles.max_EMG=[handles.emg1max, handles.emg2max, handles.emg3max, handles.emg4max, handles.emg5max, handles.emg6max, handles.emg7max, handles.emg8max...
    handles.emg9max, handles.emg10max, handles.emg11max, handles.emg12max, handles.emg13max, handles.emg14max];

for ch=1:size(handles.EMG_menu,2)
    set(handles.EMG_menu(ch), 'value', 0);
end

if handles.nEMG<size(handles.EMG_menu,2)   
    for ch=1:handles.nEMG
        set(handles.EMG_menu(ch), 'string', handles.labelEMG(ch));
    end
    for ch=handles.nEMG+1:size(handles.EMG_menu,2)
        set(handles.EMG_menu(ch),'Enable','off');
        set(handles.min_EMG(ch),'Enable','off');
        set(handles.max_EMG(ch),'Enable','off');
    end
else   
    for ch=1:size(handles.EMG_menu,2)
        set(handles.EMG_menu(ch), 'string', handles.labelEMG(ch));
    end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up FORCE & CoP
handles.FORCE_menu=[handles.FORCEX, handles.FORCEY, handles.FORCEZ];
set(handles.FORCE_menu, 'value', 0);
handles.max_FORCE=[handles.forceXmax, handles.forceYmax, handles.forceZmax];
handles.min_FORCE=[handles.forceXmin, handles.forceYmin, handles.forceZmin];
handles.CoP_menu=[handles.Lat_CoP, handles.For_CoP];
set(handles.CoP_menu, 'value', 0);
handles.min_CoP=[handles.Lat_CoP_min, handles.For_CoP_min];
handles.max_CoP=[handles.Lat_CoP_max, handles.For_CoP_max];

if isempty(handles.force)
    set(handles.FORCE_menu,'Enable','off');
    set(handles.max_FORCE,'Enable','off');
    set(handles.min_FORCE,'Enable','off');
    set(handles.CoP_menu,'Enable','off');
    set(handles.min_CoP,'Enable','off');
    set(handles.max_CoP,'Enable','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up CoM
handles.CoM_menu=[handles.BODY_X, handles.BODY_Y, handles.BODY_Z];
set(handles.CoM_menu, 'value', 0);
handles.max_BODY=[handles.BODY_Xmax, handles.BODY_Ymax, handles.BODY_Zmax];
handles.min_BODY=[handles.BODY_Xmin, handles.BODY_Ymin, handles.BODY_Zmin];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up NEURONS
handles.NEU_menu=[handles.NEU1_menu, handles.NEU2_menu,handles.NEU3_menu,handles.NEU4_menu,handles.NEU5_menu,handles.NEU6_menu,handles.NEU7_menu,handles.NEU8_menu...
    handles.NEU9_menu, handles.NEU10_menu,handles.NEU11_menu,handles.NEU12_menu, handles.NEU13_menu];
handles.NEU_PLOT_menu={'LINE', 'HEAT MAP'};
set(handles.NEU_PLOT, 'string', handles.NEU_PLOT_menu)
handles.NEU_FILTER_menu={'NONE', 'MOVING-AVERAGE', 'JACK'};
set(handles.NEU_FILTER, 'string', handles.NEU_FILTER_menu)

for ch=1:size(handles.NEU_menu,2)
    set(handles.NEU_menu(ch), 'value', 0);
end

if isempty(handles.DATA_NEU)
    set(handles.NEU_menu,'Enable','off');
    set(handles.NEU_PLOT,'Enable','off');
    set(handles.NEU_FILTER,'Enable','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up figure option
switch size(handles.gait_info_L,1)<size(handles.gait_info_R,1)    
    case 1        
        set(handles.onset_menu, 'string', handles.gait_info_L(:,6));
        set(handles.onset_menu, 'value', 1);
        set(handles.end_menu, 'string', handles.gait_info_L(:,6));
        set(handles.end_menu, 'value', size(handles.gait_info_L(:,6),1));
        handles.side=1;       
    case 0     
        set(handles.onset_menu, 'string', handles.gait_info_R(:,6));
        set(handles.onset_menu, 'value', 1);
        set(handles.end_menu, 'string', handles.gait_info_R(:,6));
        set(handles.end_menu, 'value', size(handles.gait_info_R(:,6),1));
        handles.side=2;        
end

handles.scale_menu_options={'AUTOSCALE', 'CUSTOM'};
set(handles.scale_menu, 'string', handles.scale_menu_options);
set(handles.scale_menu, 'value', 1);

handles.output = hObject;

guidata(hObject, handles);

function varargout = REPRESENTATION_SEQUENCE_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function figure_average_Callback(hObject, eventdata, handles)

%% Set up figure topology
n_plots=1;

for i=1:size(handles.KINEMATIC_LHL_menu,2)
    if get(handles.KINEMATIC_LHL_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

for i=1:size(handles.KINEMATIC_RHL_menu,2)
    if get(handles.KINEMATIC_RHL_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

for i=1:size(handles.KINEMATIC_LFL_menu,2)
    if get(handles.KINEMATIC_LFL_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

for i=1:size(handles.KINEMATIC_RFL_menu,2)
    if get(handles.KINEMATIC_RFL_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

if handles.FORELIMB
    n_plots=n_plots+1;
end

for i=1:size(handles.EMG_menu,2)
    if get(handles.EMG_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

for i=1:size(handles.FORCE_menu,2)
    if get(handles.FORCE_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

for i=1:size(handles.CoP_menu,2)
    if get(handles.CoP_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

for i=1:size(handles.CoM_menu,2)
    if get(handles.CoM_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

for i=1:size(handles.NEU_menu,2)
    if get(handles.NEU_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

%% PLOT data
nnplots=0;
figure(100),clf,set_myFig(figure(100),1200,600,200,200)
subplot(n_plots,1,1), title(handles.name);

% DISPLAY CYCLES
switch handles.side
    case 1
        first_time=handles.gait_info_L(get(handles.onset_menu, 'value'), 7);
        last_time=handles.gait_info_L(get(handles.end_menu, 'value'), 8);
        first=find(handles.time_kinematic(:,2)==handles.gait_info_L(get(handles.onset_menu, 'value'), 7));
        last=find(handles.time_kinematic(:,2)==handles.gait_info_L(get(handles.end_menu, 'value'), 8));
        if ~isempty(handles.emg)
            first_emg=find(handles.emg(:,2)==handles.gait_info_L(get(handles.onset_menu, 'value'), 7));
            last_emg=find(handles.emg(:,2)==handles.gait_info_L(get(handles.end_menu, 'value'), 8));
        end
        if ~isempty(handles.force)
            first_for=find(handles.force(:,2)==handles.gait_info_L(get(handles.onset_menu, 'value'), 7));
            last_for=find(handles.force(:,2)==handles.gait_info_L(get(handles.end_menu, 'value'), 8));
            first_for_limb=find(handles.FORCE_LEFT(:,2)==handles.gait_info_L(get(handles.onset_menu, 'value'), 7));
            last_for_limb=find(handles.FORCE_LEFT(:,2)==handles.gait_info_L(get(handles.end_menu, 'value'), 8));
        end
        if ~isempty(handles.DATA_CoP)
            first_CoP=find(handles.DATA_CoP(:,2)==handles.gait_info_L(get(handles.onset_menu, 'value'), 7));
            last_CoP=find(handles.DATA_CoP(:,2)==handles.gait_info_L(get(handles.end_menu, 'value'), 8));
        end        
        if ~isempty(handles.DATA_NEU)
            first_NEU=find(handles.DATA_NEU(:,2)==handles.gait_info_L(get(handles.onset_menu, 'value'), 7));
            last_NEU=find(handles.DATA_NEU(:,2)==handles.gait_info_L(get(handles.end_menu, 'value'), 8));
        end
        
    case 2
        first_time=handles.gait_info_R(get(handles.onset_menu, 'value'), 7);
        last_time=handles.gait_info_R(get(handles.end_menu, 'value'), 8);
        first=find(handles.time_kinematic(:,2)==handles.gait_info_R(get(handles.onset_menu, 'value'), 7));
        last=find(handles.time_kinematic(:,2)==handles.gait_info_R(get(handles.end_menu, 'value'), 8));
        if ~isempty(handles.emg)
            first_emg=find(handles.emg(:,2)==handles.gait_info_R(get(handles.onset_menu, 'value'), 7));
            last_emg=find(handles.emg(:,2)==handles.gait_info_R(get(handles.end_menu, 'value'), 8));
        end
        if ~isempty(handles.force)
            first_for=find(handles.force(:,2)==handles.gait_info_R(get(handles.onset_menu, 'value'), 7));
            last_for=find(handles.force(:,2)==handles.gait_info_R(get(handles.end_menu, 'value'), 8));
            first_for_limb=find(handles.FORCE_RIGHT(:,2)==handles.gait_info_R(get(handles.onset_menu, 'value'), 7));
            last_for_limb=find(handles.FORCE_RIGHT(:,2)==handles.gait_info_R(get(handles.end_menu, 'value'), 8));           
        end        
        if ~isempty(handles.DATA_CoP)
            first_CoP=find(handles.DATA_CoP(:,2)==handles.gait_info_R(get(handles.onset_menu, 'value'), 7));
            last_CoP=find(handles.DATA_CoP(:,2)==handles.gait_info_R(get(handles.end_menu, 'value'), 8));
        end       
        if ~isempty(handles.DATA_NEU)
            first_NEU=find(handles.DATA_NEU(:,2)<=handles.gait_info_R(get(handles.onset_menu, 'value'), 7));
            last_NEU=find(handles.DATA_NEU(:,2)==handles.gait_info_R(get(handles.end_menu, 'value'), 8));
        end
end

% KINEMATIC LEFT
position=5;%where the angles are positioned
for angle=1:size(handles.KINEMATIC_LHL_menu,2)   
    if get(handles.KINEMATIC_LHL_menu(angle), 'value')
        nnplots=nnplots+1;
        subplot(n_plots,1,nnplots); hold on
        plot(handles.time_kinematic(first:last,2), handles.kinematic_L(first:last, position+angle),'LineWidth',1,'Color',[0 0 0]);hold on        
        switch get(handles.scale_menu, 'value')
            case 1, YL=ylim; axis([first_time last_time YL(1) YL(2)]);
            case 2, axis([first_time last_time str2double(get(handles.min_KINEMATIC(angle), 'string')) str2double(get(handles.max_KINEMATIC(angle), 'string'))]);
        end
        ylabel(handles.kin_L_label(angle));        
    end  
end

% GAIT
nnplots=nnplots+1;
subplot(n_plots, 1 ,nnplots)
for limb =1:2   
    if limb==1;columns=2;bar=2.5;end
    if limb==2;columns=7;bar=1;end
    
    for i =1:size(handles.GAIT_INFO,1)       
        % STANCE
        if isnan(handles.GAIT_INFO(i,columns:columns+1))~=1 & handles.GAIT_INFO(i,columns:columns+1)~=0
            x=[handles.GAIT_INFO(i,columns); handles.GAIT_INFO(i,columns); handles.GAIT_INFO(i,columns+1); handles.GAIT_INFO(i,columns+1)];
            y=[bar; bar+1; bar+1; bar];
            patch(x, y, [0.7 0.7 0.7]);           
            % DRAG
            if isnan(handles.GAIT_INFO(i,columns+2))~=1 & handles.GAIT_INFO(i,columns+2)~=0
                x=[handles.GAIT_INFO(i,columns+1); handles.GAIT_INFO(i,columns+1); handles.GAIT_INFO(i,columns+2); handles.GAIT_INFO(i,columns+2)];
                y=[bar; bar+1; bar+1; bar];
                patch(x, y, [1 0 0]);
            end
        end
    end %loop cycle
end % loop LIMB
axis([first_time last_time 0.5 3.5]);
ylabel('HINDLIMB');

% KINEMATIC RIGHT
for angle=1:size(handles.KINEMATIC_RHL_menu,2)
    if get(handles.KINEMATIC_RHL_menu(angle), 'value')
        nnplots=nnplots+1;
        subplot(n_plots,1,nnplots); hold on
        plot(handles.time_kinematic(first:last,2), handles.kinematic_R(first:last, position+angle),'LineWidth',1,'Color',[0 0 0]);hold on        
        switch get(handles.scale_menu, 'value')
            case 1, YL=ylim; axis([first_time last_time YL(1) YL(2)]);         
            case 2, axis([first_time last_time str2double(get(handles.min_KINEMATIC(angle), 'string')) str2double(get(handles.max_KINEMATIC(angle), 'string'))]);              
        end
        ylabel(handles.kin_R_label(angle));
    end
end

% CoM
for direction=1:size(handles.CoM_menu,2)    
    if get(handles.CoM_menu(direction), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1 ,nnplots)       
        plot(handles.CoM(first:last, 2), handles.CoM(first:last, 2+direction),'LineWidth',1,'Color',[0 0 0]);hold on       
        switch get(handles.scale_menu, 'value')          
            case 1, YL=ylim; axis([first_time last_time YL(1) YL(2)]);            
            case 2, axis([first_time last_time str2double(get(handles.min_BODY(direction), 'string')) str2double(get(handles.max_BODY(direction), 'string'))]);
        end        
        ylabel(handles.labelCoM(direction));      
    end   
end

% EMG
for emg=1:size(handles.EMG_menu,2)
    if get(handles.EMG_menu(emg), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1, nnplots); hold on        
        plot(handles.emg(first_emg:last_emg, 2), handles.emg(first_emg:last_emg, 2+emg),'LineWidth',1,'Color',[0 0 0]);hold on
        switch get(handles.scale_menu, 'value')           
            case 1, YL=ylim; axis([first_time last_time YL(1) YL(2)]);               
            case 2, axis([first_time last_time str2double(get(handles.min_EMG(emg), 'string')) str2double(get(handles.max_EMG(emg), 'string'))]);
        end       
        ylabel(char(handles.labelEMG(emg)));      
    end  
end

% FORCE
for force=1:size(handles.FORCE_menu,2)  
    if get(handles.FORCE_menu(force), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1 ,nnplots)       
        plot(handles.force(first_for:last_for, 2), handles.force(first_for:last_for, 2+force),'LineWidth',1,'Color',[0 0 0]);hold on       
        switch get(handles.scale_menu, 'value')           
            case 1, YL=ylim; axis([first_time last_time YL(1) YL(2)]);           
            case 2, axis([first_time last_time str2double(get(handles.min_FORCE(force), 'string')) str2double(get(handles.max_FORCE(force), 'string'))]);
        end
        ylabel(handles.labelFORCE(force));       
    end   
end

% CoP
for cop=1:size(handles.CoP_menu,2)    
    if get(handles.CoP_menu(cop), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1 ,nnplots)      
        plot(handles.DATA_CoP(first_CoP:last_CoP, 2), handles.DATA_CoP(first_CoP:last_CoP, 2+cop),'LineWidth',1,'Color',[0 0 0]);hold on
        axis([first_time last_time str2double(get(handles.min_CoP(cop), 'string')) str2double(get(handles.max_CoP(cop), 'string'))]); 
        ylabel(handles.labelCoP(cop));        
    end   
end

% NEURONS
for neu=1:size(handles.NEU_menu,2)
    if get(handles.NEU_menu(neu), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1, nnplots); hold on
        
        switch get(handles.NEU_FILTER,'value')            
            case 1, data_to_plot=handles.DATA_NEU(:, 2+neu);
            case 2, data_to_plot=moving_average2(handles.DATA_NEU(:, neu+2),5);
            case 3, data_to_plot=smoothJ2(handles.DATA_NEU(:, neu+2),3)';
                  data_to_plot=resample(data_to_plot, size(handles.DATA_NEU,1));
        end
        
        switch get(handles.NEU_PLOT, 'value')           
            case 1
                plot(handles.DATA_NEU(:, 2), data_to_plot,'LineWidth',1,'Color',[1 0 0]);hold on
                if get(handles.scale_menu, 'value')==1
                    YL=ylim; axis([first_time last_time 0 YL(2)]);
                end               
            case 2             
                X=linspace(1,length(handles.DATA_NEU)+1,length(handles.DATA_NEU)+1)';
                Y=linspace(1,2,2)';                
                pcolor([data_to_plot, data_to_plot]');
                shading interp
                C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [234/255 248/255 252/255], [1 1 1], [1 1 1],[1 1 1], [229/255 209/255 218/255 ], [255/255 124/255 128/255], [255/255 29/255 29/255])
                colormap('jet');
                set(gca,'XTickLabel',[]);
                axis([first_time*handles.fe_NEU last_time*handles.fe_NEU 1 2]);
        end      
        ylabel(['NEU #' num2str(neu)]);       
    end    
end

% KINEMATIC FORELIMB LEFT
if handles.FORELIMB
    position=5; %where the angles are positioned
    for angle=1:size(handles.KINEMATIC_LFL_menu,2)       
        if get(handles.KINEMATIC_LFL_menu(angle), 'value')
            nnplots=nnplots+1;
            subplot(n_plots,1,nnplots); hold on
            plot(handles.time_kinematic(first:last,2), handles.kinematic_LFL(first:last, position+angle),'LineWidth',1,'Color',[0 0 0]);hold on            
            switch get(handles.scale_menu, 'value')               
                case 1, YL=ylim; axis([first_time last_time YL(1) YL(2)]);                  
                case 2, axis([first_time last_time str2double(get(handles.min_KINEMATIC_FORELIMB(angle), 'string')) str2double(get(handles.max_KINEMATIC_FORELIMB(angle), 'string'))]);                   
            end
            ylabel(handles.kin_LFL_label(angle));           
        end        
    end
    
    % GAIT FORELIMB
    nnplots=nnplots+1;
    subplot(n_plots, 1 ,nnplots)
    
    for limb =1:2        
        if limb==1;columns=2;bar=2.5;end
        if limb==2;columns=7;bar=1;end
        
        for i =1:size(handles.GAIT_INFO_FORELIMB,1)           
            % STANCE
            if isnan(handles.GAIT_INFO_FORELIMB(i,columns:columns+1))~=1 & handles.GAIT_INFO_FORELIMB(i,columns:columns+1)~=0
                x=[handles.GAIT_INFO_FORELIMB(i,columns); handles.GAIT_INFO_FORELIMB(i,columns); handles.GAIT_INFO_FORELIMB(i,columns+1); handles.GAIT_INFO_FORELIMB(i,columns+1)];
                y=[bar; bar+1; bar+1; bar];
                patch(x, y, [0.7 0.7 0.7]);
            end
        end %loop cycle       
    end % loop LIMB
    axis([first_time last_time 0.5 3.5]);
    ylabel('FORELIMB');
    
    % KINEMATIC RIGHT
    for angle=1:size(handles.KINEMATIC_RFL_menu,2)
        
        if get(handles.KINEMATIC_RFL_menu(angle), 'value')
            nnplots=nnplots+1;
            subplot(n_plots,1,nnplots); hold on
            plot(handles.time_kinematic(first:last,2), handles.kinematic_RFL(first:last, position+angle),'LineWidth',1,'Color',[0 0 0]);hold on            
            switch get(handles.scale_menu, 'value')               
                case 1, YL=ylim; axis([first_time last_time YL(1) YL(2)]);                
                case 2, axis([first_time last_time str2double(get(handles.min_KINEMATIC_FORELIMB(angle), 'string')) str2double(get(handles.max_KINEMATIC_FORELIMB(angle), 'string'))]);                  
            end
            ylabel(handles.kin_RFL_label(angle));                  
        end       
    end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function onset_menu_Callback(hObject, eventdata, handles)
function onset_menu_CreateFcn(hObject, eventdata, handles)
function end_menu_Callback(hObject, eventdata, handles)
function end_menu_CreateFcn(hObject, eventdata, handles)
function n_cycle_menu_Callback(hObject, eventdata, handles)
function n_cycle_menu_CreateFcn(hObject, eventdata, handles)
function scale_menu_Callback(hObject, eventdata, handles)
function scale_menu_CreateFcn(hObject, eventdata, handles)
function figure1_ResizeFcn(hObject, eventdata, handles)

function filter_force_menu_Callback(hObject, eventdata, handles)
function filter_force_menu_CreateFcn(hObject, eventdata, handles)

function FORCEZ_Callback(hObject, eventdata, handles)
function FORCEY_Callback(hObject, eventdata, handles)
function FORCEX_Callback(hObject, eventdata, handles)
function forceXmax_Callback(hObject, eventdata, handles)
function forceXmax_CreateFcn(hObject, eventdata, handles)
function forceYmax_Callback(hObject, eventdata, handles)
function forceYmax_CreateFcn(hObject, eventdata, handles)
function forceZmax_Callback(hObject, eventdata, handles)
function forceZmax_CreateFcn(hObject, eventdata, handles)
function forceXmin_Callback(hObject, eventdata, handles)
function forceXmin_CreateFcn(hObject, eventdata, handles)
function forceYmin_Callback(hObject, eventdata, handles)
function forceYmin_CreateFcn(hObject, eventdata, handles)
function forceZmin_Callback(hObject, eventdata, handles)
function forceZmin_CreateFcn(hObject, eventdata, handles)

function hipL_menu_Callback(hObject, eventdata, handles)
function hip_min_Callback(hObject, eventdata, handles)
function hip_min_CreateFcn(hObject, eventdata, handles)
function hip_max_Callback(hObject, eventdata, handles)
function hip_max_CreateFcn(hObject, eventdata, handles)
function kneeL_menu_Callback(hObject, eventdata, handles)
function knee_min_Callback(hObject, eventdata, handles)
function knee_min_CreateFcn(hObject, eventdata, handles)
function knee_max_Callback(hObject, eventdata, handles)
function knee_max_CreateFcn(hObject, eventdata, handles)
function ankleL_menu_Callback(hObject, eventdata, handles)
function ankle_min_Callback(hObject, eventdata, handles)
function ankle_min_CreateFcn(hObject, eventdata, handles)
function ankle_max_Callback(hObject, eventdata, handles)
function ankle_max_CreateFcn(hObject, eventdata, handles)
function MTPL_menu_Callback(hObject, eventdata, handles)
function MTP_min_Callback(hObject, eventdata, handles)
function MTP_min_CreateFcn(hObject, eventdata, handles)
function MTP_max_Callback(hObject, eventdata, handles)
function MTP_max_CreateFcn(hObject, eventdata, handles)
function limbL_menu_Callback(hObject, eventdata, handles)
function limb_min_Callback(hObject, eventdata, handles)
function limb_min_CreateFcn(hObject, eventdata, handles)
function limb_max_Callback(hObject, eventdata, handles)
function limb_max_CreateFcn(hObject, eventdata, handles)
function limb_abbL_menu_Callback(hObject, eventdata, handles)
function limb_abb_min_Callback(hObject, eventdata, handles)
function limb_abb_min_CreateFcn(hObject, eventdata, handles)
function limb_abb_max_Callback(hObject, eventdata, handles)
function limb_abb_max_CreateFcn(hObject, eventdata, handles)
function foot_rot_min_Callback(hObject, eventdata, handles)
function foot_rot_min_CreateFcn(hObject, eventdata, handles)
function foot_rot_max_Callback(hObject, eventdata, handles)
function foot_rot_max_CreateFcn(hObject, eventdata, handles)
function foot_rotL_menu_Callback(hObject, eventdata, handles)
function foot_rotL_menu_CreateFcn(hObject, eventdata, handles)

function EMG1_menu_Callback(hObject, eventdata, handles)
function emg1max_Callback(hObject, eventdata, handles)
function emg1max_CreateFcn(hObject, eventdata, handles)
function EMG2_menu_Callback(hObject, eventdata, handles)
function emg2max_Callback(hObject, eventdata, handles)
function emg2max_CreateFcn(hObject, eventdata, handles)
function EMG3_menu_Callback(hObject, eventdata, handles)
function emg3max_Callback(hObject, eventdata, handles)
function emg3max_CreateFcn(hObject, eventdata, handles)
function EMG4_menu_Callback(hObject, eventdata, handles)
function emg4max_Callback(hObject, eventdata, handles)
function emg4max_CreateFcn(hObject, eventdata, handles)
function EMG5_menu_Callback(hObject, eventdata, handles)
function emg5max_Callback(hObject, eventdata, handles)
function emg5max_CreateFcn(hObject, eventdata, handles)
function EMG6_menu_Callback(hObject, eventdata, handles)
function emg6max_Callback(hObject, eventdata, handles)
function emg6max_CreateFcn(hObject, eventdata, handles)
function emg1min_Callback(hObject, eventdata, handles)
function emg1min_CreateFcn(hObject, eventdata, handles)
function emg2min_Callback(hObject, eventdata, handles)
function emg2min_CreateFcn(hObject, eventdata, handles)
function emg3min_Callback(hObject, eventdata, handles)
function emg3min_CreateFcn(hObject, eventdata, handles)
function emg4min_Callback(hObject, eventdata, handles)
function emg4min_CreateFcn(hObject, eventdata, handles)
function emg5min_Callback(hObject, eventdata, handles)
function emg5min_CreateFcn(hObject, eventdata, handles)
function emg6min_Callback(hObject, eventdata, handles)
function emg6min_CreateFcn(hObject, eventdata, handles)
function emg7max_Callback(hObject, eventdata, handles)
function emg7max_CreateFcn(hObject, eventdata, handles)
function emg8max_Callback(hObject, eventdata, handles)
function emg8max_CreateFcn(hObject, eventdata, handles)
function EMG7_menu_Callback(hObject, eventdata, handles)
function EMG8_menu_Callback(hObject, eventdata, handles)
function emg7min_Callback(hObject, eventdata, handles)
function emg7min_CreateFcn(hObject, eventdata, handles)
function emg8min_Callback(hObject, eventdata, handles)
function emg8min_CreateFcn(hObject, eventdata, handles)
function emg9max_Callback(hObject, eventdata, handles)
function emg9max_CreateFcn(hObject, eventdata, handles)
function emg10max_Callback(hObject, eventdata, handles)
function emg10max_CreateFcn(hObject, eventdata, handles)
function emg9min_Callback(hObject, eventdata, handles)
function emg9min_CreateFcn(hObject, eventdata, handles)
function emg10min_Callback(hObject, eventdata, handles)
function emg10min_CreateFcn(hObject, eventdata, handles)
function emg11max_Callback(hObject, eventdata, handles)
function emg11max_CreateFcn(hObject, eventdata, handles)
function emg12max_Callback(hObject, eventdata, handles)
function emg12max_CreateFcn(hObject, eventdata, handles)
function emg11min_Callback(hObject, eventdata, handles)
function emg11min_CreateFcn(hObject, eventdata, handles)
function emg12min_Callback(hObject, eventdata, handles)
function emg12min_CreateFcn(hObject, eventdata, handles)
function EMG9_menu_Callback(hObject, eventdata, handles)
function EMG10_menu_Callback(hObject, eventdata, handles)
function EMG11_menu_Callback(hObject, eventdata, handles)
function EMG12_menu_Callback(hObject, eventdata, handles)

function EMG13_menu_Callback(hObject, eventdata, handles)
function emg13max_Callback(hObject, eventdata, handles)
function emg13max_CreateFcn(hObject, eventdata, handles)
function EMG14_menu_Callback(hObject, eventdata, handles)
function emg14max_Callback(hObject, eventdata, handles)
function emg14max_CreateFcn(hObject, eventdata, handles)
function emg13min_Callback(hObject, eventdata, handles)
function emg13min_CreateFcn(hObject, eventdata, handles)
function emg14min_Callback(hObject, eventdata, handles)
function emg14min_CreateFcn(hObject, eventdata, handles)

function foot_rotR_menu_Callback(hObject, eventdata, handles)
function hipR_menu_Callback(hObject, eventdata, handles)
function kneeR_menu_Callback(hObject, eventdata, handles)
function ankleR_menu_Callback(hObject, eventdata, handles)
function MTPR_menu_Callback(hObject, eventdata, handles)
function limbR_menu_Callback(hObject, eventdata, handles)
function limb_abbR_menu_Callback(hObject, eventdata, handles)

function Lat_CoP_max_Callback(hObject, eventdata, handles)
function Lat_CoP_max_CreateFcn(hObject, eventdata, handles)
function Lat_CoP_min_Callback(hObject, eventdata, handles)
function Lat_CoP_min_CreateFcn(hObject, eventdata, handles)
function For_CoP_min_Callback(hObject, eventdata, handles)
function For_CoP_min_CreateFcn(hObject, eventdata, handles)
function Lat_CoP_Callback(hObject, eventdata, handles)
function For_CoP_Callback(hObject, eventdata, handles)
function For_CoP_max_Callback(hObject, eventdata, handles)
function For_CoP_max_CreateFcn(hObject, eventdata, handles)

function Elbow_min_Callback(hObject, eventdata, handles)
function Elbow_min_CreateFcn(hObject, eventdata, handles)
function Elbow_max_Callback(hObject, eventdata, handles)
function Elbow_max_CreateFcn(hObject, eventdata, handles)
function Wrist_min_Callback(hObject, eventdata, handles)
function Wrist_min_CreateFcn(hObject, eventdata, handles)
function Wrist_max_Callback(hObject, eventdata, handles)
function Wrist_max_CreateFcn(hObject, eventdata, handles)
function MCP_min_Callback(hObject, eventdata, handles)
function MCP_min_CreateFcn(hObject, eventdata, handles)
function MCP_max_Callback(hObject, eventdata, handles)
function MCP_max_CreateFcn(hObject, eventdata, handles)
function LimbFL_min_Callback(hObject, eventdata, handles)
function LimbFL_min_CreateFcn(hObject, eventdata, handles)
function LimbFL_max_Callback(hObject, eventdata, handles)
function LimbFL_max_CreateFcn(hObject, eventdata, handles)
function limbFL_abb_min_Callback(hObject, eventdata, handles)
function limbFL_abb_min_CreateFcn(hObject, eventdata, handles)
function limbFL_abb_max_Callback(hObject, eventdata, handles)
function limbFL_abb_max_CreateFcn(hObject, eventdata, handles)
function Hand_rot_min_Callback(hObject, eventdata, handles)
function Hand_rot_min_CreateFcn(hObject, eventdata, handles)
function Hand_rot_max_Callback(hObject, eventdata, handles)
function Hand_rot_max_CreateFcn(hObject, eventdata, handles)
function limb_abbFR_menu_Callback(hObject, eventdata, handles)
function LimbFR_menu_Callback(hObject, eventdata, handles)
function MCPR_menu_Callback(hObject, eventdata, handles)
function WristR_menu_Callback(hObject, eventdata, handles)
function ElbowR_menu_Callback(hObject, eventdata, handles)
function ShoulderR_menu_Callback(hObject, eventdata, handles)
function Hand_rotFR_menu_Callback(hObject, eventdata, handles)
function limb_abbFL_menu_Callback(hObject, eventdata, handles)
function LimbFL_menu_Callback(hObject, eventdata, handles)
function MCPL_menu_Callback(hObject, eventdata, handles)
function WristL_menu_Callback(hObject, eventdata, handles)
function ElbowL_menu_Callback(hObject, eventdata, handles)
function ShoulderL_menu_Callback(hObject, eventdata, handles)
function Hand_rotFL_menu_Callback(hObject, eventdata, handles)
function Shoulder_min_Callback(hObject, eventdata, handles)
function Shoulder_min_CreateFcn(hObject, eventdata, handles)
function Shoulder_max_Callback(hObject, eventdata, handles)
function Shoulder_max_CreateFcn(hObject, eventdata, handles)

function NEU13_menu_Callback(hObject, eventdata, handles)
function NEU12_menu_Callback(hObject, eventdata, handles)
function NEU11_menu_Callback(hObject, eventdata, handles)
function NEU10_menu_Callback(hObject, eventdata, handles)
function NEU8_menu_Callback(hObject, eventdata, handles)
function NEU7_menu_Callback(hObject, eventdata, handles)
function NEU6_menu_Callback(hObject, eventdata, handles)
function NEU5_menu_Callback(hObject, eventdata, handles)
function NEU4_menu_Callback(hObject, eventdata, handles)
function NEU3_menu_Callback(hObject, eventdata, handles)
function NEU2_menu_Callback(hObject, eventdata, handles)
function NEU1_menu_Callback(hObject, eventdata, handles)
function NEU9_menu_Callback(hObject, eventdata, handles)
function NEU_PLOT_Callback(hObject, eventdata, handles)
function NEU_PLOT_CreateFcn(hObject, eventdata, handles)
function NEU_FILTER_Callback(hObject, eventdata, handles)
function NEU_FILTER_CreateFcn(hObject, eventdata, handles)

function BODY_Xmax_Callback(hObject, eventdata, handles)
function BODY_Xmax_CreateFcn(hObject, eventdata, handles)
function BODY_Ymax_Callback(hObject, eventdata, handles)
function BODY_Ymax_CreateFcn(hObject, eventdata, handles)
function BODY_Zmax_Callback(hObject, eventdata, handles)
function BODY_Zmax_CreateFcn(hObject, eventdata, handles)
function BODY_Z_Callback(hObject, eventdata, handles)
function BODY_Y_Callback(hObject, eventdata, handles)
function BODY_X_Callback(hObject, eventdata, handles)
function BODY_Xmin_Callback(hObject, eventdata, handles)
function BODY_Xmin_CreateFcn(hObject, eventdata, handles)
function BODY_Ymin_Callback(hObject, eventdata, handles)
function BODY_Ymin_CreateFcn(hObject, eventdata, handles)
function BODY_Zmin_Callback(hObject, eventdata, handles)
function BODY_Zmin_CreateFcn(hObject, eventdata, handles)
