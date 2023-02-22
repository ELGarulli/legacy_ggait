
clear all
%%
name = '406_EMG';
path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\Collected_Force_files\EMG_NORMALIZATION_NEW\';
% path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\402_dec_6\';
% path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\370_Sept_27\';

% path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\346_August_29\';
% path = 'C:\Users\Niko\Desktop\Phasic_PCA\C3D_Files\345_August_30\';
name_short = name;


[dataANA,txt_ANA,raw_ANA] = importdata([path,name_short,'.txt']);

dataTXT = dataANA.textdata;

dataANA= dataANA.data;


phasic_Index = find(dataANA(:,1)==1);


normData=[];
for x = 2:size(dataANA,2)
normData = [normData,(dataANA(:,x)- std(dataANA(phasic_Index,x)))/mean(dataANA(phasic_Index,x))];
end

filename = [path,name,'_norm.xls'];

A ={};
A =  {'GaitCycle','Leg','Condition','MeanAmp','PeakValue','Peak_to_Peak','RMS','iForce'...
    'MeanAmp_F','PeakValue_F','Peak_to_Peak_F','RMS_F','iForce_F'};

for x = 1 :size(normData,1)
A{x+1,1} = dataTXT{x+1,1};  
A{x+1,2} = filename;
A{x+1,3} = dataANA(x,4);
A{x+1,4} = normData(x,1);
A{x+1,5} = normData(x,2);
A{x+1,6} = normData(x,3);
A{x+1,7} = normData(x,4);
A{x+1,8} = normData(x,5);

A{x+1,9} = normData(x,6);
A{x+1,10} = normData(x,7);
A{x+1,11} = normData(x,8);
A{x+1,12} = normData(x,9);
A{x+1,13} = normData(x,10);
end
%%

xlswrite(filename,A)