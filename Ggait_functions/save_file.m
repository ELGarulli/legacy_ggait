function success = save_file(desired_filename,header_cell_array,data_cell_array,data_array)
% SAVE FILE IN A LOW-LEVEL SORT OF WAY
% Save file in a very simple way. I haven't bothered with setting the width and the 
% precision of the output but have simply used %d instead. This seems to work fine
% for Matlab 5 on Windows NT.
%
% USAGE:
%   success = save_file(desired_filename, header_cell_array, data_cell_array, data_array)
% INPUTS:
%   desired_filename = the full path of the file to be saved
%   header_cell_array = a cell array containing strings to be made the header (first row) of the file
%   data_cell_array = a cell array with strings or other things to be made the first (left-most) column of the file
%   data_array = a 2-D array of numbers to be saved
% OUTPUTS:
%   success: whether file was successfully saved


success = 0;
fid = fopen(desired_filename,'w');
if fid ~= -1
    progressbar
    
    SIZE_header = length(header_cell_array);
    SIZE1_array = size(data_array,1);
    SIZE2_array = size(data_array,2);
    SIZE2_cell = size(data_cell_array,2);
    Nrows = 1 + SIZE1_array;
    
	for header_col = 1:(SIZE_header-1)
		fprintf(fid,'%s\t',header_cell_array{1,header_col});
	end
	fprintf(fid,'%s\n',header_cell_array{end});
    progressbar(1/Nrows)
    
	for row=1:SIZE1_array        
		if SIZE2_cell > 0
			for string_col=1:SIZE2_cell
				fprintf(fid,'%s\t',data_cell_array{row,string_col});
			end
		end
		for col=1:(SIZE2_array-1)
			fprintf(fid,'%d\t',data_array(row,col));
		end
		if SIZE2_array > 0
			fprintf(fid,'%d\n',data_array(row,end));
        end
        progressbar((row+1)/Nrows)
	end
	fclose(fid);
	fprintf('\nSaved file: %s.\n', desired_filename);
	
	success = 1;
end
return
