function success=plot_gait_quadrupedal(GAIT, GAIT_FORELIMB, frame, limbL, limbR, forelimbL, forelimbR)

figure(404),clf,hold on
set_myFig(figure(404),600,420,10+(325+15)*2,300)

if ~isempty(GAIT_FORELIMB)
    nplot=4;
else nplot=2; end

COLOR(1,:) = [0.4 0.4 0.4]; % STANCE
COLOR(2,:) = [0.9 0 0]; % DRAG
COLOR(3,:) = [0 0.4 0.75]; % SWING

for limbin=1:nplot
    
    switch limbin
        case 1, GAITin=GAIT(find(GAIT(:,2)~=0),2:4);limb=limbL;name='left hindlimb';
        case 2, GAITin=GAIT(find(GAIT(:,7)~=0),7:9);limb=limbR;name='right hindlimb';
        case 3, GAITin=GAIT_FORELIMB(find(GAIT_FORELIMB(:,2)~=0),2:4);limb=forelimbL;name='left forelimb';
        case 4, GAITin=GAIT_FORELIMB(find(GAIT_FORELIMB(:,7)~=0),7:9);limb=forelimbR;name='right forelimb';
    end
    
    subplot(nplot,1,limbin);hold on
    ylabel(name)
    X = frame(find(frame(:,1)==min(GAITin(:,1))):find(frame(:,1)==max(GAITin(:,1))),1);
    Y = limb(find(frame(:,1)==min(GAITin(:,1))):find(frame(:,1)==max(GAITin(:,1))),1);
    minY = min(Y);
    maxY = max(Y);
    
    plot(X, Y, 'LineWidth',2,'Color','black');     
    for i=1:size(GAITin,1)
        plot([GAITin(i,1), GAITin(i,1)],[minY,maxY], 'LineWidth',2,'Color',COLOR(1,:)); % foot strike           
        if GAITin(i,2)~=0 && isnan(GAITin(i,2))~=1 
            plot([GAITin(i,2), GAITin(i,2)],[minY,maxY], 'LineWidth',2,'Color',COLOR(2,:)); % minimal limb axis angle
        end       
        plot([GAITin(i,3), GAITin(i,3)],[minY,maxY], 'LineWidth',2,'Color',COLOR(3,:)); % toe off
    end
    
    axis([min(GAITin(:,1)) max(GAITin(:,1)) minY maxY]);   
end
suptitle('Limb axis angle')

success='Plot created';