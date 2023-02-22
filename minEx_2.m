function varargout = minEx_2(handles, varargin)
varargin{1} = handles.Data_L;
varargin{2} = handles.Data_R;
varargin{3} = handles.TIME;
record_LTO = double(varargin{4});
record_LFS = double(varargin{6});
record_RTO  = double(varargin{5});
record_RFS = double(varargin{7});
uneven_l = varargin{8};
uneven_r = varargin{9};


handles.record_LTO = (record_LTO./200)+handles.TIME(1,1);
handles.record_LFS = (record_LFS./200)+handles.TIME(1,1);

handles.record_RTO = record_RTO./200+handles.TIME(1,1);
handles.record_RFS = record_RFS./200+handles.TIME(1,1);

if uneven_l == 1
    handles.THRESHOLD_L = record_LTO;
    [handles.record_LFS,handles.record_LTO] = event_detector(handles.Data_L, ...
        handles.THRESHOLD_L,handles.DATA_KIN(1,2), handles.KIN_freq);
end

record_LTO = repmat(handles.record_LTO,2,1);
record_LFS = repmat(handles.record_LFS,2,1);

disp(record_LTO);

y2=[min(handles.Data_L) max(handles.Data_L)]; %originally [0 1]

%frames = 0:1:1559;
%frames = 0:1:1421;

ax1 = subplot(2,1,1);
axes(ax1), hold off
plot(ax1, handles.TIME,handles.Data_L,'b'); % plot Left
xlabel('Time [s]'); ylabel('left MTP on vertical axis [mm]');
hold on

ax2 = subplot(2,1,2);
axes(ax2), hold off
plot(ax2, handles.TIME,handles.Data_R,'b'); % plot Right
xlabel('Time [s]'); ylabel('right MTP on vertical axis [mm]');
hold on

% plot LFS
hold on;
plot(ax1, handles.TIME,handles.Data_L,'b');
plot(ax1, record_LFS, y2,'r');
plot(ax1, record_LTO, y2,'g');
hold off;

ylim([min(handles.Data_R) max(handles.Data_R)]) % originally [0 1]
%THRESHOLD_R = 0.35;
hold off;

if uneven_r == 1
    handles.THRESHOLD_R = record_RTO;
    [handles.record_RFS,handles.record_RTO ] = event_detector(handles.Data_R, ...
        handles.THRESHOLD_R,handles.DATA_KIN(1,2), handles.KIN_freq);
end

record_RTO = repmat(handles.record_RTO,2,1);
record_RFS = repmat(handles.record_RFS,2,1);

% plot RFS
hold on;
plot(ax2,handles.TIME,handles.Data_R,'b');
plot(ax2,record_RFS, y2,'r');
plot(ax2,record_RTO, y2,'g');
hold off;
%% 
% ggait state following previous "THRESHOLD" step
% 
% 
% 
% The next steps to be taken from this state is as follows:
%% 
% * Press "SAVE" ==> Pop up "GAIT FILE CREATED"

handles.NEWNAME = [handles.FILENAME(1:end-4) ,'_GAIT.csv'];
filename = [handles.PATHNAME, handles.NEWNAME];
% Animal ID not used, thus set empty
subject = ' ';  % char(get(handles.EDanimal,'String')); 

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
    disp('Problem when saving the file')%,'Event_detection','error');
else
    fprintf(fid,'EVENTS \n');
    fprintf(fid,'Subject,Context,Name,Time (s),Description \n');
    fprintf(fid,p1');
    fprintf(fid,p2');
    fprintf(fid,p3');
    fprintf(fid,p4');
    if fclose(fid)==-1
        disp('Problem when saving the file')%,'Event_detection','error')
    else
        %disp('GAIT FILE CREATED')
    end
end

%varargout{1} = hObject;
varargout{1} = handles;
end
