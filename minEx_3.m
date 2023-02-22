function varargout = minEx_3(handles)

%Code taken from 
% Get experiment conditions
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

%%% Headers initialization
handles = load_headers(handles);

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

%closeFigures(handles.figure1)

handles.animal_iD = '1';
handles.speed = 0;
COND1 = 'P10';
COND2 = 'tonic_E1';
TITLE = sprintf('# %s, %s, %s, speed %d', char(handles.animal_iD), COND1, COND2,handles.speed);

FRAME_KIN = handles.DATA_KIN(:,1:2);
if handles.is_emg, FRAME_EMG = handles.DATA_EMG(:,1:2); end
if handles.is_force, FRAME_FORCE = handles.DATA_FORCE(:,1:2); end


%% AVERAGE EMG
if handles.is_emg
    if handles.emgChLeft_n ~= 0
        for ch=1:handles.emgChLeft_n
            EMG1temp(:,ch)=handles.DATA_EMG(:,handles.emgChLeft(ch)+2);
        end
        handles.EMG_LHL_mean=params_average(handles.GAIT_LHL, [FRAME_EMG, EMG1temp],1000);
    end
    
    if handles.emgChRight_n~=0
        for ch=1:handles.emgChRight_n
            EMG2temp(:,ch)=handles.DATA_EMG(:,handles.emgChRight(ch)+2);
        end
        handles.EMG_RHL_mean=params_average(handles.GAIT_RHL,[FRAME_EMG, EMG2temp],1000);
    end
    
    if handles.emgChLeft_FL_n~=0
        for ch=1:handles.emgChLeft_FL_n
            EMG3temp(:,ch)=handles.DATA_EMG(:,handles.emgChLeft_FL(ch)+2);
        end
        handles.EMG_LFL_mean=params_average(handles.GAIT_LFL, [FRAME_EMG, EMG3temp],1000);
    end
    
    if handles.emgChRight_FL_n~=0
        for ch=1:handles.emgChRight_FL_n
            EMG4temp(:,ch)=handles.DATA_EMG(:,handles.emgChRight_FL(ch)+2);
        end
        handles.EMG_RFL_mean=params_average(handles.GAIT_RFL, [FRAME_EMG, EMG4temp],1000);
    end
    
end

%% AVERAGE FORCE
if handles.is_force
    
    for ch=1:length(handles.FORCE)
        FORCEtemp(:,ch)=handles.DATA_FORCE(:,handles.FORCE(ch)+2);
    end
    handles.FORCE_LHL_mean = params_average(handles.GAIT_LHL,[FRAME_FORCE,FORCEtemp],100);
    handles.FORCE_RHL_mean = params_average(handles.GAIT_RHL,[FRAME_FORCE,FORCEtemp],100);
    if handles.gait_type==2 % quadrupedal gait
        handles.FORCE_LFL_mean = params_average(handles.GAIT_LFL,[FRAME_FORCE,FORCEtemp],100);
        handles.FORCE_RFL_mean = params_average(handles.GAIT_RFL,[FRAME_FORCE,FORCEtemp],100);
    end
    
    % GENERATE CoP MEAN + DISPLAY CoP
    handles.CoP_LHL_mean = params_average(handles.GAIT_LHL,handles.DATA_CoP,100);
    handles.CoP_RHL_mean = params_average(handles.GAIT_RHL,handles.DATA_CoP,100);
    if  handles.gait_type==2 % quadrupedal gait
        handles.CoP_LFL_mean = params_average(handles.GAIT_LFL,handles.DATA_CoP,100);
        handles.CoP_RFL_mean = params_average(handles.GAIT_RFL,handles.DATA_CoP,100);
    end

 %% BELOW SECTION ONLY RELEVANT IF COP DATA AVAILABLE
    
   % is_plotCoP = questdlg('DO YOU WANT TO DISPLAY CENTER OF FOOT PRESSURE TRAJECTORIES?', ...
   %    'Ggait - CoP', 'NON', 'YES', 'NON');
    
   % if strcmp(is_plotCoP,'YES')
   %     if handles.gait_type==1 % bipedal gait
   %         plot_CoP(handles.GAIT_LHL, handles.GAIT_RHL, handles.DATA_KIN, handles.DATA_CoP, TITLE);
   %     else % quadrupedal gait
   %         plot_CoP_quadgait(handles.GAIT_LHL, handles.GAIT_RHL, handles.GAIT_LFL, handles.GAIT_RFL, ...
   %             handles.DATA_KIN, handles.DATA_CoP, TITLE);
   %     end
   % end
    
