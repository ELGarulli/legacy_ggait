%% LOAD FILES
function BNload_Callback(hObject, eventdata, handles)

%% Initialize variables

% project & gait type
Setup = get(handles.PMsetup,'Value'); % index of the project
handles.gait_type = get(handles.PMgaittype,'Value'); % bipedal (=1) or quadrupedal (=2)



% bools
handles.is_force=get(handles.RBforce,'Value'); % bool, true if FORCE data are available
handles.is_noise=get(handles.RBnoise,'Value'); % bool, true if denoising processing is required on EMG data
handles.is_euler=get(handles.RBeuler,'Value'); % bool, true if Euler angles computation is required
handles.is_emg=get(handles.RBemg,'Value'); % bool, true if EMG data are available
handles.is_gait_file=get(handles.RBgait_file,'Value'); % bool, true if *_GAIT.csv file exists
handles.is_event_swing=get(handles.RBgait_events,'Value'); % bool, true if SWING events have been detected
handles.is_gait_auto=get(handles.RBgait_auto,'Value'); % bool, true if automatic detection of gait events is required
handles.is_gait_manual=get(handles.RBgait_manual,'Value'); % bool, true if manual detection of gait events is required

% EMG gain
handles.emg_gain = str2double(get(handles.EDemg,'String'));

% data
handles.DATA_KIN=[];
handles.DATA_EMG=[];
handles.DATA_FORCE=[];
handles.DATA_CoP=[];
handles.DATA_NEU=[];
handles.DATA_SumAverage_HL=[]; handles.DATA_SumAverage_FL=[];

% angles
handles.ANGLE_trunk=[];
handles.ANGLE_RHL=[]; handles.ANGLE_LHL=[]; handles.ANGLE_RFL=[]; handles.ANGLE_LFL=[];
handles.ANGLE_trunk_LHL_mean=[]; handles.ANGLE_trunk_RHL_mean=[];
handles.ANGLE_RHL_mean=[]; handles.ANGLE_LHL_mean=[]; handles.ANGLE_RFL_mean=[]; handles.ANGLE_LFL_mean=[];

handles.ANGLEspeed_trunk=[];
handles.ANGLEspeed_LHL=[]; handles.ANGLEspeed_RHL=[]; handles.ANGLEspeed_LFL=[]; handles.ANGLEspeed_RFL=[];
handles.ANGLEspeed_LHL_mean=[]; handles.ANGLEspeed_RHL_mean=[]; handles.ANGLEspeed_LFL_mean=[]; handles.ANGLEspeed_RFL_mean=[];

% endpoint
handles.ENDPOINT_Vel_HL=[]; handles.ENDPOINT_Vel_FL=[];
handles.ENDPOINT_Angle_HL=[]; handles.ENDPOINT_Angle_FL=[];

% gait
handles.GAIT_INFO=[]; handles.GAIT_INFO_FL=[];
handles.GAIT_LHL=[]; handles.GAIT_RHL=[]; handles.GAIT_LFL=[]; handles.GAIT_RFL=[];

% EMG
handles.EMG_freq=0;
handles.EMG_LHL =[]; handles.EMG_RHL =[]; handles.EMG_LFL =[]; handles.EMG_RFL =[];
handles.EMG_RHL_mean=[]; handles.EMG_LHL_mean=[]; handles.EMG_RFL_mean=[]; handles.EMG_LFL_mean=[];
handles.EMG_CoCo_LHL=[]; handles.EMG_CoCo_RHL=[]; handles.EMG_CoCo_LFL=[]; handles.EMG_CoCo_RFL=[];
handles.EMG_features_LHL=[]; handles.EMG_features_RHL=[];

% force & CoP
handles.FORCE_freq=0;
handles.FORCE_L=[]; handles.FORCE_R=[];
handles.FORCE_LHL_mean=[]; handles.FORCE_RHL_mean=[]; handles.FORCE_LFL_mean=[]; handles.FORCE_RFL_mean=[];
handles.FORCE_features=[];

