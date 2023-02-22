function [record_FS,record_TO ] = event_detector( Data ,THRESHOLD,Start_time, Hz_kin )
% Detect events (FOOT STRIKE and TOE OFF) based on threshold crossing
% method

% Initialization
th_up =THRESHOLD;
th_down = THRESHOLD;
th_mean = median(Data);
cross_up=0;
cross_down=0;
cross_mean=0;
nb_to=0;
nb_fs=0;

previous = Data(1);

for i=2:length(Data)
    
    % Detection
    if Data(i)> th_up && previous<th_up   
        cross_up=i;        
    end
    
    if Data(i)< th_down && previous> th_down
        cross_up=0;
        cross_down=i;    
    end
    
    if Data(i)< th_mean && previous> th_mean
       cross_mean=i;    
    end
      
    % Analysis
    if cross_up && cross_down &&  cross_mean    
        index=[1:(cross_up-cross_down)];
        part = Data(cross_down:cross_up);
        dp = smooth(diff(part),5);
                
        rise = index( dp>0.015 & dp < 0.025 );       
        fall = index( dp>-0.04 & dp<-0.02);

        if isempty(rise)
            rise=index(end);
        end
        if isempty(fall)
            fall = 1;
        end
               
        nb_to=nb_to+1;
        nb_fs=nb_fs+1;
        
        record_TO(nb_to) = (rise(end) + cross_down)/ Hz_kin + Start_time; 
        record_FS(nb_fs) = (fall(1) + cross_down)/ Hz_kin + Start_time; 

       % record_TO = [1, record_TO];
       % record_FS = [record_FS, 4];
        
        cross_up=0;
        cross_down=0;
        cross_mean=0;
    end
    
    previous=Data(i);    


end

%% ES addition
%Calculate the average step length and one toe off event to the beginning 
% and one foot strike event to the end
dist = 0;
temp_rec_TO = record_TO;
temp_rec_TO(length(temp_rec_TO)) = [];
temp_rec_FS = record_FS;
temp_rec_FS(1) = [];

for i = 1:(length(temp_rec_TO))
    dist = dist+(temp_rec_FS(i)-temp_rec_TO(i));
end

av_dist = dist/(length(temp_rec_TO));

record_TO = [(record_FS(1)-av_dist),record_TO];
record_FS = [record_FS, (record_TO(end)+av_dist)];
