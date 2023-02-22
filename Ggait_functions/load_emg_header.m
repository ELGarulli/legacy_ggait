function EMG_header = load_emg_header(input_filename,timecode)
% load_emg_header: Load an EMG header from binary EMG file
% USAGE:
%    EMG_header = load_emg_header(input_filename,timecode)
% INPUTS:
%    input_filename: string with the name of the file to be loaded
%    timecode: whether the last column is timecode (1)
% OUTPUTS:
%    EMG_header: a structure with the fields:
%      EMG_header.header_cell: a cell array with the channel names
%      EMG_header.num_channels: the number of channels to be loaded including the time code
%      EMG_header.group_settings: an array of structures (one for each channel) of format
%          group_settings.channel_name
%          group_settings.upper_input_limits
%          group_settings.lower_input_limits
%          group_settings.range
%          group_settings.polarity
%          group_settings.gain
%          group_settings.coupling
%          group_settings.input_mode
%          group_settings.scale_multiplier
%          group_settings.scale_offset
%      EMG_header.scan_rate: the sampling frequency used
%      EMG_header.interchannel_delay: the interchannel delay used
%      EMG_header.header_cell: a cell array with channel names
%      EMG_header.subject_info: subject information
%      EMG_header.data_position: position in the file where data start
%
% Refer questions to Devin Jindrich (jindrich@ucla.edu)

fid=fopen(input_filename,'r','ieee-be');
if fid == -1
   fprintf('\nERROR: file %s not found\n',input_filename);
   return;
end

EMG_header = initialize_emg_header_struct;

header_length = fread(fid,1,'int32');
channel_string_length = fread(fid,1,'int32');
channel_string = char(fread(fid,channel_string_length,'char')');
EMG_header.channel_number_cell = tokenize(channel_string,{','},{});
if timecode==1
    EMG_header.num_channels = size(EMG_header.channel_number_cell,2)+1; % consider time code a channel
else
    EMG_header.num_channels = size(EMG_header.channel_number_cell,2);
end
channel_settings_length = fread(fid,1,'int32'); % group channel settings total length
group_array_length = fread(fid,1,'int32'); % # of elements in the group channel settings array

for i=1:group_array_length
    channel_string_length = fread(fid,1,'int32'); % length of the channel string in the group settings element
    group_settings.channel_name = char(fread(fid,channel_string_length,'char')');
    group_settings.upper_input_limits = fread(fid,1,'float32');
    group_settings.lower_input_limits = fread(fid,1,'float32');
    group_settings.range = fread(fid,1,'float32');
    group_settings.polarity = fread(fid,1,'uint16');
    group_settings.gain = fread(fid,1,'float32');
    group_settings.coupling = fread(fid,1,'uint16');
    group_settings.input_mode = fread(fid,1,'uint16');
    group_settings.scale_multiplier = fread(fid,1,'float32');
    group_settings.scale_offset = fread(fid,1,'float32');
    EMG_header.group_settings(i) = group_settings;
end

if timecode==1
    % add timecode struct
    group_settings.channel_name = 'timecode';
    group_settings.upper_input_limits = 1;
    group_settings.lower_input_limits = 1;
    group_settings.range = 1;
    group_settings.polarity = 1;
    group_settings.gain = 1;
    group_settings.coupling = 1;
    group_settings.input_mode = 1;
    group_settings.scale_multiplier = 1;
    group_settings.scale_offset = 1;
    EMG_header.group_settings(group_array_length+1) = group_settings;
end

EMG_header.scan_rate = fread(fid,1,'float32');
EMG_header.interchannel_delay = fread(fid,1,'float32');
channel_name_length = fread(fid,1,'int32');
channel_names = char(fread(fid,channel_name_length,'char')');
EMG_header.header_cell = [tokenize(channel_names,{','},{}) {'timecode'}];
subject_info_length = fread(fid,1,'int32');
EMG_header.subject_info = char(fread(fid,subject_info_length,'char')');
%EMG_header.data_position = ftell(fid) % new headers seem to have a lot of junk added into them
EMG_header.data_position = header_length+4; % don't know where the 4 comes from but it's there

status = fclose(fid);



function arg_cell = tokenize(input_string,delimiters_cell,reserved_characters)
% tokenize: convert a string to a cell array based on delimiters
% USAGE:
%   arg_cell = tokenize(input_string,delimiters_cell,reserved_characters)
% INPUTS:
%   input_string: string to tokenize
%   delimiters_cell: cell array with delimiters to use to divide string
%   reserved_characters: reserved characters to be removed from the arguments after they are tokenized

arg_cell = {};
delimiter_string = '';
delimiters_cell = delimiters_cell(:)';
for delim=1:size(delimiters_cell,2)
    delimiter_string = [delimiter_string sprintf(delimiters_cell{1,delim})];
end

while(any(input_string))
    [new_arg input_string] = strtok(input_string,delimiter_string);
    new_arg = remove_chars(new_arg,reserved_characters,2);
    if ~isempty(new_arg)
        arg_cell{1,(size(arg_cell,2)+1)} = new_arg;
    end
end


function newstring = remove_chars(string_in,unwanted_char_cell,preserve_words)
% remove_chars: remove characters from a short string, potentially preserving words
% USAGE:
%   remove_chars(string_in,unwanted_char_cell,preserve_words)
% INPUTS:
%   string_in: string to be processed
%   unwanted_char_cell: characters to be excised
%   preserve_words: 0 not to preserve words. To preserve words: 1 to replace or more unwanted chars with spaces 
%                   2 to preserve words with underscores
% OUTPUT:
%   newstring: a string with the characters removed
%

string_length = length(string_in);
newword = [];
newstring = [];

i=1;
while i<=string_length
    c=string_in(i);
    if preserve_words == 0
        switch c
        case unwanted_char_cell
        otherwise
            newstring = [newstring c]; % slow but simple
        end
    else
        switch c
        case unwanted_char_cell
            if ~isempty(newword)
                if preserve_words == 2
                    newstring = [newstring '_' newword];
                else
                    newstring = [newstring ' ' newword];
                end
                newword = [];
            end
        otherwise
            newword = [newword c]; % slow but simple
        end
    end
    i=i+1;
end
if ~isempty(newword)
    if preserve_words == 2
        newstring = [newstring '_' newword];
    else
        newstring = [newstring ' ' newword];
    end
end
if preserve_words > 0
    newstring = newstring(2:length(newstring));
end