handles.CoP_LHL_mean=[]; handles.CoP_RHL_mean=[]; handles.CoP_LFL_mean=[]; handles.CoP_RFL_mean=[];



%% LOAD c3d FILE

%[handles.FILENAME, handles.PATHNAME] = uigetfile([handles.PATHNAME,'*.c3d'], 'Select the .c3d file');
handles.FILENAME = 'runway_06.c3d';
handles.PATHNAME = 'Users\wenge\Documents\GitHub\gait-new-repo';
if ~strcmp(handles.FILENAME(end-3:end),'.c3d'), msgbox('No .c3d file has been selected.','Ggait','error'), return, end
progressbar


% Print filename in GUI
set(handles.TXfilename, 'string', ['Loaded file: ' handles.FILENAME(1:end-4)]);
    
% Load KIN data from c3d file
[first_frame,num_frame,num_markers,handles.freq,handles.freq_analog,...
    handles.F,handles.M,handles.CP,handles.coord,handles.mkr,handles.MarkerName, ...
    handles.emg_analog,handles.AnalogName] = load_VICON_c3d([handles.PATHNAME,handles.FILENAME],handles.is_force);

[handles.mkr,handles.MarkerName]=ChangeNameMkr(handles.mkr,handles.MarkerName); %problem with capital letters
if isfield(handles.mkr, 'LFinger') %Eduardo settings
    OrderMarkerName={ 'Lshoulder' 'LCrest'  'LHip' 'LKnee'  'LAnkle' 'LMTP'  'LFinger' ...
        'Rshoulder' 'RCrest'  'RHip' 'RKnee'  'RAnkle' 'RMTP' 'RFinger' ...
        'Lelbow'    'Lwrist'  'Relbow'    'Rwrist' 'LScap' 'RScap' ...
        'T12' 'HeadFront' 'LEar' 'REar' 'LToe' 'RToe' 'Trunk' 'COP_FP1' ...
        'RawCentreFP1' 'VECTIP_FP1' 'Force_FP1' 'RawForceFP1' 'RawMomentFP1'};
else
    OrderMarkerName={'Lshoulder' 'LCrest'  'LHip'  'LKnee'  'LAnkle'  'LMTP'  'LTip' ...
        'Rshoulder'  'RCrest' 'RHip'   'RKnee'  'RAnkle'  'RMTP'  'RTip'...
        'Lelbow' 'Lwrist'  'Relbow' 'Rwrist' 'LScap' 'RScap' ...
        'T12' 'HeadFront' 'LEar' 'REar' 'LToe' 'RToe' 'Trunk' 'COP_FP1' ...
        'RawCentreFP1' 'VECTIP_FP1' 'Force_FP1' 'RawForceFP1' 'RawMomentFP1'};
    handles.CoP_position=82; % (length(OrderMarkerName)-6)*3+1;
end
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
if ~isfield(handles.mkr, 'LKnee') %ladder with only right side
    choice = questdlg('Only Right SIDE is present...continue?','Error Menu','Yes','No','Yes');
    if strcmp(choice,'Yes')
        handles.is_right=1;
        handles.mkr.LCrest=handles.mkr.RHip;
        handles.mkr.LHip=handles.mkr.RCrest;
        handles.mkr.LKnee=handles.mkr.RKnee;
        handles.mkr.LAnkle=handles.mkr.RAnkle;
        handles.mkr.LMTP=handles.mkr.RMTP;
        if handles.gait_type == 2 %quadrupedal case
            handles.mkr.Lshoulder=handles.mkr.Relbow;
            handles.mkr.Lelbow=handles.mkr.Rshoulder;
            handles.mkr.Lwrist=handles.mkr.Rwrist;
            %handles.mkr.LMCP=handles.mkr.RMCP;
            handles.mkr.LToe=handles.mkr.RToe;
        end
    end
end

progressbar(1/6)


if strcmp(handles.setups(Setup),'MOUSE') %MOUSE PROJECT (no TIP marker, no Scap marker)
    [handles.mkr] = PROJECT_MOUSE_mkr(handles.mkr);
