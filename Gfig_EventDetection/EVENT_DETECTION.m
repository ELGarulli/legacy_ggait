%% EVENT_DETECTION
% Integrated in Ggait v9.0 by CamilleLG - 26.Sep.2013
% Last Modified by Jerome - v0.2 - 25.Sep.2013
% (created by Jerome on 19.Sep.2013)
% Last Modified by CamilleLG - 24.Oct.2013
%  - modification of extract_KINdata.m and code in "%% LOAD FILE KIN.CSV" part
%    to extract properly Z pos of LEFT and RIGHT MTP markers whatever their order in KIN file
% Last Modified by CamilleLG - 27.Nov.2013
%  - EVENT_DETECTION receive as input KINEMATIC data and ANGLE data
%    -> do not extract KINdata anymore
%    -> 


function varargout = EVENT_DETECTION(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EVENT_DETECTION_OpeningFcn, ...
                   'gui_OutputFcn',  @EVENT_DETECTION_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function EVENT_DETECTION_OpeningFcn(hObject, eventdata, handles, varargin)

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

%% PLOTS
axes(handles.plots(1)), hold off
plot(handles.plots(1),handles.TIME,handles.Data_L,'b'); % plot Left
xlabel('Time [s]'); ylabel('MTP on vertical axis [mm]');
hold on

axes(handles.plots(2)), hold off
plot(handles.plots(2),handles.TIME,handles.Data_R,'b'); % plot Right
xlabel('Time [s]'); ylabel('MTP on vertical axis [mm]');
hold on

guidata(hObject, handles);
uiwait

function varargout = EVENT_DETECTION_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.is_saved;
varargout{2} = handles.NEWNAME;
delete(handles.figure1)


function BNevent_reload_Callback(hObject, eventdata, handles)
handles.record_LFS=[];
handles.record_LTO=[];
handles.record_RFS=[];
handles.record_RTO=[];

%% PLOTS
cla(handles.axes1,'reset'), cla(handles.axes2,'reset')

axes(handles.plots(1)), hold off
plot(handles.plots(1),handles.TIME,handles.Data_L,'b'); % plot Left
ylabel('MTP on vertical axis [mm]');
hold on

axes(handles.plots(2)), hold off
plot(handles.plots(2),handles.TIME,handles.Data_R,'b'); % plot Right
xlabel('Time [s]'); ylabel('MTP on vertical axis [mm]');
hold on

guidata(hObject, handles);


function BNevent_writefile_Callback(hObject, eventdata, handles)
%% Export for gait.csv file
handles.NEWNAME = [handles.FILENAME(1:end-4) ,'_GAIT.csv'];
filename = [handles.PATHNAME, handles.NEWNAME];
subject = char(get(handles.EDanimal,'String'));

L = 'Left,';
R = 'Right,';
TO = 'Foot Off';
FS = 'Foot Strike';

p1 = [repmat(subject,size(handles.record_LFS')),repmat(',',size( handles.record_LFS')),repmat(L,size(handles.record_LFS')),repmat(FS,size(handles.record_LFS')), ...
    repmat(',',size( handles.record_LFS')), num2str(handles.record_LFS'), repmat(',',size( handles.record_LFS')), ...
    repmat(FS,size( handles.record_LFS')),repmat('\n',size( handles.record_LFS'))];
p2 = [repmat(subject,size(handles.record_LTO')),repmat(',',size( handles.record_LTO')),repmat(L,size(handles.record_LTO')),repmat(TO,size(handles.record_LTO')), ...
    repmat(',',size( handles.record_LTO')), num2str(handles.record_LTO'), repmat(',',size( handles.record_LTO')), ...
    repmat(TO,size( handles.record_LTO')),repmat('\n',size( handles.record_LTO'))];
p3 = [repmat(subject,size(handles.record_RFS')),repmat(',',size( handles.record_RFS')),repmat(R,size(handles.record_RFS')),repmat(FS,size(handles.record_RFS')), ...
    repmat(',',size( handles.record_RFS')), num2str(handles.record_RFS'), repmat(',',size( handles.record_RFS')), ...
    repmat(FS,size( handles.record_RFS')),repmat('\n',size( handles.record_RFS'))];
p4 = [repmat(subject,size(handles.record_RTO')),repmat(',',size( handles.record_RTO')),repmat(R,size(handles.record_RTO')),repmat(TO,size(handles.record_RTO')), ...
    repmat(',',size( handles.record_RTO')), num2str(handles.record_RTO'), repmat(',',size( handles.record_RTO')), ...
    repmat(TO,size( handles.record_RTO')),repmat('\n',size( handles.record_RTO'))];

fid = fopen(filename,'w');
if fid==-1
    display('Problem when saving the file')%,'Event_detection','error');
else
    fprintf(fid,'EVENTS \n');
    fprintf(fid,'Subject,Context,Name,Time (s),Description \n');
    fprintf(fid,p1');
    fprintf(fid,p2');
    fprintf(fid,p3');
    fprintf(fid,p4');
    if fclose(fid)==-1
        display('Problem when saving the file')%,'Event_detection','error')
    else
        handles.is_saved = 1;
        msgbox('GAIT FILE CREATED','EVENT DETECTION')
    end
end

guidata(hObject, handles);

function BNevent_quit_Callback(hObject, eventdata, handles)

if ~handles.is_saved
    display('Data were not saved')%,'Event_detection','warn');
end

guidata(hObject, handles);
uiresume;



function BNevent_threshold_Callback(hObject, eventdata, handles)
axes(handles.plots(1));
hold on
%ylim([0 1])
THRESHOLD_L=0.64;
%[~, THRESHOLD_L]=ginput(1);
hold off;

[handles.record_LFS,handles.record_LTO] = event_detector(handles.Data_L,THRESHOLD_L,handles.DATA_KIN(1,2), handles.KIN_freq);

record_LTO = repmat(handles.record_LTO,2,1);
record_LFS = repmat(handles.record_LFS,2,1);

y2=[0 1];

% plot LFS
hold on;
plot(handles.plots(1), handles.TIME,handles.Data_L,'b');
plot(handles.plots(1), record_LFS, y2,'r');
plot(handles.plots(1), record_LTO, y2,'g');

hold off;

axes(handles.plots(2));
hold on
ylim([0 1])
THRESHOLD_R = 0.12;
%[~, THRESHOLD_R]=ginput(1);
hold off;

[handles.record_RFS,handles.record_RTO ] = event_detector(handles.Data_R,THRESHOLD_R,handles.DATA_KIN(1,2), handles.KIN_freq);

record_RTO = repmat(handles.record_RTO,2,1);
record_RFS = repmat(handles.record_RFS,2,1);

% plot RFS
hold on;
plot(handles.plots(2),handles.TIME,handles.Data_R,'b');
plot(handles.plots(2),record_RFS, y2,'r');
plot(handles.plots(2),record_RTO, y2,'g');
hold off;


guidata(hObject, handles);

function BNevent_add_LTO_Callback(hObject, eventdata, handles)
axes(handles.plots(1));
hold on
ylim([0 1])
[Xtime1, Yaxe]=ginput(1);
hold off;

handles.record_LTO(end+1)=Xtime1;
handles.record_LTO = sort(handles.record_LTO);

record_LFS = repmat(handles.record_LFS,2,1);
record_LTO = repmat(handles.record_LTO,2,1);

y2=[0 1];

% plot LFS
plot(handles.plots(1),handles.TIME,handles.Data_L,'b');
hold on;
plot(handles.plots(1),record_LFS, y2,'r');
plot(handles.plots(1),record_LTO, y2,'g');
hold off;

guidata(hObject, handles);
function BNevent_add_LFS_Callback(hObject, eventdata, handles)
axes(handles.plots(1));
hold on
ylim([0 1])
[Xtime1, ~]=ginput(1);
hold off;

handles.record_LFS(end+1)=Xtime1;
handles.record_LFS = sort(handles.record_LFS);

record_LFS = repmat(handles.record_LFS,2,1);
record_LTO = repmat(handles.record_LTO,2,1);

y2=[0 1];

%plot LFS
plot(handles.plots(1),handles.TIME,handles.Data_L,'b');
hold on;
plot(handles.plots(1), record_LFS, y2,'r');
plot(handles.plots(1), record_LTO, y2,'g');
hold off;

guidata(hObject, handles);
function BNevent_add_RTO_Callback(hObject, eventdata, handles)
axes(handles.plots(2));
hold on
ylim([0 1])
[Xtime2, ~]=ginput(1);
hold off;

handles.record_RTO(end+1)=Xtime2;
handles.record_RTO = sort(handles.record_RTO);

record_RFS = repmat(handles.record_RFS,2,1);
record_RTO = repmat(handles.record_RTO,2,1);

y2=[0 1];

%plot RFS
plot(handles.plots(2),handles.TIME,handles.Data_R,'b');
hold on;
plot(handles.plots(2),record_RFS, y2,'r');
plot(handles.plots(2),record_RTO, y2,'g');
hold off;

guidata(hObject, handles);
function BNevent_add_RFS_Callback(hObject, eventdata, handles)
axes(handles.plots(2));
hold on
ylim([0 1])
[Xtime2, ~]=ginput(1);
hold off;

handles.record_RFS(end+1)=Xtime2;
handles.record_RFS = sort(handles.record_RFS);

record_RFS = repmat(handles.record_RFS,2,1);
record_RTO = repmat(handles.record_RTO,2,1);

y2=[0 1];

%plot RFS
plot(handles.plots(2),handles.TIME,handles.Data_R,'b');
hold on;
plot(handles.plots(2),record_RFS, y2,'r');
plot(handles.plots(2),record_RTO, y2,'g');
hold off;

guidata(hObject, handles);

function BNevent_remove_L_Callback(hObject, eventdata, handles)
axes(handles.plots(1));
hold on
ylim([0 1])
[Xtime, ~]=ginput(1);
hold off;

[to, pos_to] = min(abs( handles.record_LTO - Xtime));
[fs, pos_fs] = min(abs( handles.record_LFS - Xtime));

if to < fs
    handles.record_LTO(pos_to)=[];
else
    handles.record_LFS(pos_fs)=[];
end

%plot LFS, LTO
record_LFS = repmat(handles.record_LFS,2,1);
record_LTO = repmat(handles.record_LTO,2,1);
y2=[0 1];

plot(handles.plots(1),handles.TIME,handles.Data_L,'b');
hold on;
plot(handles.plots(1),record_LFS, y2,'r');
plot(handles.plots(1),record_LTO, y2,'g');
hold off;

guidata(hObject, handles);
function BNevent_remove_R_Callback(hObject, eventdata, handles)
axes(handles.plots(2));
hold on
ylim([0 1])
[Xtime, ~]=ginput(1);
hold off;

[to, pos_to] = min(abs( handles.record_RTO - Xtime));
[fs, pos_fs] = min(abs( handles.record_RFS - Xtime));

if to < fs
    handles.record_RTO(pos_to)=[];
else
    handles.record_RFS(pos_fs)=[];
end

%plot RFS, RTO
record_RFS = repmat(handles.record_RFS,2,1);
record_RTO = repmat(handles.record_RTO,2,1);
y2=[0 1];

plot(handles.plots(2),handles.TIME,handles.Data_R,'b');
hold on;
plot(handles.plots(2),record_RFS, y2,'r');
plot(handles.plots(2),record_RTO, y2,'g');
hold off;

guidata(hObject, handles);

function axes1_CreateFcn(hObject, eventdata, handles)
function axes2_CreateFcn(hObject, eventdata, handles)

function EDanimal_Callback(hObject, eventdata, handles)
function EDanimal_CreateFcn(hObject, eventdata, handles)