end

%% AVERAGE KINEMATIC DATA
handles.ANGLE_RHL_mean=params_average(handles.GAIT_RHL, [FRAME_KIN,handles.ANGLE_RHL],100);
handles.ANGLE_trunk_RHL_mean=params_average(handles.GAIT_RHL, [FRAME_KIN,handles.ANGLE_trunk(:,1:12)],100);
handles.ANGLE_LHL_mean=params_average(handles.GAIT_LHL, [FRAME_KIN,handles.ANGLE_LHL],100);
handles.ANGLE_trunk_LHL_mean=params_average(handles.GAIT_LHL, [FRAME_KIN, handles.ANGLE_trunk(:,1:12)],100);

if handles.gait_type==2 % quadrupedal gait
    handles.ANGLE_LFL_mean=params_average(handles.GAIT_LFL, [FRAME_KIN,handles.ANGLE_LFL],100);
    handles.ANGLE_RFL_mean=params_average(handles.GAIT_RFL, [FRAME_KIN,handles.ANGLE_RFL],100);
end

%% Just because values are needed - cleaner to remove them in later functions
handles.DATA_EMG = handles.DATA_KIN(:,1:2);
handles.emgChRight=[];
handles.emgChLeft=[];
handles.emgChLeft_n=0;
handles.emgChRight_n=0;
handles.emgChRight_FL=[];
handles.emgChLeft_FL=[];
handles.emgChLeft_FL_n=0;
handles.emgChRight_FL_n=0;

%%FIGURE Uncomment line 202 to 204 to show plots
%plot_gait_average(handles.GAIT_LHL, handles.ANGLE_LHL_mean, handles.EMG_LHL_mean, handles.FORCE_LHL_mean, handles.emgChLeft_n,...
 %   handles.GAIT_RHL, handles.ANGLE_RHL_mean, handles.EMG_RHL_mean, handles.FORCE_RHL_mean, handles.emgChRight_n,...
  %  TITLE, handles.EMG_freq, handles.emgChLeft, handles.emgChRight, handles.DATA_EMG_header, 'HL', handles.TXkin_HL);
    
  %if handles.gait_type==2 % quadrupedal gait
     %   plot_gait_average(handles.GAIT_LFL, handles.ANGLE_LFL_mean, handles.EMG_LFL_mean, handles.FORCE_LFL_mean, handles.emgChLeft_FL_n,...
     %       handles.GAIT_RFL, handles.ANGLE_RFL_mean, handles.EMG_RFL_mean, handles.FORCE_RFL_mean, handles.emgChRight_FL_n,...
     %       TITLE, handles.EMG_freq, handles.emgChLeft_FL, handles.emgChRight_FL, handles.DATA_EMG_header, 'FL', handles.TXkin_FL);
    %end

%% ENDPOINT PROCESS
[handles.GAIT_LHL, handles.GAIT_RHL, handles.ENDPOINT_Vel_HL, handles.ENDPOINT_Angle_HL] = ...
    params_ENDPOINT(FRAME_KIN, handles.GAIT_LHL, handles.GAIT_RHL, ...
    handles.DATA_KIN(:,16+2:17+2),handles.DATA_KIN(:,37+2:38+2), ...
    handles.DATA_KIN(:,4+2:6+2),handles.DATA_KIN(:,25+2:27+2), ...
    handles.freq, 0.05, TITLE, 0);

handles.ENDPOINT_PCA_HL = params_ENDPOINT_PCA(handles.GAIT_LHL, handles.GAIT_RHL, ...
    [FRAME_KIN(:,2), handles.DATA_KIN(:,16+2:18+2)],[FRAME_KIN(:,2), handles.DATA_KIN(:,37+2:39+2)]);