elseif strcmp(handles.setups(Setup),'HUMAN LU') || strcmp(handles.setups(Setup),'HUMAN LOCOMOTION'), %HUMAN PROJECT (the horizontal plane is not correct)
    [handles.mkr] = PROJECT_HUMAN_setup(handles.mkr,OrderMarkerName);
end





% %% Computes the axes. Needs to be run at some point: Niko Jean
% % Origin is LS8
% O = [55.6152 -31.67848 1310.137695] ;
% 
% % Based on the ladder, X and Y vectors are the following
% X = [70.34823 -25.85053911 119.2168921] ;
% Y = [-333.2383555 5.3877655	205.548645] ;
% % Z is computed by vectorial cross product
% Z = cross(X,Y) ;
% % Because of the way it is constructed, Z is orthogonal to both X and Y
% % X and Y are not 100% orthogonal yet. We will fix that by recomputing Y so
% % that it is orthogonal to X and Z
% Y = cross(Z,X) ;
% 
% % Finally normalize those vectors
% X = X/norm(X);
% Y = Y/norm(Y);
% Z = Z/norm(Z);
% 
% % For any point (x,y,z) in the old reference frame, the coordinates in the
% % new frames are obtained by projection:
% % X coordinate: X(1)*(x-O(1)) + X(2)*(y-O(2)) + X(3)*(z-O(3)) ;
% % Y coordinate: Y(1)*(x-O(1)) + Y(2)*(y-O(2)) + Y(3)*(z-O(3)) ;
% 
% %% Code where it retrieves kinematic data
% 
% handles.DATA_KIN(1:num_frame,1)= first_frame:1:first_frame+num_frame-1;
% TIME_DATA_KIN=handles.DATA_KIN(:,1);
% 
% col=2;
% for ii=1:length(OrderMarkerName),
%     if isfield(handles.mkr,(char(OrderMarkerName(ii))))
%         old_x = handles.mkr.(char(OrderMarkerName(ii))).x ;
%         old_y = handles.mkr.(char(OrderMarkerName(ii))).y ;
%         old_z = handles.mkr.(char(OrderMarkerName(ii))).z ;
%         
%         handles.DATA_KIN(1:num_frame,col)= X(1)*(old_x-O(1)) + X(2)*(old_y-O(2)) + X(3)*(old_z-O(3)) ;
%         handles.DATA_KIN(1:num_frame,col+1)= Y(1)*(old_x-O(1)) + Y(2)*(old_y-O(2)) + Y(3)*(old_z-O(3)) ;
%         handles.DATA_KIN(1:num_frame,col+2)= Z(1)*(old_x-O(1)) + Z(2)*(old_y-O(2)) + Z(3)*(old_z-O(3)) ;
%     end
%     col=col+3;
% end



handles.DATA_KIN(1:num_frame,1)= first_frame:1:first_frame+num_frame-1;
TIME_DATA_KIN=handles.DATA_KIN(:,1);

col=2;
for ii=1:length(OrderMarkerName),
    if isfield(handles.mkr,(char(OrderMarkerName(ii))))
        handles.DATA_KIN(1:num_frame,col)=handles.mkr.(char(OrderMarkerName(ii))).x;
        handles.DATA_KIN(1:num_frame,col+1)=  handles.mkr.(char(OrderMarkerName(ii))).y;
        handles.DATA_KIN(1:num_frame,col+2)= handles.mkr.(char(OrderMarkerName(ii))).z;
    end
    col=col+3;
end

progressbar(2/6)

if handles.is_force
    for i=1:2 % fill gap of CoP data
        handles.DATA_CoP(:,i)=preprocessingDATA_fill_gaps(handles.DATA_KIN(:,handles.CoP_position+i),1);
    end
    handles.DATA_CoP=preprocessingDATA_filter(handles.DATA_CoP, 0, 6, handles.freq, 2,0); % filter CoP data
    handles.DATA_CoP=handles.DATA_CoP./10; % convert CoP to cm
    handles.DATA_CoP=[TIME_DATA_KIN, TIME_DATA_KIN./handles.freq, handles.DATA_CoP];
