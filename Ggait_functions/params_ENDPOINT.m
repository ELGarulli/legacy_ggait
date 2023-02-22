function [GAITleft, GAITright, ENDPOINT_ModVel, ENDPOINT_Angle] = params_ENDPOINT(TIME, ...
    GAITleft, GAITright, DATAleft, DATAright, RefDATAleft, RefDATAright, fe, percent, name, figN)

% DATAleft (DATAright) contains the X and Y positions of left (resp. right) MTP marker
% Positions of Crest markers are used for normalization
% In FORELIMB case, MTP is replaced by Wrist and Crest by Scap

XMTP = 1;
YMTP = 2;
PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix
PSO = 14; % position of time of swing onset in GAIT matrix
PDE = 62; % position of time of drag end in GAIT matrix

scaling_coeff=0.3;
dimension = 100; % for resampling

COLOR(1,:) = [0.4 0.4 0.4]; % STANCE
COLOR(2,:) = [0.9 0 0]; % DRAG
COLOR(3,:) = [0 0.4 0.75]; % SWING

norm_position = 'NON'; 
%%questdlg('DO YOU WANT TO NORMALIZE ENDPOINT TRAJECTORY WITH RESPECT TO PROXIMAL JOINT POSITION?', ...
    %%'Ggait - Normalization', 'NON', 'YES', 'NON');

