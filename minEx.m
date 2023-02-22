%% ggait workflow w/o GUI
% 
% 
% This is a minimum example script to replicate the ggait workflow Evelyn showewd 
% me 2022-03-17. I divided this live script into sections, showing the workflow 
% along with the code. Code sections are naimed after the respective m-files they 
% have been taken from. Only code that is executed given the workflow was taken 
% over into this script. The tools used to extract it was the MATLAB Debugger 
% along with GUIDE. The graphical workflow can be divided into the following steps:
%% 
% * Open ggait
% * Unselect all ratio-controls in the SET UP - pane
% * Select ""Multi-EMGs #341" and "BIPEDAL"
% * Press "LOAD" button ==> A new winbdow "Event Detection" opens.
%% 
% 
%% Minimum code provoking these steps
% Initial clean-up and code executed from ggait.m 

% Init
function varargout = minEx(varargin)

handles.gait_type = 1; %bipedal
handles.DATA_FORCE = []; 
handles.is_swing = 0;
handles.is_force = 0;
handles.is_ladder = 0;
% Code from ggait
handles.filterKIN_freq = 10;
% Code from BNload_Callback

handles.FILENAME = 'runway_06.c3d';
handles.PATHNAME = 'C:\Users\wenge\Documents\GitHub\gait-new-repo\';

% The variable handles.isforce contains 0

% Load KIN data from c3d file
[first_frame,num_frame,num_markers,handles.freq,handles.freq_analog,...
    handles.F,handles.M,handles.CP,handles.coord,handles.mkr,handles.MarkerName, ...
    handles.emg_analog,handles.AnalogName] = load_VICON_c3d([handles.PATHNAME,handles.FILENAME], 0);


[handles.mkr,handles.MarkerName]=ChangeNameMkr(handles.mkr,handles.MarkerName); %problem with capital letters


OrderMarkerName={'Lshoulder' 'LCrest'  'LHip'  'LKnee'  'LAnkle'  'LMTP'  'LTip' ...
        'Rshoulder'  'RCrest' 'RHip'   'RKnee'  'RAnkle'  'RMTP'  'RTip'...
        'Lelbow' 'Lwrist'  'Relbow' 'Rwrist' 'LScap' 'RScap' ...
        'T12' 'HeadFront' 'LEar' 'REar' 'LToe' 'RToe' 'Trunk' 'COP_FP1' ...
        'RawCentreFP1' 'VECTIP_FP1' 'Force_FP1' 'RawForceFP1' 'RawMomentFP1'};
handles.CoP_position=82; % (length(OrderMarkerName)-6)*3+1;

if ~isfield(handles.mkr, 'RToe') % no Toe marker
    handles.mkr.RToe.x=zeros(1,size(handles.mkr.RMTP.x,2));
    handles.mkr.RToe.y=handles.mkr.RToe.x;
    handles.mkr.RToe.z=handles.mkr.RToe.x;
    handles.mkr.LToe = handles.mkr.RToe;
end

if ~isfield(handles.mkr, 'RTip') % no TIP marker
    handles.mkr.RTip.x=zeros(1,size(handles.mkr.RMTP.x,2));
    handles.mkr.RTip.y=handles.mkr.RTip.x;
    handles.mkr.RTip.z=handles.mkr.RTip.x;
    handles.mkr.LTip = handles.mkr.RTip;
end

handles.DATA_KIN(1:num_frame,1)= first_frame:1:first_frame+num_frame-1;
TIME_DATA_KIN=handles.DATA_KIN(:,1);

col=2;
for ii=1:length(OrderMarkerName)
    if isfield(handles.mkr,(char(OrderMarkerName(ii))))
        handles.DATA_KIN(1:num_frame,col)=handles.mkr.(char(OrderMarkerName(ii))).x;
        handles.DATA_KIN(1:num_frame,col+1)=  handles.mkr.(char(OrderMarkerName(ii))).y;
        handles.DATA_KIN(1:num_frame,col+2)= handles.mkr.(char(OrderMarkerName(ii))).z;
    end
    col=col+3;
end

handles.DATA_KIN=handles.DATA_KIN(:,2:43); %bipedal task with only lower markers

for i=1:3:size(handles.DATA_KIN, 2)
    handles.DATA_KIN(:, i:i+2)=[handles.DATA_KIN(:, i+1), handles.DATA_KIN(:, i+2), handles.DATA_KIN(:, i)];
end
handles.DATA_KIN=handles.DATA_KIN./10; % convert kin data to cm

for i =1:size(handles.DATA_KIN,2)
    handles.DATA_KIN(:,i) = preprocessingDATA_fill_gaps(handles.DATA_KIN(:,i),1);
end

handles.DATA_KIN = preprocessingDATA_filter_KIN(handles.DATA_KIN, handles.freq, handles.filterKIN_freq);
handles.DATA_KIN = [TIME_DATA_KIN, TIME_DATA_KIN./handles.freq, handles.DATA_KIN]; % add frame number and time
handles.mkr = preprocessingDATA_filter_MKR(handles.mkr,handles.MarkerName, handles.freq, handles.filterKIN_freq);
handles.mkr = comp_velacc(handles.mkr, handles.MarkerName, handles.freq);

