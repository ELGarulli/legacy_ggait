function [mkr]=comp_velacc(mkr,MarkerName, fe)
% compute velocity and acceleration as derivatives of markers

for ii=1:length(MarkerName),
    if isfield(mkr,(char(MarkerName(ii))))==1,
        mkr.(char(MarkerName(ii))).vx=comp_derivedt(mkr.(char(MarkerName(ii))).x',fe);
        mkr.(char(MarkerName(ii))).vy=comp_derivedt(mkr.(char(MarkerName(ii))).y',fe);
        mkr.(char(MarkerName(ii))).vz=comp_derivedt(mkr.(char(MarkerName(ii))).z',fe);
        
        mkr.(char(MarkerName(ii))).ax=comp_derivedt(mkr.(char(MarkerName(ii))).vx',fe);
        mkr.(char(MarkerName(ii))).ay=comp_derivedt(mkr.(char(MarkerName(ii))).vy',fe);
        mkr.(char(MarkerName(ii))).az=comp_derivedt(mkr.(char(MarkerName(ii))).vz',fe);
    end
    
end