if handles.gait_type==2 % quadrupedal gait
    [handles.GAIT_LFL, handles.GAIT_RFL, handles.ENDPOINT_Vel_FL, handles.ENDPOINT_Angle_FL] = ...
        params_ENDPOINT(FRAME_KIN, handles.GAIT_LFL, handles.GAIT_RFL, ...
        handles.DATA_KIN(:,46+2:48+2),handles.DATA_KIN(:,52+2:54+2), ...
        handles.DATA_KIN(:,55+2:57+2),handles.DATA_KIN(:,58+2:60+2), ...
        handles.freq, 0.05, TITLE, 1);
    
    handles.ENDPOINT_PCA_FL = params_ENDPOINT_PCA(handles.GAIT_LFL, handles.GAIT_RFL, ...
        [FRAME_KIN(:,2), handles.DATA_KIN(:,46+2:48+2)],[FRAME_KIN(:,2), handles.DATA_KIN(:,52+2:54+2)]);
end


%% Taken from BNwritefiles_Callback
failure_writing=0;
handles.save_option = 1;
COND1 = 'P10';
COND2 = 'tonic_E1';
COND3 = 'TRAINING';

% Create folders
if ~exist([handles.PATHNAME, 'PROCESS'],'dir'), mkdir([handles.PATHNAME, 'PROCESS']); end
if ~exist([handles.PATHNAME, 'AVERAGE'],'dir'), mkdir([handles.PATHNAME, 'AVERAGE']); end
if ~exist([handles.PATHNAME, 'SUM'],'dir'), mkdir([handles.PATHNAME, 'SUM']); end

if ispc, mySlash = '\'; else mySlash = '/'; end

%% CREATING SUM DATA
Ncolumns = 9;
Nrows_HL = size(handles.GAIT_LHL,1)+size(handles.GAIT_RHL,1);

switch handles.gait_type
    case 1 % bipedal
        sumfile{Nrows_HL,Ncolumns}=[];
        sumfile(:,7)={'BIPEDAL'};
        sumfile(:,8)={'HINDLIMB'};
        sumfile(1:size(handles.GAIT_LHL,1),9)={'LEFT'};
        sumfile(size(handles.GAIT_LHL,1)+1:end,9)={'RIGHT'};
    case 2 % quadrupedal
        Nrows_FL = size(handles.GAIT_LFL,1)+size(handles.GAIT_RFL,1);
        sumfile{Nrows_HL+Nrows_FL,Ncolumns}=[];
        sumfile(:,7)={'QUADRUPEDAL'};
        sumfile(1:Nrows_HL,8)={'HINDLIMB'};
        sumfile(Nrows_HL+1:end,8)={'FORELIMB'};
        sumfile(1:size(handles.GAIT_LHL,1),9)={'LEFT'};
        sumfile(size(handles.GAIT_LHL,1)+1:Nrows_HL,9)={'RIGHT'};
        sumfile(Nrows_HL+1:Nrows_HL+size(handles.GAIT_LFL,1),9)={'LEFT'};
        sumfile(Nrows_HL+1+size(handles.GAIT_LFL,1):end,9)={'RIGHT'};
end

sumfile(:,1)={[handles.PATHNAME]};
sumfile(:,2)={[handles.FILENAME]};
sumfile(:,3)={COND1};
sumfile(:,4)={COND2};
sumfile(:,5)={COND3};
sumfile(:,6)={['#', char(handles.animal_iD)]};

% Sort GAIT_* matrices
GAIT_LHL=sort_matrix_ref(handles.DATA_GAIT_header_REF, handles.GAIT_LHL);
GAIT_RHL=sort_matrix_ref(handles.DATA_GAIT_header_REF, handles.GAIT_RHL);
if handles.gait_type == 2 % quadrupedal case
    GAIT_LFL=sort_matrix_ref(handles.DATA_GAIT_header_REF, handles.GAIT_LFL);
    GAIT_RFL=sort_matrix_ref(handles.DATA_GAIT_header_REF, handles.GAIT_RFL);
end
GAIT_header=sort_matrix_ref_header(handles.DATA_GAIT_header_REF, handles.GAIT_header);

