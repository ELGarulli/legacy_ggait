function [output]=create_stick_diagram(dataa, onset_frame, swing_frame, drag_frame, end_frame, stance_bef, stance_aft, swing_bef, swing_aft, speed, fe, skip, basic, emg);

TRID=0;
style=0;
speed=speed; % change for BW stepping

if basic==0 % case STANCE AND SWING DIAGRAM
    
        % stance
        counter=0;
        for frame=onset_frame+stance_bef:skip:swing_frame+stance_aft

                    for markers=1:6
                        data(markers, 1)=dataa(frame,markers*3-2)-counter*(speed/fe);
                        data(markers, 3)=dataa(frame,markers*3);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    end

                       figure(4);hold on
                        if TRID==1
                            plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black', 'MarkerFaceColor',[166/255 166/255 166/255], 'MarkerSize',8);
                        else
                          plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black', 'MarkerFaceColor',[166/255 166/255 166/255], 'MarkerSize',8);
                         end
                            counter=counter+skip;
        end

        %plot(dataa(onset_frame+extra_stance:skip:swing_frame-swing_extra,6*3-2), dataa(onset_frame+extra_stance:skip:swing_frame-swing_extra,6*3-1),'-','LineWidth',3,'color','red');
        set(figure(4),'position',[111 288 560 420]);
        axis equal

        % SWING
        counter=0;

        if drag_frame==0
    
                for frame=swing_frame+swing_bef:skip:end_frame+swing_aft

                    for markers=1:6
                        data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
                        data(markers, 3)=dataa(frame,markers*3);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    end

                    counter=counter+skip;

                   figure(5);hold on
                   if TRID==1
                     plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black',...
                                'MarkerFaceColor',[0 112/255 192/255],...
                                'MarkerSize',8);
                   else
                       plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black',...
                                'MarkerFaceColor',[0 112/255 192/255],...
                                'MarkerSize',8); 

                   end


                end

        else

                for frame=swing_frame+swing_bef:skip:drag_frame

                    for markers=1:6
                        data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
                        data(markers, 3)=dataa(frame,markers*3);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    end

                    counter=counter+skip;

                   figure(5);hold on
                   if TRID==1
                     plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black',...
                                'MarkerFaceColor',[1 0 0],...
                                'MarkerSize',8);
                   else
                       plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black',...
                                'MarkerFaceColor',[1 0 0],...
                                'MarkerSize',8);

                   end


                end
    
         
        
                for frame=drag_frame:skip:end_frame+swing_aft

                    for markers=1:6
                        data(markers, 1)=dataa(frame,markers*3-2)+counter*(speed/fe);
                        data(markers, 3)=dataa(frame,markers*3);
                        data(markers, 2)=dataa(frame,markers*3-1);
                    end

                    counter=counter+skip;

                   figure(5);hold on
                   if TRID==1
                     plot3(data(:, 1), data(:, 2), data(:, 3),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black',...
                                'MarkerFaceColor',[0 112/255 192/255],...
                                'MarkerSize',8);
                   else
                       plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black',...
                                'MarkerFaceColor',[0 112/255 192/255],...
                                'MarkerSize',8);

                   end


                end
        
            
        %plot(dataa(swing_frame+swing_bef:skip:end_frame+swing_aft,6*3-2), dataa(swing_frame+swing_bef:skip:end_frame+swing_aft,6*3-1),'-','LineWidth',3,'color',[0 112/255 192/255]);
         set(figure(5),'position',[682 287 560 420]);
                %axis equal
        end
        

else % case basic STICK DIAGRAM
    
    colorscale=[0 0 0; 0.2 0.2 0.2; 0.4 0.4 0.4; 0.6 0.6 0.6; 0.8 0.8 0.8];
    
            % ADD TREADMILL BELT SPEED ALONG X AXIS
             for markers=1:12
                for i=1:size(dataa,1)
                dataa(i,markers*3-2)=dataa(i,markers*3-2)+i*(speed/fe);
                end
             end

            for markers=7:12
            dataa(:,markers*3-1)=dataa(:,markers*3-1)+1.5*max(max(dataa(:,2)));
            end

figure(5);plot(dataa(:,2),'-r');hold on
             set(figure(5),'position',[7 300 1257 420]);
             window=ginput(2);
             if window(2,1)>size(dataa,1)-50;window(2,1)=size(dataa,1);end
             if window(1,1)<50;window(2,1)=1;end
             dataa=dataa(round(window(1,1)):round(window(2,1)),:);
             close(figure(5));

             %window(1,1)=3474;
             %window(2,1)=5246;
             
             figure(5);hold on
             set(figure(5),'position',[7 300 1257 360]);
     
                
                for side=1:2
                    
                for frame=1:skip:size(dataa,1)

                for markers=1:6
                    data(markers, 1)=dataa(frame,markers*3-2+18*(side-1));
                    data(markers, 2)=dataa(frame,markers*3-1+18*(side-1));
                end

                   figure(5);hold on
                   for segment=1:5
                       plot([data(segment, 1) data(segment+1, 1)], [data(segment, 2) data(segment+1, 2)],'-','LineWidth',0.5,'color',colorscale(segment,1:3));%o,'MarkerEdgeColor','black', 'MarkerFaceColor',[0.5 0.5 0.5], 'MarkerSize',5);
                   end
                   
                end
                end

%for markers=1:12
%    plot(dataa(:,markers*3-2), dataa(:,markers*3-1), '-','LineWidth',0.5,'color',[0.3 0.3 0.3])
%end

              figure(6);hold on
             set(figure(6),'position',[16 86 1242 254]);
             emg=emg(find(emg(:,1)==round(window(1,1))):find(emg(:,1)==round(window(2,1))),2:size(emg,2));

             for i=1:size(emg,2)
                 if style==1
                     subplot(size(emg,2),1,i);hold on;plot(emg(:,i),'k');
                 else
                     plot(emg(:,i)-6*(i-1),'color','black');
                 end
             end

end


output='graph created'