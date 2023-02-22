function [analog,nome]=blocco_analog(labels,analog_temp,jj,analog) 



%     if (findstr(':',labels))>0,
%         t1=findstr(':',labels);
%     else
%         t1=0;
%     end
%     labels(findstr(labels,'-'))='';
%     if findstr(' ',labels)>0,
%         nome=(labels(t1+1:min(findstr(' ',labels))-1));   %questo con i nostri files .c3d
%     else
%         nome=labels(t1+1:end); % questo con i files .c3d di Brx
%     end
t1=0;
labels(findstr(labels,' '))='';
nome=labels(t1+1:end);
analog.(nome)=analog_temp(jj,:);

