function varargout = minEx_1(handles, varargin)
Setup = handles.setup;

% Load KIN data from c3d file
[handles.first_frame,num_frame,num_markers,handles.freq,...
    handles.F,handles.M,handles.CP,handles.coord,handles.mkr,handles.MarkerName] = load_VICON_c3d([handles.PATHNAME,handles.FILENAME], 0);


[handles.mkr,handles.MarkerName]=ChangeNameMkr(handles.mkr,handles.MarkerName); %problem with capital letters


OrderMarkerName={'Lshoulder' 'LCrest'  'LHIP'  'LKnee'  'LAnkle'  'LMTP'  'LTip' ...
        'Rshoulder'  'RCrest' 'RHip'   'RKnee'  'RAnkle'  'RMTP'  'RTip'...
        'Lelbow' 'Lwrist'  'Relbow' 'Rwrist' 'LScap' 'RScap' ...
        'T12' 'HeadFront' 'LEar' 'REar' 'LToe' 'RToe' 'Trunk' 'COP_FP1' ...
        'RawCentreFP1' 'VECTIP_FP1' 'Force_FP1' 'RawForceFP1' 'RawMomentFP1'};

% OrderMarkerName={'RShoulder' 'RCrest'  'RHip'  'RKnee'  'RAnkle'  'RMTP'   ...
%         'Lshoulder'  'LCrest' 'LHip'   'LKnee'  'LAnkle'  'LMTP'  'RTip' 'LTip'...
%         'Lelbow' 'Lwrist'  'Relbow' 'Rwrist' 'LScap' 'RScap' ...
%         'T12' 'HeadFront' 'LEar' 'REar' 'LToe' 'RToe' 'Trunk' 'COP_FP1' ...
%         'RawCentreFP1' 'VECTIP_FP1' 'Force_FP1' 'RawForceFP1' 'RawMomentFP1'};

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

if strcmp(handles.setups(Setup),'MOUSE') %MOUSE PROJECT (no TIP marker, no Scap marker)
    [handles.mkr] = PROJECT_MOUSE_mkr(handles.mkr);
elseif strcmp(handles.setups(Setup),'HUMAN LU') || strcmp(handles.setups(Setup),'HUMAN LOCOMOTION'), %HUMAN PROJECT (the horizontal plane is not correct)
    [handles.mkr] = PROJECT_HUMAN_setup(handles.mkr,OrderMarkerName);
end

handles.DATA_KIN(1:num_frame,1)= handles.first_frame:1:handles.first_frame+num_frame-1;
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

if isfield(handles.mkr,'Relbow'),
    if isfield(handles.mkr,'RScap'),
        handles.DATA_KIN=handles.DATA_KIN(:,2:61); %bipedal task with upper markers and Scapula
    else handles.DATA_KIN=handles.DATA_KIN(:,2:55); %bipedal task with upper markers
    end
else handles.DATA_KIN=handles.DATA_KIN(:,2:43); %bipedal task with only lower markers
end

% reorder matrix DATA_KIN
% -> X is forward direction; Y is vertical direction; Z is lateral direction
for i=1:3:size(handles.DATA_KIN, 2),
    if ~isempty(strfind(handles.FILENAME, 'FW-')) %Nad inverse forward direction (end filename FW-)
        handles.DATA_KIN(:, i:i+2)=[-handles.DATA_KIN(:, i+1), handles.DATA_KIN(:, i+2), -handles.DATA_KIN(:, i)];
    else
        handles.DATA_KIN(:, i:i+2)=[handles.DATA_KIN(:, i+1), handles.DATA_KIN(:, i+2), handles.DATA_KIN(:, i)];
    end
end
handles.DATA_KIN=handles.DATA_KIN./10; % convert kin data to cm
for i =1:size(handles.DATA_KIN,2)
    handles.DATA_KIN(:,i) = preprocessingDATA_fill_gaps(handles.DATA_KIN(:,i),1);
end

