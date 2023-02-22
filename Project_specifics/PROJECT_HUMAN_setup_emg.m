%% HUMAN PROJECT (emgs with no zero level)
function [DATA_EMG] = PROJECT_HUMAN_setup_emg(DATA_EMG,LHLn,RHLn,LFLn,RFLn)
for ij=2+1:LHLn+RHLn+LFLn+RFLn,
    DATA_EMG(:,ij)=DATA_EMG(:,ij)-mean(DATA_EMG(:,ij));
end