function PARAM_mean = comp_average_waveforms(GAIT, PARAM, dimension, type)
%
% INPUT - GAIT, PARAM, dimension, type
% OUTPUT - PARAM_mean = [mean_wave, mean_wave+sd,mean_wave-sd];
% 
% Compute the mean of the param and its STD over the non-rejected gait cycles (i.e. data from
% rejected gait cycles are not taken into account).
% In case dimension == 1000, SEM is calculated.
%

N=0;
PTO = 7; % position of time of gait cycle onset in GAIT matrix
PTE = 8; % position of time of gait cycle end in GAIT matrix
PSO = 14; % position of time of swing onset in GAIT matrix

SIZEparam = size(PARAM,2);

switch type
    case 'GAIT', position=PTO;
    case 'SWING', position=PSO;
end


for i=1:size(GAIT,1)
    
    if GAIT(i,111)==1 && GAIT(i,position)~=GAIT(i,PTE)
        N=N+1;
        PARAMtemp=PARAM(find(PARAM(:,2)==GAIT(i,position)):find(PARAM(:,2)==GAIT(i,PTE)),3:SIZEparam);
        PARAMtemp=resample(PARAMtemp,dimension);
        mean_param_pooling(1:dimension,1:SIZEparam-2,N)=PARAMtemp;
    end
    
end

if dimension==1000
    mean_wave=mean(abs(mean_param_pooling(:,:,:)),3);
    sd=std(mean_param_pooling(:,:,:),0,3)/(size(GAIT,1)^0.5); %SEM
else
    mean_wave=mean(mean_param_pooling(:,:,:),3);
    sd=std(mean_param_pooling(:,:,:),0,3);
end

PARAM_mean=[mean_wave, mean_wave+sd,mean_wave-sd];

end