handles.DATA_KIN = preprocessingDATA_filter_KIN(handles.DATA_KIN, handles.freq, handles.filterKIN_freq);
handles.DATA_KIN = [TIME_DATA_KIN, TIME_DATA_KIN./handles.freq, handles.DATA_KIN]; % add frame number and time
handles.mkr = preprocessingDATA_filter_MKR(handles.mkr,handles.MarkerName, handles.freq, handles.filterKIN_freq);
handles.mkr = comp_velacc(handles.mkr, handles.MarkerName, handles.freq);

if isempty(handles.DATA_KIN)
    handles.DATA_KIN=[handles.DATA_EMG(:,1:2) zeros(size(handles.DATA_EMG,1),81)];
    handles.ANGLE_RHL=NaN(size(handles.DATA_EMG,1),12);
    handles.ANGLE_LHL=NaN(size(handles.DATA_EMG,1),12);
    handles.ANGLE_trunk=NaN(size(handles.DATA_EMG,1),15);
    handles.ANGLEspeed_LHL=NaN(size(handles.DATA_EMG,1),12);
    handles.ANGLEspeed_RHL=NaN(size(handles.DATA_EMG,1),12);
    handles.ANGLEspeed_trunk=NaN(size(handles.DATA_EMG,1),15);
    handles.freq=200;
end

handles.ANGLE_trunk=comp_KIN_trunk(handles.DATA_KIN(:,1+2:3+2),handles.DATA_KIN(:,22+2:24+2), ...
                handles.DATA_KIN(:,7+2:9+2),handles.DATA_KIN(:,28+2:30+2), ...
                handles.DATA_KIN(:,4+2:6+2),handles.DATA_KIN(:,25+2:27+2));

handles.ANGLE_RHL=comp_ANGLE(handles.DATA_KIN(:,25+2:42+2),handles.ANGLE_trunk(:,8));
handles.ANGLE_LHL=comp_ANGLE(handles.DATA_KIN(:,4+2:21+2),handles.ANGLE_trunk(:,9));

% Compute HINDLIMB SPEEDS
    handles.ANGLEspeed_LHL=comp_ANGLE_speed(handles.ANGLE_LHL, handles.freq);
    handles.ANGLEspeed_RHL=comp_ANGLE_speed(handles.ANGLE_RHL, handles.freq);
    handles.ANGLEspeed_trunk=comp_ANGLE_speed(handles.ANGLE_trunk, handles.freq);


%[gaitfile_written handles.gaitFILENAME] = EVENT_DETECTION(1, char(handles.PATHNAME), char(handles.FILENAME), handles.DATA_KIN, ...
 %       handles.ANGLE_LHL, handles.ANGLE_RHL);
% Code from EVENT_DETECTION.m

handles.KIN_freq=200; %Hz
handles.TIME = handles.DATA_KIN(:,2);
YMTP_L = 19; % Y pos of LEFT MTP marker (vertical axis)
YMTP_R = 40; % Y pos of RIGHT MTP marker (vertical axis)

% normalize data
handles.temp_DATA_KIN = handles.DATA_KIN;

%% comment out below code (until line 120 to get smooth angular velocity)
%handles.temp_DATA_KIN(:,3:end) = (handles.DATA_KIN(:,3:end) ...
  %  - repmat(min(handles.DATA_KIN(:,3:end)),size(handles.DATA_KIN,1),1)) ...
   % ./repmat(max(handles.DATA_KIN(:,3:end)) - min(handles.DATA_KIN(:,3:end)),size(handles.DATA_KIN,1),1);

% smooth MTP position on Z axis (vertical axis)
handles.Data_L = smooth(handles.temp_DATA_KIN(:,YMTP_L),5); 
handles.Data_R = smooth(handles.temp_DATA_KIN(:,YMTP_R),5); 

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

%handles.THRESHOLD_L = 0;
%handles.THRESHOLD_R = 0;

%varargout{1} = hObject;
varargout{1} = handles;

end