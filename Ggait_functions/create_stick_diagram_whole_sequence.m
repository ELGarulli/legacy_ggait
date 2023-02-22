function [output]=create_stick_diagram_whole_sequence(dataa, GAITL, GAITR, SIDE, start_step, nsteps, speed, fe, skip, emg, option);

%%%%%%%
% COLOR
%%%%%%%%%%
colorgait=[127/255 127/255 127/255; 73/255 86/255 119/255];
%colorgait=[1 0 0; 0 112/255 192/255];
colorscale=[1 0 0; 0 1 0; 0 0 1; 0 1 1; 0 0 0];
style=0;

       
       
switch option
    
    case 1
        
       % ADD TREADMILL BELT SPEED ALONG X AXIS
             for markers=1:12
                for i=1:size(dataa,1)
                dataa(i,markers*3-2)=dataa(i,markers*3-2)+i*(speed/fe);
                end
             end

            for markers=7:12
            dataa(:,markers*3-1)=dataa(:,markers*3-1)+1.5*max(max(dataa(:,2)));
            end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
figure(5);hold on
set(figure(5),'position',[7 300 1257 360]);


            for side=1:2
                    
                side=2
                    
                  if side==1;gait=GAITL;end
                  if side==2;gait=GAITR;end
                  
                  for n=start_step:start_step+nsteps%+side-1   
                      
                          for frame=gait(n,7):skip:gait(n,14)
                           
                               for markers=1:6
                                data(markers, 1)=dataa(frame,markers*3-2+18*(side-1));
                                data(markers, 2)=dataa(frame,markers*3-1+18*(side-1));
                               end
                              figure(5);hold on
                              plot(data(:, 1), data(:, 2), '-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black', 'MarkerFaceColor',[166/255 166/255 166/255], 'MarkerSize',7);
                        %'o-','LineWidth',1,'color',colorgait(1,1:3));

                          end

                          for frame=gait(n,14):skip:gait(n,8)
                           
                               for markers=1:6
                                data(markers, 1)=dataa(frame,markers*3-2+18*(side-1));
                                data(markers, 2)=dataa(frame,markers*3-1+18*(side-1));
                               end   
                             figure(5);hold on
                             plot(data(:, 1), data(:, 2),'-o','LineWidth',2,'color','black',...
                                'MarkerEdgeColor','black',...
                                'MarkerFaceColor',[0 112/255 192/255],...
                                'MarkerSize',7);
                             %'-','LineWidth',0.5,'color',colorgait(2,1:3));
                          end
                          
                end
            end
            
case 2
        
    
            
             figure(5);plot(dataa(:,2),'-r');hold on
             set(figure(5),'position',[7 300 1257 420]);
             window=ginput(2);
             if window(2,1)>size(dataa,1)-50;window(2,1)=size(dataa,1);end
             if window(1,1)<50;window(2,1)=1;end
             dataa=dataa(round(window(1,1)):round(window(2,1)),:);
             close(figure(5));

             % ADD TREADMILL BELT SPEED ALONG X AXIS
             for markers=1:12
                for i=1:size(dataa,1)
                dataa(i,markers*3-2)=dataa(i,markers*3-2)+i*(speed/fe);
                end
             end

            for markers=7:12
            dataa(:,markers*3-1)=dataa(:,markers*3-1)+1.5*max(max(dataa(:,2)));
            end
            
             figure(5);hold on
             set(figure(5),'position',[7 300 1257 360]);

             %window(1,1)=3474;
             %window(2,1)=5246;
        
                
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


 end % CASE

output='graph created'