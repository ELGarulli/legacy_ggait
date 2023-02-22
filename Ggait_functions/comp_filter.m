function [ data ] = comp_filter(data, high_pass, low_pass, sample_rate, filter_order, rect)

[datarows datacols]= size (data);
half_rate = sample_rate/2;

if high_pass==0
    cutoff = [low_pass/half_rate];
else
    cutoff = [high_pass/half_rate low_pass/half_rate];
end

[b a]= butter(filter_order, cutoff);

for i=1:datacols
    data_filtered(:,i)=filtfilt(b, a, (data(:,i)));
end

if rect==1
    data=abs(data_filtered);
else
    data=data_filtered;
end
