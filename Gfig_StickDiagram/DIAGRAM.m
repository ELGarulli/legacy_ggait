function varargout = DIAGRAM(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DIAGRAM_OpeningFcn, ...
    'gui_OutputFcn',  @DIAGRAM_OutputFcn, ...
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
function DIAGRAM_OpeningFcn(hObject, eventdata, handles, varargin)

handles.LIMB=varargin{1};
handles.FILENAME=varargin{2};
handles.freq=varargin{3};
handles.speeds=varargin{4};
handles.GAIT_LHL=varargin{5};
handles.GAIT_RHL=varargin{6};
handles.GAIT_LFL=varargin{7};
handles.GAIT_RFL=varargin{8};
handles.DATA_KIN=varargin{9};
handles.speed_in=varargin{10};
handles.mkr=varargin{11};
handles.conds=varargin{12};
handles.is_ladder=varargin{13};

handles.TIMES = handles.DATA_KIN(:,1:2);

set(handles.name_file, 'string', handles.FILENAME);
set(handles.limb, 'string', handles.LIMB);
set(handles.speed, 'string', handles.speeds);
set(handles.speed, 'value', handles.speed_in);

handles.rate_menu=[1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 20; 30; 40; 50; 100];
set(handles.rate, 'string', handles.rate_menu);
set(handles.rate, 'value', 3);

set(handles.is_TIP,'string',{'YES','NO'})
set(handles.is_TIP, 'value', 1);

handles.dimension_menu=[2; 3];
set(handles.DIMENSION, 'string', handles.dimension_menu);
set(handles.DIMENSION, 'value', 1);

set(handles.scaling, 'value', 1);
set(handles.seq_plane, 'string', {'XY','ZY','XZ','All'})

set(handles.stance_after,'value',0);
set(handles.stance_before,'value',0);
set(handles.swing_before,'value',0);
set(handles.swing_after,'value',0);

handles.output = hObject;

guidata(hObject, handles);
limb_Callback(hObject, eventdata, handles)
function varargout = DIAGRAM_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
function limb_Callback(hObject, eventdata, handles)

switch get(handles.limb, 'value')
    case 1
        set(handles.first_cycle,'String',handles.GAIT_LHL(:,6));
        set(handles.end_cycle,'String',handles.GAIT_LHL(:,6));
        set(handles.step_stick,'String',handles.GAIT_LHL(:,6));
        set(handles.first_time,'String',handles.GAIT_LHL(1,7));
        set(handles.end_time,'String',handles.GAIT_LHL(end,8));
    case 2
        set(handles.first_cycle,'String',handles.GAIT_RHL(:,6));
        set(handles.end_cycle,'String',handles.GAIT_RHL(:,6));
        set(handles.step_stick,'String',handles.GAIT_RHL(:,6));
        set(handles.first_time,'value',handles.GAIT_RHL(1,7));
        set(handles.end_time,'value',handles.GAIT_RHL(1,8));
    case 3
        set(handles.first_cycle,'String',handles.GAIT_LFL(:,6));
        set(handles.end_cycle,'String',handles.GAIT_LFL(:,6));
        set(handles.step_stick,'String',handles.GAIT_LFL(:,6));
        set(handles.first_time,'value',handles.GAIT_LFL(1,7));
        set(handles.end_time,'value',handles.GAIT_LFL(1,8));
    case 4
        set(handles.first_cycle,'String',handles.GAIT_RFL(:,6));
        set(handles.end_cycle,'String',handles.GAIT_RFL(:,6));
        set(handles.step_stick,'String',handles.GAIT_RFL(:,6));
        set(handles.first_time,'value',handles.GAIT_RFL(1,7));
        set(handles.end_time,'value',handles.GAIT_RFL(1,8));
end

%% STICK DIAGRAM SINGLE
function gait_cycle_Callback(hObject, eventdata, handles)

switch get(handles.limb, 'value')
    case 1
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,6:20); % no TIP
        else data=handles.DATA_KIN(:,6:23); end
        GAIT=handles.GAIT_LHL;
    case 2
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,27:41); % no TIP
        else data=handles.DATA_KIN(:,27:44); end
        GAIT=handles.GAIT_RHL;
    case 3
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2)]; % no TIP
        else data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2), handles.DATA_KIN(:,73+2:75+2)]; end
        GAIT=handles.GAIT_LFL;
    case 4
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2)]; % no TIP
        else data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2), handles.DATA_KIN(:,76+2:78+2)]; end        
        GAIT=handles.GAIT_RFL;
