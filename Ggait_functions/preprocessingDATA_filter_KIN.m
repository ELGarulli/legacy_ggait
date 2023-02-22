function [ data_filtered ] = preprocessingDATA_filter_KIN(data, sample_rate, fre_filt)
%FILTER 
%  Butterworth filter 

[datarows datacols]= size(data);

half_rate = sample_rate/2;
filter_order = 4;
cutoff = fre_filt/half_rate;

[b a]= butter(filter_order, cutoff);

temp = filtfilt(b,a,(data(:,1)));
data_filtered = ones(length(temp),datacols)*NaN;

for i=1:datacols
    data_filtered(:,i)=filtfilt(b, a, (data(:,i)));
end