end

switch handles.gait_type
    case 1 %bipedal
        if isfield(handles.mkr,'Relbow'),
            if isfield(handles.mkr,'RScap'),
                handles.DATA_KIN=handles.DATA_KIN(:,2:61); %bipedal task with upper markers and Scapula
            else handles.DATA_KIN=handles.DATA_KIN(:,2:55); %bipedal task with upper markers
            end
        else handles.DATA_KIN=handles.DATA_KIN(:,2:43); %bipedal task with only lower markers
        end
    case 2  %quadrupedal
        handles.DATA_KIN=handles.DATA_KIN(:,2:end);
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

% Euler computation
if  handles.is_euler
    if exist([handles.PATHNAME, handles.FILENAME(1:end-4), '_EULER.txt'],'file')
        msgbox('A "*_EULER.txt" file already exists. Euler computation will not be performed.')
    else
        comp_eulerangles_main(handles.PATHNAME, handles.FILENAME(1:end-4), TIME_DATA_KIN, ...
            handles.DATA_KIN, handles.DATA_KIN_HL_header(:,3:end), handles.type_euler);
    end
end

% Filter KIN and add FRAME and TIME
handles.DATA_KIN = preprocessingDATA_filter_KIN(handles.DATA_KIN, handles.freq, handles.filterKIN_freq);
handles.DATA_KIN = [TIME_DATA_KIN, TIME_DATA_KIN./handles.freq, handles.DATA_KIN]; % add frame number and time
handles.mkr = preprocessingDATA_filter_MKR(handles.mkr,handles.MarkerName, handles.freq, handles.filterKIN_freq);
handles.mkr = comp_velacc(handles.mkr, handles.MarkerName, handles.freq);

progressbar(3/6)

%% EMG
if handles.is_emg
    if exist([handles.PATHNAME, handles.FILENAME(1,1:end-4),'_ANA.csv'],'file')==2,  %load the ANA file if it's present
        disp('[Ggait - LOAD] - Take EMG data from _ANA.csv file')
        [type, handles.EMG_freq, header_data, unit_header_data, data]=load_VICON([handles.FILENAME(1,1:end-4),'_ANA.csv'], handles.PATHNAME);
        handles.EMG_freq=str2double(char(handles.EMG_freq));
        FRAME_TIME_EMG(:,1:2)=[data(:,1), data(:,1)./handles.EMG_freq];        
        if handles.is_force
            handles.DATA_EMG_header=header_data(8:end);
            handles.DATA_EMG=data(:,8:end);
        else
            handles.DATA_EMG_header=header_data(2:end);
            handles.DATA_EMG=data(:,2:end);
        end
    else %otherwise use the information on the c3d file for emgs data
        handles.EMG_freq=handles.freq_analog;
        handles.DATA_EMG_header=handles.AnalogName;
        num_frame_analog=size(handles.emg_analog.(char(handles.AnalogName(1))),2);
        FRAME_TIME_EMG(:,1)=(first_frame*(handles.EMG_freq/handles.freq)...
            -(handles.EMG_freq/handles.freq-1)):1:(first_frame*(handles.EMG_freq/handles.freq)...
            -(handles.EMG_freq/handles.freq-1))+num_frame_analog-1;
        FRAME_TIME_EMG(:,2)=FRAME_TIME_EMG(:,1)./handles.EMG_freq;
        for ii=1:length(handles.AnalogName),
            handles.DATA_EMG(1:num_frame_analog,ii)=handles.emg_analog.(char(handles.AnalogName(ii)));
        end
    end
    
    % EMG gain
    handles.EMG_gain=1000*ones(1,handles.section_to_filter_EMG(2)-handles.section_to_filter_EMG(1)+1);
    
    if handles.emg_gain ~= 1000 % in case EMG gain was not set to 1000
        [index,selection] = listdlg('PromptString',strcat({'Muscles with EMG gain = ',handles.emg_gain}),...
            'SelectionMode','multiple',...
            'ListString',handles.DATA_EMG_header(handles.section_to_filter_EMG(1):handles.section_to_filter_EMG(2)));
        if selection==1
            handles.EMG_gain(index) = handles.emg_gain;
        end
    end
    [r,~]=size(handles.DATA_EMG(:,handles.section_to_filter_EMG(1):handles.section_to_filter_EMG(2)));
    handles.EMG_gain=ones(r,1)*handles.EMG_gain;
    
    handles.DATA_EMG = [preprocessingDATA_filter(handles.DATA_EMG(:,handles.section_to_filter_EMG(1):handles.section_to_filter_EMG(2)).*handles.EMG_gain, ...
        10, handles.EMG_freq/2-1, handles.EMG_freq, 5,0),...
        handles.DATA_EMG(:,handles.section_to_filter_EMG(2)+1:end)];
    handles.DATA_EMG =[FRAME_TIME_EMG, handles.DATA_EMG];
    
    if strcmp(handles.setups(Setup),'HUMAN LOCOMOTION') || strcmp(handles.setups(Setup),'HUMAN REACHING'), %HUMAN PROJECT (emgs with no zero level)
        handles.DATA_EMG = PROJECT_HUMAN_setup_emg(handles.DATA_EMG, ...
            handles.emgChLeft_n,handles.emgChRight_n,handles.emgChLeft_FL_n,handles.emgChRight_FL_n);
    end
    
    % Filter 40Hz noise due to 40Hz stimulations
    if handles.is_noise
        for muscle=2+1:2+handles.section_to_filter_EMG(2)-handles.section_to_filter_EMG(1)+1
            handles.DATA_EMG(:, muscle)= preprocessingDATA_filter_bandstop(handles.DATA_EMG(:, muscle), 40, 5, handles.EMG_freq);
        end
    end
    
