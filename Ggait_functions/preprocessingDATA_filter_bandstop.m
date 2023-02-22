function output_data = preprocessingDATA_filter_bandstop(source_data, stopfreq, widthbandstop, freq)

output_data = source_data;

for j = 2:2:48
    [b,a] = butter(2, [(stopfreq*j-widthbandstop)/freq (stopfreq*j+widthbandstop)/freq],'stop');
    output_data = filtfilt(b,a,output_data);
end


[b,a] = butter(2, stopfreq/freq,'high');
output_data = filtfilt(b,a,output_data);