handles.DATA_EMG = handles.DATA_KIN(:,1:2);
handles.emgChRight=[];
handles.emgChLeft=[];
handles.emgChLeft_n=0;
handles.emgChRight_n=0;
handles.emgChRight_FL=[];
handles.emgChLeft_FL=[];
handles.emgChLeft_FL_n=0;
handles.emgChRight_FL_n=0;

handles.ANGLE_trunk=comp_KIN_trunk(handles.DATA_KIN(:,4+2:6+2),handles.DATA_KIN(:,25+2:27+2), ...
                handles.DATA_KIN(:,7+2:9+2),handles.DATA_KIN(:,28+2:30+2), ...
                handles.DATA_KIN(:,4+2:6+2),handles.DATA_KIN(:,25+2:27+2));

handles.ANGLE_RHL=comp_ANGLE(handles.DATA_KIN(:,25+2:42+2),handles.ANGLE_trunk(:,8));
    handles.ANGLE_LHL=comp_ANGLE(handles.DATA_KIN(:,4+2:21+2),handles.ANGLE_trunk(:,9));

% Compute HINDLIMB SPEEDS
    handles.ANGLEspeed_LHL=comp_ANGLE_speed(handles.ANGLE_LHL, handles.freq);
    handles.ANGLEspeed_RHL=comp_ANGLE_speed(handles.ANGLE_RHL, handles.freq);
    handles.ANGLEspeed_trunk=comp_ANGLE_speed(handles.ANGLE_trunk, handles.freq);


%[gaitfile_written handles.gaitFILENAME] = EVENT_DETECTION(1, char(handles.PATHNAME), char(handles.FILENAME), handles.DATA_KIN, ...
%        handles.ANGLE_LHL, handles.ANGLE_RHL);
% Code from EVENT_DETECTION.m

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

ax1 = subplot(2,1,1);
plot(ax1, handles.TIME,handles.Data_L,'b'); % plot Left
xlabel('Time [s]'); ylabel('MTP on vertical axis [mm]');
hold on

ax2 = subplot(2,1,2);
plot(ax2, handles.TIME,handles.Data_R,'b'); % plot Right
xlabel('Time [s]'); ylabel('MTP on vertical axis [mm]');
hold on

% ggait state following previous "LOAD" steps
% 
% 
% The next steps to be taken from this state is as follows:
%% 
% * Press "THRESHOLD" 

THRESHOLD_L=0.6594;

[handles.record_LFS,handles.record_LTO] = event_detector(handles.Data_L,THRESHOLD_L,handles.DATA_KIN(1,2), handles.KIN_freq);

record_LTO = repmat(handles.record_LTO,2,1);
record_LFS = repmat(handles.record_LFS,2,1);

y2=[0 1];

% plot LFS
hold on;
plot(ax1, handles.TIME,handles.Data_L,'b');
plot(ax1, record_LFS, y2,'r');
plot(ax1, record_LTO, y2,'g');
hold off;

ylim([0 1])
THRESHOLD_R = 0.35;
hold off;

[handles.record_RFS,handles.record_RTO ] = event_detector(handles.Data_R,THRESHOLD_R,handles.DATA_KIN(1,2), handles.KIN_freq);

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
        disp('GAIT FILE CREATED')
    end
end

handles.animal_iD = 1;
handles.conds1={'P10'; 'P13'; 'P16'};
handles.conds2={'tonic_E1'; 'tonic_E2'; 'tonic_E3'; 'tonic_E4'; ...
            'tonic_E5'; 'tonic_E6'; 'tonic_E7'; 'tonic_E8'; ...
            'tonic_left_right'; 'phaston_left_right'; 'extratonic_left_right'; ...
            'tonic_right'; 'phaston_right'; 'extratonic_right'; ...
            'tonic_left'; 'phaston_left'; 'extratonic_left'};
handles.conds3={'TRAINING'; 'NO TRAINING'};
handles.bwss=100:-5:0;
handles.speeds=[0;9;13];

handles.speed = 1;
handles.bws = 1;
handles.cond1 = 1;
handles.cond2 = 1; 
handles.cond3 = 1; 
handles.gaitFILENAME = [handles.FILENAME(1:end-4),'_GAIT.csv'];

%%%In case of Multi-EMGs project, correct EMG here =========================================
if handles.animal_iD==341
    handles.DATA_EMG_header=correction_EMGnames(handles.DATA_EMG_header, handles.animal_iD);
end

[~, handles.gait_data]=load_VICON_GAIT(handles.gaitFILENAME, handles.PATHNAME); 

% FRAME and TIME
handles.DATA_KIN_FRAME = handles.DATA_KIN(:,1:2);

handles.is_event_swing = 0; %This might have to be updated later, 0 for now 

