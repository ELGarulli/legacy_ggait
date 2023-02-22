function [output]=plotStick_swings(time, dataa, GAITDATA, speed, fe, skip, TRID,nmarkers)

switch TRID
    case 1, is_3D = 0;
    case 2, is_3D = 1;
end

COLOR(1,:) = [0.2 0.2 0.2]; % STANCE
COLOR(2,:) = [1 0 0]; % DRAG
COLOR(3,:) = [0 110/255 190/255]; % SWING

figure(302),clf,set_myFig(figure(302),1100,625,200,200),hold on
n_line=ceil(size(GAITDATA,1)./5);
n_columns=5;

for i=1:size(GAITDATA,1)
    
    subplot(n_line, n_columns,i);hold on
    title(['#' num2str(i)]);
    axis equal
    counter=0;
    
    if GAITDATA(i,62)==0 % without drag
        for frame=find(time(:,2)==GAITDATA(i,14)):skip:find(time(:,2)==GAITDATA(i,8))
            for markers=1:nmarkers
                data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
                data(markers, 3)=dataa(frame,markers*3);
                data(markers, 2)=dataa(frame,markers*3-1);
            end
            
            if is_3D, plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',0.5,'color','black',...
                    'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:), 'MarkerSize',5);
            else plot(data(:, 1), data(:, 2),'-o','LineWidth',0.5,'color','black',...
                    'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:), 'MarkerSize',5);
            end
            
            counter=counter+skip;
        end
        
    else % with drag
        for frame=find(time(:,2)==GAITDATA(i,14)):skip:find(time(:,2)==GAITDATA(i,62))
            for markers=1:nmarkers
                data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
                data(markers, 3)=dataa(frame,markers*3);
                data(markers, 2)=dataa(frame,markers*3-1);
            end
            
            if is_3D, plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',0.5,'color','black',...
                    'MarkerEdgeColor','black','MarkerFaceColor',COLOR(2,:),'MarkerSize',5);
            else plot(data(:, 1), data(:, 2),'-o','LineWidth',0.5,'color','black',...
                    'MarkerEdgeColor','black','MarkerFaceColor',COLOR(2,:),'MarkerSize',5);
            end
            
            counter=counter+skip;
        end
        
        for frame=find(time(:,2)==GAITDATA(i,62)):skip:find(time(:,2)==GAITDATA(i,8))
            for markers=1:nmarkers
                data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
                data(markers, 3)=dataa(frame,markers*3);
                data(markers, 2)=dataa(frame,markers*3-1);
            end
            counter=counter+skip;
            
            if is_3D, plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',0.5,'color','black',...
                    'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:), 'MarkerSize',5);
            else plot(data(:, 1), data(:, 2),'-o','LineWidth',0.5,'color','black',...
                    'MarkerEdgeColor','black','MarkerFaceColor',COLOR(3,:), 'MarkerSize',5);
            end
        end
    end
end

output=1;