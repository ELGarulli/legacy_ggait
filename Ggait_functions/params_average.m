function mean_param=params_average(GAIT, PARAM, dimension)

PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix
PSE = 14; % position of time of stance end in GAIT matrix
PSD = 17; % position of stance duration (in percent) in GAIT matrix

n_cycle_in_averaging=0;

for cycle=1:size(GAIT,1)   
    if GAIT(cycle,111)==1
        
        n_cycle_in_averaging=n_cycle_in_averaging+1;
        
        for phase=1:2  % STANCE and SWING phases         
            if phase==1 % STANCE phase
                pos_start=PTO; pos_end=PSE;
                n_frame=round(mean(GAIT(:,PSD)))*dimension/100;
                pos_index=1;
            else % SWING phase
                pos_start=PSE;pos_end=PTE;
                n_frame=round(100-mean(GAIT(:,PSD)))*dimension/100;
                if n_frame==0
                    n_frame=1;
                    pos_index=99;
                else
                    pos_index=round(mean(GAIT(:,PSD)))*dimension/100+1;
                end               
            end
            
            if GAIT(cycle,pos_start)==GAIT(cycle,pos_end)
                warndlg(['A GAIT CYCLE HAS NO STANCE / SWING'],'Ggait - NOT ENOUGH DATA POINT');
                return
            end
            
            PARAMtemp=PARAM(find(PARAM(:,2)==GAIT(cycle,pos_start)):find(PARAM(:,2)==GAIT(cycle,pos_end)),3:size(PARAM,2));
            PARAMtemp=resample(PARAMtemp, n_frame);
            
            mean_param_pooling(pos_index:pos_index+n_frame-1,1:size(PARAM,2)-2,n_cycle_in_averaging)=PARAMtemp;           
        end      
    end   
end

if dimension==1000
    mean_wave=mean(abs(mean_param_pooling(:,:,:)),3);
    sd=std(mean_param_pooling(:,:,:),0,3)/(size(GAIT,1)^0.5); %SEM
else
    mean_wave=mean(mean_param_pooling(:,:,:),3);
    sd=std(mean_param_pooling(:,:,:),0,3);
end

mean_param=[mean_wave, mean_wave+sd,mean_wave-sd];