for side=1:2
    
    if side==1;
        DATA=DATAleft;
        GAIT=GAITleft;
        RefDATA=RefDATAleft;
    else % side==2;
        DATA=DATAright;
        GAIT=GAITright;
        RefDATA=RefDATAright;
    end
    
    %% Compute PARAMS (velocity, acceleration, angle)
    DATAd(:,XMTP)=comp_derivedt(DATA(:,XMTP), fe);
    DATAd(:,YMTP)=comp_derivedt(DATA(:,YMTP), fe);
    ENDPOINT_Vel=(DATAd(:,XMTP).^2+DATAd(:,YMTP).^2).^0.5;
    ENDPOINT_Vel_mean = comp_average_waveforms(GAIT, [TIME, ENDPOINT_Vel], dimension, 'SWING');
    
    DATA_Ang=(atan2(DATAd(:,YMTP), DATAd(:,XMTP)))*180./pi;
    DATA_Ang_mean = comp_average_waveforms(GAIT, [TIME, DATA_Ang], dimension, 'SWING');
    
    DATAd2(:,XMTP)=comp_derivedt(DATAd(:,XMTP), fe);
    DATAd2(:,YMTP)=comp_derivedt(DATAd(:,YMTP), fe);
    
    ENDPOINT=[DATA(:,XMTP)-min(DATA(:,XMTP)), DATA(:,YMTP)];
    
    %% Find STANCE, DRAG, SWING phases and plot them
    figure(130+side+2*figN);hold on;
    if side==1, set_myFig(figure(130+side+2*figN),475,280,(275+15)*2+600+15,300+280+90);
    else set_myFig(figure(130+side+2*figN),475,280,(275+15)*2+600+15,300);end

    figure(125+figN); set_myFig(figure(125+figN),600,650,(275+15)*2,300);
    subplot(3,2,side); axis equal; hold on;
    
    for cycle=1:size(GAIT,1)
        
        posPSO = find(TIME(:,2)==GAIT(cycle,PSO));
        posPTE = find(TIME(:,2)==GAIT(cycle,PTE));
        posPTO = find(TIME(:,2)==GAIT(cycle,PTO));
        posPDE = find(TIME(:,2)==GAIT(cycle,PDE));
        
        if isempty(posPSO), break, end
        
        RANGE=round((GAIT(cycle,PTE)-GAIT(cycle,PSO))*fe*percent);
        
        GAIT(cycle,109) = mean((DATAd2(posPSO:posPSO+RANGE, XMTP).^2+ DATAd2(posPSO:posPSO+RANGE, YMTP).^2).^0.5, 1);% Acceleration at swing onset
        GAIT(cycle,112) = mean((DATAd(posPSO:posPSO+RANGE, XMTP).^2+ DATAd(posPSO:posPSO+RANGE, YMTP).^2).^0.5, 1);% Speed at swing onset
        GAIT(cycle,113) = mean(atan2(DATAd(posPSO:posPSO+RANGE, YMTP), DATAd(posPSO:posPSO+RANGE, XMTP))*180/pi, 1);% Angle velocity at swing onset
        [GAIT(cycle,35), GAIT(cycle,36)] = max(ENDPOINT_Vel(posPSO:posPTE));% Maximal speed
        GAIT(cycle,36) = GAIT(cycle,36)*100./length(ENDPOINT_Vel(posPSO:posPTE)); % Time of peak velocity expressed as % of swing duration
        
        
        if GAIT(cycle,111) % this gait cycle was not rejected
            data_stance=ENDPOINT(posPTO:posPSO,:);
            
            if GAIT(cycle,64)==0 % no drag
                data_drag=[];
                data_swing=ENDPOINT(posPSO:posPTE,:);
            else
                data_drag=ENDPOINT(posPSO:posPDE,:);
                data_swing=ENDPOINT(posPDE:posPTE,:);
            end
            
            figure(125+figN); subplot(3,2,side); hold on;
            if strcmp(norm_position,'YES')
                data_cycle_ref=RefDATA(posPTO:posPTE,1);
                data_stance(:,1)=data_stance(:,1)-mean(data_cycle_ref);
                if GAIT(cycle,64)~=0, data_drag(:,1)=data_drag(:,1)-mean(data_cycle_ref); end % drag
                data_swing(:,1)=data_swing(:,1)-mean(data_cycle_ref);
                plot([ENDPOINT(posPSO, XMTP)-mean(data_cycle_ref), ENDPOINT(posPSO, XMTP)-mean(data_cycle_ref)+DATAd(posPSO, XMTP)*scaling_coeff], ...
                    [ENDPOINT(posPSO, YMTP), ENDPOINT(posPSO, YMTP)+DATAd(posPSO, YMTP)*scaling_coeff], 'k','linewidth',2);
            else
                plot([ENDPOINT(posPSO, XMTP), ENDPOINT(posPSO, XMTP)+DATAd(posPSO, XMTP)*scaling_coeff],...
                    [ENDPOINT(posPSO, YMTP), ENDPOINT(posPSO, YMTP)+DATAd(posPSO, YMTP)*scaling_coeff], 'k','linewidth',2);
                axis([-2 10 0 6]);
                
            end
            plot(data_stance(:,XMTP), data_stance(:,YMTP),'color', COLOR(1,:), 'linewidth',2);
            if ~isempty(data_drag), plot(data_drag(:,XMTP), data_drag(:,YMTP),'color',COLOR(2,:),'linewidth',2); end
            plot(data_swing(:,XMTP), data_swing(:,YMTP),'color',COLOR(3,:),'linewidth',2);
            
        end
    end
    
    for cycle=1:size(GAIT,1)
        
        posPSO = find(TIME(:,2)==GAIT(cycle,PSO));
        posPTE = find(TIME(:,2)==GAIT(cycle,PTE));
        posPTO = find(TIME(:,2)==GAIT(cycle,PTO));
        posPDE = find(TIME(:,2)==GAIT(cycle,PDE));
        
        if GAIT(cycle,111) % this gait cycle was not rejected
            data_stance=ENDPOINT(posPTO:posPSO,:);
            
            if GAIT(cycle,64)==0 % no drag
                data_drag=[];
                data_swing=ENDPOINT(posPSO:posPTE,:);
            else
                data_drag=ENDPOINT(posPSO:posPDE,:);
                data_swing=ENDPOINT(posPDE:posPTE,:);
            end
            
            figure(130+side+2*figN);hold on;
            if strcmp(norm_position,'YES')
                data_cycle_ref=RefDATA(posPTO:posPTE,1);
                data_stance(:,1)=data_stance(:,1)-mean(data_cycle_ref);
                if GAIT(cycle,64)~=0, data_drag(:,1)=data_drag(:,1)-mean(data_cycle_ref); end % drag
                data_swing(:,1)=data_swing(:,1)-mean(data_cycle_ref);
                plot([ENDPOINT(posPSO, XMTP)-mean(data_cycle_ref), ENDPOINT(posPSO, XMTP)-mean(data_cycle_ref)+DATAd(posPSO, XMTP)*scaling_coeff], ...
                    [ENDPOINT(posPSO, YMTP), ENDPOINT(posPSO, YMTP)+DATAd(posPSO, YMTP)*scaling_coeff], 'k','linewidth',2);
            else
                plot([ENDPOINT(posPSO, XMTP), ENDPOINT(posPSO, XMTP)+DATAd(posPSO, XMTP)*scaling_coeff],...
                    [ENDPOINT(posPSO, YMTP), ENDPOINT(posPSO, YMTP)+DATAd(posPSO, YMTP)*scaling_coeff], 'k','linewidth',2);
            end
            plot(data_stance(:,XMTP), data_stance(:,YMTP),'color', COLOR(1,:), 'linewidth',2);
            if ~isempty(data_drag), plot(data_drag(:,XMTP), data_drag(:,YMTP),'color',COLOR(2,:),'linewidth',2); end
            plot(data_swing(:,XMTP), data_swing(:,YMTP),'color',COLOR(3,:),'linewidth',2);            
        end
    end
    
    
    
    %% PLOT VELOCITY AND ANGLE
    figure(125+figN);subplot(3,2,2+side);hold on;
    plot(DATA_Ang_mean(:,1), 'LineWidth',3, 'color', 'k');
    plot(DATA_Ang_mean(:,2), 'LineWidth',1, 'color', 'k');
    plot(DATA_Ang_mean(:,3), 'LineWidth',1, 'color', 'k');
    
    figure(125+figN);subplot(3,2,4+side);hold on;
    plot(ENDPOINT_Vel_mean(:,1), 'LineWidth',3, 'color', 'k');
    plot(ENDPOINT_Vel_mean(:,2), 'LineWidth',1, 'color', 'k');
    plot(ENDPOINT_Vel_mean(:,3), 'LineWidth',1, 'color', 'k');
    subplot(3,2,1);hold on
    
    if side==1
        figure(125+figN);subplot(3,2,1);hold on;
        switch figN
            case 0, title([name ' LEFT HL']);
            case 1, title([name ' LEFT FL']);
        end
        xlabel('FORWARD (X)');
        ylabel('VERTICAL (Y)');
        figure(125+figN);subplot(3,2,3);hold on;
        ylabel({'ANGLE VELOCITY';'(mean and SD)'});
        xlabel('CYCLE DURATION %');
        figure(125+figN);subplot(3,2,5);hold on;
        ylabel({'ENDPOINT VELOCITY';'(mean and SD)'});
        xlabel('CYCLE DURATION %');
        
        GAITleft=GAIT;
        ENDPOINT_ModVel(:,1:3)=ENDPOINT_Vel_mean;
        ENDPOINT_Angle(:,1:3)=DATA_Ang_mean;
        
        figure(130+side+2*figN); hold on;
        switch figN
            case 0, title([name ' LEFT HL']);
            case 1, title([name ' LEFT FL']);
        end
        xlabel('FORWARD (X)');
        ylabel('VERTICAL (Y)');
        
    else % side==2;
        figure(125+figN);subplot(3,2,2);hold on;
        switch figN
            case 0, title([name ' RIGHT HL']);
            case 1, title([name ' RIGHT FL']);
        end
        xlabel('FORWARD (X)');
        figure(125+figN);subplot(3,2,4);hold on;
        xlabel('CYCLE DURATION %');
        figure(125+figN);subplot(3,2,6);hold on;
        xlabel('CYCLE DURATION %');
        
        GAITright=GAIT;
        ENDPOINT_ModVel(:,4:6)=ENDPOINT_Vel_mean;
        ENDPOINT_Angle(:,4:6)=DATA_Ang_mean;
        
        figure(130+side+2*figN); hold on;
        switch figN
            case 0, title([name ' RIGHT HL']);
            case 1, title([name ' RIGHT FL']);
        end
        xlabel('FORWARD (X)');
        ylabel('VERTICAL (Y)');
    end
end