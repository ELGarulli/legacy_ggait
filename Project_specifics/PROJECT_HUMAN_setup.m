function [mkr] = PROJECT_HUMAN_setup(mkr,OrderMarkerName)

choice = questdlg('Is the horizontal plane correct?', 'Error Menu','Yes','No','Yes');
switch choice
    case 'No'
        for ii=1:length(OrderMarkerName),
            if isfield(mkr,(char(OrderMarkerName(ii))))==1,
                tmp=mkr.(char(OrderMarkerName(ii))).x;
                mkr.(char(OrderMarkerName(ii))).x=mkr.(char(OrderMarkerName(ii))).y;
                mkr.(char(OrderMarkerName(ii))).y=tmp;
            end
        end
end