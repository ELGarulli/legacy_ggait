function [type, gait_data]=load_VICON_GAIT(FILENAME, PATHNAME)

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
                % EVENTS
                type{1,1} = current_header(1,1:size(current_header,2));
            case 2
                for i=1:num_headers
                    % header contains Subject, Context, Name, Time(s),
                    % Description
                    type{2,i} = current_header(1,(header_delimiters(i)+1):(header_delimiters(i+1)-1));
                end
                type{2,i+1} = current_header(1,(header_delimiters(i+1)+1):size(current_header,2));
                
            otherwise
                for i=2:num_headers+1
                    valid_header = valid_header+1;
                    gait_data{current_header_line-2,valid_header} = current_header(1,(header_delimiters(i-1)+1):(header_delimiters(i)-1));
                end
                if header_delimiters(num_headers+1) < size(current_header,2)
                    gait_data{current_header_line-2,(num_headers+1)} = current_header(1,(header_delimiters((num_headers+1))+1):size(current_header,2));
                end
        end     
    end
end

fclose(fid);


