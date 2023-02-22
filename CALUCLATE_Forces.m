% CALCULATE_FORCES 
clear all
%%
name = 'August3012_GAIT';
%  path = 'C:\Users\Niko\Desktop\Phasic_PCA\Healthy_Rats\P0_Rubia_TM\#129\';
% path = 'C:\Users\Niko\Desktop\Phasic_PCA\Healthy_Rats\P0_Rubia_TM\#202\';

% path = 'C:\Users\Niko\Desktop\Phasic_PCA\Healthy_Rats\P0_Rubia_TM\#208\';
% path = 'C:\Users\Niko\Desktop\Phasic_PCA\Healthy_Rats\P0_Rubia_TM\#130\';

% path = 'C:\Users\Niko\Desktop\Phasic_PCA\Healthy_Rats\healthyrats_TM\';


% path = 'C:\Users\Niko\Desktop\Videos_array\healthy_Simone\';


% path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\406_dec_17\';
% path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\402_dec_6\';
% path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\370_Sept_27\';

% path = 'C:\Users\Niko\Desktop\Videos_array\healthy_Simone\';

%  path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\346_August_29\';
path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\345_August_30\';

filearranger = 1;

name_short = name(1:end-5);

[first_frame,num_frame,num_markers,handles.freq,handles.freq_analog,...
    handles.F,handles.M,handles.CP,handles.coord,handles.mkr,handles.MarkerName, ...
    handles.emg_analog,handles.AnalogName] = load_VICON_c3d([path,name_short,'.c3d'],1);
% [dataANA,txt_ANA,raw_ANA] = xlsread([path,name_short,'_ANA.csv']);
dataANA =handles.F;
[dataGAIT,txt_GAIT,raw_GAIT] = xlsread([path,name_short,'_GAIT.csv']);
%%
sampleFreq=4000;

%%
Left_FS =[];
Left_TO=[];
Right_FS=[];
Right_TO=[];

for x = 3:size(txt_GAIT,1)

if    strcmp(txt_GAIT{x,2},'Left') 
    if  strcmp(txt_GAIT{x,3},'Foot Strike') 
        Left_FS =[Left_FS,x-2];
    end
    if  strcmp(txt_GAIT{x,3},'Foot Off') 
        Left_TO =[Left_TO,x-2];
    end
end

if    strcmp(txt_GAIT{x,2},'Right') 
    if  strcmp(txt_GAIT{x,3},'Foot Strike') 
        Right_FS =[Right_FS,x-2];
    end
    if  strcmp(txt_GAIT{x,3},'Foot Off') 
        Right_TO =[Right_TO,x-2];
    end
end
end
%%

%%
ForceZ = abs(dataANA(3,:))';
% ForceZ = abs(dataANA(4:end,4))';


%STIM = abs( dataANA(4:end,14));
%edge_stim = edge( smooth(STIM,100)-mean(smooth(STIM,100)) );


Index_seconds = 1:size(dataANA,2);
Index_seconds = Index_seconds/sampleFreq+ first_frame/200-1/200;

% Index_seconds= abs(dataANA(4:end,1))'/sampleFreq;

% figure(4)
% plot(ForceZ,'g')
Left_FS_seconds =dataGAIT(Left_FS,filearranger);
Left_TO_seconds = dataGAIT(Left_TO,filearranger);
Right_FS_seconds = dataGAIT(Right_FS,filearranger);
Right_TO_seconds = dataGAIT(Right_TO,filearranger);


figure;
hold off
plot(Index_seconds,ForceZ,'g')
%%
hold on
windowSize = 120;
b = (1/windowSize)*ones(1,windowSize);
a=1;
%FilteredForce = filter(b,a,ForceZ);
FilteredForce = smooth(ForceZ,windowSize);

[b,a]= butter(2, 1/sampleFreq, 'Low');
FilteredForce_1 = filtfilt(b,a,ForceZ);
% temp = std(ForceZ - FilteredForce_1);

temp = mean(ForceZ(round(Left_FS_seconds(1)*sampleFreq)-first_frame*sampleFreq/200:round(Left_FS_seconds(end)*sampleFreq)-first_frame*sampleFreq/200));


FilteredForce_1 = (FilteredForce - FilteredForce_1);
FilteredForce_1=FilteredForce_1+temp;
hold on
plot(Index_seconds,FilteredForce_1,'m')
% figure
% plot(Index_seconds,FilteredForce,'r')
%%


