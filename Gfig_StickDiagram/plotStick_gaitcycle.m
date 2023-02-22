function [output]=plotStick_gaitcycle(dataa, onset_frame, swing_frame, drag_frame, end_frame, ...
    stance_bef, stance_aft, swing_bef, swing_aft, speed, fe, skip, dimension, nmarkers, scaling)

if dimension==1, is_3D = 0; % 2D
else is_3D = 1; end

COLOR(1,:) = [0.2 0.2 0.2]; % STANCE
COLOR(2,:) = [1 0 0]; % DRAG
COLOR(3,:) = [0 110/255 190/255]; % SWING

%% STANCE
figure(309),clf,set_myFig(figure(309),600,450,200,500),hold on
xlabel('X - forward axis [cm]'), ylabel('Y - vertical axis [cm]')
if scaling, axis equal, end

counter=0;
for frame=onset_frame-stance_bef:skip:swing_frame+stance_aft
    for markers=1:nmarkers
        data(markers, 1)=dataa(frame,markers*3-2)-counter*(speed/fe);
        data(markers, 2)=dataa(frame,markers*3-1);
        data(markers, 3)=dataa(frame,markers*3);
    end
    
    if is_3D, plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
            'MarkerEdgeColor','black', 'MarkerFaceColor',COLOR(1,:), 'MarkerSize',8);
    else plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
            'MarkerEdgeColor','black', 'MarkerFaceColor',COLOR(1,:), 'MarkerSize',8);
    end
    
    drawnow()
    counter=counter+skip;
end


%% SWING
figure(310),clf,set_myFig(figure(310),600,450,200+15+600,500),hold on
xlabel('X - forward axis [cm]'), ylabel('Y - vertical axis [cm]')
if scaling,  axis equal, end

counter=0;
if isempty(drag_frame)   % without drag
    for frame=swing_frame-swing_bef:skip:end_frame+swing_aft
        for markers=1:nmarkers
            data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
            data(markers, 3)=dataa(frame,markers*3);
            data(markers, 2)=dataa(frame,markers*3-1);
        end
        
        if is_3D, plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
                'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:),'MarkerSize',8);
        else plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:),'MarkerSize',8);
        end
        
        drawnow()
        counter=counter+skip;
    end
else   % with drag
    for frame=swing_frame+swing_bef:skip:drag_frame
        for markers=1:nmarkers
            data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
            data(markers, 3)=dataa(frame,markers*3);
            data(markers, 2)=dataa(frame,markers*3-1);
        end
        
        if is_3D, plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
                'MarkerEdgeColor','black','MarkerFaceColor',COLOR(2,:),'MarkerSize',8);
        else plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                'MarkerEdgeColor','black','MarkerFaceColor',COLOR(2,:),'MarkerSize',8);
        end
        
        drawnow()
        counter=counter+skip;
    end
    
    for frame=drag_frame:skip:end_frame+swing_aft
        for markers=1:nmarkers
            data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
            data(markers, 3)=dataa(frame,markers*3);
            data(markers, 2)=dataa(frame,markers*3-1);
        end
        
        if is_3D, plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
                'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:),'MarkerSize',8);
        else plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:),'MarkerSize',8)
        end
        
        drawnow()
        counter=counter+skip;
    end
end

output=1;