% this is to generate input signal.  times should be in seconds 
% ACCEPTABLE BIN SIZES ARE <= 1.0 seconds

function [x, extra_time] = making_bins(spikeTimes,t1,t2, binSize) 

Cells = size(spikeTimes,2);                                  


spikeTimes = 1000*(spikeTimes - (t1-binSize));  % +0.1 assumes 100ms window 
                                           % need t-100:t data for bin(t) 
                                           
spikeTimes = [spikeTimes; inf*ones(1,Cells)];
        % extra row to 'gracefully' handle the while loop searching into
        % unallocated memory. bin_genV.c should be rewritten with
        % better security and more straightforward output. 2/4/10

x = zeros(floor((t2-(t1-binSize))/binSize),Cells); 
c_C = zeros(1,Cells/binSize); 

cnt = 1; 

for t = 1000:1000:floor((t2-(t1-binSize))*1000)   
   [temp c_C] = bin_genV(t,1000*binSize,c_C,spikeTimes);
   
   temp2 = flipud(reshape(temp,1/binSize,Cells)); 
   x((cnt-1)*(1/binSize)+1:cnt*(1/binSize),:)=temp2; 
   cnt = cnt+1; 
end 

%% Not used as of 4 Feb 2010
% this variable is the amount of time that the last lever press exceeds the 
% last bin of neural data 
extra_time = t2-(t1-0.1+t/1000);