Left_FS_seconds =dataGAIT(Left_FS,filearranger);
Left_TO_seconds = dataGAIT(Left_TO,filearranger);
Right_FS_seconds = dataGAIT(Right_FS,filearranger);
Right_TO_seconds = dataGAIT(Right_TO,filearranger);


barsL = [0,max(abs(ForceZ))];
barsR = [-max(abs(ForceZ)),-.1];

%figure(1)
hold on
for x = 1:length(Left_FS_seconds)
    plot([Left_FS_seconds(x),Left_FS_seconds(x)],barsL,'k')
end
 for x = 1:length(Left_TO_seconds)
     plot([Left_TO_seconds(x),Left_TO_seconds(x)],barsL,'--k')
 end
for x = 1:length(Right_FS_seconds)
     plot([Right_FS_seconds(x),Right_FS_seconds(x)],barsL,'r')
end
 for x = 1:length(Right_TO_seconds)
      plot([Right_TO_seconds(x),Right_TO_seconds(x)],barsL,'--r')
 end


%plot(Index_seconds,STIM,'b');
%plot(Index_seconds,smooth(STIM,100),'b');



%% calculate values for Forces
Left_Force_Index_Matrix=[];
for x = 1:size(Left_FS_seconds,1)
    if isempty(find(Right_FS_seconds > Left_FS_seconds(x)))
    else
       runner = find(Right_FS_seconds > Left_FS_seconds(x));
       Left_Force_Index_Matrix=[Left_Force_Index_Matrix;Left_FS_seconds(x),Right_FS_seconds(runner(1))];
    end
end

Right_Force_Index_Matrix=[];
for x = 1:size(Right_FS_seconds,1)
    if isempty(find(Left_FS_seconds > Right_FS_seconds(x)))
    else
        runner = find(Left_FS_seconds > Right_FS_seconds(x));
        Right_Force_Index_Matrix=[Right_Force_Index_Matrix;Right_FS_seconds(x),Left_FS_seconds(runner(1))];
    end
end

Right_Stim_Index_Matrix=[];


