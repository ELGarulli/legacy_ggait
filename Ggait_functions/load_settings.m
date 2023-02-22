function settings_cell_array = load_settings(settings_file)
% Load settings file from disk
% Refer questions to Devin Jindrich (dljindrich@yahoo.com)
% 2001

% load settings file from disk
settings_cell_array = {};
settings_loaded = 0;
destination = 1;
variable_temp = [];
value_temp = [];
comment_temp = [];
settings_row_index = 1;

path = ['./Settings/' settings_file];
fid=fopen(path,'r');              % open settings file 
if fid == -1
    fprintf('\nERROR: file %s not found.\n', settings_file);
    return
end

fprintf('Reading settings file %s...', settings_file);
setting_header = fgetl(fid); 
while 1
    data_line = fgetl(fid); 
    if ~isempty(data_line)
        if data_line == -1
            break % if no more text, stop reading
        end
        for i = 1:size(data_line,2)
           if (double(data_line(1,i)) == 9) | (double(data_line(1,i)) > 31) % only consider characters and tabs
              switch data_line(1,i)
              case {' ' '\t'}
                 if destination == 3 
                    comment_temp = [comment_temp data_line(1,i)]; 
                 end
                 if destination == 2
                    value_temp = [value_temp data_line(1,i)];
                 end
              case '='
                 if destination == 3 
                    comment_temp = [comment_temp data_line(1,i)]; 
                 else destination = 2;
                 end
              case '/'
                 if data_line(1,(i+1)) == '*'	 
                    destination = 3;
                    comment_temp = [comment_temp data_line(1,i)];
                 end
              otherwise 
                 if destination == 1 
                    variable_temp = [variable_temp data_line(1,i)];
                 elseif destination == 2
                    value_temp = [value_temp data_line(1,i)];
                 elseif destination == 3
                    comment_temp = [comment_temp data_line(1,i)];
                 end
              end 
           end 
         end
        if ~isempty(variable_temp)
            settings_cell_array{settings_row_index,1} = variable_temp;
            if isempty(value_temp) 
                fprintf('ERROR: No value specified for variable %s.\n', variable_temp)
            end
            settings_cell_array{settings_row_index,2} = value_temp;
        end
        settings_cell_array{settings_row_index,3} = comment_temp;
        destination = 1;
        variable_temp = [];
        value_temp = [];
        comment_temp = [];
        settings_row_index = settings_row_index+1;
    end
end
settings_loaded = 1;

status = fclose(fid);
fprintf('Loaded file: %s\n', settings_file); 
return