end

onset_frame=find(handles.TIMES(:,2)==GAIT(get(handles.step_stick, 'value'),7));
end_frame=find(handles.TIMES(:,2)==GAIT(get(handles.step_stick, 'value'),8));
swing_frame=find(handles.TIMES(:,2)==GAIT(get(handles.step_stick, 'value'),14));
drag_frame=find(handles.TIMES(:,2)==GAIT(get(handles.step_stick, 'value'),62));

plotStick_gaitcycle(data, onset_frame, swing_frame, drag_frame, end_frame, ...
    round(str2double(get(handles.stance_before, 'String'))), ...
    round(str2double(get(handles.stance_after, 'String'))), ...
    round(str2double(get(handles.swing_before, 'String'))), ...
    round(str2double(get(handles.swing_after, 'String'))), ...
    handles.speeds(get(handles.speed, 'value')), ...
    handles.freq, handles.rate_menu(get(handles.rate, 'value')), ...
    get(handles.DIMENSION, 'value'), size(data,2)./3, get(handles.scaling, 'value'));

%% SWINGS
function swings_Callback(hObject, eventdata, handles)

switch get(handles.limb, 'value')
    case 1
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,6:20); % no TIP
        else data=handles.DATA_KIN(:,6:23); end
        GAIT=handles.GAIT_LHL;
    case 2
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,27:41); % no TIP
        else data=handles.DATA_KIN(:,27:44); end
        GAIT=handles.GAIT_RHL;
    case 3
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2)]; % no TIP
        else data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2), handles.DATA_KIN(:,73+2:75+2)]; end
        GAIT=handles.GAIT_LFL;
    case 4
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2)]; % no TIP
        else data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2), handles.DATA_KIN(:,76+2:78+2)]; end        
        GAIT=handles.GAIT_RFL;
end

plotStick_swings(handles.TIMES, data, GAIT, handles.speeds(get(handles.speed, 'value')),...
    handles.freq, handles.rate_menu(get(handles.rate, 'value')), get(handles.DIMENSION, 'value'), size(data,2)./3);

%% STANCES
function stances_Callback(hObject, eventdata, handles)

switch get(handles.limb, 'value')
    case 1
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,6:20); % no TIP
        else data=handles.DATA_KIN(:,6:23); end
        GAIT=handles.GAIT_LHL;
    case 2
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,27:41); % no TIP
        else data=handles.DATA_KIN(:,27:44); end
        GAIT=handles.GAIT_RHL;
    case 3
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2)]; % no TIP
        else data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2), handles.DATA_KIN(:,73+2:75+2)]; end
        GAIT=handles.GAIT_LFL;
    case 4
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2)]; % no TIP
        else data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2), handles.DATA_KIN(:,76+2:78+2)]; end        
        GAIT=handles.GAIT_RFL;
end

plotStick_stances(handles.TIMES, data, GAIT, handles.speeds(get(handles.speed, 'value')), handles.freq, ...
    handles.rate_menu(get(handles.rate, 'value')), get(handles.DIMENSION, 'value'), size(data,2)./3);

%% SEQUENCES
function gait_sequence_Callback(hObject, eventdata, handles)

