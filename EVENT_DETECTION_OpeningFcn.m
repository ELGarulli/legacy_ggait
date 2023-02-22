function varargout = EVENT_DETECTION_OpeningFcn(hObject, eventdata, handles, varargin)

% INPUTS
handles.PATHNAME = varargin{2};
handles.FILENAME = varargin{3};
handles.DATA_KIN = varargin{4};
handles.ANGLE_LHL = varargin{5};
handles.ANGLE_RHL = varargin{6};

% INTERNAL VARIABLES
handles.is_saved = 0;   % bool, true once file has been saved
handles.plots=[handles.axes1,handles.axes2]; % Holds the two axes
cla(handles.axes1,'reset'), cla(handles.axes2,'reset')
handles.KIN_freq=200; %Hz
handles.TIME = handles.DATA_KIN(:,2);

YMTP_L = 19; % Y pos of LEFT MTP marker (vertical axis)
YMTP_R = 40; % Y pos of RIGHT MTP marker (vertical axis)

% normalize data
handles.DATA_KIN(:,3:end) = (handles.DATA_KIN(:,3:end) ...
    - repmat(min(handles.DATA_KIN(:,3:end)),size(handles.DATA_KIN,1),1)) ...
    ./repmat(max(handles.DATA_KIN(:,3:end)) - min(handles.DATA_KIN(:,3:end)),size(handles.DATA_KIN,1),1);

% smooth MTP position on Z axis (vertical axis)
handles.Data_L = smooth(handles.DATA_KIN(:,YMTP_L),5); 
handles.Data_R = smooth(handles.DATA_KIN(:,YMTP_R),5); 

%% PLOTS - plots the first time (before threshold is set and additional events are marked)
axes(handles.plots(1)), hold off
plot(handles.plots(1),handles.TIME,handles.Data_L,'b'); % plot Left
xlabel('Time [s]'); ylabel('MTP on vertical axis [mm]');
hold on

axes(handles.plots(2)), hold off
plot(handles.plots(2),handles.TIME,handles.Data_R,'b'); % plot Right
xlabel('Time [s]'); ylabel('MTP on vertical axis [mm]');
hold on

varargout{1} = hObject;
varargout{2} = handles;
guidata(hObject, handles);
uiwait