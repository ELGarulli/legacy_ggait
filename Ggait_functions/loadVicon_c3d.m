function [primo_frame,num_frame,num_markers,frequenza,frequenza_analog,F,M,CP,coord1,mkr,MarkerName,analog_emg,AnalogName]=loadVicon_c3d(nome_file,SoloCinet)

% lettura_dati = Questa funzione legge il file di dati nome_file.c3d ed estrae le varie informazioni
%                da questo file, calcola la forza F e il Centro di Pressione.
%
% Syntax: [num_frame,num_markers,frequenza,set,F,M,CP,coord]=lettura_dati(nome_file);
%
% Input:        nome_file   - Nome del file .c3d
%
% Output:       num_frame           - Numero di frame (campioni)
%               num_markers         - Numero di markers utilizzati
%               frequenza           - Frequenza di campionamento dei dati cinematici
%               frequenza_analog    - Frequenza di campionamento dei dati cinematici
%               F                   - Matrice Forza F(1:3;1:num_frame), ha la stessa frequenza di campionamento dei dati cinematici,
%                                    F(1,:)=Fx F(2,:)=Fy F(3,:)=Fz
%               M                   - Matrice Momento M(1:3,1:num_frame)
%               CP                  - Matrice Centro di Pressione nelle 3 coordinate (x,y,z) in mm
%               coord               - Matrice coord dove ci sono tutti i dati cinematici dei markers
%               mkr                 - Struttura con le coordinate dei marker organizzata mkr.(nomeMarker).x or .y or .z nelle tre coordinate in mm
%               MarkerName          - Elenco nomi dei marker 
%               analog_emg          - Struttura con gli emgs e gli analog channels organizzata analog_emg.(nome emg)
%               AnalogName          - Elenco nomi degli emgs 



fid=fopen(nome_file); % fid  � il puntatore al file c3d aperto in lettuta

if fid<0, disp('Errore nell''apertura del file!'); end;

pedane=0;   %flag che identifica se uso le due pedane o la pedana grande

parameter_section=fread(fid,1,'int8');  %puntatore al primo blocco della sezione parametri
key=fread(fid,1,'int8');    %key indicante il c3d file
if key~=80, disp('Errore! Il file letto non � un c3d file.');  end;
num_markers=fread(fid,1,'int16');   %numero di markers
analog_per_frame=fread(fid,1,'int16');  %numero di misure analogiche per 3D frame
primo_frame=fread(fid,1,'int16');    %numero del primo frame dei dati 3D
if primo_frame>1,  primo_frame;  end;
ultimo_frame=fread(fid,1,'int16');  %numero dell'ultimo frame di dati 3D

% ultimo_frame=ultimo_frame;

gap=fread(fid,1,'int16');   %massima interpolazione gap nei 3D frame
fattore_scala=fread(fid,1,'real*4');    %fattore di scala per i dati -se negativo i dati 3D e analogici sono reali
if fattore_scala>0, disp('I dati sono registrati come interi e bisogna riscalarli'); sound(1);  end;
data_start=fread(fid,1,'int16');    %puntatore al primo blocco di dati 3D e analogici
analog_sample_frame=fread(fid,1,'int16');   %numero di campioni analogici per 3D frame
frequenza=fread(fid,1,'real*4');    %frequenza di campinamento dei dati cinematici

frequenza_analog=frequenza*analog_sample_frame; %frequenza di campionamento per i dati analogici
if analog_per_frame==0,
    num_chan=1; %non ci sono dati analogici
else
    num_chan=analog_per_frame/analog_sample_frame;
end

% se ho + di 32767 dati l'informazione numero frame � contenuta all'interno
% della sezione parametri, gruppo TRIAL parametro ACTUAL_END_FIELD
% altrimenti l'informazione � gi� in ultimo_frame preso dalla sezione
% Header
if ultimo_frame>0,
    num_frame=ultimo_frame-primo_frame+1;
end;

% fattore_offset(1:num_chan)=0;
% scale(1:num_chan)=1;
% gen_scale=1;
%---------------------------prelevo dati e li metto in 2 matrici-------------------------------
%-------------------------una per 3D, e una per i dati analogici-------------------------------
if ultimo_frame>0,
    fseek(fid,512*(data_start-1),-1);
    co=4;
    
    coord_analog=fread(fid,[num_markers*co+num_chan*analog_sample_frame,num_frame],'real*4');%matrice che contiene tutti i dati 3D e analog
    coord=coord_analog(1:num_markers*co,:);     %matrice che contiene tutti i dati cinematici (1:num_markers*4,1:num_frame)
    analog_data=reshape(coord_analog(num_markers*co+1:num_markers*co+num_chan*analog_sample_frame,:),num_chan,[]); %matrice che contiene i dati analogici
