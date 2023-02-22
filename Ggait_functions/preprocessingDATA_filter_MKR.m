function [mkr ] = preprocessingDATA_filter_MKR(mkr, MarkerName, sample_rate, fre_filt)
%FILTER 
%  Butterworth filter 

half_rate = sample_rate/2;
filter_order = 4;
cutoff = fre_filt/half_rate;
[b a]= butter (filter_order, cutoff);
for ii=1:length(MarkerName),
         mkr.(char(MarkerName(ii))).x=filtfilt(b,a,mkr.(char(MarkerName(ii))).x);
         mkr.(char(MarkerName(ii))).y=filtfilt(b,a,mkr.(char(MarkerName(ii))).y);
         mkr.(char(MarkerName(ii))).z=filtfilt(b,a,mkr.(char(MarkerName(ii))).z);
end