switch get(handles.limb, 'value')
    case 1
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,6:20); % no TIP
        else data=handles.DATA_KIN(:,6:23); end
        GAIT=handles.GAIT_LHL;
        limb='L';
    case 2
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,27:41); % no TIP
        else data=handles.DATA_KIN(:,27:44); end
        GAIT=handles.GAIT_RHL;
        limb='R';
    case 3
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2)]; % no TIP
        else data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2), handles.DATA_KIN(:,73+2:75+2)]; end
        GAIT=handles.GAIT_LFL;
        limb='L';
    case 4
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2)]; % no TIP
        else data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2), handles.DATA_KIN(:,76+2:78+2)]; end        
        GAIT=handles.GAIT_RFL;
        limb='R';
end

switch get(handles.seq_plane,'Value')
    case 1 % XY plane
        plotStick_sequences(handles.TIMES, data, GAIT, get(handles.first_cycle,'value'), get(handles.end_cycle,'value'), handles.speeds(get(handles.speed, 'value')),...
                handles.freq, handles.rate_menu(get(handles.rate, 'value')),size(data,2)./3, 1);
    case 2 % ZY plane
        plotStick_sequences(handles.TIMES, data, GAIT, get(handles.first_cycle,'value'), get(handles.end_cycle,'value'), handles.speeds(get(handles.speed, 'value')),...
                handles.freq, handles.rate_menu(get(handles.rate, 'value')),size(data,2)./3, 2);
    case 3 % XZ plane
        plotStick_sequences(handles.TIMES, data, GAIT, get(handles.first_cycle,'value'), get(handles.end_cycle,'value'), handles.speeds(get(handles.speed, 'value')),...
                handles.freq, handles.rate_menu(get(handles.rate, 'value')),size(data,2)./3, 3);
    case 4 % All planes
        for plane=1:3
            plotStick_sequences(handles.TIMES, data, GAIT, get(handles.first_cycle,'value'), get(handles.end_cycle,'value'), handles.speeds(get(handles.speed, 'value')),...
                handles.freq, handles.rate_menu(get(handles.rate, 'value')),size(data,2)./3, plane);
        end
end

if handles.is_ladder % LADDER
    end_ladder=30;
    data_rightX=[]; data_rightY=[]; data_leftX=[]; data_leftY=[];
    while ~isfield(handles.mkr,(strcat('RS',num2str(end_ladder))))
        end_ladder=end_ladder-1;
    end
    for ii=1:end_ladder
        data_rightX = [data_rightX, mean(handles.mkr.(strcat('RS',num2str(ii))).y)./10];
        data_rightY = [data_rightY, mean(handles.mkr.(strcat('RS',num2str(ii))).z)./10];
        data_leftX = [data_leftX, mean(handles.mkr.(strcat('LS',num2str(ii))).y)./10];
        data_leftY = [data_leftY, mean(handles.mkr.(strcat('LS',num2str(ii))).z)./10];
    end  
    %left ladder
    plot(data_leftX,data_leftY,'ok','MarkerEdgeColor',[51 51 51]./255,'MarkerFaceColor',[51 51 51]./255,'MarkerSize',7)
    %right ladder
    plot(data_rightX,data_rightY,'ok','MarkerEdgeColor',[151 151 151]./255,'MarkerFaceColor',[151 151 151]./255,'MarkerSize',7)
    %legend('Rungs markers right-side','Rungs markers left-side',2);
    axis equal
elseif isfield(handles.mkr, 'RS5') | isfield(handles.mkr, 'RS1') % STAIRS
    XSTAIRS=[]; YSTAIRS=[]; ZSTAIRS=[];
    if isfield(handles.mkr, 'RS1')==0 | isfield(handles.mkr, 'LS1')==0,
        start=2;
    else start=1;
    end
    if isfield(handles.mkr, 'RS9')==0 |  isfield(handles.mkr, 'LS9')==0,
        end1=8;
    else end1=8;
    end
    for ii=start:end1,
        name=strcat(limb,'S',num2str(ii));
        XSTAIRS=[XSTAIRS mean(handles.mkr.(name).y)-2]./10;
        YSTAIRS=[YSTAIRS mean(handles.mkr.(name).z)+2]./10;
        ZSTAIRS=[ZSTAIRS mean(handles.mkr.(name).x)]./10;
    end
    line(XSTAIRS,YSTAIRS,'Color','k','LineWidth',2)
    axis equal
