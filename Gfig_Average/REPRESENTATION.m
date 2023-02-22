function varargout = REPRESENTATION(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @REPRESENTATION_OpeningFcn, ...
    'gui_OutputFcn',  @REPRESENTATION_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function REPRESENTATION_OpeningFcn(hObject, eventdata, handles, varargin)

handles.name=varargin{1};
handles.gait_info=varargin{2};
handles.kinematic_mean=varargin{3};
handles.emg_mean=varargin{4};
handles.force_mean=varargin{5};
handles.labelEMG=varargin{6};
handles.nEMG=varargin{7};
handles.fe=varargin{8};
handles.fe_EMG=varargin{9};
handles.fe_FOR=varargin{10};
handles.CoP_mean=varargin{11};
handles.limb=varargin{12};

switch handles.limb
    case 1
        handles.kin_label={'LIMB', 'HIP', 'KNEE', 'ANKLE', 'MTP', 'LIMB Abb', 'FOOT Rot'};  
    case 0
        handles.kin_label={'LIMB', 'SHOULDER', 'ELBOW', 'WRIST', 'MCP', 'LIMB Abb', 'HAND Rot'};
end
handles.labelFORCE={'X (N)' 'Y (N)' 'Z (N)'};
handles.labelCoP={'MEDIO-LAT' 'FORWARD'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up KINEMATIC
handles.select_menu={'YES', 'NO'};
handles.KINEMATIC_menu=[handles.limb_menu, handles.hip_menu, handles.knee_menu,handles.ankle_menu,handles.MTP_menu,handles.limb_abb_menu, handles.foot_rot_menu];
handles.min_KINEMATIC=[handles.limb_min, handles.hip_min, handles.knee_min, handles.ankle_min, handles.MTP_min, handles.limb_abb_min, handles.foot_rot_min];
handles.max_KINEMATIC=[handles.limb_max, handles.hip_max, handles.knee_max, handles.ankle_max, handles.MTP_max, handles.limb_abb_max, handles.foot_rot_max];
for i=1:7
    set(handles.KINEMATIC_menu(i), 'String', handles.kin_label(i));
end
set(handles.KINEMATIC_menu, 'value', 0);
set(handles.limb_menu, 'value', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up EMG
handles.EMG_menu=[handles.EMG1_menu, handles.EMG2_menu,handles.EMG3_menu,handles.EMG4_menu,handles.EMG5_menu,handles.EMG6_menu...
    handles.EMG7_menu, handles.EMG8_menu,handles.EMG9_menu,handles.EMG10_menu,handles.EMG11_menu,handles.EMG12_menu];
handles.max_EMG=[handles.emg1max, handles.emg2max, handles.emg3max, handles.emg4max, handles.emg5max, handles.emg6max...
    handles.emg7max, handles.emg8max, handles.emg9max, handles.emg10max, handles.emg11max, handles.emg12max];
handles.min_EMG=[handles.emg1min, handles.emg2min, handles.emg3min, handles.emg4min, handles.emg5min, handles.emg6min...
    handles.emg7min, handles.emg8min, handles.emg9min, handles.emg10min, handles.emg11min, handles.emg12min];

set(handles.EMG_menu, 'value', 0);
for ch=1:handles.nEMG
    set(handles.EMG_menu(ch), 'string', handles.labelEMG(ch));
end
if handles.nEMG<12
    set(handles.EMG_menu(handles.nEMG+1:12),'Enable','off');
    set(handles.max_EMG(handles.nEMG+1:12),'Enable','off');
    set(handles.min_EMG(handles.nEMG+1:12),'Enable','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up FORCE and CoP
handles.FORCE_menu=[handles.FORCEX, handles.FORCEY, handles.FORCEZ];
handles.max_FORCE=[handles.forceXmax, handles.forceYmax, handles.forceZmax];
handles.min_FORCE=[handles.forceXmin, handles.forceYmin, handles.forceZmin];
handles.Cop_menu=[handles.Cop_LAT, handles.Cop_FW];
handles.min_CoP=[handles.Cop_LATmin, handles.Cop_FWmin];
handles.max_CoP=[handles.Cop_LATmax, handles.Cop_FWmax];

set(handles.FORCE_menu, 'value', 0);
set(handles.Cop_menu, 'value', 0);

if isempty(handles.force_mean)
    set(handles.FORCE_menu,'Enable','off');
    set(handles.max_FORCE,'Enable','off');
    set(handles.min_FORCE,'Enable','off');
    set(handles.Cop_menu,'Enable','off');
    set(handles.min_CoP,'Enable','off');
    set(handles.max_CoP,'Enable','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up figure option
handles.error_menu_options={'NONE', 'LINE SE', 'SURFACE SE'};
set(handles.error_menu, 'string', handles.error_menu_options);
set(handles.error_menu, 'value', 3);

handles.filter_emg_menu_options={'NONE', 'FILTER', 'MOVING AVERAGE'};
set(handles.filter_emg_menu, 'string', handles.filter_emg_menu_options);
set(handles.filter_emg_menu, 'value', 3);

handles.filter_force_menu_options={'NONE', 'FILTER', 'MOVING AVERAGE'};
set(handles.filter_force_menu, 'string', handles.filter_force_menu_options);
set(handles.filter_force_menu, 'value', 3);

handles.n_cycle_menu_options={'SINGLE', 'DOUBLE'};
set(handles.n_cycle_menu, 'string', handles.n_cycle_menu_options);
set(handles.n_cycle_menu, 'value', 2);

handles.scale_menu_options={'AUTOSCALE', 'CUSTOM'};
set(handles.scale_menu, 'string', handles.scale_menu_options);
set(handles.scale_menu, 'value', 1);

handles.output = hObject;

guidata(hObject, handles);

function varargout = REPRESENTATION_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function figure_average_Callback(hObject, eventdata, handles)

%% Set up figure topology
n_plots=1;
for i=1:size(handles.KINEMATIC_menu,2)
    if get(handles.KINEMATIC_menu(i), 'value')
        n_plots=n_plots+1;
    end
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
for i=1:size(handles.Cop_menu,2)
    if get(handles.Cop_menu(i), 'value')
        n_plots=n_plots+1;
    end
end

%% prepare data
KIN=handles.kinematic_mean;
EMG=[];
FORCE=[];
CoP=[];

if ~isempty(handles.emg_mean)    
    switch get(handles.filter_emg_menu, 'value')        
        case 1, EMG=handles.emg_mean;
        case 2
            EMG=comp_filter(handles.emg_mean, 80, [], handles.fe_EMG, 5, 1);
            EMG=resample(handles.emg_mean,100);
        case 3 
            for i=1:size(handles.emg_mean, 2);
                EMG(:,i) = moving_average2(handles.emg_mean(:,i),20);
            end
            EMG=resample(EMG,100);
    end
end

if ~isempty(handles.force_mean)    
    switch get(handles.filter_force_menu, 'value')       
        case 1, FORCE = handles.force_mean;
        case 2
            FORCE = comp_filter(handles.force_mean, 80, [], handles.fe_FOR, 5, 1);
            FORCE = resample(FORCE,100);
        case 3            
            for i=1:size(handles.force_mean, 2);
                FORCE(:,i) = moving_average2(handles.force_mean(:,i),5);
            end            
            FORCE=resample(FORCE,100);
    end   
end

if ~isempty(handles.CoP_mean)   
    switch get(handles.filter_force_menu, 'value')        
        case 1, CoP=handles.CoP_mean;
        case 2, CoP=comp_filter(handles.CoP_mean, 20, [], handles.fe, 5, 1);
        case 3            
            for i=1:size(handles.CoP_mean, 2);
                CoP(:,i) = moving_average2(handles.CoP_mean(:,i),5);
            end          
    end    
end

switch get(handles.n_cycle_menu, 'value')   
    case 1       
    case 2       
        KIN=[KIN; KIN];
        EMG=[EMG; EMG];
        FORCE=[FORCE; FORCE];
        CoP=[CoP;CoP];
end


%% PLOT data
nnplots=0;
figure(200),clf,set_myFig(figure(200),600,600,200,200)
subplot(n_plots,1,1), title(handles.name);

% KINEMATIC
position=5;%where the angle are positioned
for angle=1:size(handles.KINEMATIC_menu,2)   
    if get(handles.KINEMATIC_menu(angle), 'value')
        nnplots=nnplots+1;
        subplot(n_plots,1,nnplots); hold on       
        if get(handles.error_menu,'value')==3           
            for i=1:size(KIN, 1)-1
                x=[i, i, i+1, i+1];
                y=[KIN(i,angle+position+24), KIN(i,angle+position+12), KIN(i+1,angle+position+12), KIN(i+1,angle+position+24)];
                patch(x, y, [0.5 0.5 0.5], 'edgecolor', [0.5 0.5 0.5]);hold on
            end           
        end
        
        if get(handles.error_menu, 'value')==2 | get(handles.error_menu, 'value')==3
            plot(KIN(:,angle+position+12),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(KIN(:,angle+position+24),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
        end
        
        plot(KIN(:,position+angle),'LineWidth',2,'Color',[0 0 0]);hold on       
        if get(handles.scale_menu, 'value')==2           
            switch get(handles.n_cycle_menu, 'value')
                case 1
                    axis([0 100 str2double(get(handles.min_KINEMATIC(angle), 'string')) str2double(get(handles.max_KINEMATIC(angle), 'string'))]);
                    set(gca,'XTick',[0 100]);
                case 2
                    axis([0 200 str2double(get(handles.min_KINEMATIC(angle), 'string')) str2double(get(handles.max_KINEMATIC(angle), 'string'))]);
                    set(gca,'XTick',[0 100 200]);
            end
        end
        ylabel(handles.kin_label(angle));        
    end   
end

% EMG
for emg=1:size(handles.EMG_menu,2)   
    if get(handles.EMG_menu(emg), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1, nnplots); hold on
        
        if get(handles.error_menu,'value')==3           
            for i=1:size(EMG, 1)-1
                x=[i, i, i+1, i+1];
                y=[EMG(i,emg+2*size(EMG,2)/3), EMG(i,emg+size(EMG,2)/3), EMG(i+1,emg+size(EMG,2)/3), EMG(i+1,emg+2*size(EMG,2)/3)];
                patch(x, y, [0.5 0.5 0.5], 'edgecolor', [0.5 0.5 0.5]);hold on
            end           
        end
        
        if get(handles.error_menu, 'value')==2 | get(handles.error_menu, 'value')==3
            plot(EMG(:,emg+size(EMG,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(EMG(:,emg+2*size(EMG,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
        end
        
        plot(EMG(:,emg),'LineWidth',2,'Color',[0 0 0]);hold on
        
        if get(handles.scale_menu, 'value')==2           
            switch get(handles.n_cycle_menu, 'value')
                case 1
                    axis([0 100 str2double(get(handles.min_EMG(emg), 'string')) str2double(get(handles.max_EMG(emg), 'string'))]);
                    set(gca,'XTick',[0 100]);
                case 2
                    axis([0 200 str2double(get(handles.min_EMG(emg), 'string')) str2double(get(handles.max_EMG(emg), 'string'))]);
                    set(gca,'XTick',[0 100 200]);
            end
        end       
        ylabel(char(handles.labelEMG(emg)));      
    end    
end

% FORCE
for force=1:size(handles.FORCE_menu,2)   
    if get(handles.FORCE_menu(force), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1 ,nnplots)
        
        if get(handles.error_menu,'value')==3          
            for i=1:size(FORCE, 1)-1
                x=[i, i, i+1, i+1];
                y=[FORCE(i,force+2*size(FORCE,2)/3), FORCE(i,force+size(FORCE,2)/3), FORCE(i+1,force+size(FORCE,2)/3), FORCE(i+1,force+2*size(FORCE,2)/3)];
                patch(x, y, [0.5 0.5 0.5], 'edgecolor', [0.5 0.5 0.5]);hold on
            end           
        end
        
        if get(handles.error_menu, 'value')==2 | get(handles.error_menu, 'value')==3
            plot(FORCE(:,force+size(FORCE,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(FORCE(:,force+2*size(FORCE,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
        end
        
        plot(FORCE(:,force),'LineWidth',2,'Color',[0 0 0]);hold on
       
        if get(handles.scale_menu, 'value')==2
            switch get(handles.n_cycle_menu, 'value')
                case 1
                    axis([0 100 str2double(get(handles.min_FORCE(force), 'string')) str2double(get(handles.max_FORCE(force), 'string'))]);
                    set(gca,'XTick',[0 100]);
                case 2
                    axis([0 200 str2double(get(handles.min_FORCE(force), 'string')) str2double(get(handles.max_FORCE(force), 'string'))]);
                    set(gca,'XTick',[0 100 200]);
            end
        end        
        ylabel(handles.labelFORCE(force));        
    end    
end

% CoP
for cop=1:size(handles.Cop_menu,2)   
    if get(handles.Cop_menu(cop), 'value')
        nnplots=nnplots+1;
        subplot(n_plots, 1 ,nnplots)
        
        if get(handles.error_menu,'value')==3            
            for i=1:size(CoP, 1)-1
                x=[i, i, i+1, i+1];
                y=[CoP(i,cop+2*size(CoP,2)/3), CoP(i,cop+size(CoP,2)/3), CoP(i+1,cop+size(CoP,2)/3), CoP(i+1,cop+2*size(CoP,2)/3)];
                patch(x, y, [0.5 0.5 0.5], 'edgecolor', [0.5 0.5 0.5]);hold on
            end           
        end
        
        if get(handles.error_menu, 'value')==2 | get(handles.error_menu, 'value')==3
            plot(CoP(:,cop+size(CoP,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
            plot(CoP(:,cop+2*size(CoP,2)/3),'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
        end
        
        plot(CoP(:,cop),'LineWidth',2,'Color',[0 0 0]);hold on
        
        if get(handles.scale_menu, 'value')==2
            switch get(handles.n_cycle_menu, 'value')
                case 1
                    axis([0 100 str2double(get(handles.min_CoP(cop), 'string')) str2double(get(handles.max_CoP(cop), 'string'))]);
                    set(gca,'XTick',[0 100]);
                case 2
                    axis([0 200 str2double(get(handles.min_CoP(cop), 'string'))  str2double(get(handles.max_CoP(cop), 'string'))]);
                    set(gca,'XTick',[0 100 200]);
            end
        end       
        ylabel(handles.labelCoP(cop));        
    end  
end

% GAIT
nnplots=nnplots+1;
subplot(n_plots, 1 ,nnplots)
switch get(handles.n_cycle_menu, 'value')
    case 1, patch([0, 0, 100, 100], [0, 1, 1, 0],[1 1 1]);
    case 2, patch([0, 0, 200, 200], [0, 1, 1, 0],[1 1 1]);
end

for i=1:get(handles.n_cycle_menu, 'value')  
    if i==1, offet=0; else offet=100; end
    patch([offet+0, offet+0, offet+mean(handles.gait_info(:,17)), offet+mean(handles.gait_info(:,17))], [0, 1, 1, 0],[0.5 0.5 0.5]);axis tight
    patch([offet+mean(handles.gait_info(:,17))-std(handles.gait_info(:,17))/size(handles.gait_info(:,17),1)^0.5, offet+mean(handles.gait_info(:,17))-std(handles.gait_info(:,17))/size(handles.gait_info(:,17),1)^0.5, offet+mean(handles.gait_info(:,17)), offet+mean(handles.gait_info(:,17))], [0.49, 0.51, 0.51, 0.49],[1 0 0]);axis tight
    patch([offet+mean(handles.gait_info(:,17)), offet+mean(handles.gait_info(:,17)), offet+mean(handles.gait_info(:,17))+(100-mean(handles.gait_info(:,17)))*mean(handles.gait_info(:,64))/100, offet+mean(handles.gait_info(:,17))+(100-mean(handles.gait_info(:,17)))*mean(handles.gait_info(:,64))/100], [0, 1, 1, 0],[1 0 0]);axis tight
    patch([offet+mean(handles.gait_info(:,17))+(100-mean(handles.gait_info(:,17)))*mean(handles.gait_info(:,64))/100, offet+mean(handles.gait_info(:,17))+(100-mean(handles.gait_info(:,17)))*mean(handles.gait_info(:,64))/100,offet+mean(handles.gait_info(:,17))+(100-mean(handles.gait_info(:,17)))*mean(handles.gait_info(:,64))/100+(100-mean(handles.gait_info(:,17)))*(std(handles.gait_info(:,64))/size(handles.gait_info(:,17),1)^0.5)/100, offet+mean(handles.gait_info(:,17))+(100-mean(handles.gait_info(:,17)))*mean(handles.gait_info(:,64))/100+(100-mean(handles.gait_info(:,17)))*(std(handles.gait_info(:,64))/size(handles.gait_info(:,17),1)^0.5)/100], [0.49, 0.51, 0.51, 0.49],[0.2 0.2 0.2]);axis tight   
end

switch get(handles.n_cycle_menu, 'value')
    case 1, axis([0 100 0 1]);axis off
    case 2, axis([0 200 0 1]);axis off
end

ylabel('STANCE');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function n_cycle_menu_Callback(hObject, eventdata, handles)
function n_cycle_menu_CreateFcn(hObject, eventdata, handles)
function scale_menu_Callback(hObject, eventdata, handles)
function scale_menu_CreateFcn(hObject, eventdata, handles)
function sequence_figure_Callback(hObject, eventdata, handles)
function error_menu_Callback(hObject, eventdata, handles)
function error_menu_CreateFcn(hObject, eventdata, handles)
function filter_emg_menu_Callback(hObject, eventdata, handles)
function filter_emg_menu_CreateFcn(hObject, eventdata, handles)
function filter_force_menu_Callback(hObject, eventdata, handles)
function filter_force_menu_CreateFcn(hObject, eventdata, handles)
function figure1_ResizeFcn(hObject, eventdata, handles)

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

function hip_menu_Callback(hObject, eventdata, handles)
function hip_min_Callback(hObject, eventdata, handles)
function hip_min_CreateFcn(hObject, eventdata, handles)
function hip_max_Callback(hObject, eventdata, handles)
function hip_max_CreateFcn(hObject, eventdata, handles)
function knee_menu_Callback(hObject, eventdata, handles)
function knee_menu_CreateFcn(hObject, eventdata, handles)
function knee_min_Callback(hObject, eventdata, handles)
function knee_min_CreateFcn(hObject, eventdata, handles)
function knee_max_Callback(hObject, eventdata, handles)
function knee_max_CreateFcn(hObject, eventdata, handles)
function ankle_menu_Callback(hObject, eventdata, handles)
function ankle_menu_CreateFcn(hObject, eventdata, handles)
function ankle_min_Callback(hObject, eventdata, handles)
function ankle_min_CreateFcn(hObject, eventdata, handles)
function ankle_max_Callback(hObject, eventdata, handles)
function ankle_max_CreateFcn(hObject, eventdata, handles)
function MTP_menu_Callback(hObject, eventdata, handles)
function MTP_menu_CreateFcn(hObject, eventdata, handles)
function MTP_min_Callback(hObject, eventdata, handles)
function MTP_min_CreateFcn(hObject, eventdata, handles)
function MTP_max_Callback(hObject, eventdata, handles)
function MTP_max_CreateFcn(hObject, eventdata, handles)
function limb_menu_Callback(hObject, eventdata, handles)
function limb_menu_CreateFcn(hObject, eventdata, handles)
function limb_min_Callback(hObject, eventdata, handles)
function limb_min_CreateFcn(hObject, eventdata, handles)
function limb_max_Callback(hObject, eventdata, handles)
function limb_max_CreateFcn(hObject, eventdata, handles)
function limb_abb_menu_Callback(hObject, eventdata, handles)
function limb_abb_menu_CreateFcn(hObject, eventdata, handles)
function limb_abb_min_Callback(hObject, eventdata, handles)
function limb_abb_min_CreateFcn(hObject, eventdata, handles)
function limb_abb_max_Callback(hObject, eventdata, handles)
function limb_abb_max_CreateFcn(hObject, eventdata, handles)
function foot_rot_min_Callback(hObject, eventdata, handles)
function foot_rot_min_CreateFcn(hObject, eventdata, handles)
function foot_rot_max_Callback(hObject, eventdata, handles)
function foot_rot_max_CreateFcn(hObject, eventdata, handles)
function foot_rot_menu_Callback(hObject, eventdata, handles)

function Cop_LATmax_Callback(hObject, eventdata, handles)
function Cop_LATmax_CreateFcn(hObject, eventdata, handles)
function Cop_LATmin_Callback(hObject, eventdata, handles)
function Cop_LATmin_CreateFcn(hObject, eventdata, handles)
function Cop_FWmax_Callback(hObject, eventdata, handles)
function Cop_FWmax_CreateFcn(hObject, eventdata, handles)
function Cop_FW_Callback(hObject, eventdata, handles)
function Cop_LAT_Callback(hObject, eventdata, handles)
function Cop_FWmin_Callback(hObject, eventdata, handles)
function Cop_FWmin_CreateFcn(hObject, eventdata, handles)

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
function emg7max_Callback(hObject, eventdata, handles)
function emg7max_CreateFcn(hObject, eventdata, handles)
function emg8max_Callback(hObject, eventdata, handles)
function emg8max_CreateFcn(hObject, eventdata, handles)
function emg9max_Callback(hObject, eventdata, handles)
function emg9max_CreateFcn(hObject, eventdata, handles)
function emg10max_Callback(hObject, eventdata, handles)
function emg10max_CreateFcn(hObject, eventdata, handles)
function emg11max_Callback(hObject, eventdata, handles)
function emg11max_CreateFcn(hObject, eventdata, handles)
function emg12max_Callback(hObject, eventdata, handles)
function emg12max_CreateFcn(hObject, eventdata, handles)
function EMG12_menu_Callback(hObject, eventdata, handles)
function EMG11_menu_Callback(hObject, eventdata, handles)
function EMG10_menu_Callback(hObject, eventdata, handles)
function EMG9_menu_Callback(hObject, eventdata, handles)
function EMG8_menu_Callback(hObject, eventdata, handles)
function EMG7_menu_Callback(hObject, eventdata, handles)
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
function emg7min_Callback(hObject, eventdata, handles)
function emg7min_CreateFcn(hObject, eventdata, handles)
function emg8min_Callback(hObject, eventdata, handles)
function emg8min_CreateFcn(hObject, eventdata, handles)
function emg9min_Callback(hObject, eventdata, handles)
function emg9min_CreateFcn(hObject, eventdata, handles)
function emg10min_Callback(hObject, eventdata, handles)
function emg10min_CreateFcn(hObject, eventdata, handles)
function emg11min_Callback(hObject, eventdata, handles)
function emg11min_CreateFcn(hObject, eventdata, handles)
function emg12min_Callback(hObject, eventdata, handles)
function emg12min_CreateFcn(hObject, eventdata, handles)
