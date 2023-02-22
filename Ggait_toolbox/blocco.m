function [mkr,nome]=blocco(labels,coord,jj,mkr) 

% Funzione che costruisce  una struttura identificata con:
%           mkr.NOMEMARKER.COORDINATA esempio mkr.RGT.x

% Syntax: [mkr]=lettura_dati(labels,coord,jj,co,mkr);
%
% Input:        labels   - nome che vengono nellti nel file c3d  in POINT LABELS
%               coord    - matrice che contiene tutti i dati cinematici (1:num_markers*4,1:num_frame)
%               jj       - indice del ciclo for in cui vengono letti i nomi dei markers
%               mkr      - variabile che deve inizialmente posta a zero, e
%                          che successivamente viene costruita come struttuta dei  markers
%
% Output:       mkr      - Struttura identificata dai markers  :  mkr.RGT.x etc  (le coordinate cono in mm)


co=4;

if (findstr(':',labels))>0,
    t1=findstr(':',labels);
else
    t1=0;
end
if length(findstr('-',labels)>0),
   labels(findstr('-',labels))='X';
end
if findstr(' ',labels)>0,
        nome=(labels(t1+1:min(findstr(' ',labels))-1));
    else
    nome=labels(t1+1:end);  %questo valido con i file .c3d di Brx
end

mkr.(nome)=struct('x',coord((jj-1)*co+1:(jj-1)*co+1,:),'y',coord((jj-1)*co+2:(jj-1)*co+2,:),'z',coord((jj-1)*co+3:(jj-1)*co+3,:));
% mkr(jj).(labels(t1+1:min(findstr(' ',labels))-1))=struct('x',coord((jj-1)*co+1:(jj-1)*co+1,:)./1000,'y',coord((jj-1)*co+2:(jj-1)*co+2,:)./1000,'z',coord((jj-1)*co+3:(jj-1)*co+3,:)./1000);
