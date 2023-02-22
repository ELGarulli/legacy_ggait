function [DATA,freq,header] = extract_KINdata(name)
%Extract all Kinectic data from a Vicon .csv file in a matrix

data = textread(name, '%s', 'delimiter', ',', 'emptyvalue', NaN);
M = csvread(name, 4, 0);

header = data(4:34)';
header(1) = {'FRAME'};

freq = str2double(data(2));
TIME = (M(:,1)-M(1,1))./freq;
header = [{'TIME'}, header];

DATA = [TIME, M];

end