if handles.is_event_swing % if swing has been detected as "GENERAL EVENT" in GAIT file
    [handles.GAIT_INFO, handles.GAIT_INFO_FL]=create_GAIT_INFO_swing(handles.DATA_KIN(:,1:2), handles.gait_data);
else [handles.GAIT_INFO, handles.GAIT_INFO_FL]=create_GAIT_INFO(handles.DATA_KIN(:,1:2), handles.gait_data);
end

% SWINGs
if  handles.is_swing==0
    handles.GAIT_INFO=params_swing(handles.GAIT_INFO,handles.DATA_KIN_FRAME, handles.ANGLE_LHL, handles.ANGLE_RHL);
    %if handles.gait_type==2
     %   [handles.GAIT_INFO_FL]=params_swing(handles.GAIT_INFO_FL,handles.DATA_KIN_FRAME, handles.ANGLE_LFL, handles.ANGLE_RFL);
    %end
    %if handles.setup == 14 % MOUSE project
    %    handles.GAIT_INFO(:,[3,8])=handles.GAIT_INFO(:,[4,9]);
    %end
    handles.is_swing=1;
end
handles.GAIT_INFO = check_gaitinfo(handles.GAIT_INFO);
[handles.GAIT_SS, handles.FORCE_SS]=params_stance_swing(handles.GAIT_INFO, handles.GAIT_INFO_FL, handles.DATA_KIN_FRAME, handles.DATA_FORCE);
if handles.is_force
    [handles.FORCE_L, handles.FORCE_R]=params_force(handles.DATA_FORCE, handles.FORCE_SS);
end

% GAIT PARAMS 1
side = 1; % left HINDLIMB
[handles.GAIT_LHL, handles.GAIT_INFO]=params_gait(handles.GAIT_INFO, handles.GAIT_INFO_FL, side,...
    handles.animal_iD, handles.cond1, handles.cond2, handles.speed, handles.bws, ...
    [handles.DATA_KIN_FRAME handles.DATA_KIN(:,4+2:21+2)], handles.DATA_KIN(:,37+2:39+2), ...
    handles.ANGLE_LHL, handles.ANGLE_trunk, handles.ANGLEspeed_LHL, handles.ANGLEspeed_trunk, ...
    handles.GAIT_SS, handles.DATA_FORCE, handles.FORCE_SS,  ...
    handles.is_swing);

side = 2; % right HINDLIMB
[handles.GAIT_RHL, handles.GAIT_INFO]=params_gait(handles.GAIT_INFO, handles.GAIT_INFO_FL, side,...
    handles.animal_iD, handles.cond1, handles.cond2, handles.speed, handles.bws, ...
    [handles.DATA_KIN_FRAME handles.DATA_KIN(:,25+2:42+2)], handles.DATA_KIN(:,16+2:18+2), ...
    handles.ANGLE_RHL, handles.ANGLE_trunk, handles.ANGLEspeed_RHL, handles.ANGLEspeed_trunk, ...
    handles.GAIT_SS, handles.DATA_FORCE, handles.FORCE_SS,  ...
    handles.is_swing);

% GAIT PARAMS 2 - PCA, FFT and Correlation
handles.GAIT_LHL = params_PCA_FFT_cross(handles.GAIT_LHL, handles.DATA_KIN_FRAME(:,2), handles.ANGLE_LHL, ...
    handles.ANGLE_RHL, handles.ANGLE_LHL, handles.freq);
handles.GAIT_RHL = params_PCA_FFT_cross(handles.GAIT_RHL, handles.DATA_KIN_FRAME(:,2), handles.ANGLE_RHL, ...
    handles.ANGLE_RHL, handles.ANGLE_LHL, handles.freq);

% GAIT PARAMS 3 - Kinematic timing
handles.GAIT_LHL = params_KIN_timing(handles.GAIT_LHL, handles.DATA_KIN_FRAME(:,2), handles.ANGLE_LHL);
handles.GAIT_RHL = params_KIN_timing(handles.GAIT_RHL, handles.DATA_KIN_FRAME(:,2), handles.ANGLE_RHL);

% SELECT ALL CYCLES A PRIORI
handles.GAIT_LHL(:,111)=1;
handles.GAIT_RHL(:,111)=1;

% LADDER condition
if handles.is_ladder
    [handles.GAIT_RHL, handles.GAIT_LHL]=PROJECT_LADDER_analysis(handles.mkr, handles.GAIT_INFO, ...
        handles.GAIT_LHL, handles.GAIT_RHL, handles.DATA_KIN_FRAME, handles.PATHNAME, handles.FILENAME, handles.is_right);
end


varargout{1} = handles;
end

%% 
% This concludes the ggait workflow. Final steps in the GUI to clean up are
%% 
% * Press "OK"
% * Press "QUIT"
% * Close ggait window
%% Potential for optimization
%% 
% * Replace final section by table datatype and use "writetable" command. Reduces 
% length of last section considerably
% * Use Live Task to calculate MAX/MIN/...See menu insert above..
%% 
% 
% 
%