end
set=0;      %flag della piattaforma di forza

%-------------------------sezione dei parametri------------------------------

fseek(fid,(parameter_section-1)*512,'bof'); %posiziono il puntatore nella sezione dei parametri

nothing=fread(fid,1,'int16');   %i primi 2 byte sono riservati
num_parametri=fread(fid,1,'int8');  %numero di blocchi di parametri
processor=fread(fid,1,'int8');  %processor_type (non utilizzato)

%----------------------------Primo gruppo di parametri---------------------------------------------------------

num_char=fread(fid,1,'int8'); %numero di caratteri che compone il nome del gruppo
IDgroup=fread(fid,1,'int8');    %numero dell'ID gruppo (sempre negativo)

% while num_char~=0   %la fine del blocco di parametri � indicata da 0 caratteri nel nome del gruppo/parametro
while num_char>0
    %   %yyyyyyyyyyyy
    %    num_char=abs(num_char);
    %   %yyyyyyyyyyyy
    if IDgroup<0    %dati del gruppo
        IDgroup=abs(IDgroup);
        nome_group=fread(fid,[1,num_char],'char');    %nome del gruppo
        %          disp(sprintf('%s',nome_group));   %stampa su video il nome del gruppo
        offset=fread(fid,1,'int16');    %offset in byte che xmette di puntare al prossimo gruppo/parametri
        descr_char=fread(fid,1,'int8'); %numero di caratteri che costituisce la descrizione del gruppo/parametro
        descrizione=fread(fid,[1,descr_char],'char');   %descrizione del gruppo/parametro
        %         disp(sprintf('%s',descrizione));   %stampa su video la descrizione del gruppo
        
        %      index=0;
        
        fseek(fid,offset-3-descr_char,'cof');   %posiziono il puntatore all'inizione del prossimo blocco di parametri
        
        group.(strcat('GROUP',(num2str(IDgroup))))=nome_group;
        
    else    %dati dei parametri
        %     index=index+1;  %contatore dei parametri appartenenti al gruppo
        nome_group=group.(strcat('GROUP',(num2str(IDgroup))));
        nome_par=fread(fid,[1,num_char],'char');    %nome del parametro
        
        %         disp(sprintf('%s',nome_group));   %stampa su video il nome del gruppo
        %         disp(sprintf('%s',nome_par));   %stampa su video il nome del parametro
        
        offset=fread(fid,1,'int16');    %offset in byte che xmette di puntare al prossimo gruppo/parametro
        filepos=ftell(fid); %restituisce la posizione corrente del file fid
        prossimo_blocco=filepos+offset(1)-2;    %posizione all'inizio del prossimo blocco
        
        
        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        %**********Blocco dei parametri TRIAL dove � memorizzato il numero di*****
        %**********frame quando sono stati registrati pi� di 32767 dati***********
        if strcmp(sprintf('%c',nome_group),'TRIAL') & strcmp(sprintf('%c',nome_par),'ACTUAL_START_FIELD'),
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
            if primo_frame<0,
                primo_frame=fread(fid,1,'int32');
            else
                param_data=fread(fid,dimension,datatype);
                primo_frame=param_data(1);
            end
            
        end
        
        if strcmp(sprintf('%c',nome_group),'TRIAL') & strcmp(sprintf('%c',nome_par),'ACTUAL_END_FIELD'),
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
            if ultimo_frame<0,
                ultimo_frame=fread(fid,1,'int32');
            else
                param_data=fread(fid,dimension,datatype);
                ultimo_frame=param_data(1);
            end
            %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            %caso in cui ho +di 32767 dati e leggo qui i dati
            num_frame=ultimo_frame-primo_frame+1;
            fseek(fid,512*(data_start-1),-1);
            co=4;
            mkr=struct;MarkerName=cellstr('0');AnalogName=cellstr('0');
            coord_analog=fread(fid,[num_markers*co+num_chan*analog_sample_frame,num_frame],'real*4');%matrice che contiene tutti i dati 3D e analog
            coord=coord_analog(1:num_markers*co,:);     %matrice che contiene tutti i dati cinematici (1:num_markers*4,1:num_frame)
            analog_data=reshape(coord_analog(num_markers*co+1:num_markers*co+num_chan*analog_sample_frame,:),num_chan,[]); %matrice che contiene i dati analogici
            %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        end
        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        %---------------------richiedo in particolare solo i parametri che mi interessano--------------------
        if strcmp(sprintf('%c',nome_group),'POINT') & strcmp(sprintf('%c',nome_par),'LABELS'),
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'uint8');   %dimensione del parametro
            param_data=fread(fid,dimension,datatype);    %dato del parametro
            
            coord_temp=zeros(25*4,size(coord,2));
            %             coord_temp=coord;
            
            mkr=struct;
            ih=1;
            for jj=1:dimension(2),
                labels=sprintf('%c',param_data(:,jj));
                
                %mkr=Struttura che salva tutti i marker, associati al nome
                %mkr.'NomeMarkers'.x o y o z
                
                %condizione per escludere i markers RGT-1 RGT-2 etc
                %elimino tutti i marker unlabel  
                if length(findstr('*',labels)>0),
                else
                    [mkr,nome]=blocco(labels,coord,jj,mkr);
                    MarkerName(ih)=cellstr(nome);
                    ih=ih+1;
                end
                %                %markers del lato destro
                if findstr('RSho',labels)>0;
                    coord_temp(1:4,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('RCr',labels)>0,
                    coord_temp(5:8,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('RHi',labels)>0,
                    coord_temp(9:12,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('RKne',labels)>0,
                    coord_temp(13:16,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('RAnk',labels)>0,
                    coord_temp(17:20,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('RMT',labels)>0,
                    coord_temp(21:24,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                
                %markers del lato sinistro
                if findstr('LSho',labels)>0;
                    coord_temp(25:28,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LCr',labels)>0,
                    coord_temp(29:32,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LHI',labels)>0,
                    coord_temp(33:36,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LKne',labels)>0,
                    coord_temp(37:40,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LAnk',labels)>0,
                    coord_temp(41:44,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LMT',labels)>0,
                    coord_temp(45:48,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                %braccia
                if findstr('RE',labels)>0,
                    coord_temp(49:52,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('RW',labels)>0,
                    coord_temp(53:56,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LE',labels)>0,
                    coord_temp(57:60,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LW',labels)>0,
                    coord_temp(61:64,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                
                if findstr('RHEE',labels)>0,
                    coord_temp(65:68,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('LHEE',labels)>0,
                    coord_temp(69:72,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                
                if findstr('HEAD1',labels)>0,
                    coord_temp(73:76,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('HEAD2',labels)>0,
                    coord_temp(77:80,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                if findstr('HEAD3',labels)>0,
                    coord_temp(81:84,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                
                if findstr('T1',labels)>0,
                    coord_temp(85:88,:)=coord((jj-1)*co+1:(jj-1)*co+4,:); end;
                   
            end; %fine ciclo for jj.
            coord1=coord_temp;
            
        end;    %end if del parametro POINT:LABELS
        
        %------------------------parametri per la piattaforma di forza-------------------
        
        if strcmp(sprintf('%c',nome_group),'FORCE_PLATFORM') & strcmp(sprintf('%c',nome_par),'USED'), %FORCE_PLATFORM:USED mi dice se i dati della pedana ci sono o non ci sono nel file c3d
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
            param_data=fread(fid,1,datatype);    %dato del parametro
            %  disp('ci sono dati dalla piattaforma'); disp(param_data);
            if param_data~=0,
                set1=1;  %set1=1 ci sono dati di forza nel c3d
            else
                set1=0;  %set1=0 NON ci sono dati di forza nel c3d
            end
        end       %fine dell'if FORCE_PLATFORM:USED
        
        if set==1,
            if strcmp(sprintf('%c',nome_group),'FORCE_PLATFORM') & strcmp(sprintf('%c',nome_par),'CHANNEL'),
                type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
                if type==-1
                    datatype='char';    %carattere
                elseif type==1
                    datatype='int8';    %1 byte
                elseif type==2
                    datatype='int16';   %intero
                else    %vuol dire che type � 4
                    datatype='float';   %reale (real*4)
                end
                
                dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
                dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
                param_data=fread(fid,dimension,datatype);    %dato del parametro
                %  disp(param_data);
                
                
            end;    %end if della piattaforma  FORCE_PLATFORM:CHANNELS
            
            if strcmp(sprintf('%c',nome_group),'FORCE_PLATFORM') & strcmp(sprintf('%c',nome_par),'TYPE'),%specifica il tipo dei segnali della pedana che sono registrati:nel caso di pedane kistler 8 canali analogici TYPE-4
                type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
                if type==-1
                    datatype='char';    %carattere
                elseif type==1
                    datatype='int8';    %1 byte
                elseif type==2
                    datatype='int16';   %intero
                else    %vuol dire che type � 4
                    datatype='float';   %reale (real*4)
                end
                
                dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
                dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
                param_data=fread(fid,dimension,datatype);    %dato del parametro
                %   disp(param_data);
                
                
            end    %end if della piattaforma  FORCE_PLATFORM:TYPE
            
            if strcmp(sprintf('%c',nome_group),'FORCE_PLATFORM') & strcmp(sprintf('%c',nome_par),'ZERO'),
                type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
                if type==-1
                    datatype='char';    %carattere
                elseif type==1
                    datatype='int8';    %1 byte
                elseif type==2
                    datatype='int16';   %intero
                else    %vuol dire che type � 4
                    datatype='float';   %reale (real*4)
                end
                
                dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
                dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
                param_data=fread(fid,dimension,datatype);    %dato del parametro
                %    disp(param_data);
                
                
            end    %end if della piattaforma  FORCE_PLATFORM:ZERO
            
            
            if strcmp(sprintf('%c',nome_group),'FORCE_PLATFORM') & strcmp(sprintf('%c',nome_par),'CORNERS'),
                type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
                if type==-1
                    datatype='char';    %carattere
                elseif type==1
                    datatype='int8';    %1 byte
                elseif type==2
                    datatype='int16';   %intero
                else    %vuol dire che type � 4
                    datatype='float';   %reale (real*4)
                end
                
                dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
                dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
                %             param_data=fread(fid,dimension(1),datatype);    %dato del parametro
                %             corner=param_data;
                for jj=1:dimension(3),
                    corner1.(strcat('Pedana',num2str(jj)))=fread(fid,dimension(1),datatype);
                    corner2.(strcat('Pedana',num2str(jj)))=fread(fid,dimension(1),datatype);
                    corner3.(strcat('Pedana',num2str(jj)))=fread(fid,dimension(1),datatype);
                    corner4.(strcat('Pedana',num2str(jj)))=fread(fid,dimension(1),datatype);
                end
                
            end    %end if della piattaforma  FORCE_PLATFORM:CORNERS
            
            if strcmp(sprintf('%c',nome_group),'FORCE_PLATFORM') & strcmp(sprintf('%c',nome_par),'ORIGIN'),
                type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
                if type==-1
                    datatype='char';    %carattere
                elseif type==1
                    datatype='int8';    %1 byte
                elseif type==2
                    datatype='int16';   %intero
                else    %vuol dire che type � 4
                    datatype='float';   %reale (real*4)
                end
                
                dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
                dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
                origin=fread(fid,dimension,datatype);    %dato del parametro
                if length(origin)>0,
                    a=origin(1);    %parametro della piattaforma distanza tra il trasduttore 2 e l'asse y
                    b=origin(2);    %distanza tra il trasduttore 3 e l'asse X
                    c=origin(3);    %distanza tra il piano contenente i trasduttori e la superfice al di sotto della piattaforma
                else
                    a=0;    %parametro della piattaforma distanza tra il trasduttore 2 e l'asse y
                    b=0;    %distanza tra il trasduttore 3 e l'asse X
                    c=0;    %distanza tra il piano contenente i trasduttori e la superfice al di sotto della piattaforma
                end
            end    %end if della piattaforma  FORCE_PLATFORM:ORIGIN
            
            
        end       %fine sezione piattaforma oppure non ci sono dati di piattaforma (set=1)
        
        
        %-----------------------parametri della sezione ANALOG---------------------------
        
        
        if strcmp(sprintf('%c',nome_group),'ANALOG') & strcmp(sprintf('%c',nome_par),'GEN_SCALE'),
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
            param_data=fread(fid,1,datatype);    %dato del parametro
            %     disp(param_data);
            gen_scale=param_data;
        end     %fine del parametro ANALOG:GEN_SCALE
        
        if strcmp(sprintf('%c',nome_group),'ANALOG') & strcmp(sprintf('%c',nome_par),'SCALE'),
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
            param_data=fread(fid,dimension,datatype);    %dato del parametro
            scale=param_data;
            % disp(scale);
        end     %fine del parametro ANALOG:SCALE
        
        
        if strcmp(sprintf('%c',nome_group),'ANALOG') & strcmp(sprintf('%c',nome_par),'OFFSET'),
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
            param_data=fread(fid,dimension,datatype);    %dato del parametro
            fattore_offset=param_data;
        end     %fine del parametro ANALOG:OFFSET
        
        
        
        
        
        if strcmp(sprintf('%c',nome_group),'ANALOG') && strcmp(sprintf('%c',nome_par),'LABELS'),
            type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
            if type==-1
                datatype='char';    %carattere
            elseif type==1
                datatype='int8';    %1 byte
            elseif type==2
                datatype='int16';   %intero
            else    %vuol dire che type � 4
                datatype='float';   %reale (real*4)
            end
            
            dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
            dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
            param_data=fread(fid,dimension,datatype);    %dato del parametro
            analog_temp=analog_data;
            analog_emg=struct;
            Pedana=struct;
            ip=1;
            fp=1;
            for jj=1:dimension(2),
                labels=sprintf('%c',param_data(:,jj)); %disp(labels);
                
                if ((strcmp('Fx',labels(1:2))>0) || (strcmp('Fy',labels(1:2))>0) || (strcmp('Fz',labels(1:2))>0) || (strcmp('Mx',labels(1:2))>0) || (strcmp('My',labels(1:2))>0) || (strcmp('Mz',labels(1:2))>0) || (strcmp('Pin',labels(1:3))>0)),
                    set=1;
                    %----------------------PEDANA Zurich--------------------------------
                    analog_temp(jj,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;
                    [Pedana,nome]=blocco_analog(labels(1:2),analog_temp,jj,Pedana);
                    F_Name(fp)=cellstr(nome);
                    fp=fp+1;
                    %----------------------PEDANA 3 ( 60*90)--------------------------------
                    if findstr('Fx123',labels)>0,   pedane=0;    analog_temp(1,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fx343',labels)>0,   analog_temp(2,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fy143',labels)>0,   analog_temp(3,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fy233',labels)>0,   analog_temp(4,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz1_3',labels)>0,   analog_temp(5,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz2_3',labels)>0,   analog_temp(6,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz3_3',labels)>0,   analog_temp(7,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz4_3',labels)>0,   analog_temp(8,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    %--------------------PEDANA 1-2 (40*60)-------------------------
                    if findstr('Fx121',labels)>0,  pedane=1;   analog_temp1(1,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fx341',labels)>0,   analog_temp1(2,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fy141',labels)>0,   analog_temp1(3,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fy231',labels)>0,   analog_temp1(4,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz1_1',labels)>0,   analog_temp1(5,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz2_1',labels)>0,   analog_temp1(6,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz3_1',labels)>0,   analog_temp1(7,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz4_1',labels)>0,   analog_temp1(8,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    
                    if findstr('Fx122',labels)>0,   analog_temp2(1,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fx342',labels)>0,   analog_temp2(2,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fy142',labels)>0,   analog_temp2(3,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fy232',labels)>0,   analog_temp2(4,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz1_2',labels)>0,   analog_temp2(5,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz2_2',labels)>0,   analog_temp2(6,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz3_2',labels)>0,   analog_temp2(7,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    if findstr('Fz4_2',labels)>0,   analog_temp2(8,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;   end
                    
                    %++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    %caso in cui registro MP
                      if (strcmp('MP',labels(1:2))>0) || (strcmp('FDP',labels(1:3))>0),
                         analog_temp(jj,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;
                         [analog_emg,nome]=blocco_analog(labels,analog_temp,jj,analog_emg);
                        AnalogName(ip)=cellstr(nome);
                        ip=ip+1;
                      end
                else
                    if (isempty(str2num(labels)))==1, %quando nel nome c'e' un numero non funziona
                    analog_temp(jj,:)=(analog_data(jj,:)-abs(fattore_offset(jj)))*scale(jj)*gen_scale;
                    [analog_emg,nome]=blocco_analog(labels,analog_temp,jj,analog_emg);
                    AnalogName(ip)=cellstr(nome);
                    ip=ip+1;
                    end
                end
                
                
                
            end  %fine ciclo jj
            
            
            
            if pedane==1,
                analog_data1=analog_temp1;
                analog_data2=analog_temp2;
            else
                analog_data=analog_temp;
            end
            
            
        end    %end if della piattaforma  ANALOG:LABELS
        
  %------------------------SEZIONE EVENT-------------------
        
  if strcmp(sprintf('%c',nome_group),'EVENT') & strcmp(sprintf('%c',nome_par),'USED'), %EVENT:USED mi dice se ci sono data EVENT nel file c3d
      type=fread(fid,1,'int8');   %lunghezza in byte di ogni elemento
      if type==-1
          datatype='char';    %carattere
      elseif type==1
          datatype='int8';    %1 byte
      elseif type==2
          datatype='int16';   %intero
      else    %vuol dire che type � 4
          datatype='float';   %reale (real*4)
      end
      
      dim_num=fread(fid,1,'int8');    %numero di dimensioni del parametro (0 se il parametro � uno scalare)
      dimension=fread(fid,[1,dim_num],'int8');   %dimensione del parametro
      param_data=fread(fid,1,datatype);    %dato del parametro
      if param_data~=0,
          set1=1;  %ci sono EVENT nel c3d
      else
          set1=0;  %set1=0 NON ci sono EVENT nel c3d
      end
  end       %fine dell'if EVENT:USED
     %------------------------SEZIONE EVENT-------------------
     
        fseek(fid,prossimo_blocco,'bof');   %posiziono il puntatore a file al prossimo gruppo/parametri
        
    end %end if del blocco di parametri
    
    
    num_char=fread(fid,1,'int8'); %numero di caratteri che compone il nome del gruppo
    IDgroup=fread(fid,1,'int8');    %numero dell'ID gruppo (sempre negativo)
    
end %end del while..fine di tutti i gruppi e parametri del file c3d



fclose(fid);    %chiusura del file


% -----------------------------------------Analisi dati della piattaforma:offset, inizio-fine segnale-----------------
% num_emg=ip-1;
% gain=10000;
% if num_emg==0,
%     %     SoloCinet=0;
% end

    if SoloCinet==0,
        
%         figure(1200)
%         plot(-(Pedana.Fz))
%         title('Clicca intervallo segnale per OFFSET con il tasto sinistro del mouse,altrimenti tasto destro');      
%         figure(1200)
%         [i1,posy,but]=ginput(1);
%         if but==1
%             figure(1200)
%             [i2,posy,but]=ginput(1);
%             i1=round(i1);          
%             % shift dei segnali nei canali della piattaforma
%             Pedana.Fx=offset1(Pedana.Fx,i1,i2);
%             Pedana.Fy=offset1(Pedana.Fy,i1,i2);
%             Pedana.Fz=offset1(Pedana.Fz,i1,i2);
%         end
 
    
%     %---------------------------Converto la matrice dei dati analogici della piattaforma nella stessa dimensione dei dati cinematici------
%     rap_freq=(frequenza_analog/frequenza);
%     for ii=1:length(F_Name),
%         Pedana.(char(F_Name(ii)))=resample(Pedana.(char(F_Name(ii))),frequenza,frequenza_analog);
%     end
    
    F(1,:)=Pedana.Fx;
    F(2,:)=Pedana.Fy;
    F(3,:)=-Pedana.Fz;
    M(1,:)=Pedana.Mx;
    M(2,:)=Pedana.My;
    M(3,:)=Pedana.Mz;

    %Centro di pressione (mm)
     CP(1,:)=mkr.COP_FP1.x;
     CP(2,:)=mkr.COP_FP1.y;



    
else
%non ci sono dati della pedana di forza    
    F(1:3,:)=zeros(3,round(num_frame./frequenza)*frequenza_analog);
    M(1:3,:)=zeros(3,round(num_frame./frequenza)*frequenza_analog);
    CP(1:2,:)=zeros(2,round(num_frame./frequenza)*frequenza_analog);
end
Mtot=sqrt(M(1,:).^2+M(2,:).^2+M(3,:).^2);  %momento risultante (Nm)
Ftot=sqrt(F(1,:).^2+F(2,:).^2+F(3,:).^2);     %Calcolo la Forza risultante a partire dalle componenti

 %if ip==1,
 
 AnalogName=' ';
 %end


