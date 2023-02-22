function [mkr,MarkerName]=ChangeNameMkr(mkr,MarkerName)

% se Elbow e Wrist sono scritti con la lettera maiuscola, li cambio con la
% lettera minuscola, nel prog e' usata questa dicitura

for ii=1:2,
    if ii==1, leg='L'; else leg='R'; end
    if isfield(mkr, strcat(leg,'Elbow'))
        mkr.(strcat(leg,'elbow'))=mkr.(strcat(leg,'Elbow'));
        mkr=rmfield(mkr,(strcat(leg,'Elbow')));
    end
    if isfield(mkr, strcat(leg,'Wrist'))
        mkr.(strcat(leg,'wrist'))=mkr.(strcat(leg,'Wrist'));
        mkr=rmfield(mkr,(strcat(leg,'Wrist')));
    end
    if isfield(mkr, strcat(leg,'Shoulder'))
        mkr.(strcat(leg,'shoulder'))=mkr.(strcat(leg,'Shoulder'));
        mkr=rmfield(mkr,(strcat(leg,'Shoulder')));
    end
end

MarkerName(find(strcmp(MarkerName,'RElbow')))={'Relbow'};
MarkerName(find(strcmp(MarkerName,'RWrist')))={'Rwrist'};
MarkerName(find(strcmp(MarkerName,'LElbow')))={'Lelbow'};
MarkerName(find(strcmp(MarkerName,'LWrist')))={'Lwrist'};
MarkerName(find(strcmp(MarkerName,'LShoulder')))={'Lshoulder'};
MarkerName(find(strcmp(MarkerName,'RShoulder')))={'Rshoulder'};
