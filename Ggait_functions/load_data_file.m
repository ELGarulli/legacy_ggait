function [input_header_cell_array,text_column_cell_array,input_array] = load_data_file(input_filename,text_columns,decimation)
% load_data_file: Load a tab-delimited text data file with a text header in the first row and
%    possibly one or more text columns as the first columns in the file.
% USAGE:
%    [input_header_cell_array,text_column_cell_array,input_array] = load_data_file(input_filename,text_columns,decimation)
%    (if no text columns are present, can be invoked as: load_data_file(input_filename,0,decimation))
% INPUTS:
%    input_filename = the name of the file to be loaded
%    text_columns = an integer referring to the number of initial columns which are to be treated as text (starting from left)
%    decimation = how much to subsample the data, i.e. a decimation of 10 takes every 10th row
% OUTPUTS:
%    input_header_cell_array = a 1xn cell array containing the header (first row) of the file
%    text_column_cell_array = a mxn cell array containing initial columns treated as text
%    input_array = the input data (2-D) array
%
% Refer questions to Devin Jindrich (dljindrich@yahoo.com)

data_cell_array = {};
num_data_arrays = 0;
num_data_array_rows = 1000;
input_header_cell_array = {};
input_array = [];
text_column_cell_array = {};
rows_read = 0;
tmp_num_cols = 0;
data_row_index=0;

fid=fopen(input_filename,'r');
if fid == -1
   fprintf('\nERROR: file %s not found\n',input_filename);
   return;
end
% read first row of file as header
current_header = fgetl(fid);
header_tabs =  findstr(current_header,'	');
num_headers = size(header_tabs,2);
header_delimiters = [0 header_tabs];
valid_header = 0;
for i=2:(num_headers+1)
   valid_header = valid_header+1;
   input_header_cell_array{1,valid_header} = current_header(1,(header_delimiters(i-1)+1):(header_delimiters(i)-1));
end
if header_delimiters(num_headers+1) < size(current_header,2)
   input_header_cell_array{1,(num_headers+1)} = current_header(1,(header_delimiters((num_headers+1))+1):size(current_header,2));
end
% read text columns to the left of file if any. dlmread seems not to like some types of text so load the rest of the file slowly
if text_columns > 0
   data_row_index = 0;
   while 1
      input_line = fgetl(fid);
      if ~isempty(input_line) % ignore empty lines
         if(input_line == -1), break, end %if no more text, stop reading
         data_row_index=data_row_index+1;
         if text_columns > 0
            line_tabs =  [0 findstr(input_line,'	')];
            if size(line_tabs,2) > text_columns
               for text_col = 1:text_columns
                  text_column_cell_array{data_row_index,text_col} = input_line(1,(line_tabs(1,text_col)+1):(line_tabs(1,(text_col+1))-1));
               end
            else
               status = fclose(fid);
               fprintf('\nERORR: Mal-formed input file. %s.\nNo data (not enough columns).\n',input_filename);
               input_header_cell_array = {};
               text_column_cell_array = {};
               input_array = [];
               return;
            end
            input_vector = str2num(input_line(1,(line_tabs(1,(text_columns+1))+1):size(input_line,2)));   
         else
            input_vector = str2num(input_line); 
         end
         if(isempty(input_vector))
            data_row_index = data_row_index-1;
            break
         end %if no more text, stop reading
         if rows_read == 0
            tmp_num_cols = size(input_vector, 2);
            rows_read = 1;
         else
            if size(input_vector, 2) ~= tmp_num_cols
               status = fclose(fid);
               fprintf('\nERORR: Mal-formed input file %s.\nNot all rows have the same number of columns.\n',input_filename);
               input_header_cell_array = {};
               text_column_cell_array = {};
               input_array = [];
               input_vector = [];
               return;
            end
         end
         if (data_row_index/num_data_array_rows) > num_data_arrays
            num_data_arrays = num_data_arrays + 1;
            data_cell_array{num_data_arrays,1} = zeros(num_data_array_rows,tmp_num_cols);
         end
         data_cell_array{num_data_arrays,1}((rem((data_row_index-1),num_data_array_rows)+1),:) = input_vector; % add the row to the data matrix
      end
   end
   status = fclose(fid);
   last_bit_start = (((num_data_arrays-1)*num_data_array_rows)+1);
   last_bit = rem(data_row_index,num_data_array_rows);
   input_array = zeros((last_bit_start + last_bit - 1),tmp_num_cols);
   for i=1:(num_data_arrays-1)
      input_array((((i-1)*num_data_array_rows)+1):(i*num_data_array_rows),:) = data_cell_array{i,1};
   end
   if last_bit > 0
      input_array(last_bit_start:data_row_index,:) = data_cell_array{num_data_arrays,1}(1:last_bit,:);
   elseif data_row_index > 0
      input_array(last_bit_start:data_row_index,:) = data_cell_array{num_data_arrays,1}(1:num_data_array_rows,:);
   end   
else
   status = fclose(fid);
   % read numeric data in file quicker and easier if there are no text columns
   input_array = dlmread(input_filename,'\t',1,0);
end

if decimation > 1
   index_tmp = find(mod((1:size(input_array,1)),decimation) == 0);
   input_array = input_array(index_tmp,:);
   if ~isempty(text_column_cell_array)
      text_column_cell_array = text_column_cell_array(index_tmp,:);
   end
end

% The number of headers may not correspond with 
% the number of columns. So if the header is screwed up, substitute a generic header.

if size(input_header_cell_array,2) ~= (size(input_array,2)+text_columns)
   for val_head = 1:size(input_array,2)
      input_header_cell_array{1,val_head} = ['Variable ' num2str(val_head)];
   end
end

fprintf('\nFile %s read. Found %d rows, %d columns.\n',input_filename,size(input_array,1),size(input_array,2));
return

