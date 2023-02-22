function nogap_array = preprocessingDATA_fill_gaps(gap_array,preserve_length)
% fill_gaps.m: fill gaps in an array
% USAGE:
%  nogap_array = fill_gaps(gap_array,preserve_length)
% INPUTS:
%  gap_array: an array with gaps, or rows that consist only of zeros
%  preserve_length: whether to preserve the length (rows) of the array, or shorten to only contain data with nonzero values
% OUTPUTS:
%  nogap_array: an array with gaps interpolated

series = (1:size(gap_array,1))';
nogaps = find(any(gap_array,2) == 1);
if preserve_length ~= 0
    nogap_array = zeros(size(gap_array));
end
if (size(nogaps) ~= size(series,1)) & ~isempty(nogaps)
    last_valid_index = nogaps(end);
    nogap_series = series(1:last_valid_index,1);
    series = series(nogaps,1);
    gap_array = gap_array(nogaps,:);
    for i=1:size(gap_array,2)
        nogap_array(1:last_valid_index,i) = spline(series,gap_array(:,i),nogap_series);
    end
else
   nogap_array = gap_array; 
end