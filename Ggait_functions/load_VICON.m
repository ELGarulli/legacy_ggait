function [type, fe, header_data, XYZ_header_data, data]=load_VICON(FILENAME, PATHNAME)

fid=fopen([PATHNAME,FILENAME],'r');

if fid == -1
   msgbox(['THE FILE [' char(FILENAME) '] CONTAINING KINEMATIC DATA CANNOT BE FOUND'],'FILE NOT FOUND', 'warn');
   return;
end

current_header_line=0;
 
while 1
     
current_header = fgetl(fid);
    
    if current_header==-1

        break

    else

    header_tabs =  findstr(current_header,',');
    num_headers = size(header_tabs,2);
    header_delimiters = [0 header_tabs];
    current_header_line=current_header_line+1;
    valid_header = 0;

            switch current_header_line

                case 1
                    type{1,1} = current_header(1,1:size(current_header,2));
                case 2
                    fe{1,1} = current_header(1,(header_delimiters(2-1)+1):(header_delimiters(2)-1));
                case 3

                    for i=2:num_headers+1
                    valid_header = valid_header+1;
                    header_data{1,valid_header} = current_header(1,(header_delimiters(i-1)+1):(header_delimiters(i)-1));
                    end
                    if header_delimiters(num_headers+1) < size(current_header,2)
                    header_data{1,(num_headers+1)} = current_header(1,(header_delimiters((num_headers+1))+1):size(current_header,2));
                    end
                    
                case 4
                    
                    for i=2:num_headers+1
                    valid_header = valid_header+1;
                    XYZ_header_data{1,valid_header} = current_header(1,(header_delimiters(i-1)+1):(header_delimiters(i)-1));
                    end
                    if header_delimiters(num_headers+1) < size(current_header,2)
                    XYZ_header_data{1,(num_headers+1)} = current_header(1,(header_delimiters((num_headers+1))+1):size(current_header,2));
                    end
                    
            end

            if current_header_line>4
            fclose(fid)

            data=dlmread([PATHNAME,FILENAME],',', 4, 0);
            break
            end

    end
 end
 
 
