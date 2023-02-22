function [GAIT_INFO,GAIT_INFO_FORELIMB]=create_GAIT_INFO_swing(time, gait_data)

ToeStrike_left=[];
Swing_left=[];
ToeOff_left=[];
ToeStrike_right=[];
Swing_right=[];
ToeOff_right=[];
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
            Swing_left(size(Swing_left,1)+1,1)=event_data(i,1);
        end
    elseif ismember(gait_data(i,2), 'Right')
        if ismember(gait_data(i,3), 'Foot Strike')
            ToeStrike_right(size(ToeStrike_right,1)+1,1)=event_data(i,1);
        end
        if ismember(gait_data(i,3), 'Foot Off')==1
            ToeOff_right(size(ToeOff_right,1)+1,1)=event_data(i,1);
        end
        if ismember(gait_data(i,3), 'Event')
            Swing_right(size(Swing_right,1)+1,1)=event_data(i,1);
        end
    end
end

% Sort events temporally
ToeStrike_left=sort(ToeStrike_left,1);
ToeStrike_right=sort(ToeStrike_right,1);
Swing_left=sort(Swing_left,1);
Swing_right=sort(Swing_right,1);

% Create gait info matrix
GAIT_INFO(:,2)=ToeStrike_left;
GAIT_INFO(1:size(ToeStrike_right,1),7)=ToeStrike_right;

% Reorder toe off events
for i=1:size(ToeOff_left,1)
    t=max(find(ToeOff_left(i)>GAIT_INFO(find(GAIT_INFO(:,2)~=0),2)));
    GAIT_INFO(t,4)=ToeOff_left(i);
end

for i=1:size(ToeOff_right,1)
    t=max(find(ToeOff_right(i)>GAIT_INFO(find(GAIT_INFO(:,7)~=0),7)));
    GAIT_INFO(t,9)=ToeOff_right(i);
end

% Reorder swing events
for i=1:size(Swing_left,1)
    t=max(find(Swing_left(i)>GAIT_INFO(find(GAIT_INFO(:,2)~=0),2)));
    GAIT_INFO(t,3)=Swing_left(i);
end
for i=1:size(Swing_right,1)
    t=max(find(Swing_right(i)>GAIT_INFO(find(GAIT_INFO(:,7)~=0),7)));
    GAIT_INFO(t,8)=Swing_right(i);
end

% Control size of gait info matrices
if size(GAIT_INFO,2)<9
    GAIT_INFO(1:size(GAIT_INFO,1),9)=0;
end
if size(GAIT_INFO_FORELIMB,2)<9
    GAIT_INFO_FORELIMB(1:size(GAIT_INFO_FORELIMB,1),9)=0;
end

end