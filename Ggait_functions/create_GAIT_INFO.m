function [GAIT_INFO,GAIT_INFO_FORELIMB]=create_GAIT_INFO(time, gait_data)

ToeStrike_left=[];
ToeOff_left=[];
ToeStrike_right=[];
ToeOff_right=[];
ToeStrike_left_forelimb=[];
ToeStrike_right_forelimb=[];
GAIT_INFO=[];
GAIT_INFO_FORELIMB=[];

% Correct for VICON
event_data=NaN(size(gait_data,1),1);
for i=1:size(gait_data,1)
    event_data(i,1)=str2double(char(gait_data(i,4)));
    [nothing t] = min(abs(time(:,2) - event_data(i,1)));
    event_data(i,1) = time(t,2);
end

% Find events
for i=1:size(gait_data)    
    if ismember(gait_data(i,2), 'Left')
        if ismember(gait_data(i,3), 'Foot Strike')
            ToeStrike_left(size(ToeStrike_left,1)+1,1)=event_data(i,1);
        end
        if ismember(gait_data(i,3), 'Foot Off')
            ToeOff_left(size(ToeOff_left,1)+1,1)=event_data(i,1);
        end
        if ismember(gait_data(i,3), 'Event')
            ToeStrike_left_forelimb(size(ToeStrike_left_forelimb,1)+1,1)=event_data(i,1);
        end
    elseif ismember(gait_data(i,2), 'Right')        
        if ismember(gait_data(i,3), 'Foot Strike')
            ToeStrike_right(size(ToeStrike_right,1)+1,1)=event_data(i,1);
        end        
        if ismember(gait_data(i,3), 'Foot Off')
            ToeOff_right(size(ToeOff_right,1)+1,1)=event_data(i,1);
        end       
        if ismember(gait_data(i,3), 'Event')
            ToeStrike_right_forelimb(size(ToeStrike_right_forelimb,1)+1,1)=event_data(i,1);
        end
    end
end

% Sort events temporally
ToeStrike_left=sort(ToeStrike_left,1);
ToeStrike_right=sort(ToeStrike_right,1);
ToeStrike_left_forelimb=sort(ToeStrike_left_forelimb,1);
ToeStrike_right_forelimb=sort(ToeStrike_right_forelimb,1);

% Create gait info matrix
if ~isempty(ToeStrike_left)
    GAIT_INFO(:,2)=ToeStrike_left;
end
if ~isempty(ToeStrike_right)
    GAIT_INFO(1:size(ToeStrike_right,1),7)=ToeStrike_right;
end
if ~isempty(ToeStrike_left_forelimb)
    GAIT_INFO_FORELIMB(:,2)=ToeStrike_left_forelimb;
end
if ~isempty(ToeStrike_right_forelimb)
    GAIT_INFO_FORELIMB(1:size(ToeStrike_right_forelimb,1),7)=ToeStrike_right_forelimb;
end

% Reorder toe off events
for i=1:size(ToeOff_left,1)
    t=max(find(ToeOff_left(i)>GAIT_INFO(find(GAIT_INFO(:,2)~=0),2)));
    GAIT_INFO(t,4)=ToeOff_left(i);
end

for i=1:size(ToeOff_right,1)
    t=max(find(ToeOff_right(i)>GAIT_INFO(find(GAIT_INFO(:,7)~=0),7)));
    GAIT_INFO(t,9)=ToeOff_right(i);
end

%
if size(GAIT_INFO,2)<9
    GAIT_INFO(:,9)=0;
end

if ~isempty(ToeStrike_left_forelimb) & ~isempty(ToeOff_left_forelimb) & size(GAIT_INFO_FORELIMB,2)<9
    GAIT_INFO_FORELIMB(:,9)=0;
end

end