else % i.e. no EMG, so put just frames and time of kinematic data
    handles.DATA_EMG = handles.DATA_KIN(:,1:2);
    handles.emgChRight=[];
    handles.emgChLeft=[];
    handles.emgChLeft_n=0;
    handles.emgChRight_n=0;
    handles.emgChRight_FL=[];
    handles.emgChLeft_FL=[];
    handles.emgChLeft_FL_n=0;
    handles.emgChRight_FL_n=0;
end

%% FORCE
if handles.is_force
     num_frame_analog=size(handles.emg_analog.(char(handles.AnalogName(1))),2);
    handles.FORCE_freq = handles.freq_analog;
    FRAME_TIME_FORCE(:,1)=(first_frame*(handles.FORCE_freq/handles.freq)...
        -(handles.FORCE_freq/handles.freq-1)):1:(first_frame*(handles.FORCE_freq/handles.freq)...
        -(handles.FORCE_freq/handles.freq-1))+num_frame_analog-1;
    FRAME_TIME_FORCE(:,2)=FRAME_TIME_FORCE(:,1)./handles.FORCE_freq;        
    handles.DATA_FORCE = [handles.F' handles.M'];
    handles.DATA_FORCE = [FRAME_TIME_FORCE, preprocessingDATA_filter(handles.DATA_FORCE, ...
        0, 500, handles.FORCE_freq, 2,1)];
end

%% NEU
if handles.is_NEU
    load([handles.PATHNAME, handles.FILENAME(1,1:end-4),'_NEU.mat'])
    extract_bins
    plot_vicon_trials_selec(vicon, t, x);
    handles.DATA_NEU = x(ii,:);
    TIME_NEU=linspace(1,size(handles.DATA_NEU,1),size(handles.DATA_NEU,1))';
    TIME_NEU=[TIME_NEU, TIME_NEU./handles.NEU_freq];
    handles.DATA_NEU=[TIME_NEU,handles.DATA_NEU];
end

%% NO KIN DATA
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
progressbar(4/6)