if ~isempty(handles.EMG_RHL) || ~isempty(handles.EMG_LHL) ...
        || ~isempty(handles.EMG_RFL) || ~isempty(handles.EMG_LFL)
    
    DATA_EMG_header=[];
    for i=1:length(handles.DATA_EMG_header);
        chan=handles.DATA_EMG_header(1,i);
        HeaderTemp={[char(chan) '_onset'] [char(chan) '_end'] [char(chan) '_%onset'] [char(chan) '_%end'] ...
            [char(chan) '_burst duration'] [char(chan) '_meanAMP'] [char(chan) '_iEMG'] [char(chan) '_RMS']};
        DATA_EMG_header=[DATA_EMG_header HeaderTemp];
    end
    
    N = length(DATA_EMG_header);
    if isempty(handles.EMG_LHL), handles.EMG_LHL=zeros(size(GAIT_LHL,1), N); end
    if isempty(handles.EMG_RHL), handles.EMG_RHL=zeros(size(GAIT_RHL,1), N); end
    if handles.gait_type == 2 % quadrupedal case
        if isempty(handles.EMG_LFL), handles.EMG_LFL=zeros(size(GAIT_LFL,1), N); end
        if isempty(handles.EMG_RFL), handles.EMG_RFL=zeros(size(GAIT_RFL,1), N); end
    end
    
    DATA_CoCo_header=[];
    for i=1:(size(handles.pairs,1));
        chan1=handles.DATA_EMG_header(1,handles.pairs(i,1));
        chan2=handles.DATA_EMG_header(1,handles.pairs(i,2));
        chans = sort([chan1,chan2]);
        HeaderTemp={['CoCo ' char(chans(1)) '_' char(chans(2))]};
        DATA_CoCo_header=[DATA_CoCo_header HeaderTemp];
    end
    
    N = length(DATA_CoCo_header);
    if isempty(handles.EMG_CoCo_LHL), handles.EMG_CoCo_LHL=zeros(size(handles.GAIT_LHL,1), N); end
    if isempty(handles.EMG_CoCo_RHL), handles.EMG_CoCo_RHL=zeros(size(handles.GAIT_RHL,1), N); end
    if handles.gait_type == 2 % quadrupedal case
        if isempty(handles.EMG_CoCo_RFL), handles.EMG_CoCo_RFL=zeros(size(handles.GAIT_RFL,1), N); end
        if isempty(handles.EMG_CoCo_LFL), handles.EMG_CoCo_LFL=zeros(size(handles.GAIT_LFL,1), N); end
    end
    
    % DATA TO SAVE
    switch handles.gait_type
        case 1
            GAIT_LHL=[GAIT_LHL, handles.EMG_LHL, handles.EMG_CoCo_LHL];
            GAIT_RHL=[GAIT_RHL, handles.EMG_RHL, handles.EMG_CoCo_RHL];
            data_to_save=[GAIT_LHL; GAIT_RHL];

        case 2
            GAIT_LHL=[GAIT_LHL, handles.EMG_LHL, handles.EMG_CoCo_LHL];
            GAIT_RHL=[GAIT_RHL, handles.EMG_RHL, handles.EMG_CoCo_RHL];
            GAIT_LFL=[GAIT_LFL, handles.EMG_LFL, handles.EMG_CoCo_LFL];
            GAIT_RFL=[GAIT_RFL, handles.EMG_RFL, handles.EMG_CoCo_RFL];
            data_to_save=[GAIT_LHL; GAIT_RHL; GAIT_LFL; GAIT_RFL];
            
    end
    
    Header=[handles.FILE_header, GAIT_header, DATA_EMG_header, DATA_CoCo_header];
else
    % DATA TO SAVE
    switch handles.gait_type
        case 1, data_to_save=[GAIT_LHL; GAIT_RHL];
        case 2, data_to_save=[GAIT_LHL; GAIT_RHL; GAIT_LFL; GAIT_RFL];
    end
    Header=[handles.FILE_header, GAIT_header];
    
end

success = save_file([handles.PATHNAME, 'SUM', mySlash, handles.FILENAME(1:end-4), '_GAIT_SUM.txt'], Header, sumfile, data_to_save);
if success~=1
    warndlg([handles.FILENAME(1:end-4), '_GAIT_SUM.txt'], 'G-gait: WRITING FAILURE');
    failure_writing=1;
end

