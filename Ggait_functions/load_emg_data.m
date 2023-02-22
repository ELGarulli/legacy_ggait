function data_array = load_emg_data(input_filename,header_struct,file_start,startsample,numsamples,timecode)
% load_emg_data: Load EMG data from binary EMG file
% USAGE:
%    data_array = load_emg_data(input_filename,header_struct,file_start,startsample,numsamples)
% INPUTS:
%    input_filename: string with the name of the file to be loaded
%    header_struct: a structure containing the header for the file to be loaded
%    start_position: position in file where numeric data start
%    number_of_samples: number of samples to acquire from file
% OUTPUTS:
%    data_array: array with numeric data
%
% Refer questions to Devin Jindrich (jindrich@ucla.edu)

data_array = [];
time = [];
    
if numsamples > 0
    startsample = max(startsample,1);
    if startsample == 1
        file_position = file_start;
    else % treated differently because there are 2 bytes/sample
        file_position = file_start+(2*startsample*header_struct.num_channels);
    end

    fid=fopen(input_filename,'r','ieee-be');
    if fid == -1
        fprintf('\nERROR: file %s not found\n',input_filename);
        return;
    end

    status=fseek(fid,file_position,'bof');
    if numsamples == inf
        data_array = fread(fid,[header_struct.num_channels,inf],'int16')'; % read all the samples
    else
        data_array = fread(fid,[header_struct.num_channels,numsamples],'int16')'; % read only a specified number of samples
    end
    
    if timecode > 0
        % last column is timecode. format: sets of 2 numbers in adjacent rows.
        % both numbers are sets of 2 unsigned 8-bit ints concatenated in a 16 bit int
        % I can't figure out how to easily convert int16s into uint16s because of 
        % some funny properties of MATLAB (i.e. not possible to use bitget with signed integers for some reason)
        % so just do it the slow way and re-load all the data as unsigned ints.
        status=fseek(fid,file_position,'bof');
        udata_array = fread(fid,[header_struct.num_channels,numsamples],'uint16','ieee-be')';

        tc(1:(size(udata_array,1)-1),1) = udata_array(1:(size(udata_array,1)-1),size(udata_array,2));
        tc(1:(size(udata_array,1)-1),2) = udata_array(2:size(udata_array,1),size(udata_array,2));
        timecode_indices = find(all(tc,2) ~= 0); % indices where the row and next row are both nonzero: timecode elements
       
        for i=1:length(timecode_indices)
            tci = timecode_indices(i);
            if tci < size(tc,1) % to avoid the case in which the first half of the time code points to the last element of the array
                hours = uint8(0);
                minutes = uint8(0);
                seconds = uint8(0);
                frames = uint8(0);
                tca = uint32(tc(tci,1));
                tcb = uint32(tc((tci+1),1));
                tca = bitshift(tca,16);
                tcui = bitor(tca,tcb);

                timecode_string = num2str(tcui);

                hours = str2num(timecode_string(2:3));
                minutes  = str2num(timecode_string(4:5));
                seconds =  str2num(timecode_string(6:7));
                frames = str2num(timecode_string(8:9));

                time(i) = frames*(1/29.97)+seconds+(minutes*60)+(hours*3600);
                if (i==1) & (timecode_indices(i) ~= 1) % extrapolate from the beginning of the file to the first timecode
                    start_time = time(i)-(timecode_indices(i)/header_struct.scan_rate);
                    data_array(1:timecode_indices(i),size(data_array,2)) = linspace(start_time,time(i),timecode_indices(i));
                elseif (i<=length(timecode_indices)) & (i > 1) % fill in the space between timecodes
                    data_array(timecode_indices(i-1):timecode_indices(i),size(data_array,2)) = linspace(time(i-1),time(i),...
                        (timecode_indices(i)-timecode_indices(i-1)+1));
                end
            end % of tci < size(tc,1) if
        end % of time code i for
        if ~isempty(timecode_indices) & ~isempty(time)
            if timecode_indices(end) < size(data_array,1) % extrapolate from the last timecode to the end of the file
                end_time = time(end)+((size(data_array,1)-timecode_indices(end))/header_struct.scan_rate);
                data_array(timecode_indices(end):size(data_array,1),size(data_array,2)) =...
                    linspace(time(end),end_time,(size(data_array,1)-timecode_indices(end)+1));
            end
        end
    end % of timecode if
    fclose(fid);
    
    for channel=1:header_struct.num_channels-1
        data_array(:,channel) = data_array(:,channel)*header_struct.group_settings(channel).scale_multiplier;
    end
end