%% Generate ANGLES
if strcmp(handles.FILENAME(end-3:end),'.c3d')  % c3d file exists
    progressbar
    
    % trunk refers to pelvis for bipedal and quadrupedal locomotion(HIP - CREST MARKERS)
    switch handles.gait_type
        case 1 % bipedal
            handles.ANGLE_trunk=comp_KIN_trunk(handles.DATA_KIN(:,4+2:6+2),handles.DATA_KIN(:,25+2:27+2), ...
                handles.DATA_KIN(:,7+2:9+2),handles.DATA_KIN(:,28+2:30+2), ...
                handles.DATA_KIN(:,4+2:6+2),handles.DATA_KIN(:,25+2:27+2));
        case 2 % quadrupedal
            handles.ANGLE_trunk=comp_KIN_trunk(handles.DATA_KIN(:,1+2:3+2),handles.DATA_KIN(:,22+2:24+2),...
                handles.DATA_KIN(:,7+2:9+2),handles.DATA_KIN(:,28+2:30+2), ...
                handles.DATA_KIN(:,4+2:6+2),handles.DATA_KIN(:,25+2:27+2));
            if isfield(handles.mkr,'Trunk') % if Trunk marker is present
                handles.ANGLE_trunk(:,16)=comp_ANGLE_atan2(handles.DATA_KIN(:,79+2)',handles.DATA_KIN(:,80+2)',handles.ANGLE_trunk(:,1)',handles.ANGLE_trunk(:,2)')...
                    - comp_ANGLE_atan2(handles.DATA_KIN(:,79+2)',handles.DATA_KIN(:,80+2)',handles.ANGLE_trunk(:,13)',handles.ANGLE_trunk(:,14)'); %joint angle btw Trunk and shoulder and Crest
                handles.DATA_KIN_FL_header = [handles.DATA_KIN_FL_header {'Trunk X' 'Trunk Y' 'Trunk Z'}];
                handles.ANGLES_trunk_header= [handles.ANGLES_trunk_header {'JOINT Trunk'}];
                handles.ANGLES_HL_header=[handles.ANGLES_LHL_header,handles.ANGLES_RHL_header handles.ANGLES_trunk_header];
            end
    end
    
    progressbar(1/3)
    
    % Compute HINDLIMB ANGLES
    handles.ANGLE_RHL=comp_ANGLE(handles.DATA_KIN(:,25+2:42+2),handles.ANGLE_trunk(:,8));
    handles.ANGLE_LHL=comp_ANGLE(handles.DATA_KIN(:,4+2:21+2),handles.ANGLE_trunk(:,9));
    
    if handles.is_euler
        DATA_EULER_JOINT = dlmread([handles.PATHNAME,handles.FILENAME(1,1:end-4),'_EULER.txt'],'\t',1,0); % PUT one back load EULER joint angles and change joint angles in matrix
        handles.ANGLE_LHL(:,8:9) =[180+DATA_EULER_JOINT(:,7),180+DATA_EULER_JOINT(:,10)];
        handles.ANGLE_RHL(:,8:9)=[180+DATA_EULER_JOINT(:,19),180+DATA_EULER_JOINT(:,22)];
    end
    
    if handles.is_BWstepping % FOR BW STEPPING
        handles.ANGLE_LHL(:,6)=-handles.ANGLE_LHL(:,6);
        handles.ANGLE_RHL(:,6)=-handles.ANGLE_RHL(:,6);
    end
    if handles.is_SWstepping % FOR SW STEPPING
        handles.ANGLE_LHL(:,6)=handles.ANGLE_LHL(:,11);
        handles.ANGLE_RHL(:,6)=handles.ANGLE_RHL(:,11);
    end
    
    % Compute HINDLIMB SPEEDS
    handles.ANGLEspeed_LHL=comp_ANGLE_speed(handles.ANGLE_LHL, handles.freq);
    handles.ANGLEspeed_RHL=comp_ANGLE_speed(handles.ANGLE_RHL, handles.freq);
    handles.ANGLEspeed_trunk=comp_ANGLE_speed(handles.ANGLE_trunk, handles.freq);
    
    progressbar(2/3)
    
    % COMPUTE FORELIMB ANGLES & SPEEDS
    if handles.gait_type==2 % quadrupedal gait
        handles.ANGLE_RFL=comp_ANGLE_FL([handles.DATA_KIN(:,58+2:60+2), ...
            handles.DATA_KIN(:,22+2:24+2), ...
            handles.DATA_KIN(:,49+2:54+2), ...
            handles.DATA_KIN(:,76+2:78+2)], ...
            handles.ANGLE_trunk(:,8));
        handles.ANGLE_LFL=comp_ANGLE_FL([handles.DATA_KIN(:,55+2:57+2), ...
            handles.DATA_KIN(:,1+2:3+2), ...
            handles.DATA_KIN(:,43+2:48+2), ...
            handles.DATA_KIN(:,73+2:75+2)], ...
            handles.ANGLE_trunk(:,9));
        
        handles.ANGLEspeed_LFL=comp_ANGLE_speed(handles.ANGLE_LFL, handles.freq);
        handles.ANGLEspeed_RFL=comp_ANGLE_speed(handles.ANGLE_RFL, handles.freq);
    end
    
    progressbar(3/3)
