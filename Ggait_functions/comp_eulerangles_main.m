function []=comp_eulerangles_main(PATHNAME, FILENAME, body_point, DATA_KIN_raw, DATA_KIN_HEADING, type)

TEMP_FOLDER=cd;

front_l=4;%crest left
rear_l=7;%hip left
front_r=25;%crest right
rear_r=28;%hip right

body_point(:,2:4)=DATA_KIN_raw(:,rear_r:rear_r+2); %hip right
body_point(:,5:7)=DATA_KIN_raw(:,rear_l:rear_l+2); %hip left
body_point(:,8:10) =DATA_KIN_raw(:,front_r:front_r+2); %crest right
body_point(:,11:13)=DATA_KIN_raw(:,front_l:front_l+2); %crest left

% Remove right and left Scap from raw Data
DATA_KIN_raw=[DATA_KIN_raw(:,4:21),DATA_KIN_raw(:,25:42)];
DATA_KIN_HEADING=[DATA_KIN_HEADING(1,4:21) DATA_KIN_HEADING(1,25:42)];

% Save data TEMP for Euler transformation
DATA_KIN_HEADING = [{'FRAME' 'rearRX' 'rearRY' 'rearRZ' 'rearLX' 'rearLY' 'rearLZ' 'frontRX' 'frontRY' 'frontRZ' 'frontLX' 'frontLY' 'frontLZ'} DATA_KIN_HEADING];
success = save_file([TEMP_FOLDER, '\TEMP.txt'],DATA_KIN_HEADING, [], [body_point DATA_KIN_raw]);
if ~success
    msgbox('[comp_eulerangles_main]: Problems when saving TEMP data for Euler computation.')
    return
end

% Run euler angle computation
switch type  
    case 0
        comp_eulerangles('rat_euler_sets.txt')
    case 1       
        comp_eulerangles('rat_euler_monoamine_sets.txt')
    otherwise
        msgbox('[comp_eulerangles_main]: Euler angles are not computed.')
end

% Load computed euler angle and save them in appropriate folder
[DATA_KIN_HEADING,~,~] = load_data_file([TEMP_FOLDER, '\TEMP_meulang_deg.txt'],0,10);
DATA = dlmread([TEMP_FOLDER, '\TEMP_meulang_deg.txt'],'\t',1,0);
success = save_file([PATHNAME, FILENAME '_EULER.txt'],DATA_KIN_HEADING,[],DATA);

if ~success
    msgbox('[comp_eulerangles_main]: Problems when saving data for Euler computation.')
    return
else
    msgbox('Euler computation done')
end