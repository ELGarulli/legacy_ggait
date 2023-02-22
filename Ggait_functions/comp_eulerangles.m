function comp_eulerangles(settings_filename)
% comp_eulerangles.m: calculate euler angles
%
%
% Where settings_filename is a string with the filename of the settings file to be loaded. Settings files are text files of the format:
%
% (first line is ignored: meant to be a description of the settings file). /* delimits comments
% SAVE_FILES = 1; /* Whether to save output files
% SAVE_SUMMARIES = 1; /* Whether to save summary data (i.e. calculated descriptive statistics)
% JOINT_AXIS = 2; /* Axis for the joints: at 0 rotation joint axes are parallel to this axis
% SEGMENT_AXIS = 1; /* Axis for the segments: at nominal configuration segments are parallel this axis
% KINEMATIC_SCALE = 0.001; /* adjustment factor (e.g. scaling or negation) to apply to kinematics
% FILTER_KIN = 1; /* Whether to filter the kinematics data
% XYZ_SAMPLING_FREQUENCY_S = 240; /* sampling frequency of kinematics
% XYZ_CUTOFF_FREQUENCY_HZ = 5; /* cutoff frequency to use for low-pass Butterworth
% CALCULATE_VELOCITIES = 1; /* whether to calculate and save angular velocities
% COERCE_ANGLES = 0; /* whether to try to coerce the angles to the same sense
% USE_MEAN_SEGMENT_LENGTHS = 0; /* whether to use mean segment lengths when re-constructing xyz data
% INVOKE_MAKESTICK = 0; /* whether to run makestick.m after completion of eulerangles
% BEGIN_SAMPLE = 0; /* sample for makestick to begin displaying if all data in file are not good
% END_SAMPLE = 0; /* sample for makestick to end displaying if all data in file are not good
% FILL_GAPS = 0; /* whether to fill gaps in the data. 0 = don't fill gaps, 1 = fill gaps in raw data, 2 = fill gaps in calculated angles
% BODY_POINTS = <dataset> <rear_r> <rear_l> <front_r> <front_l>
% SEGMENT_CHAIN = <dataset> <chain_1_seg_1_start> <chain_1_seg_2_start> <chain_1_seg_3_start> <chain_1_seg_4_start>
% SEGMENT_CHAIN = <dataset> <chain_2_seg_1_start> <chain_2_seg_2_start> <chain_2_seg_3_start> <chain_2_seg_4_start>
% SOURCE_FILES = 1 .\31748_041123_PRE_RT_RIGHT_3ld.txt
% SOURCE_FILES = 1 .\34564_041124_P3_RT_RIGHT_3ld.txt
% etc.
%
% Individual animals are identified as datasets: there is one COM file per dataset, i.e.
% SOURCE_FILES = <dataset> <filename1>
% SOURCE_FILES = <dataset> <filename2>

% N.B. These calculations are based on legacy code and are not pretty or efficient. Sorry.

%Spacelib variables
Xaxis = [1 0 0]';
Yaxis = [0 1 0]';
Zaxis = [0 0 1]';

X = 1;
Y = 2;
Z = 3;

XYZ_ORDER_STRING_CELL = {'_X' '_Y' '_Z'};

ANGLE_ORDER = [Z Y X]; % the order of the Euler angles to use for body
ANGLE_ORDER_UNITVS = [Zaxis Yaxis Xaxis];
ANGLE_ORDER_STRING_CELL = {'_Z' '_Y' '_X'};
GANGLE_ORDER_STRING_CELL = {'_X' '_Y' '_Z'};

body_point_indices = [];
reference_point_indices = [];
chain_dofs = [];
chain_ango = [];

% LOAD SETTINGS FILE AND PARSE ENTRIES ======================================

settings_cell_array = load_settings(settings_filename);
settings_loaded = size(settings_cell_array,1);

num_trials_array = [];
num_sc_array = [];
num_bp_array = [];
num_rp_array = [];
num_dof_array = [];
num_ango_array = [];
body_points = [];
reference_points = [];

kin_filenames = {};

% parse settings file

if settings_loaded > 0
    for loaded_setting = 1:size(settings_cell_array,1)
        setting = char(settings_cell_array{loaded_setting,1});
        value = settings_cell_array{loaded_setting,2};
        value = fliplr(deblank(fliplr(deblank(value))));
        if isempty(value)
            fprintf('ERROR: No value for FILE found. Filename expected.\n');
        else
            dataset_number = 0;
            switch setting

                case {'SOURCE_FILE' 'FILE'}
                    value_temp = [];
                    for i=1:size(value,2)
                        switch value(i)
                            case {' ','	'}
                                if dataset_number == 0
                                    dataset_number = str2num(value_temp);
                                    if isempty(dataset_number)
                                        fprintf('ERROR: string found instead of dataset number in settings file.\n');
                                        fprintf('Format of setting file should be:\n');
                                        fprintf('SOURCE_FILE = 1 data_file_set_1_a.txt\n');
                                        fprintf('SOURCE_FILE = 1 data_file_set_1_b.txt\n');
                                        fprintf('SOURCE_FILE = 2 data_file_set_2_a.txt\n');
                                        fprintf('SOURCE_FILE = 2 data_file_set_2_b.txt\n');
                                        return
                                    end
                                    if dataset_number == 0
                                        fprintf('ERROR: invalid dataset numbet in settings file.\n');
                                        return;
                                    end
                                    value_temp = [];
                                    if size(num_trials_array,2) < dataset_number
                                        num_trials_array(1,dataset_number) = 0;
                                    end
                                end
                            otherwise
                                value_temp = [value_temp value(i)];
                        end
                    end
                    num_trials_array(1,dataset_number) = num_trials_array(1,dataset_number)+1;
                    kin_filenames{dataset_number,num_trials_array(1,dataset_number)} = value_temp;
                    data_filename_read = 1;
                    value_temp = [];
                case 'BODY_POINTS'
                    value_temp = [];
                    for i=1:size(value,2)
                        switch value(i)
                            case {' ','	'}
                                if dataset_number == 0
                                    dataset_number = str2num(value_temp);
                                    if dataset_number == 0
                                        fprintf('ERROR: invalid dataset number in settings file.\n');
                                        return;
                                    end
                                    value_temp = [];
                                    if size(num_bp_array,2) < dataset_number
                                        num_bp_array(1,dataset_number) = 0;
                                    end
                                else
                                    value_temp = [value_temp value(i)];
                                end
                            otherwise
                                value_temp = [value_temp value(i)];
                        end
                    end
                    num_bp_array(1,dataset_number) = num_bp_array(1,dataset_number)+1;
                    body_points{dataset_number,num_bp_array(1,dataset_number)} = str2num(value_temp);
                    body_points_read = 1;
                    value_temp = [];
                case 'COM_REFERENCE_POINTS'
                    value_temp = [];
                    for i=1:size(value,2)
                        switch value(i)
                            case {' ','	'}
                                if dataset_number == 0
                                    dataset_number = str2num(value_temp);
                                    if dataset_number == 0
                                        fprintf('ERROR: invalid dataset number in settings file.\n');
                                        return;
                                    end
                                    value_temp = [];
                                    if size(num_rp_array,2) < dataset_number
                                        num_rp_array(1,dataset_number) = 0;
                                    end
                                else
                                    value_temp = [value_temp value(i)];
                                end
                            otherwise
                                value_temp = [value_temp value(i)];
                        end
                    end
                    num_rp_array(1,dataset_number) = num_rp_array(1,dataset_number)+1;
                    reference_points{dataset_number,num_rp_array(1,dataset_number)} = str2num(value_temp);
                    reference_points_read = 1;
                    value_temp = [];
                case 'SEGMENT_CHAIN'
                    value_temp = [];
                    for i=1:size(value,2)
                        switch value(i)
                            case {' ','	'}
                                if dataset_number == 0
                                    dataset_number = str2num(value_temp);
                                    if dataset_number == 0
                                        fprintf('ERROR: invalid dataset number in settings file.\n');
                                        return;
                                    end
                                    value_temp = [];
                                    if size(num_sc_array,2) < dataset_number
                                        num_sc_array(1,dataset_number) = 0;
                                    end
                                else
                                    value_temp = [value_temp value(i)];
                                end
                            otherwise
                                value_temp = [value_temp value(i)];
                        end
                    end
                    num_sc_array(1,dataset_number) = num_sc_array(1,dataset_number)+1;
                    segment_chains{dataset_number,num_sc_array(1,dataset_number)} = str2num(value_temp);
                    segment_chains_read = 1;
                    value_temp = [];
                case 'DOFS_TO_USE'
                    value_temp = [];
                    for i=1:size(value,2)
                        switch value(i)
                            case {' ','	'}
                                if dataset_number == 0
                                    dataset_number = str2num(value_temp);
                                    if dataset_number == 0
                                        fprintf('ERROR: invalid dataset number in settings file.\n');
                                        return;
                                    end
                                    value_temp = [];
                                    if size(num_dof_array,2) < dataset_number
                                        num_dof_array(1,dataset_number) = 0;
                                    end
                                else
                                    value_temp = [value_temp value(i)];
                                end
                            otherwise
                                value_temp = [value_temp value(i)];
                        end
                    end
                    num_dof_array(1,dataset_number) = num_dof_array(1,dataset_number)+1;
                    chain_dofs{dataset_number,num_dof_array(1,dataset_number)} = str2num(value_temp);
                    chain_dofs_read = 1;
                    value_temp = [];
                case 'ANGLE_ORDER'
                    value_temp = [];
                    for i=1:size(value,2)
                        switch value(i)
                            case {' ','	'}
                                if dataset_number == 0
                                    dataset_number = str2num(value_temp);
                                    if dataset_number == 0
                                        fprintf('ERROR: invalid dataset number in settings file.\n');
                                        return;
                                    end
                                    value_temp = [];
                                    if size(num_ango_array,2) < dataset_number
                                        num_ango_array(1,dataset_number) = 0;
                                    end
                                else
                                    value_temp = [value_temp value(i)];
                                end
                            otherwise
                                value_temp = [value_temp value(i)];
                        end
                    end
                    num_ango_array(1,dataset_number) = num_ango_array(1,dataset_number)+1;
                    chain_ango{dataset_number,num_ango_array(1,dataset_number)} = str2num(value_temp);
                    chain_angos_read = 1;
                    value_temp = [];
                case 'JOINT_AXIS'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for JOINT_AXIS found. Number expected.\n', value);
                    else
                        JOINT_AXIS = value;
                        fprintf('Setting %s found. JOINT_AXIS = %d.\n',setting, JOINT_AXIS);
                    end
                case 'SEGMENT_AXIS'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for SEGMENT_AXIS found. Number expected.\n', value);
                    else
                        SEGMENT_AXIS = value;
                        fprintf('Setting %s found. SEGMENT_AXIS = %d.\n',setting, SEGMENT_AXIS);
                    end
                case 'FILTER_KIN'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for FILTER_KIN found. Number expected.\n', value);
                    else
                        FILTER_KIN = value;
                        fprintf('Setting %s found. FILTER_KIN = %d.\n',setting, FILTER_KIN);
                    end
                case 'XYZ_SAMPLING_FREQUENCY_S'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for XYZ_SAMPLING_FREQUENCY_S found. Number expected.\n', value);
                    else
                        XYZ_SAMPLING_FREQUENCY_S = value;
                        fprintf('Setting %s found. XYZ_SAMPLING_FREQUENCY_S = %d.\n',setting, XYZ_SAMPLING_FREQUENCY_S);
                    end
                case 'XYZ_CUTOFF_FREQUENCY_HZ'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for XYZ_CUTOFF_FREQUENCY_HZ found. Number expected.\n', value);
                    else
                        XYZ_CUTOFF_FREQUENCY_HZ = value;
                        fprintf('Setting %s found. XYZ_CUTOFF_FREQUENCY_HZ = %d.\n',setting, XYZ_CUTOFF_FREQUENCY_HZ);
                    end
                case 'SAVE_FILES'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for SAVE_FILES found. Number expected.\n', value);
                    else
                        SAVE_FILES = value;
                        fprintf('Setting %s found. SAVE_FILES = %d.\n',setting, SAVE_FILES);
                    end
                case 'SAVE_SUMMARIES'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for SAVE_SUMMARIES found. Number expected.\n', value);
                    else
                        SAVE_SUMMARIES = value;
                        fprintf('Setting %s found. SAVE_SUMMARIES = %d.\n',setting, SAVE_SUMMARIES);
                    end
                case 'KINEMATIC_SCALE'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for KINEMATIC_SCALE found. Number expected.\n', value);
                    else
                        KINEMATIC_SCALE = value;
                        fprintf('Setting %s found. KINEMATIC_SCALE = %d.\n',setting, KINEMATIC_SCALE);
                    end
                case 'CALCULATE_VELOCITIES'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for CALCULATE_VELOCITIES found. Number expected.\n', value);
                    else
                        CALCULATE_VELOCITIES = value;
                        fprintf('Setting %s found. CALCULATE_VELOCITIES = %d.\n',setting, CALCULATE_VELOCITIES);
                    end
                case 'USE_MEAN_SEGMENT_LENGTHS'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for USE_MEAN_SEGMENT_LENGTHS found. Number expected.\n', value);
                    else
                        USE_MEAN_SEGMENT_LENGTHS = value;
                        fprintf('Setting %s found. USE_MEAN_SEGMENT_LENGTHS = %d.\n',setting, USE_MEAN_SEGMENT_LENGTHS);
                    end
                case 'COERCE_ANGLES'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for COERCE_ANGLES found. Number expected.\n', value);
                    else
                        COERCE_ANGLES = value;
                        fprintf('Setting %s found. COERCE_ANGLES = %d.\n',setting, COERCE_ANGLES);
                    end
                case 'INVOKE_MAKESTICK'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for INVOKE_MAKESTICK found. Number expected.\n', value);
                    else
                        INVOKE_MAKESTICK = value;
                        fprintf('Setting %s found. INVOKE_MAKESTICK = %d.\n',setting, INVOKE_MAKESTICK);
                    end
                case 'BEGIN_SAMPLE'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for BEGIN_SAMPLE found. Number expected.\n', value);
                    else
                        BEGIN_SAMPLE = value;
                        fprintf('Setting %s found. BEGIN_SAMPLE = %d.\n',setting, BEGIN_SAMPLE);
                    end
                case 'END_SAMPLE'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for END_SAMPLE found. Number expected.\n', value);
                    else
                        END_SAMPLE = value;
                        fprintf('Setting %s found. END_SAMPLE = %d.\n',setting, END_SAMPLE);
                    end
                case 'FILL_GAPS'
                    value = str2num(value);
                    if isempty(value)
                        fprintf('ERROR: Character value %s for FILL_GAPS found. Number expected.\n', value);
                    else
                        FILL_GAPS = value;
                        fprintf('Setting %s found. FILL_GAPS = %d.\n',setting, FILL_GAPS);
                    end

                otherwise
                    fprintf('WARNING: Setting %s found but not recognized. Ignored.\n', setting);
            end
        end
    end
else
    fprintf('ERROR: unable to load settings file.\n');
    return;
end

if SAVE_FILES == 1
    SAVE_SUMMARIES = SAVE_FILES; % for backward-compatibility. Assume that if you want to save files you want to save summaries
    fprintf('\n Saving files and summary files.\n');
end



% INITIALIZE ======================================

data_header_cell_array = {};
text_column_cell_array = {};
forces_forceref = [];
forces_kinref = [];

num_datasets = size(num_trials_array,2);
trials_completed = 0;
total_force_filenames = {};

total_trials = sum(num_trials_array');

% if no dofs to use or separate angle orders specified, use default values
if isempty(chain_ango)
    for dataset=1:num_datasets
        for sc=1:num_sc_array(1,dataset);
            chain_ango{dataset,sc} = repmat(ANGLE_ORDER,(length(segment_chains{dataset,sc})-1),1);
        end
    end
end
if isempty(chain_dofs)
    for dataset=1:num_datasets
        for sc=1:num_sc_array(1,dataset);
            chain_dofs{dataset,sc} = repmat([1 1 1],(length(segment_chains{dataset,sc})-1),1);
        end
    end
end

current_file = 0;

% Check to make sure all required files are present. Helps when doing lots of files -- don't have to
% wait for many files to process before eventually encountering an error...
for dataset=1:num_datasets
    for trial = 1:num_trials_array(1,dataset)
        [P N E] = fileparts(kin_filenames{dataset,trial});
        filespresent = dir(P);
        K_file_found = 0;
        for currfile=1:length(filespresent)
            if strcmp(filespresent(currfile).name,[N E]);
                K_file_found = 1;
                break;
            end
        end
        if K_file_found == 0
            fprintf('\nERROR!. Kinematics file for dataset %d trial %d not found: %s.\n',dataset,trial,kin_filenames{dataset,trial})
            return;
        end
    end
end
fprintf('\n All files present... Proceeding.\n');

NUMBER_OF_PARAMETERS = 3;

% LOAD FILES AND CALCULATE ANGLES ======================================

for dataset=1:num_datasets
    successful_trials(dataset) = 0;
    current_file = current_file+1;
    results_array = [];
    com_r = [];
    for trial = 1:num_trials_array(1,dataset)
        forces_forceref = [];
        forces_kinref = [];
        moments_forceref = [];
        body_data_kinref = [];
        reference_data_kinref = [];
        limb_data_kinref = [];
        sl_header_cell_array = {};
        eu_header_cell_array = {};
        ga_header_cell_array = {};
        reconxyz_header_cell_array = {};
        good_trial = 1;

        if ~isempty(num_rp_array)
            if num_rp_array(1,dataset) == 1
                reference_point_indices = reference_points{dataset,1};
            elseif num_rp_array(1,dataset) == num_trials_array(1,dataset)
                reference_point_indices = reference_points{dataset,trial};
            else
                fprintf('\nERROR! Number of reference point vectors does not equal 1 or number of trials in dataset.\n');
            end
        end
        if ~isempty(num_bp_array)
            if size(num_bp_array,2) >= dataset
                if num_bp_array(1,dataset) == 1
                    body_point_indices = body_points{dataset,1};
                elseif num_bp_array(1,dataset) == num_trials_array(1,dataset)
                    body_point_indices = body_points{dataset,trial};
                else
                    fprintf('\nERROR! Number of body point vectors does not equal 1 or number of trials in dataset.\n');
                end
            else
                fprintf('\nERROR! No BODY_POINTS found for dataset %d.\n',dataset);
                return;
            end
        end

        fprintf('\nLoading kinematics file %s...',kin_filenames{dataset,trial});
        [xyz_header_cell_array{dataset,trial},~,src_xyz_data_kinref] = load_data_file(kin_filenames{dataset,trial},0,1);
        if isempty(src_xyz_data_kinref)
            fprintf('\nERROR: FILE %s NOT FOUND.\n',kin_filenames{dataset,trial});
            good_trial = 0;
        end
        if FILTER_KIN > 0
            fprintf('\nFiltering kinematic data, sampling frequency = %d, cutoff frequency = %d\n',XYZ_SAMPLING_FREQUENCY_S,XYZ_CUTOFF_FREQUENCY_HZ);
            [D,C] = butter(4,(XYZ_CUTOFF_FREQUENCY_HZ/(XYZ_SAMPLING_FREQUENCY_S/2)));
            src_xyz_data_kinref = filtfilt(D,C,src_xyz_data_kinref);
        end

        if good_trial
            trials_completed = trials_completed + 1;
            input_rows = size(src_xyz_data_kinref,1);
            num_chains = num_sc_array(1,dataset);
            chain_num_points = [];

            USE_BODY_FRAME = ~isempty(body_point_indices);
            BODY_START = 1;
            BODY_POINTS = 0;
            com_to_body_array = zeros(input_rows,(BODY_POINTS*3));
            body_euler_angles = zeros(input_rows,3);
            com_to_pt1_array = zeros(input_rows,(num_chains*3));
            body_global_angles = zeros(input_rows,3);
            % if there are no body points specified, put some in anyway. It is assumed that this happens only during
            % debugging or preliminary data and body points will be added later
            % body_data_kinref = zeros(size(src_xyz_data_kinref,1),12);
            new_origin_g_array = zeros(input_rows,3);
            total_joints = 0;
            for sc = 1:num_chains
                total_joints = total_joints+length(segment_chains{dataset,sc})-1;
            end
            segment_lengths_array = zeros(input_rows,total_joints);
            euler_angle_array = zeros(input_rows,(total_joints*3));
            global_angle_array = zeros(input_rows,(total_joints*3));
            
            % EXTRACT REFERENCE DATA =================================================================================
            % Reference points are used to calculate the location of the COM if available
            if ~isempty(reference_point_indices)
                if FILL_GAPS == 1
                    e=1;
                    reference_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,reference_point_indices(1):(reference_point_indices(1)+2)),1);
                    e=e+3;
                    reference_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,reference_point_indices(2):(reference_point_indices(2)+2)),1);
                    e=e+3;
                    reference_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,reference_point_indices(3):(reference_point_indices(3)+2)),1);
                    e=e+3;
                    reference_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,reference_point_indices(4):(reference_point_indices(4)+2)),1);
                else
                    e=1;
                    reference_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,reference_point_indices(1):(reference_point_indices(1)+2));
                    e=e+3;
                    reference_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,reference_point_indices(2):(reference_point_indices(2)+2));
                    e=e+3;
                    reference_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,reference_point_indices(3):(reference_point_indices(3)+2));
                    e=e+3;
                    reference_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,reference_point_indices(4):(reference_point_indices(4)+2));
                end
            end

            % EXTRACT BODY DATA =================================================================================
            % do a little rearrangement just to make things simpler
            % create separate arrays for body points
            % '_kinref' indicates in reference frame of kinematics
            if ~isempty(body_point_indices)
                if FILL_GAPS == 1
                    e=1;
                    body_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,body_point_indices(1):(body_point_indices(1)+2)),1);
                    kin_header_array{1,1} = 'REAR_R';
                    e=e+3;
                    body_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,body_point_indices(2):(body_point_indices(2)+2)),1);
                    kin_header_array{1,2} = 'REAR_L';
                    e=e+3;
                    body_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,body_point_indices(3):(body_point_indices(3)+2)),1);
                    kin_header_array{1,3} = 'FRONT_R';
                    e=e+3;
                    body_data_kinref(:,e:(e+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,body_point_indices(4):(body_point_indices(4)+2)),1);
                    kin_header_array{1,3} = 'FRONT_L';
                else
                    e=1;
                    body_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,body_point_indices(1):(body_point_indices(1)+2));
                    kin_header_array{1,1} = 'REAR_R';
                    e=e+3;
                    body_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,body_point_indices(2):(body_point_indices(2)+2));
                    kin_header_array{1,2} = 'REAR_L';
                    e=e+3;
                    body_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,body_point_indices(3):(body_point_indices(3)+2));
                    kin_header_array{1,3} = 'FRONT_R';
                    e=e+3;
                    body_data_kinref(:,e:(e+2)) = src_xyz_data_kinref(:,body_point_indices(4):(body_point_indices(4)+2));
                    kin_header_array{1,3} = 'FRONT_L';
                end
            end
            REAR_R = 1;
            REAR_L = 4;
            FRONT_R = 7;
            FRONT_L = 10;
            
            % REMOVE GAPS IN SEGMENT DATA IF DESIRED =================================================================================
            for sc = 1:num_chains
                segment_chain_indices = segment_chains{dataset,sc};
                chain_num_points(sc) = length(segment_chain_indices);
                chain_joints = chain_num_points - 1;
                for segment = 1:chain_joints(sc)
                    start_1 = segment_chain_indices(segment);
                    if FILL_GAPS == 1
                        src_xyz_data_kinref(:,start_1:(start_1+2)) = preprocessingDATA_fill_gaps(src_xyz_data_kinref(:,start_1:(start_1+2)),1);
                    else
                        src_xyz_data_kinref(:,start_1:(start_1+2)) = src_xyz_data_kinref(:,start_1:(start_1+2));
                    end
                end
            end

            % CONSTRUCT HEADERS =================================================================================
            sl_header_cell_array = {};
            for j=1:3
                sl_header_cell_array{1,j} = ['New_origin' XYZ_ORDER_STRING_CELL{j}];
                eu_header_cell_array{1,j} = ['body' ANGLE_ORDER_STRING_CELL{j}];
                ga_header_cell_array{1,j} = ['body' GANGLE_ORDER_STRING_CELL{j}];
            end
            for i=1:length(reference_points)
                for j=1:3
                    sl_header_cell_array{1,(size(sl_header_cell_array,2)+1)} = sprintf('COM_to_reference_point_%d%s',i,XYZ_ORDER_STRING_CELL{j});
                end
            end
            for i=1:BODY_POINTS
                for j=1:3
                    sl_header_cell_array{1,(size(sl_header_cell_array,2)+1)} = sprintf('COM_to_body_point_%d%s',i,XYZ_ORDER_STRING_CELL{j});
                end
            end
            for sc = 1:num_chains
                for rdim = 1:3
                    sl_header_cell_array{1,(size(sl_header_cell_array,2)+1)} = sprintf('COM_to_pt1:chain_%d%s',sc,XYZ_ORDER_STRING_CELL{rdim});
                end
            end
            for sc = 1:num_chains
                segment_chain_indices = segment_chains{dataset,sc};
                s = 1;
                limb_data_kinref = [];
                chain_num_points(sc) = length(segment_chain_indices);
                kinmaxidx = max([segment_chain_indices body_point_indices]);
                chain_joints = chain_num_points - 1;
                if  kinmaxidx > size(src_xyz_data_kinref,2)
                    fprintf('\nERROR: SEGMENT CHAIN OR BODY POINT INDEX %d EXCEEDS NUMBER OF COLUMNS IN KINEMATIC FILE %s.\n',kinmaxidx,kin_filenames{dataset,trial});
                    return;
                end
                for segment=1:(length(segment_chain_indices)-1)
                    % limb_data_kinref(:,((s-1)*3+1):((s-1)*3+3)) = src_xyz_data_kinref(:,segment_chain_indices(segment):(segment_chain_indices(segment)+2));
                    % kin_header_array{1,s} = ['segment_' num2str(s)];
                    sl_header_cell_array{1,(size(sl_header_cell_array,2)+1)} = sprintf('Seg_length:chain_%d_segment_%d',sc,segment);
                    seg_angle_order = chain_ango{dataset,sc};
                    for angle = 1:3
                        eulang = seg_angle_order(segment,angle);
                        switch eulang
                            case 1
                                angle_string = '_X';
                            case 2
                                angle_string = '_Y';
                            case 3
                                angle_string = '_Z';
                        end
                        eu_header_cell_array{1,(size(eu_header_cell_array,2)+1)} = sprintf('chain_%d_segment_%d%s',sc,segment,angle_string);
                        ga_header_cell_array{1,(size(ga_header_cell_array,2)+1)} = sprintf('chain_%d_segment_%d%s',sc,segment,GANGLE_ORDER_STRING_CELL{angle});
                    end
                    s=s+1;
                end
            end

            % SCALE DATA =================================================================================
            if ~isempty(KINEMATIC_SCALE)
                body_data_kinref = KINEMATIC_SCALE*body_data_kinref;
                reference_data_kinref = KINEMATIC_SCALE*reference_data_kinref;
                src_xyz_data_kinref = KINEMATIC_SCALE*src_xyz_data_kinref;
            end

            % time vector for differentiating and plotting
            kin_time = linspace((1/XYZ_SAMPLING_FREQUENCY_S),(size(src_xyz_data_kinref,1)/XYZ_SAMPLING_FREQUENCY_S),size(src_xyz_data_kinref,1))';

            % CALCULATE EULER ANGLES =========================================================
            % calculate segment lengths and body euler angles. Put into their respective arrays
            fprintf('\nCalculating segment lengths and body euler angles...\n');
            valid_rows = [];
            valid_body_rows = all(body_data_kinref,2)';

            for row=1:size(src_xyz_data_kinref,1)
                body_frame = eye(4);
                % give some feedback so we know program hasn't crashed...
                if mod(row,10) == 0
                    if mod(row,200) == 0
                        fprintf('\n');
                    else
                        fprintf(' .');
                    end
                end
                if USE_BODY_FRAME == 0
                    body_frame = eye(4);
                    new_origin_g = [0;0;0;1];
                    g_to_r_t = eye(4);
                    current_frame = eye(4);
                    body_angles = [0 0 0];
                else
                    %calculate global location of new origin based on COM reference points and center of mass point specified
                    [body_frame_g base_point_g success] = comp_bodyframe(body_data_kinref(row,:));
                    if success ~= 1
                        fprintf('\nERROR calculating global location of new origin\n');
                        return
                    end
                    new_origin_g = base_point_g;
                    
                    % put results into array to be used later and saved
                    new_origin_g_array(row,1:3) = new_origin_g(1:3)';
                    com_frame(1:3,4) = body_frame_g(1:3);

                    % Calculate body euler angles in a simple way using atans
                    % This could probably be made a bit more accurate using a more
                    % sophisticated search for the best transformation matrix
                    % and extraction of the Euler angles from T using the kinemat library,
                    % but in the interests of time I am keeping the simple method for now
                    left_point_g = body_data_kinref(row,FRONT_L:(FRONT_L+2))';
                    right_point_g = body_data_kinref(row,FRONT_R:(FRONT_R+2))';
                    terminal_point_g = (body_data_kinref(row,FRONT_L:(FRONT_L+2))'+...
                        body_data_kinref(row,FRONT_R:(FRONT_R+2))')/2;

                    % Body elevation angles -- not really used now
                    b_t_segment = terminal_point_g-base_point_g;
                    x_z_body = atan2(b_t_segment(3),b_t_segment(1));
                    x_y_body = atan2(b_t_segment(2),b_t_segment(1));
                    y_z_body = atan2(b_t_segment(3),b_t_segment(2));
                    body_global_angles(row,:) = [x_z_body x_y_body y_z_body];

                    % So, the basic idea is to calculate the rotation about each axis
                    % then rotate the frame of reference by that angle and calculate
                    % the next Euler angle
                    current_frame_2 = eye(4);
                    body_angles = [];
                    for current_ang = ANGLE_ORDER
                        switch current_ang
                            case 1
                                current_frame_2(1:3,4) = right_point_g;
                                local_left_point = inv(current_frame_2) * [left_point_g;1];
                                X_angle_rad = atan2(local_left_point(3), local_left_point(2));
                                if X_angle_rad < (-pi/2)
                                    X_angle_rad = (2*pi) + X_angle_rad;
                                end
                                current_frame_2(1:3,1:3) = current_frame_2(1:3,1:3)*rotat(Xaxis,X_angle_rad);
                                body_angles = [body_angles X_angle_rad];
                            case 2
                                current_frame_2(1:3,4) = base_point_g;
                                local_terminal_point = inv(current_frame_2) * [terminal_point_g;1];
                                Y_angle_rad = -atan2(local_terminal_point(3),local_terminal_point(1));
                                if Y_angle_rad < (-pi/2)
                                    Y_angle_rad = (2*pi) + Y_angle_rad;
                                end
                                current_frame_2(1:3,1:3) = current_frame_2(1:3,1:3)*rotat(Yaxis,Y_angle_rad);
                                body_angles = [body_angles Y_angle_rad];
                            case 3
                                current_frame_2(1:3,4) = base_point_g;
                                local_terminal_point = inv(current_frame_2) * [terminal_point_g;1];
                                Z_angle_rad = atan2(local_terminal_point(2),local_terminal_point(1));
                                if Z_angle_rad < (-pi/2)
                                    Z_angle_rad = (2*pi) + Z_angle_rad;
                                end
                                current_frame_2(1:3,1:3) = current_frame_2(1:3,1:3)*rotat(Zaxis,Z_angle_rad);
                                body_angles = [body_angles Z_angle_rad];
                        end
                    end
                    if (COERCE_ANGLES > 0) & any(body_angles)
                        % try to make calculated angles continuous
                        % and of the same sense as the euler angles calculated
                        % for other trials in the analysis
                        if (current_file == 1) & (row == 1)
                            last_angles = zeros(1,3);
                        else
                            if row == 1
                                last_angles = last_body_angles;
                            else
                                last_angles = body_euler_angles((row-1),1:3);
                            end
                        end
                        for i=1:3
                            angles_complement_1(i) = (2*pi)+body_angles(i);
                            angles_complement_2(i) = body_angles(i)-(2*pi);
                            dist0 = abs(body_angles(i)-last_angles(i));
                            dist1 = abs(angles_complement_1(i) - last_angles(i));
                            dist2 = abs(angles_complement_2(i) - last_angles(i));
                            if (dist1<dist0) & (dist1<dist2)
                                body_angles(i) = angles_complement_1(i);
                            elseif (dist2<dist0) & (dist2<dist1)
                                body_angles(i) = angles_complement_2(i);
                            end
                        end
                    end % of COERCE_ANGLES if
                    g_to_r_t = inv(body_frame);
                    com_to_base_r = g_to_r_t*[base_point_g;1];
                    com_to_term_r = g_to_r_t*[terminal_point_g;1];
                    com_to_left_r = g_to_r_t*[left_point_g;1];
                    com_to_right_r = g_to_r_t*[right_point_g;1];
                    current_frame = body_frame;
                end % of use body frame if
                % place body angles in array body_euler_angles to be used later
                body_euler_angles(row,1:3)= body_angles;

                % Calculate a frame of reference for the body
                body_frame = eye(4);
                for ang=1:3
                    body_frame(1:3,1:3) = body_frame(1:3,1:3)*rotat(ANGLE_ORDER_UNITVS(:,ang),body_angles(ang));
                end
                body_frame(1:3,4) = new_origin_g(1:3);

                % calculate relative body points. Add to com_to_body_array, which contains the additional
                % body points if specified.
                for body_point = 0:(BODY_POINTS-1)
                    start_col = BODY_START+(body_point*NUMBER_OF_PARAMETERS);
                    body_point_g = body_data_kinref(row,start_col:(start_col+2))';
                    if (FILL_GAPS == 0) | all(body_point_g)
                        body_point_r = g_to_r_t*[body_point_g;1];
                        com_to_body_array(row,((body_point*3)+1):((body_point*3)+3)) = body_point_r(1:3)';
                    end
                end

                % calculate lengths for each segment. Add to segment_lengths_arrays
                for sc = 1:num_chains
                    segment_chain_indices = segment_chains{dataset,sc};
                    start_column = segment_chain_indices(1);
                    point_g = src_xyz_data_kinref(row,start_column:(start_column+2));
                    point_r = g_to_r_t*[point_g 1]';
                    % calculate the distance from the COM to the base of the chain.
                    if (FILL_GAPS == 0) | all(point_r)
                        com_to_pt1 = point_r(1:3)';
                        start_com_col = (sc-1)*3+1;
                        com_to_pt1_array(row,start_com_col:(start_com_col+2)) = com_to_pt1(1:3);
                    end
                    valid_row = 1;
                    for segment = 1:chain_joints(sc)
                        start_1 = segment_chain_indices(segment);
                        start_2 = segment_chain_indices(segment+1);
                        point_1 = src_xyz_data_kinref(row,start_1:(start_1+2));
                        point_2 = src_xyz_data_kinref(row,start_2:(start_2+2));
                        if (FILL_GAPS == 0) | all([point_1 point_2])
                            valid_row = valid_row&1;
                            if sc==1
                                start_seglen_col = segment;
                            else
                                start_seglen_col = sum(chain_joints(1:(sc-1)))+segment;
                            end
                            segment_lengths_array(row,start_seglen_col) = norm(point_2-point_1);
                        end
                    end
                end
                if valid_row >0
                    valid_rows = [valid_rows row];
                end
            end % of row if

            if FILL_GAPS == 2
                com_to_body_array = preprocessingDATA_fill_gaps(com_to_body_array,1);
                com_to_pt1_array = preprocessingDATA_fill_gaps(com_to_pt1_array,1);
            end
            %new_origin_g_cell_array{dataset,trial} = new_origin_g_array;
            last_body_angles = mean(body_euler_angles,1);

            % mean_com_to_reference_array(1,:) = mean(com_to_reference_array,1);
            mean_com_to_pt1(1,:) = mean(com_to_pt1_array,1);
            mean_segment_length(1,:) = mean(segment_lengths_array,1);

            % calculate euler angles for each joint/segment ============================================================

            fprintf('\nCalculating euler angles.\nWait.');
            NUM_EULER_COLUMNS = sum(chain_joints)*3;
            euler_angle_arrays = zeros(input_rows,NUM_EULER_COLUMNS);

            rotation_frame = eye(4);
            digitized_points = [];

            % new_origin_g_array = new_origin_g_cell_array{dataset,trial};
            for row=valid_rows
                if mod(row,10) == 0
                    if mod(row,200) == 0
                        fprintf('\n');
                    else
                        fprintf(' .');
                    end
                end
                new_origin_g(1:3) = new_origin_g_array(row,1:3)';
                digitized_points(row) = 0;

                % Re-calculate body_frame based on the body euler angles.
                body_frame = eye(4);
                for ang=1:3
                    body_frame(1:3,1:3) = body_frame(1:3,1:3)*rotat(ANGLE_ORDER_UNITVS(:,ang),body_euler_angles(row,ang));
                end
                body_frame(1:3,4) = new_origin_g(1:3);
                current_frame = body_frame;

                % for each chain, calculate the Euler angles using three points if possible
                % (the point on the joint, on the next joint, and two joints away)
                % These calculations assume that the points are placed on joint centers
                % (which in most situations will result in some error since they are not exactly...)
                for sc = 1:num_chains
                    segment_chain_indices = segment_chains{dataset,sc};
                    r_frame = body_frame;
                    com_to_pt1 = com_to_pt1_array(row,((sc-1)*3+1));
                    segment_length = 0;
                    segment_1_vector_r = com_to_pt1;
                    segment_2_vector_r = com_to_pt1;
                    sc_dof_array = chain_dofs{dataset,sc};
                    sc_ango_array = chain_ango{dataset,sc};

                    for segment = 0:(chain_joints(sc)-1)
                        if sc == 1
                            start_column = (segment*NUMBER_OF_PARAMETERS)+1;
                        else
                            start_column = (sum(chain_joints(1:(sc-1)))*NUMBER_OF_PARAMETERS)+(segment*NUMBER_OF_PARAMETERS)+1;
                        end
                        % the first column of data containing the point in the data array
                        point_1_start = segment_chain_indices(segment+1);
                        point_2_start = segment_chain_indices(segment+2);
                        point_1_g = [src_xyz_data_kinref(row,point_1_start:(point_1_start+2))';1];
                        point_2_g = [src_xyz_data_kinref(row,point_2_start:(point_2_start+2))';1];
                        digitized_points(row) = any(point_2_g(1:3)) | digitized_points(row);

                        % calculate segment angles with global axes (i.e. elevation angles)
                        segment_g = point_2_g-point_1_g;
                        x_z_angle = atan2(segment_g(3),segment_g(1));
                        x_y_angle = atan2(segment_g(2),segment_g(1));
                        y_z_angle = atan2(segment_g(3),segment_g(2));
                        calculated_angles = [x_z_angle x_y_angle y_z_angle];

                        if (COERCE_ANGLES > 0)  & any(calculated_angles)
                            % Try to make the global angles continuous
                            if or((current_file > 1),(row > 1))
                                if row == 1
                                    last_angles = last_global_angles(1,start_column:(start_column+2));
                                else
                                    last_angles = global_angle_array((row-1),start_column:(start_column+2));
                                end
                                for i=1:3
                                    angles_complement_1(i) = (2*pi)+calculated_angles(i);
                                    angles_complement_2(i) = calculated_angles(i)-(2*pi);
                                    dist0 = abs(calculated_angles(i)-last_angles(i));
                                    dist1 = abs(angles_complement_1(i) - last_angles(i));
                                    dist2 = abs(angles_complement_2(i) - last_angles(i));
                                    if (dist1<dist0) & (dist1<dist2)
                                        calculated_angles(i) = angles_complement_1(i);
                                    elseif (dist2<dist0) & (dist2<dist1)
                                        calculated_angles(i) = angles_complement_2(i);
                                    end
                                end
                                % coerce angles to values close to 0 and preferentially positive to start
                            else % it is the first row of the current file
                                for i=1:3
                                    if (abs(calculated_angles(i))>(pi/2)) & (calculated_angles(i)<0)
                                        calculated_angles(i)=(2*pi)+calculated_angles(i);
                                    end
                                end
                            end
                        end  % of COERCE_ANGLES if
                        global_angle_array(row,start_column:(start_column+2)) = calculated_angles;

                        % CALCULATE SEGMENTAL EULER ANGLES ==================================================================================
                        % Calculate euler angles using atans
                        % Pretty braindead way to do inverse kinematics,
                        % but it seems to work OK.
                        % r_frame = body_frame;
                        calculated_angles = [];
                        dofs_to_use = sc_dof_array((segment+1),:);
                        seg_angle_order = sc_ango_array((segment+1),:);

                        if (SEGMENT_AXIS == 1) & (JOINT_AXIS == 2)
                            for current_ang = seg_angle_order
                                switch current_ang
                                    case 1
                                        if (dofs_to_use(1,current_ang) > 0) & (segment < chain_joints(sc)-2)
                                            point_3_start = segment_chain_indices(segment+3);
                                            point_3_g = [src_xyz_data_kinref(row,point_3_start:(point_3_start+2))';1];
                                            r_frame(1:3,4) = point_2_g(1:3); % shift the frame of reference to the distal joint
                                            point_3_t = inv(r_frame)*point_3_g;
                                            X_angle_rad = atan2(point_3_t(3),point_3_t(2))-(pi/2); % -pi/2 necessary for joint axis to be Y
                                            r_frame(1:3,1:3) = r_frame(1:3,1:3)*rotat(Xaxis,X_angle_rad);
                                            calculated_angles = [calculated_angles X_angle_rad];
                                        else
                                            calculated_angles = [calculated_angles 0];
                                        end
                                    case 2
                                        if dofs_to_use(1,current_ang) > 0
                                            r_frame(1:3,4) = point_1_g(1:3); % shift the frame of reference to the proximal joint
                                            point_2_t = inv(r_frame)*point_2_g; % express the global distal point in the local frame of reference
                                            Y_angle_rad = -atan2(point_2_t(3),point_2_t(1)); % calculate the rotation about the Y axis
                                            r_frame(1:3,1:3) = r_frame(1:3,1:3)*rotat(Yaxis,Y_angle_rad); % rotate the reference frame so that the y axis is in the plane of the next segment
                                            calculated_angles = [calculated_angles Y_angle_rad];
                                        else
                                            calculated_angles = [calculated_angles 0];
                                        end
                                    case 3
                                        if dofs_to_use(1,current_ang) > 0
                                            r_frame(1:3,4) = point_1_g(1:3); % shift the frame of reference to the proximal joint
                                            point_2_t = inv(r_frame)*point_2_g; % express the global distal point in the local frame of reference
                                            Z_angle_rad = atan2(point_2_t(2),point_2_t(1));
                                            r_frame(1:3,1:3) = r_frame(1:3,1:3)*rotat(Zaxis,Z_angle_rad); % rotate the reference frame so that the y axis points along the segment
                                            calculated_angles = [calculated_angles Z_angle_rad];
                                        else
                                            calculated_angles = [calculated_angles 0];
                                        end
                                end
                            end
                        else
                            fprintf('ERROR: SEGMENT_AXIS not = 1 (X) or JOINT_AXIS not = 2 (Y) not implemented. Sorry.\n');
                            return;
                        end

                        if (COERCE_ANGLES > 0) & any(calculated_angles)
                            % try to make calculated angles continuous
                            % and of the same sense as the euler angles calculated
                            % for other trials in the analysis
                            if (current_file == 1) & (row == 1)
                                last_angles = zeros(1,3);
                            else
                                if row == 1
                                    last_angles = last_euler_angles(1,start_column:(start_column+2));
                                else
                                    last_angles = euler_angle_array((row-1),start_column:(start_column+2));
                                end
                            end
                            for i=1:3
                                angles_complement_1(i) = (2*pi)+calculated_angles(i);
                                angles_complement_2(i) = calculated_angles(i)-(2*pi);
                                dist0 = abs(calculated_angles(i)-last_angles(i));
                                dist1 = abs(angles_complement_1(i) - last_angles(i));
                                dist2 = abs(angles_complement_2(i) - last_angles(i));
                                if (dist1<dist0) & (dist1<dist2)
                                    calculated_angles(i) = angles_complement_1(i);
                                elseif (dist2<dist0) & (dist2<dist1)
                                    calculated_angles(i) = angles_complement_2(i);
                                end
                            end
                        end % of COERCE_ANGLES if

                        euler_angle_array(row,start_column:(start_column+2)) = calculated_angles;
                    end
                end
            end
            if FILL_GAPS == 2
                euler_angle_array = preprocessingDATA_fill_gaps(euler_angle_array,1);
                segment_lengths_array = preprocessingDATA_fill_gaps(segment_lengths_array,1);
            end
            last_euler_angles = mean(euler_angle_array);
            last_global_angles = mean(global_angle_array);
            digitizing_start = ~digitized_points(1:(length(digitized_points)-1)) & digitized_points(2:end);
            digitizing_end = digitized_points(1:(length(digitized_points)-1)) & ~digitized_points(2:end);
            digitizing_start_indices = find(digitizing_start>0);
            digitizing_end_indices = find(digitizing_end>0);

            if ~isempty(digitizing_start_indices)
                events_array = [];
                for dsi=1:length(digitizing_start_indices)
                    next_end = find(digitizing_end_indices>digitizing_start_indices(dsi));
                    if ~isempty(next_end)
                        events_array(size(events_array,1)+1,1) = digitizing_start_indices(dsi);
                        events_array(size(events_array,1)+1,1) = digitizing_end_indices(next_end(1));
                    end
                end
            else
                events_array = [1;size(euler_angle_array,1)];
            end

            
            % save euler angles ===========================================================================
            [flpath,kinname,ext] = fileparts(kin_filenames{dataset,trial});
            eu_deg_filenames{dataset,trial} = [flpath '\' kinname '_meulang_deg.txt'];
            save_file(eu_deg_filenames{dataset,trial},eu_header_cell_array,{},(180*[body_euler_angles euler_angle_array]/pi));
            fprintf('\nSaved file %s: Chain euler angles.\n',eu_deg_filenames{dataset,trial})
            fprintf('\nFILE %s complete.\n\n',kin_filenames{dataset,trial});

            % ==================================================================================

        end  % of files loaded if
    end % of trial loop (all trials analyzed)
end % of dataset loop (all datasets analyzed)




function R=rotat(u,fi)

%ROTAT (Spacelib): Builds the rotation matrix R.
%
% Builds the rotation matrix R from the unit vector u and the rotation angle
% fi of the angular displacement; it stores the matrix in the 3*3
% matrix A.
% The function ROTAT performs the inverse operation than EXTRACT.
% Related functions : ROTAT2, ROTAT4
% Usage:
%                       R=rotat(u,fi)
%
% Example :
%
% R=rotat(u,fi)          Builds a 3*3 rotation matrix
% M(1:3,1:3)=rotat(u,fi) Builds a rotation matrix storing it in the 3*3
%                        left-upper part of matrix M.
%
% (c) G.Chainnani, C. Moiola 1998; adapted from: G.Chainnani and R.Faglia 1990
%___________________________________________________________________________


X = 1;
Y = 2;
Z = 3;

s=sin(fi);
v=1-cos(fi);

R(X,X)= 1 + (u(X)^2-1)*v;
R(X,Y)= -u(Z)*s + u(X)*u(Y)*v;
R(X,Z)= u(Y)*s + u(X)*u(Z)*v;

R(Y,X)= u(Z)*s + u(X)*u(Y)*v;
R(Y,Y)= 1 + (u(Y)^2-1)*v;
R(Y,Z)= -u(X)*s + u(Y)*u(Z)*v;

R(Z,X)= -u(Y)*s + u(X)*u(Z)*v;
R(Z,Y)= u(X)*s + u(Y)*u(Z)*v;
R(Z,Z)= 1 + (u(Z)^2-1)*v;

return