end
progressbar(5/6)

%% Generate or Load GAIT DATA
guidata(hObject, handles);
if ~handles.is_gait_file % _GAIT file does not exist (Toe off and Foot strike events)
    waitfor(msgbox('No GAIT data file. Please help create the GAIT data file.','Ggait'));
    [gaitfile_written handles.gaitFILENAME] = EVENT_DETECTION(1, char(handles.PATHNAME), char(handles.FILENAME), handles.DATA_KIN, ...
        handles.ANGLE_LHL, handles.ANGLE_RHL);
    if ~gaitfile_written
        waitfor(msgbox('Problem when creating GAIT data file, please retry.','Ggait','error'));
        return
    else disp(['Path and name of created GAIT file: ', handles.PATHNAME, handles.gaitFILENAME]);
    end
    [~, handles.gait_data]=load_VICON_GAIT(handles.gaitFILENAME, handles.PATHNAME);      
else % _GAIT file exists
    handles.gaitFILENAME = [handles.FILENAME(1:end-4),'_GAIT.csv'];
    if exist([handles.PATHNAME,handles.gaitFILENAME],'file') ~= 2
        msgbox('No GAIT data file has been found!','Ggait','error')
        return
    end
    [~, handles.gait_data]=load_VICON_GAIT(handles.gaitFILENAME, handles.PATHNAME);
end

if handles.is_event_swing % if swing has been detected as "GENERAL EVENT" in GAIT file
    [handles.GAIT_INFO, handles.GAIT_INFO_FL]=create_GAIT_INFO_swing(handles.DATA_KIN(:,1:2), handles.gait_data);
else [handles.GAIT_INFO, handles.GAIT_INFO_FL]=create_GAIT_INFO(handles.DATA_KIN(:,1:2), handles.gait_data);
end
    
if handles.is_gait_manual % Erase everything in GAIT_INFO and then detect Stance events and Drag end events
                           % based on Max limb axis angle for Stance start - manual
                           % based on Min limb axis angle for Drag end - automatic
    [handles.GAIT_INFO]=create_GAIT_INFO_manual(handles.GAIT_INFO,handles.DATA_KIN(:,1:2), ...
        handles.ANGLE_LHL, handles.ANGLE_RHL,strcat(handles.PATHNAME,handles.FILENAME));    
elseif handles.is_gait_auto % Erase everything in GAIT_INFO and then detect Stance events (only!)
                            % based on Max limb axis angle for Stance start - automatic   
    [handles.GAIT_INFO]=create_GAIT_INFO_auto(handles.GAIT_INFO,handles.DATA_KIN(:,1:2), ...
        handles.ANGLE_LHL, handles.ANGLE_RHL);
end

if isempty(find(handles.GAIT_INFO(:,3),1))
    handles.is_swing=0;
else handles.is_swing=1;
end

% set animal iD automatically using animal number written in GAIT data
set(handles.EDanimal,'String',handles.gait_data(1,1)); 
handles.animal_iD = str2double(get(handles.EDanimal,'string'));


%% LOADING DONE
progressbar(6/6)
guidata(hObject, handles);