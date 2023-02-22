function EMG_FEATURE=params_features_EMG(GAIT, emgCh, EMG_mean, DATA_EMG_HEADING, side, freq)


% FILTER EMG
EMG_mean= [EMG_mean ; EMG_mean];
EMG_mean= comp_filter(EMG_mean, 60, [], freq, 5, 1);

%% PLOT

% Plot JOINT and EMG
figure(10); subplot(size(emgCh,1)+1, 1, 1);hold on;
set(figure(10),'position',[445 75 590 650]);

patch([0, 0, 200, 200], [0, 1, 1, 0],[1 1 1]);
for i=1:2
    if i==1, offet=0; else offet=100; end
    patch_StanceDragSwing(GAIT, offet)
    axis([0 200 0 1]);axis off
end
switch side
    case 1, title('EMG on LEFT LIMB');
    case 2, title('EMG on RIGHT LIMB');
end


for ch=1:size(emgCh,1)
    figure(10);subplot(size(emgCh,1)+1, 1, ch+1);hold on;
    plot(EMG_mean(:,ch), 'LineWidth',3,'Color',[0 0 0]);
    title(DATA_EMG_HEADING(emgCh(ch)));
end

% User
for ch=1:size(emgCh,1)
    figure(10);subplot(size(emgCh,1)+1, 1, ch+1);hold on;
    TEMP=ginput(2);
    
    if TEMP(1,1)<1000, EMG_FEATURE(side,4*ch-3)=round(TEMP(1,1))./10;
    else               EMG_FEATURE(side,4*ch-3)=round(TEMP(1,1)-1000)./10;
    end
    
    if TEMP(2,1)<1000, EMG_FEATURE(side,4*ch-2)=round(TEMP(2,1))./10;
    else               EMG_FEATURE(side,4*ch-2)=round(TEMP(2,1)-1000)./10;
    end
    
    EMG_FEATURE(side,4*ch)=mean(EMG_mean(round(TEMP(1,1)):round(TEMP(2,1)), ch));
    EMG_FEATURE(side,4*ch-1)=round(TEMP(2,1))./10-round(TEMP(1,1))./10;
    
    plot([round(TEMP(1,1)) round(TEMP(1,1))], [0 max(EMG_mean(:, ch))], 'o-r');
    plot([round(TEMP(2,1)) round(TEMP(2,1))], [0 max(EMG_mean(:, ch))], 'o-r');
end
