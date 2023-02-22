function [GAIT_INFO]=create_GAIT_INFO_manual(GAIT_INFO, MARKER, ANGLEleft, ANGLEright, filename)

if exist(strcat(filename(1:end-4),'_GAIT_MANUAL','.mat'),'file')==2
    load(strcat(filename(1:end-4),'_GAIT_MANUAL','.mat'))
else
    TEMPGAIT=[GAIT_INFO(:,2); GAIT_INFO(:,7)];
    min_frame=find(MARKER(:,2)==(min(min(TEMPGAIT(find(TEMPGAIT~=0),1)))));
    max_frame=find(MARKER(:,2)==(max(max(TEMPGAIT(find(TEMPGAIT~=0),1)))));
    
    figure(3);subplot(2,1,1); hold on; plot(ANGLEleft(min_frame:max_frame,6));
    figure(3);subplot(2,1,2); hold on; plot(ANGLEright(min_frame:max_frame,6),'r');
    
    for side=1:2
        
        stance_time=[];
        
        if side==1; ANGLE=ANGLEleft; place=2; end
        if side==2; ANGLE=ANGLEright; place=7; end
        
        n_click=str2double(inputdlg(['How many clicks (forward peaks) for side: ' num2str(side)], 'Stance finder', 1));
        
        subplot(2,1,side); hold on;
        if n_click~=0
            GAIT_INFO(:,place)=0;
            GAIT_INFO(:,place+1)=0; %remove stance info -- becoming incorrect
            
            [stance_time,~]=ginput(n_click);
            stance_time=round(stance_time)+min_frame-1;
            
            for i=1:n_click
                temp=find(ANGLE(:,6)==max(ANGLE(stance_time(i,1)-4:stance_time(i,1)+4,6)));
                stance_time(i,1)=MARKER(temp,2);
            end
            
            GAIT_INFO(1:size(stance_time,1),place)=stance_time(:,1);
            
            % Dragging all the way, change place +1 if swing with NO DRAG
            GAIT_INFO(1:size(stance_time,1)-1,place+2)=stance_time(2:end,1);
            
        end
    end
    
    close(figure(3))
    
    % SAVE DATA IN .mat FILE TO AVOID REPROCESSING THIS AGAIN
    save(strcat(filename(1:end-4),'_GAIT_MANUAL','.mat'),'GAIT_INFO');
end