% %%
% 
% for x = 1 : size(Left_Force_Index_Matrix,1)
%    
%     Onset= round(Left_Force_Index_Matrix(x,1)*sampleFreq)-first_frame*sampleFreq/200;
%     EndZZZZ= round(Left_Force_Index_Matrix(x,2)*sampleFreq)-first_frame*sampleFreq/200;
%     
% MeanAmplitude_Left(x) = mean(FilteredForce(Onset:EndZZZZ));
% [PeakValue_Left(x), MAXPL(x)]= max(FilteredForce(Onset:EndZZZZ));
% [Peakmin_Left(x), MINPL(x)]= min(FilteredForce(Onset:EndZZZZ));
% 
% Peak_to_Peak_Left(x)= max(FilteredForce(Onset:EndZZZZ))-min(FilteredForce(Onset:EndZZZZ));
% RMS_Left(x)= rms(FilteredForce(Onset:EndZZZZ));
% iForce_Left(x)=  sum(FilteredForce(Onset:EndZZZZ));
% 
% MeanAmplitude_Left_filtred(x) = mean(FilteredForce_1(Onset:EndZZZZ));
% PeakValue_Left_filtred(x)= max(FilteredForce_1(Onset:EndZZZZ));
% Peak_to_Peak_Left_filtred(x)= max(FilteredForce_1(Onset:EndZZZZ))-min(FilteredForce_1(Onset:EndZZZZ));
% RMS_Left_filtred(x)= rms(FilteredForce_1(Onset:EndZZZZ));
% iForce_Left_filtred(x)=  sum(FilteredForce_1(Onset:EndZZZZ));
% 
% end
% 
% 
% 
% for x = 1 : size(Right_Force_Index_Matrix,1)
%    
%     Onset= round(Right_Force_Index_Matrix(x,1)*sampleFreq)-first_frame*sampleFreq/200;
%     EndZZZZ= round(Right_Force_Index_Matrix(x,2)*sampleFreq)-first_frame*sampleFreq/200;
%     
% MeanAmplitude_Right(x) = mean(FilteredForce(Onset:EndZZZZ));
% PeakValue_Right(x)= max(FilteredForce(Onset:EndZZZZ));
% Peakmin_Right(x)= min(FilteredForce(Onset:EndZZZZ));
% 
% Peak_to_Peak_Right(x)= max(FilteredForce(Onset:EndZZZZ))-min(FilteredForce(Onset:EndZZZZ));
% RMS_Right(x)= rms(FilteredForce(Onset:EndZZZZ));
% iForce_Right(x)=  sum(FilteredForce(Onset:EndZZZZ));
% 
% MeanAmplitude_Right_filtred(x) = mean(FilteredForce_1(Onset:EndZZZZ));
% [PeakValue_Right_filtred(x), MAXPR(x)]= max(FilteredForce_1(Onset:EndZZZZ));
% [Peakmin_Right_filtred(x), MINPR(x)]= min(FilteredForce_1(Onset:EndZZZZ));
% 
% Peak_to_Peak_Right_filtred(x)= max(FilteredForce_1(Onset:EndZZZZ))-min(FilteredForce_1(Onset:EndZZZZ));
% RMS_Right_filtred(x)= rms(FilteredForce_1(Onset:EndZZZZ));
% iForce_Right_filtred(x)=  sum(FilteredForce_1(Onset:EndZZZZ));
% 
% MAXPR(x) = MAXPR(x) + Onset+first_frame*sampleFreq/200;
% MINPR(x) = MINPR(x) + Onset+first_frame*sampleFreq/200;
% end
% 
% 
% plot(MAXPR/sampleFreq, PeakValue_Right_filtred, 'xr','MarkerSize',10)
% plot(MINPR/sampleFreq, Peakmin_Right_filtred, 'xb','MarkerSize',10)
% 
% %%
% filename = [path,name,'_force.xls'];
% %%
% A ={};
% A =  {'GaitCycle','Leg','MeanAmp','PeakValue','Peak_to_Peak','RMS','iForce'...
%     'MeanAmp_F','PeakValue_F','Peak_to_Peak_F','RMS_F','iForce_F'};
% 
% for x = 1 :size(MeanAmplitude_Left,2)
% A{x+1,1} = x;  
% A{x+1,2} = 'Left';
% A{x+1,3} = MeanAmplitude_Left(x);
% A{x+1,4} = PeakValue_Left(x);
% A{x+1,5} = Peak_to_Peak_Left(x);
% A{x+1,6} = RMS_Left(x);
% A{x+1,7} = iForce_Left(x);
% 
% A{x+1,8} = MeanAmplitude_Left_filtred(x);
% A{x+1,9} = PeakValue_Left_filtred(x);
% A{x+1,10} = Peak_to_Peak_Left_filtred(x);
% A{x+1,11} = RMS_Left_filtred(x);
% A{x+1,12} = iForce_Left_filtred(x);
% end
% %%
% for x = 1 :size(MeanAmplitude_Right,2)
%     
% par = x+size(MeanAmplitude_Left,2);
% A{par+1,1} = x;
% A{par+1,2} = 'Right';
% A{par+1,3} = MeanAmplitude_Right(x);
% A{par+1,4} = PeakValue_Right(x);
% A{par+1,5} = Peak_to_Peak_Right(x);
% A{par+1,6} = RMS_Right(x);
% A{par+1,7} = iForce_Right(x);
% 
% A{par+1,8} = MeanAmplitude_Right_filtred(x);
% A{par+1,9} = PeakValue_Right_filtred(x);
% A{par+1,10} = Peak_to_Peak_Right_filtred(x);
% A{par+1,11} = RMS_Right_filtred(x);
% A{par+1,12} = iForce_Right_filtred(x);
% end
% 
% % save(filename,'A')
% %dlmwrite(filename,A,',');
% xlswrite(filename,A)
% 
% 
% 
% % ForceZ = abs(dataANA(4:end,4));
% % Index_seconds = dataANA(4:end,1)/sampleFreq;
% % plot(Index_seconds,ForceZ,'g')
% % %%
% % hold on
% % windowSize = 100;
% % b = (1/windowSize)*ones(1,windowSize)
% % a=1;
% % FilteredForce = filter(b,a,ForceZ);
% % hold on
% % 
% % 
% % 
% % plot(Index_seconds,FilteredForce,'r')
% % %%
% % Left_FS_seconds =dataGAIT(Left_FS);
% % Left_TO_seconds = dataGAIT(Left_TO);
% % Right_FS_seconds = dataGAIT(Right_FS);
% % Right_TO_seconds = dataGAIT(Right_TO);
% % 
% % 
% % barsL = [0,max(abs(ForceZ))];
% % barsR = [-max(abs(ForceZ)),-.1];
% % 
% % figure(1)
% % hold on
% % for x = 1:length(Left_FS_seconds)
% %     plot([Left_FS_seconds(x),Left_FS_seconds(x)],barsL,'k')
% % end
% % % for x = 1:length(Left_TO_seconds)
% % %     plot([Left_TO_seconds(x),Left_TO_seconds(x)],barsL,'r')
% % % end
% % for x = 1:length(Right_FS_seconds)
% %      plot([Right_FS_seconds(x),Right_FS_seconds(x)],barsL,'r')
% % end
% % for x = 1:length(Right_TO_seconds)
% %      plot([Right_TO_seconds(x),Right_TO_seconds(x)],barsR,'r')
% % end
% 
% hold off
% 
% %% calculate values for Forces
% Left_Force_Index_Matrix=[];
% for x = 1:size(Left_FS_seconds,1)
%     if isempty(find(Right_FS_seconds > Left_FS_seconds(x)))
%     else
%    runner = find(Right_FS_seconds > Left_FS_seconds(x));
%     Left_Force_Index_Matrix=[Left_Force_Index_Matrix;Left_FS_seconds(x),Right_FS_seconds(runner(1))];
%     end
% end
% Right_Force_Index_Matrix=[];
% for x = 1:size(Right_FS_seconds,1)
%     if isempty(find(Left_FS_seconds > Right_FS_seconds(x)))
%     else
%    runner = find(Left_FS_seconds > Right_FS_seconds(x));
%     Right_Force_Index_Matrix=[Right_Force_Index_Matrix;Right_FS_seconds(x),Left_FS_seconds(runner(1))];
%     end
% end
% 
% %%
% 
% for x = 1 : size(Left_Force_Index_Matrix,1)
%    
%     Onset= round(Left_Force_Index_Matrix(x,1)*sampleFreq)-dataANA(4,1);
%     EndZZZZ= round(Left_Force_Index_Matrix(x,2)*sampleFreq)-dataANA(4,1);
%     
% MeanAmplitude_Left(x) = mean(FilteredForce(Onset:EndZZZZ));
% PeakValue_Left(x)= max(FilteredForce(Onset:EndZZZZ));
% Peak_to_Peak_Left(x)= max(FilteredForce(Onset:EndZZZZ))-min(FilteredForce(Onset:EndZZZZ));
% RMS_Left(x)= rms(FilteredForce(Onset:EndZZZZ));
% iForce_Left(x)=  sum(FilteredForce(Onset:EndZZZZ));
% end
% 
% 
% 
% for x = 1 : size(Right_Force_Index_Matrix,1)
%    
%     Onset= round(Right_Force_Index_Matrix(x,1)*sampleFreq)-dataANA(4,1);
%     EndZZZZ= round(Right_Force_Index_Matrix(x,2)*sampleFreq)-dataANA(4,1);
%     
% MeanAmplitude_Right(x) = mean(FilteredForce(Onset:EndZZZZ));
% PeakValue_Right(x)= max(FilteredForce(Onset:EndZZZZ));
% Peak_to_Peak_Right(x)= max(FilteredForce(Onset:EndZZZZ))-min(FilteredForce(Onset:EndZZZZ));
% RMS_Right(x)= rms(FilteredForce(Onset:EndZZZZ));
% iForce_Right(x)=  sum(FilteredForce(Onset:EndZZZZ));
% end
% 
% 
% 
% %%
% filename = [name,'_force.xlsx'];
% %%
% A ={};
% A =  {'GaitCycle','Leg','MeanAmp','PeakValue','Peak_to_Peak','RMS','iForce'};
% for x = 1 :size(MeanAmplitude_Left,2)
% A{x+1,1} = x;  
% A{x+1,2} = 'Left';
% A{x+1,3} = MeanAmplitude_Left(x);
% A{x+1,4} = PeakValue_Left(x);
% A{x+1,5} = Peak_to_Peak_Left(x);
% A{x+1,6} = RMS_Left(x);
% A{x+1,7} = iForce_Left(x);
% end
% %%
% for x = 1 :size(MeanAmplitude_Right,2)
%     
% par = x+size(MeanAmplitude_Left,2);
% A{par+1,1} = x;
% A{par+1,2} = 'Right';
% A{par+1,3} = MeanAmplitude_Right(x);
% A{par+1,4} = PeakValue_Right(x);
% A{par+1,5} = Peak_to_Peak_Right(x);
% A{par+1,6} = RMS_Right(x);
% A{par+1,7} = iForce_Right(x);
% end
% xlswrite(filename,A)
% 
% 
% 
% 
% 
