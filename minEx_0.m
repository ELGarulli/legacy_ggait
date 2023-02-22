function varargout = minEx_0(varargin)
% Code from ggait
handles.filterKIN_freq = 10;
% Code from BNload_Callback

%initiate values that come from ggait (some might not be needed/can be left
%empty throughout whole code, or might need to be adjustes/checked for
%accuracy)
handles.gait_type = 1; %bipedal
handles.DATA_FORCE = []; 
handles.is_swing = 0;
handles.is_force = 0;
handles.is_ladder = 0; %for now, might need to switch for ladder condition
handles.is_emg = 0;
handles.is_gait_file = 0;

%handles.FILENAME = 'runway_02.c3d';
%handles.PATHNAME = 'C:\Users\wenge\Documents\GitHub\gait-new-repo\'
%pathname = varargin{1};
filename = varargin{1};
pathname = varargin{2};

handles.PATHNAME = pathname;
%handles.PATHNAME = 'C:\Users\wenge\Desktop\Evelyn\';
handles.FILENAME = filename;

%% Used in minEx_3 
handles.DATA_SumAverage_HL=[]; handles.DATA_SumAverage_FL=[];
handles.FORCE_features=[];

%% 
%%% GAIT VARIABLES INITIALIZATION (taken from ggait) ==========================================
% data
handles.DATA_KIN=[]; % kinematic data
handles.DATA_EMG=[]; % EMG data (when EMG electrodes)
handles.DATA_FORCE=[]; % force data (when force plate)
handles.DATA_CoP=[]; % center of pressure data (when force plate)
handles.DATA_NEU=[]; % neuron data (when electrodes)
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

% gait params
handles.GAIT_INFO=[]; handles.GAIT_INFO_FL=[];
handles.GAIT_LHL=[]; handles.GAIT_RHL=[]; handles.GAIT_LFL=[]; handles.GAIT_RFL=[];

% EMG
handles.EMG_freq=0;
handles.EMG_LHL=[]; handles.EMG_RHL=[]; handles.EMG_LFL=[]; handles.EMG_RFL=[];
handles.EMG_RHL_mean=[]; handles.EMG_LHL_mean=[]; handles.EMG_RFL_mean=[]; handles.EMG_LFL_mean=[];
handles.EMG_CoCo_LHL=[]; handles.EMG_CoCo_RHL=[]; handles.EMG_CoCo_LFL=[]; handles.EMG_CoCo_RFL=[];
handles.EMG_features_LHL=[]; handles.EMG_features_RHL=[];

% force & CoP
handles.FORCE_freq=0;
handles.FORCE_L=[];handles.FORCE_R=[];
handles.FORCE_LHL_mean=[]; handles.FORCE_RHL_mean=[]; handles.FORCE_LFL_mean=[]; handles.FORCE_RFL_mean=[];
handles.FORCE_features=[];

handles.CoP_LHL_mean=[]; handles.CoP_RHL_mean=[]; handles.CoP_LFL_mean=[]; handles.CoP_RFL_mean=[];


%% ADDITIONAL SETUP FROM GGAIT 
% default and static values (do not modify, please)
handles.setup=6;
handles.FORCE=[1;2;3];
handles.is_NEU=0;
handles.type_euler=1;
handles.is_shoulder=1;
handles.bwss=100:-5:0;
speedval=1;


%% MORE SETUP FOR SPECIFIC CASE 'Multi-EMGs #341'
% process
handles.speeds=[0;9;13];

handles.conds1={'P10'; 'P13'; 'P16'};
handles.FILE_header(:,3)={'TIMEPOINT'};

handles.conds2={'tonic_E1'; 'tonic_E2'; 'tonic_E3'; 'tonic_E4'; ...
    'tonic_E5'; 'tonic_E6'; 'tonic_E7'; 'tonic_E8'; ...
    'tonic_left_right'; 'phaston_left_right'; 'extratonic_left_right'; ...
    'tonic_right'; 'phaston_right'; 'extratonic_right'; ...
    'tonic_left'; 'phaston_left'; 'extratonic_left'};
handles.FILE_header(:,4)={'TESTING'};

handles.conds3={'TRAINING'; 'NO TRAINING'};
handles.FILE_header(:,5)={'TRAINING'};

% other
handles.section_to_filter_EMG=[1;10];
handles.emgChLeft=[9;10];
handles.emgChRight=[1;2;3;4;5;6;7;8];
handles.emgChLeft_FL=[];
handles.emgChRight_FL=[];
handles.pairs=[1 4; 2 3; 5 8; 6 7; 9 10];
handles.pairsLH=[9 10];
handles.pairsRH=[1 4; 2 3; 5 8; 6 7];
handles.pairsLF=[];
handles.pairsRF=[];


%%% VISUALIZATION PANEL INITIALIZATION =============================================================
%handles.plotsPHASE=handles.axes1; axes(handles.plotsPHASE); axis off;
%handles.plotsKIN=[handles.axes2, handles.axes3, handles.axes4, handles.axes5];
%handles.legendKIN=[handles.LGkin1, handles.LGkin2, handles.LGkin3, handles.LGkin4];
%handles.plotsEMG=[handles.axes6, handles.axes7, handles.axes8, handles.axes9, handles.axes10, ...
%    handles.axes11, handles.axes12, handles.axes13, handles.axes14, handles.axes15, handles.axes16];
%handles.legendEMG=[handles.LGemg1, handles.LGemg2, handles.LGemg3, handles.LGemg4, handles.LGemg5...
%    handles.LGemg6, handles.LGemg7, handles.LGemg8, handles.LGemg9, handles.LGemg10, handles.LGemg11];
handles.TXkin_HL={'HIP'; 'KNEE'; 'ANKLE'; 'MTP'};
handles.TXkin_FL={'SHOULDER'; 'ELBOW'; 'WRIST'; 'MCP'};

        
handles.setups={'TUTORIAL'; 'ZNZ';'DEMO';'MONOAMINE'; 'MLR'; 'Multi-EMGs #341'; 'HEMISECTION 2HLs+FL'; 'HEMISECTION 2HL+4FL'; 'HEMISECTION 4FL'; 'HEMISECTION 5FL';'ZNZ_NEU';'NIKO';'ZNZ NO SHOULDER';'HUMAN LU';'HUMAN LOCOMOTION';'HUMAN REACHING'; 'MOUSE'; 'DIVAS'};
handles.gaittypes={'BIPEDAL';'QUADRUPEDAL'};


Setup = 6; % index of the project
% The variable handles.isforce contains 0
varargout{1} = handles;
end