%% CREATING AVERAGE DATA
if isnan(handles.ANGLE_RHL)~=1, % C3D AND KIN DATA
    
    Ncolumns = 9;
    
    switch handles.gait_type
        case 1 % bipedal case
            Nlimb=2;
            sumfile{Nlimb,Ncolumns}=[];
            sumfile(:,7)={'BIPEDAL'};
            sumfile(:,8)={'HINDLIMB'};
            sumfile(1,9)={'LEFT'};
            sumfile(2,9)={'RIGHT'};
            MeanSumToSave=handles.ENDPOINT_PCA_HL;
        case 2 % quadrupedal case
            Nlimb=4;
            sumfile{Nlimb,Ncolumns}=[];
            sumfile(:,7)={'QUADRUPEDAL'};
            sumfile(1:2,8)={'HINDLIMB'};
            sumfile(3:4,8)={'FORELIMB'};
            sumfile([1 3],9)={'LEFT'};
            sumfile([2 4],9)={'RIGHT'};
            MeanSumToSave=[handles.ENDPOINT_PCA_HL; handles.ENDPOINT_PCA_FL];
    end
    sumfile(:,1)={[handles.PATHNAME]};
    sumfile(:,2)={[handles.FILENAME]};
    sumfile(:,3)={COND1};
    sumfile(:,4)={COND2};
    sumfile(:,5)={COND3};
    sumfile(:,6)={['#', char(handles.animal_iD)]};
    MeanSumToSave_header=[handles.FILE_header, handles.ENDPOINT_PCA_header];
    
    
    % DATA_SumAverage
    if ~isempty(handles.DATA_SumAverage_HL)
        MeanSumToSave = [MeanSumToSave,handles.DATA_SumAverage_HL];
        MeanSumToSave_header=[MeanSumToSave_header, handles.DATA_SumAverage_header];
    end
    
    % EMG ON MEAN TRACES
    if ~isempty(handles.EMG_features_LHL)
        MeanSumToSave=[MeanSumToSave, handles.EMG_features_LHL];
        MeanSumToSave_header=[MeanSumToSave_header,handles.EMG_features_header_L];
    end
    if ~isempty(handles.EMG_features_RHL)
        MeanSumToSave=[MeanSumToSave, handles.EMG_features_RHL];
        MeanSumToSave_header=[MeanSumToSave_header, handles.EMG_features_header_R];
    end
    
    % FORCE ON MEAN TRACES
    if ~isempty(handles.FORCE_features)
        MeanSumToSave=[MeanSumToSave,handles.FORCE_features];
        MeanSumToSave_header=[MeanSumToSave_header, handles.FORCE_features_header];
    end
    
    
    % COMPUTE MEAN OF GAIT PARAMS
    mean_GAIT=[];
    pos_KinAVE=find(strcmp(GAIT_header,'Kin AVE'));
    
    for i=1:size(GAIT_LHL, 2)
        mean_GAIT(1, i)=mean(GAIT_LHL(find(isnan(GAIT_LHL(:,i))==0 & GAIT_LHL(:,pos_KinAVE)==1), i), 1);
        mean_GAIT(2, i)=mean(GAIT_RHL(find(isnan(GAIT_RHL(:,i))==0 & GAIT_RHL(:,pos_KinAVE)==1), i), 1);
        if handles.gait_type == 2
            mean_GAIT(3, i)=mean(GAIT_LFL(find(isnan(GAIT_LFL(:,i))==0 & GAIT_LFL(:,pos_KinAVE)==1), i), 1);
            mean_GAIT(4, i)=mean(GAIT_RFL(find(isnan(GAIT_RFL(:,i))==0 & GAIT_RFL(:,pos_KinAVE)==1), i), 1);
        end
    end
    
    % COMPUTE SD OF KEY PARAMETERS
    for i=1:size(handles.DATA_SD_REF,1)
        mean_GAIT_SD(1, i)=std(handles.GAIT_LHL(find(isnan(handles.GAIT_LHL(:,handles.DATA_SD_REF(i)))==0 & handles.GAIT_LHL(:,111)==1), handles.DATA_SD_REF(i)));
        mean_GAIT_SD(2, i)=std(handles.GAIT_RHL(find(isnan(handles.GAIT_RHL(:,handles.DATA_SD_REF(i)))==0 & handles.GAIT_RHL(:,111)==1), handles.DATA_SD_REF(i)));
        if handles.gait_type == 2
            mean_GAIT_SD(3, i)=std(handles.GAIT_LFL(find(isnan(handles.GAIT_LFL(:,handles.DATA_SD_REF(i)))==0 & handles.GAIT_LFL(:,111)==1), handles.DATA_SD_REF(i)));
            mean_GAIT_SD(4, i)=std(handles.GAIT_RFL(find(isnan(handles.GAIT_RFL(:,handles.DATA_SD_REF(i)))==0 & handles.GAIT_RFL(:,111)==1), handles.DATA_SD_REF(i)));
        end
    end
    
    MeanSumToSave=[MeanSumToSave, mean_GAIT, mean_GAIT_SD];
    MeanSumToSave_header=[MeanSumToSave_header, GAIT_header, handles.DATA_SD_header];
    
    
    %% SAVING AVERAGE
    success = save_file([handles.PATHNAME, 'SUM', mySlash, handles.FILENAME(1:end-4), '_MEAN_SUM.txt'], MeanSumToSave_header, sumfile, MeanSumToSave);
    if success~=1
        warndlg([handles.FILENAME(1:end-4), '_MEAN_SUM.txt'], 'G-gait: WRITING FAILURE');
        failure_writing=1;
    end
    
    
    %% SAVING MEAN KINEMATIC FILES
    HEADER_HL = {'MEAN CREST' 'MEAN THIGH' 'MEAN LEG' 'MEAN FOOT' 'MEAN TOE' 'MEAN LIMB' 'MEAN HIP' 'MEAN KNEE' 'MEAN ANKLE' 'MEAN MTP' 'MEAN AB/AD_PELVIS' 'MEAN ROT_PELVIS' ...
                 'SD CREST' 'SD THIGH' 'SD LEG' 'SD FOOT' 'SD TOE' 'SD LIMB' 'SD HIP' 'SD KNEE' 'SD ANKLE' 'SD MTP' 'SD AB/AD_PELVIS' 'SD ROT_PELVIS'};
    HEADER_FL = {'MEAN SCAPULA' 'MEAN ARM' 'MEAN FOREARM' 'MEAN HAND' 'MEAN EMPTY' 'MEAN LIMB' 'MEAN SCAP' 'MEAN SHOULDER' 'MEAN ELBOW' 'MEAN WRIST' 'MEAN LAT-LIMB' 'MEAN EMPTY' ...
                 'SD SCAPULA' 'SD ARM' 'SD FOREARM' 'SD HAND' 'SD EMPTY' 'SD LIMB' 'SD SCAP' 'SD SHOULDER' 'SD ELBOW' 'SD WRIST' 'SD LAT-LIMB' 'SD EMPTY'};
       
    success = save_file([handles.PATHNAME, 'AVERAGE', mySlash, handles.FILENAME(1:end-4), '_RIGHT_HL.txt'], ...
        HEADER_HL, [], [handles.ANGLE_RHL_mean(:,1:12), handles.ANGLE_RHL_mean(:,13:24)-handles.ANGLE_RHL_mean(:,1:12)]);
    if success~=1, warndlg([name_root, '_RIGHT_HL.txt'], 'G-gait: WRITING FAILURE'); failure_writing=1; end
    
    success = save_file([handles.PATHNAME, 'AVERAGE', mySlash, handles.FILENAME(1:end-4), '_LEFT_HL.txt'], ...
        HEADER_HL, [], [handles.ANGLE_LHL_mean(:,1:12), handles.ANGLE_LHL_mean(:,13:24)-handles.ANGLE_LHL_mean(:,1:12)]);
    if success~=1, warndlg([name_root, '_LEFT_HL.txt'], 'G-gait: WRITING FAILURE'); failure_writing=1; end
    
 
    if handles.gait_type==2 % quadrupedal case
        success = save_file([handles.PATHNAME, 'AVERAGE', mySlash, handles.FILENAME(1:end-4), '_RIGHT_FL.txt'], ...
            HEADER_FL, [], [handles.ANGLE_RFL_mean(:,1:12), handles.ANGLE_RFL_mean(:,13:24)-handles.ANGLE_RFL_mean(:,1:12)]);
        if success~=1, warndlg([name_root, '_RIGHT_FL.txt'], 'G-gait: WRITING FAILURE'); failure_writing=1; end
        
        success = save_file([handles.PATHNAME, 'AVERAGE', mySlash, handles.FILENAME(1:end-4), '_LEFT_FL.txt'], ...
            HEADER_FL, [], [handles.ANGLE_LFL_mean(:,1:12), handles.ANGLE_LFL_mean(:,13:24)-handles.ANGLE_LFL_mean(:,1:12)]);
        if success~=1, warndlg([name_root, '_LEFT_FL.txt'], 'G-gait: WRITING FAILURE'); failure_writing=1; end
    end
    
