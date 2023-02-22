function success=plot_gait_polar(GAILTLEFT, GAITRIGHT, GAILTLEFTFORE, GAITRIGHTFORE, NAME)

SIDE={'LEFT' 'RIGHT'};
LIMB={'HINDLIMB' 'IPSI FORELIMB' 'CONTRA FORELIMB'};

if ~isempty(GAILTLEFTFORE)
    nlimb=3;
else nlimb=1; end

for side=1:2
    data_toplot=[];
    
    for limb=1:nlimb        
        switch side
            case 1, GAIT=GAILTLEFT; GAITFORE=GAILTLEFTFORE;
            case 2, GAIT=GAITRIGHT;GAITFORE=GAITRIGHTFORE;
        end
        
        switch limb
            case 1, GAIT=GAIT(find(isnan(GAIT(:,32))==0),32);
            case 2, GAIT=GAITFORE(find(isnan(GAITFORE(:,168))==0),168);
            case 3, GAIT=GAITFORE(find(isnan(GAITFORE(:,170))==0),170);
        end
               
        data_toplot_mean(1:2,1)=[(mean(GAIT(:, 1))*180/50)*pi/180-pi/2 ; (mean(GAIT(:, 1))*180/50)*pi/180-pi/2];
        data_toplot_mean(1:2,2)=[0;1];
        
        figure(400+side),clf,hold on
        subplot(3,1,limb) 
        polar(data_toplot_mean(:,1), data_toplot_mean(:,2), 'r-');
        
        for i=2:size(GAIT,1)
            data_toplot(1:2,1)=[(GAIT(i, 1)*180/50)*pi/180-pi/2; (GAIT(i, 1)*180/50)*pi/180-pi/2];
            data_toplot(1:2,2)=[0;1];
            polar(data_toplot(:,1), data_toplot(:,2), 'k-');
        end
       
        title([SIDE(side), LIMB(limb)])        
    end
    
    switch side
        case 1, set_myFig(figure(400+side),325,650,10,300)
        case 2, set_myFig(figure(400+side),325,650,10+325+15,300)
    end   
end

success='Polar plot created';