function [output]=plotStick_sequences(time, dataa, gait, start_step, end_step, speed, fe, skip, nmarkers, plane)

% ADD TREADMILL BELT SPEED ALONG X AXIS ------------------------------------
for markers=1:nmarkers
    for i=1:size(dataa,1)
        dataa(i,markers*3-2)=dataa(i,markers*3-2)+i*(speed/fe);
    end
end
%--------------------------------------------------------------------------

figure(plane+304),clf,set_myFig(figure(plane+304),1100,350,200,400),hold on

switch plane
    case 1 %XY plane
        xlabel('X - forward axis [cm]')
        ylabel('Y - vertical axis [cm]')
    case 2 % ZY plane
        xlabel('Z - lateral axis [cm]')
        ylabel('Y - vertical axis [cm]')
    case 3 % XZ plane
        xlabel('X - forward axis [cm]')
        ylabel('Z - lateral axis [cm]')
end

COLOR(1,:) = [0.2 0.2 0.2]; % STANCE
COLOR(2,:) = [1 0 0]; % DRAG
COLOR(3,:) = [0 110 190]./255; % SWING

for n=start_step:end_step
    %STANCE
    for frame=find(time(:,2)==gait(n,7)):skip:find(time(:,2)==gait(n,14))
        for markers=1:nmarkers
            switch plane
                case 1 %XY plane
                    data(markers, 1)=dataa(frame,markers*3-2);
                    data(markers, 2)=dataa(frame,markers*3-1);
                case 2 % ZY plane
                    data(markers, 1)=dataa(frame,markers*3);
                    data(markers, 2)=dataa(frame,markers*3-1);
                case 3 % XZ plane
                    data(markers, 1)=dataa(frame,markers*3-2);
                    data(markers, 2)=dataa(frame,markers*3);
            end
        end
        
        plot(data(:, 1), data(:, 2), '-','LineWidth',2,'color',COLOR(1,:));
        drawnow()
    end
    
    % SWING
    if gait(n,62)==0 %WITHOUT DRAGGING
        for frame=find(time(:,2)==gait(n,14)):skip:find(time(:,2)==gait(n,8))
            for markers=1:nmarkers
                switch plane
                    case 1 %XY plane
                        data(markers, 1)=dataa(frame,markers*3-2);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    case 2 % ZY plane
                        data(markers, 1)=dataa(frame,markers*3);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    case 3 % XZ plane
                        data(markers, 1)=dataa(frame,markers*3-2);
                        data(markers, 2)=dataa(frame,markers*3);
                end
            end

            plot(data(:, 1), data(:, 2),'-','LineWidth',2,'color',COLOR(3,:));
            drawnow()
        end
    else  %WITH DRAGGING
        for frame=find(time(:,2)==gait(n,14)):skip:find(time(:,2)==gait(n,62))
            for markers=1:nmarkers
                switch plane
                    case 1 %XY plane
                        data(markers, 1)=dataa(frame,markers*3-2);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    case 2 % ZY plane
                        data(markers, 1)=dataa(frame,markers*3);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    case 3 % XZ plane
                        data(markers, 1)=dataa(frame,markers*3-2);
                        data(markers, 2)=dataa(frame,markers*3);
                end
            end

            plot(data(:, 1), data(:, 2),'-','LineWidth',2,'color',COLOR(2,:));
            drawnow()
        end
        for frame=find(time(:,2)==gait(n,62))+1:skip:find(time(:,2)==gait(n,8))
            for markers=1:nmarkers
                switch plane
                    case 1 %XY plane
                        data(markers, 1)=dataa(frame,markers*3-2);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    case 2 % ZY plane
                        data(markers, 1)=dataa(frame,markers*3);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    case 3 % XZ plane
                        data(markers, 1)=dataa(frame,markers*3-2);
                        data(markers, 2)=dataa(frame,markers*3);
                end
            end

            plot(data(:, 1), data(:, 2),'-','LineWidth',2,'color',COLOR(3,:));
            drawnow()
        end
    end
end

output=1;