end


%% SAVE ALL
if handles.save_option==2
    
    % KINEMATIC DATA
    switch handles.gait_type
        case 1
            Labels = [handles.TIME_header handles.ANGLES_HL_header handles.DATA_KIN_HL_header(3:end)];
            N_Labels=size(Labels,2);
            Data = [handles.DATA_KIN(:,1:2) handles.ANGLE_LHL handles.ANGLE_RHL handles.ANGLE_trunk handles.DATA_KIN(:,3:end)];
            N_Data=size(Data);
            if N_Labels ~= N_Data(2), disp('[Ggait - save KIN data - around line 2002] - Mismatch in labels and data size !!'), end
            success = save_file([handles.PATHNAME,'PROCESS', mySlash, handles.FILENAME(1:end-4),'_KIN.txt'], ...
                Labels, [], Data);       
        case 2
            Labels = [handles.TIME_header handles.ANGLES_HL_header handles.ANGLES_FL_header handles.DATA_KIN_FL_header(3:end)];
            N_Labels=size(Labels,2);
            Data = [handles.DATA_KIN(:,1:2) handles.ANGLE_LHL handles.ANGLE_RHL handles.ANGLE_trunk handles.ANGLE_LFL handles.ANGLE_RFL handles.DATA_KIN(:,3:end)];
            N_Data=size(Data);
            if N_Labels ~= N_Data(2), disp('[Ggait - save KIN data - around line 2010] - Mismatch in labels and data size !!'), end
            success = save_file([handles.PATHNAME,'PROCESS', mySlash, handles.FILENAME(1:end-4),'_KINA.txt'], ...
                Labels, [], Data);
    end
    if success~=1
        warndlg([handles.FILENAME(1:end-4),'_KIN.txt'], 'G-gait: WRITING FAILURE');
        failure_writing=1;
    end

    
    % EMG DATA
    if handles.is_emg
        handles.DATA_EMG_header = [handles.TIME_header handles.DATA_EMG_header];
        success = save_file([handles.PATHNAME,'PROCESS', mySlash, handles.FILENAME(1:end-4),'_EMG.txt'], handles.DATA_EMG_header, [], handles.DATA_EMG);
        if success~=1
            warndlg([handles.FILENAME(1:end-4),'_EMG.txt'], 'G-gait: WRITING FAILURE');
            failure_writing=1;
        end
    end
    
    % FORCE DATA
    if handles.is_force
        success = save_file([handles.PATHNAME,'PROCESS', mySlash, handles.FILENAME(1:end-4),'_FORCE.txt'], handles.DATA_FORCE_header, [], handles.DATA_FORCE);
        if success~=1
            warndlg([handles.FILENAME(1:end-4),'_FORCE.txt'], 'WRITING FAILURE');
            failure_writing=1;
        end
    end

    
    % NEURONAL DATA
    if handles.is_NEU
        handles.DATA_NEU_header = handles.TIME_header;
        for i=3:size(handles.DATA_NEU,2)
            handles.DATA_NEU_header(i)= {['Neu#' char(num2str(i-2))]};
        end
        
        success = save_file([handles.PATHNAME,'PROCESS', mySlash, handles.FILENAME(1:end-4),'_NEU.txt'], ...
            handles.DATA_NEU_header, [], handles.DATA_NEU);
        if success~=1
            warndlg([handles.FILENAME(1:end-4),'_NEU.txt'], 'G-gait: WRITING FAILURE');
            failure_writing=1;
        end
    end
end


switch failure_writing
    case 0, msgbox('ALL FILES SUCCESSFULLY WRITTEN','G-gait: SAVING');
    case 1, warndlg('SOME FILES COULD NOT BE WRITTEN','G-gait: FAILURE');
end


%varargout{1} = 1;
varargout{2} = handles.ANGLE_RFL_mean;

end