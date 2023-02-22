function [output]=plotStick_stick(dataa, start_stick, end_stick, speed, fe, skip, nmarkers, plane)

% ADD TREADMILL BELT SPEED ALONG X AXIS ------------------------------------
for markers=1:nmarkers
    for i=1:size(dataa,1)
        dataa(i,markers*3-2)=dataa(i,markers*3-2)+i*(speed/fe);
    end
end
%--------------------------------------------------------------------------

figure(plane+302),clf, set_myFig(figure(plane+302),900,650,200,300),hold on
xlabel('X - forward axis [cm]'), ylabel('Y - vertical axis [cm]')

COLOR(1,:) = [0.2 0.2 0.2];

for frame=start_stick:skip:end_stick
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

output=1;