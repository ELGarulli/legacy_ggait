function FORCE_FEATURE=params_features_force(GAIT, FORCE_FEATURE, forceCh, FORCE_mean, DATA_FORCE_HEADING, side)

FORCE_mean= [FORCE_mean ; FORCE_mean];

%% PLOT
% plot JOINT and FORCE
figure(11);subplot(size(forceCh,1)+1, 1, 1);hold on;
set(figure(11),'position',[445 100 1075 625]);

patch([0, 0, 200, 200], [0, 1, 1, 0],[1 1 1]);
for i=1:2
    if i==1, offet=0; else offet=100; end
    patch_StanceDragSwing(GAIT, offet)
    axis([0 200 0 1]);axis off
end

switch side
    case 1, title('FORCE on LEFT LIMB')
    case 2, title('FORCE on RIGHT LIMB')
end

for ch=1:size(forceCh,1)
    figure(11);subplot(size(forceCh,1)+1, 1, ch+1);hold on;
    plot(FORCE_mean(:,ch), 'LineWidth',3,'Color',[0 0 0]);
    title(DATA_FORCE_HEADING(forceCh(ch)));
end


% User
for ch=1:size(forceCh,1)
    figure(11);subplot(size(forceCh,1)+1, 1, ch+1);hold on;
    TEMP=ginput(2);
    
    if TEMP(1,1)<1000, FORCE_FEATURE(side,4*ch-3)=round(TEMP(1,1))./10;
    else             FORCE_FEATURE(side,4*ch-3)=round(TEMP(1,1)-1000)./10;
    end
    
    if TEMP(2,1)<1000, FORCE_FEATURE(side,4*ch-2)=round(TEMP(2,1))./10;
    else             FORCE_FEATURE(side,4*ch-2)=round(TEMP(2,1)-1000)./10;
    end
      
    FORCE_FEATURE(side,4*ch)=mean(FORCE_mean(round(TEMP(1,1)):round(TEMP(2,1)), ch));
    FORCE_FEATURE(side,4*ch-1)=round(TEMP(2,1))./10-round(TEMP(1,1))./10;
    
    plot([round(TEMP(1,1)) round(TEMP(1,1))], [0 max(FORCE_mean(:, ch))], 'o-r');
    plot([round(TEMP(2,1)) round(TEMP(2,1))], [0 max(FORCE_mean(:, ch))], 'o-r');
    
end