end

%% STICK SEQUENCES
function stick_sequence_Callback(hObject, eventdata, handles)

FrameStart = handles.TIMES(1,1);
PlotStart = round(str2double(get(handles.first_time,'string'))*handles.freq)-FrameStart;
PlotStop = round(str2double(get(handles.end_time,'string'))*handles.freq)-FrameStart;

switch get(handles.limb, 'value')
    case 1
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,6:20); % no TIP
        else data=handles.DATA_KIN(:,6:23); end
        GAIT=handles.GAIT_LHL;
    case 2
        if get(handles.is_TIP, 'value')==2
            data=handles.DATA_KIN(:,27:41); % no TIP
        else data=handles.DATA_KIN(:,27:44); end
        GAIT=handles.GAIT_RHL;
    case 3
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2)]; % no TIP
        else data=[handles.DATA_KIN(:,55+2:57+2), handles.DATA_KIN(:,1+2:3+2), handles.DATA_KIN(:,43+2:48+2), handles.DATA_KIN(:,73+2:75+2)]; end
        GAIT=handles.GAIT_LFL;
    case 4
        if get(handles.is_TIP, 'value')==2
            data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2)]; % no TIP
        else data=[handles.DATA_KIN(:,58+2:60+2), handles.DATA_KIN(:,22+2:24+2), handles.DATA_KIN(:,49+2:54+2), handles.DATA_KIN(:,76+2:78+2)]; end        
        GAIT=handles.GAIT_RFL;
end

plane=1; %plane XY
plotStick_stick(data, PlotStart, PlotStop, handles.speeds(get(handles.speed, 'value')),...
    handles.freq, handles.rate_menu(get(handles.rate, 'value')),size(data,2)./3, plane);


%===================================================================================================
function limb_CreateFcn(hObject, eventdata, handles)
function name_file_Callback(hObject, eventdata, handles)
function name_file_CreateFcn(hObject, eventdata, handles)
function step_stick_Callback(hObject, eventdata, handles)
function step_stick_CreateFcn(hObject, eventdata, handles)
function first_cycle_Callback(hObject, eventdata, handles)
function first_cycle_CreateFcn(hObject, eventdata, handles)
function end_cycle_Callback(hObject, eventdata, handles)
function end_cycle_CreateFcn(hObject, eventdata, handles)
function rate_Callback(hObject, eventdata, handles)
function rate_CreateFcn(hObject, eventdata, handles)
function speed_Callback(hObject, eventdata, handles)
function speed_CreateFcn(hObject, eventdata, handles)
function swing_before_Callback(hObject, eventdata, handles)
function swing_before_CreateFcn(hObject, eventdata, handles)
function swing_after_Callback(hObject, eventdata, handles)
function swing_after_CreateFcn(hObject, eventdata, handles)
function stance_before_Callback(hObject, eventdata, handles)
function stance_before_CreateFcn(hObject, eventdata, handles)
function stance_after_Callback(hObject, eventdata, handles)
function stance_after_CreateFcn(hObject, eventdata, handles)
function DIMENSION_Callback(hObject, eventdata, handles)
function DIMENSION_CreateFcn(hObject, eventdata, handles)
function scaling_Callback(hObject, eventdata, handles)
function scaling_CreateFcn(hObject, eventdata, handles)
function first_time_Callback(hObject, eventdata, handles)
function first_time_CreateFcn(hObject, eventdata, handles)
function end_time_Callback(hObject, eventdata, handles)
function end_time_CreateFcn(hObject, eventdata, handles)
function is_TIP_Callback(hObject, eventdata, handles)
function is_TIP_CreateFcn(hObject, eventdata, handles)
function seq_plane_Callback(hObject, eventdata, handles)
function seq_plane_CreateFcn(hObject, eventdata, handles)
