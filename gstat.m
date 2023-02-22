function varargout = gstat(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gstat_OpeningFcn, ...
    'gui_OutputFcn',  @gstat_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gstat is made visible.
function gstat_OpeningFcn(hObject, eventdata, handles, varargin)

handles.N_all=0;
handles.DATA_ALL=[];
handles.F_ALL=[];
handles.S_ALL=[];
handles.Eigenvalue_ALL=[];

handles.TXT_Col_menu=[0;1;2;3;4;5;6;7;8];
set(handles.TXT_Col,'String',handles.TXT_Col_menu);
set(handles.fitting_order, 'string',handles.TXT_Col_menu(2:size(handles.TXT_Col_menu,1)));
handles.rotation_menu={'NONE', 'VARIMAX'};
set(handles.rotation,'String',handles.rotation_menu);

handles.error_menu={'NONE', 'SD', 'SEM', 'Data points'};
set(handles.error_type,'String',handles.error_menu);

handles.REORDER_DATA_MENU={'NO RANKING', 'RANK PC1', 'RANK PC2', 'RANK PC3', 'RANK PC4'};
set(handles.REORDER_DATA,'String',handles.REORDER_DATA_MENU);

handles.color_map_choice_menu={'1', '2', '3', '4', '5', '6'};
set(handles.color_map_choice, 'string', handles.color_map_choice_menu);

handles.transparence_menu={'FILL', 'TRANSPARENT'};
set(handles.transparence, 'string', handles.transparence_menu);

handles.cat=[handles.cat1, handles.cat2, handles.average_by];

handles.PATHNAME=cd;

% DEFINE BASIC COLOR MAP
handles.color_code(1,1:3)=[1 0 0];
handles.color_code(2,1:3)=[0 0 1];
handles.color_code(4,1:3)=[1 1 0];
handles.color_code(3,1:3)=[0 1 0];
handles.color_code(5,1:3)=[0.8 0.8 0.8];
handles.color_code(6,1:3)=[1 0.3 1];
handles.color_code(7,1:3)=[0 0 0];
handles.color_code(8,1:3)=[255/255 170/255 0];
handles.color_code(9,1:3)=[0 1 1];
handles.color_code(10,1:3)=[152/255 152/255  152/255];

handles.color_code(11,1:3)=[235/255 202/255  141/255];
handles.color_code(12,1:3)=[113/255 230/255  146/255];
handles.color_code(13,1:3)=[95/255 5/255  87/255];
handles.color_code(14,1:3)=[52/255 94/255  52/255];
handles.color_code(15,1:3)=[200/255 230/255  146/255];
handles.color_code(16,1:3)=[95/255 5/255  200/255];
handles.color_code(17,1:3)=[52/255 200/255  52/255];
handles.color_code(18,1:3)=[200/255 2/255  146/255];
handles.color_code(19,1:3)=[200/255 200/255  200/255];
handles.color_code(20,1:3)=[200/255 100/255  200/255];
handles.color_code(21,1:3)=[2/255 2/255  146/255];
handles.color_code(22,1:3)=[160/255 200/255  200/255];
handles.color_code(23,1:3)=[200/255 50/255  50/255];
handles.color_code(24,1:3)=[64/255 61/255  19/255];
handles.color_code(25,1:3)=[0/255 111/255  255/255];
handles.color_code(26,1:3)=[242/255 162/255  12/255];
handles.color_code(27,1:3)=[0.2 0.2 0.2];
handles.color_code(28,1:3)=[0.5 0.5 0.5];
handles.color_code(29,1:3)=[0.8 0.5 0.5];

% INITILIAZE COLOR MAP
handles.current_color=linspace(1, 28, 28)';

handles.color_code_3D(1,1:3)=[1 0 0];
handles.color_code_3D(2,1:3)=[152/255 152/255  152/255];
handles.color_code_3D(3,1:3)=[0 0 1];
handles.color_code_3D(1,1:3)=[1 0 0];
handles.color_code_3D(2,1:3)=[152/255 152/255  152/255];
handles.color_code_3D(3,1:3)=[0 0 1];
handles.color_code_3D(1,1:3)=[1 0 0];
handles.color_code_3D(2,1:3)=[152/255 152/255  152/255];
handles.color_code_3D(3,1:3)=[0 0 1];






% Choose default command line output for gstat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gstat wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gstat_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE COLOR OUTPUTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function launch_gcolors_Callback(hObject, eventdata, handles)

handles.current_color=gcolors(handles.color_code,handles.current_color);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function load_file_Callback(hObject, eventdata, handles)

handles.DATA_CATEGORIES=[];
handles.F=[];
handles.S=[];
handles.Eigenvalue=[];

[handles.FILENAME, handles.PATHNAME] = uigetfile([handles.PATHNAME, '\*.txt'], 'Select the file containing SUMMARY DATA');
[handles.DATA_HEADING,handles.DATA_CATEGORIES,handles.DATA] = load_data_file([handles.PATHNAME,handles.FILENAME],handles.TXT_Col_menu(get(handles.TXT_Col,'value')),1);

% Ed - August 2011.
handles.dataStr = createStruct(handles.DATA_HEADING,handles.DATA_CATEGORIES,handles.DATA);


handles.DATA_HEADING_VAR=['ALL', handles.DATA_HEADING(get(handles.TXT_Col,'value'):size(handles.DATA_HEADING,2))];

set(handles.filename_TXT, 'string',handles.FILENAME(1:max(size(handles.FILENAME(:,:)))-4));


%%%% CREATE VARIABLE MENUS
set(handles.var_meanplot, 'string',handles.DATA_HEADING_VAR);
set(handles.var_meanplot, 'value', 2);

set(handles.varX, 'string',handles.DATA_HEADING_VAR(2:size(handles.DATA_HEADING_VAR,2)));
set(handles.varY, 'string',handles.DATA_HEADING_VAR(2:size(handles.DATA_HEADING_VAR,2)));
set(handles.color_plot_onset, 'string',handles.DATA_HEADING_VAR(2:size(handles.DATA_HEADING_VAR,2)));
set(handles.color_plot_end, 'string',handles.DATA_HEADING_VAR(2:size(handles.DATA_HEADING_VAR,2)));


if isempty(handles.DATA_CATEGORIES)==1
    handles.DATA_HEADING_CAT={'NONE'};
else
    handles.DATA_HEADING_CAT=['NONE', handles.DATA_HEADING(1:get(handles.TXT_Col,'value')-1)];
end

for i=1:size(handles.cat, 2)
    set(handles.cat(i), 'string', handles.DATA_HEADING_CAT);
end




guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN PCA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function load_PCA_OUTPUT_Callback(hObject, eventdata, handles)

[HEADING,handles.DATA_CATEGORIES,handles.Eigenvalue] = load_data_file([handles.PATHNAME,handles.FILENAME(1:size(handles.FILENAME,2)-4), '_EIGENVALUES.txt'],1 ,1);
[HEADING,handles.DATA_CATEGORIES,handles.F] = load_data_file([handles.PATHNAME,handles.FILENAME(1:size(handles.FILENAME,2)-4), '_FACTOR.txt'],1 ,1);
[HEADING,handles.DATA_CATEGORIES,handles.S] = load_data_file([handles.PATHNAME,handles.FILENAME(1:size(handles.FILENAME,2)-4), '_SCORE.txt'],handles.TXT_Col_menu(get(handles.TXT_Col,'value')) ,1);

% create handles.FACTORS
for i=1:size(handles.F,2)
    
    FACTORS(i)={['PC' num2str(i)]};
    
end

set(handles.PC1, 'string', FACTORS);
set(handles.PC2, 'string', FACTORS);
set(handles.PC2, 'value', 2);
set(handles.PC3, 'string', FACTORS);
set(handles.PC3, 'value', 3);
set(handles.N_PC_DISPLAY, 'string', FACTORS);
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN PCA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function run_PCA_Callback(hObject, eventdata, handles)


%[handles.Eigenvalue, handles.F, handles.S]=anfactpc(handles.DATA, get(handles.rotation, 'value'))
[handles.Eigenvalue, handles.F, handles.S]=anfactpcwod(handles.DATA, get(handles.rotation, 'value'))


% create handles.FACTORS
for i=1:size(handles.F,2)
    
    FACTORS(i)={['PC' num2str(i)]};
    
end

set(handles.PC1, 'string', FACTORS);
set(handles.PC2, 'string', FACTORS);
set(handles.PC2, 'value', 2);
set(handles.PC3, 'string', FACTORS);
set(handles.PC3, 'value', 3);
set(handles.N_PC_DISPLAY, 'string', FACTORS);

set(handles.PC_ALL, 'string', FACTORS);

%handles.S=handles.DATA;
%handles.F=handles.DATA;

guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN FLD (Fisher Linear Discriminant)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in run_FLD.
function run_FLD_Callback(hObject, eventdata, handles)
% hObject    handle to run_FLD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cat1 = get(handles.cat1, 'value')-1;
if cat1>0
    [handles.F, handles.S] = FLD_function(handles,cat1);
    guidata(hObject, handles);
else
    errordlg('please select categories for groups')
end



% --- Executes on button press in PCg.
function PCg_Callback(hObject, eventdata, handles)
% hObject    handle to PCg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cat1 = get(handles.cat1, 'value')-1;
if cat1>0
    ref_class = get(handles.MainBasis, 'value');
    group_name = handles.DATA_HEADING_CAT(cat1+1);
    PCAprojections(handles, ref_class, group_name)
else
    errordlg('please select categories for groups')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPRESENT PCA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_2D_Callback(hObject, eventdata, handles)

if isempty(handles.F)==1
    warndlg(['THE PCA ANALYSIS HAS NOT BEEN PERFORMED'], 'NO PCA DATA');
    return
end

% CASE NO CATEGORIES %%%%%%%%%%%%%%%%%%%%%%
if get(handles.cat1,'value')==1
    
    figure(3);plot(handles.S(:,get(handles.PC1, 'value')), handles.S(:,get(handles.PC2, 'value')), 'o', 'markersize', 8, 'color', handles.color_code(1, 1:3), 'markerfacecolor', handles.color_code(1, 1:3));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% CASE ONE CATEGORIE %%%%%%%%%%%%%%%%%%%%%%
if get(handles.cat1,'value')>1 & get(handles.cat2,'value')==1
    
    temp_cat1(1,1)=handles.DATA_CATEGORIES(1,get(handles.cat1, 'value')-1);
    
    for i=1:size(handles.DATA_CATEGORIES,1)
        
        if ismember(temp_cat1(:,1), handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1))==0
            
            temp_cat1=[temp_cat1; handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1)];
            
        end
    end
    
    if size(temp_cat1,1)<=size(handles.color_code, 1)
        
        for i=1:size(temp_cat1,1)
            figure(3);hold on
            plot(handles.S(find(ismember(handles.DATA_CATEGORIES(:, get(handles.cat1, 'value')-1), temp_cat1(i,1))==1), get(handles.PC1, 'value'))...
                , handles.S(find(ismember(handles.DATA_CATEGORIES(:, get(handles.cat1, 'value')-1), temp_cat1(i,1))==1), get(handles.PC2, 'value')),...
                'o', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
            legend(temp_cat1, 'location','EastOutside');
        end
    else
        msgbox(['THE CURRENT SET UP ALLOWS ONLY ', num2str(size(handles.color_code, 1)), ' COLOURS TO BE DISPLAYED']);return
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CASE TWO CATEGORIES %%%%%%%%%%%%%%%%%%%%%%
if get(handles.cat1,'value')>1 & get(handles.cat2,'value')>1
    
    temp_cat1(1,1)=handles.DATA_CATEGORIES(1,get(handles.cat1, 'value')-1);
    for i=1:size(handles.DATA_CATEGORIES,1)
        
        if ismember(temp_cat1(:,1), handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1))==0
            
            temp_cat1=[temp_cat1; handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1)];
            
        end
    end
    
    temp_cat2(1,1)=handles.DATA_CATEGORIES(1,get(handles.cat2, 'value')-1);
    for i=1:size(handles.DATA_CATEGORIES,1)
        
        if ismember(temp_cat2(:,1), handles.DATA_CATEGORIES(i,get(handles.cat2, 'value')-1))==0
            
            temp_cat2=[temp_cat2; handles.DATA_CATEGORIES(i,get(handles.cat2, 'value')-1)];
            
        end
    end
    
    if size(temp_cat1,1)<=size(handles.color_code, 1) & size(temp_cat2,1)<14
        
        nseries=0;
        for i=1:size(temp_cat1,1)
            
            for j=1:size(temp_cat2, 1)
                
                angry=0;toplotdata=[];
                for k=1:size(handles.DATA_CATEGORIES, 1)
                    
                    if find(ismember(handles.DATA_CATEGORIES(k, get(handles.cat1, 'value')-1), temp_cat1(i,1))==1) ...
                            & find(ismember(handles.DATA_CATEGORIES(k, get(handles.cat2, 'value')-1), temp_cat2(j,1))==1)
                        
                        angry=angry+1;
                        toplotdata(angry,1:2)=[handles.S(k,get(handles.PC1, 'value')), handles.S(k,get(handles.PC2, 'value'))];
                        
                    end
                    
                    
                    
                end
                
                
                if isempty(toplotdata)==0;
                    
                    nseries=nseries+1;
                    legendlabel(nseries,:)={[char(temp_cat1(i)), ' ', char(temp_cat2(j))]};
                    
                    figure(3);hold on
                    
                    switch j
                        
                        case 1
                            plot(toplotdata(:,1), toplotdata(:,2), 'o', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 2
                            plot(toplotdata(:,1), toplotdata(:,2), 'd', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 3
                            plot(toplotdata(:,1), toplotdata(:,2), 's', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 4
                            plot(toplotdata(:,1), toplotdata(:,2), 'h', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 5
                            plot(toplotdata(:,1), toplotdata(:,2), 'p', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 6
                            plot(toplotdata(:,1), toplotdata(:,2), '^', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 7
                            plot(toplotdata(:,1), toplotdata(:,2), '<', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 8
                            plot(toplotdata(:,1), toplotdata(:,2), '>', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 9
                            plot(toplotdata(:,1), toplotdata(:,2), 'v', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 10
                            plot(toplotdata(:,1), toplotdata(:,2), '*', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 11
                            plot(toplotdata(:,1), toplotdata(:,2), '+', 'markersize', 11, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 12
                            plot(toplotdata(:,1), toplotdata(:,2), 'x', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                        case 13
                            plot(toplotdata(:,1), toplotdata(:,2), '-', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));
                    end
                    
                end
                
                
            end
        end
        
    else
        
        msgbox(['THE CURRENT SET UP ALLOWS ONLY ', num2str(size(handles.color_code, 1)), ' COLOURS AND 9 SYMBOLS TO BE DISPLAYED']);return
        
    end
    
    legend(legendlabel, 'location','EastOutside');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


set(figure(3), 'position', [360   146   780   552]); grid on;
xlabel(['PC' num2str(get(handles.PC1, 'value')), ' Explained variance:', num2str(handles.Eigenvalue(3, get(handles.PC1, 'value'))), '%'])
ylabel(['PC' num2str(get(handles.PC2, 'value')), ' Explained variance:', num2str(handles.Eigenvalue(3, get(handles.PC2, 'value'))), '%'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPRESENT PCA 3d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_3D_Callback(hObject, eventdata, handles)

if isempty(handles.F)==1
    warndlg(['THE PCA ANALYSIS HAS NOT BEEN PERFORMED'], 'NO PCA DATA');
    return
end

% CASE NO CATEGORIES %%%%%%%%%%%%%%%%%%%%%%
if get(handles.cat1,'value')==1
    
    figure(4);plot3(handles.S(:,get(handles.PC1, 'value')), handles.S(:,get(handles.PC2, 'value')), handles.S(:,get(handles.PC3, 'value')), 'o', 'markersize', 8, 'color', handles.color_code(1, 1:3), 'markerfacecolor', handles.color_code(1, 1:3));
    
    if get(handles.transparence,'value')==1
        alpha(0.6);
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% CASE ONE CATEGORIE %%%%%%%%%%%%%%%%%%%%%%
if get(handles.cat1,'value')>1 & get(handles.cat2,'value')==1
    
    temp_cat1(1,1)=handles.DATA_CATEGORIES(1,get(handles.cat1, 'value')-1);
    for i=1:size(handles.DATA_CATEGORIES,1)
        
        if ismember(temp_cat1(:,1), handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1))==0
            
            temp_cat1=[temp_cat1; handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1)];
            
        end
    end
    
    if size(temp_cat1,1)<=size(handles.color_code, 1)
        
        for i=1:size(temp_cat1,1)
            
            datatoplot=[];
            datatoplot(:,1)=handles.S(find(ismember(handles.DATA_CATEGORIES(:, get(handles.cat1, 'value')-1), temp_cat1(i,1))==1), get(handles.PC1, 'value'));
            datatoplot(:,2)=handles.S(find(ismember(handles.DATA_CATEGORIES(:, get(handles.cat1, 'value')-1), temp_cat1(i,1))==1), get(handles.PC2, 'value'));
            datatoplot(:,3)=handles.S(find(ismember(handles.DATA_CATEGORIES(:, get(handles.cat1, 'value')-1), temp_cat1(i,1))==1), get(handles.PC3, 'value'));
            
            
            % do the fitting
            DATAfitted=gen_data_elliptical_fit(datatoplot);
            %DATAfitted(:,1)=-DATAfitted(:,1);
            %DATAfitted(:,2)=-DATAfitted(:,2);
            [ center, radii, evecs, v ] = ellipsoid_fit( DATAfitted, 0, [] );
            
            % draw fitting:
            nStep=50;
            radii=abs(radii.^2).^0.5;
            stepA=radii(1)/nStep; stepB=radii(2)/nStep; stepC=radii(3)/nStep;
            
            stepA=linspace(center(1)-10*radii(1), center(1)+10*radii(1),100);
            stepB=linspace(center(2)-10*radii(2), center(2)+10*radii(2),100);
            stepC=linspace(center(3)-10*radii(3), center(3)+10*radii(3),100);
            
            [x, y, z]=meshgrid(stepA, stepB, stepC);
            
            Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
                2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
                2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
            figure(4); hold on;
            p = patch( isosurface( x, y, z, Ellipsoid, 1 ) );
            set( p, 'FaceColor', handles.color_code(handles.current_color(i), 1:3), 'EdgeColor', 'none' );
            view( -40, 40 );
            axis vis3d;
            camlight;
            lighting phong;
            legend(temp_cat1, 'location','EastOutside');
            if get(handles.transparence,'value')==2
                alpha(0.6);
            end
            
            figure(6);plot3(datatoplot(:,1), datatoplot(:,2), datatoplot(:,3), 'o', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(handles.current_color(i), 1:3)); hold on
            
            
            grid on
            %view( -70, 40 );
            %%axis vis3d
            %camlight;
            %lighting phong;
            legend(temp_cat1, 'location','EastOutside');
            
            %figure(6);plot3(DATAfitted(:,1), DATAfitted(:,2), DATAfitted(:,3), 'o', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3)); hold on
            %legend(temp_cat1, 'location','EastOutside');
            
            
            
        end
    else
        msgbox(['THE CURRENT SET UP ALLOWS ONLY ', num2str(size(handles.color_code, 1)), ' COLOURS TO BE DISPLAYED']);return
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CASE TWO CATEGORIES %%%%%%%%%%%%%%%%%%%%%%
if get(handles.cat1,'value')>1 & get(handles.cat2,'value')>1
    
    temp_cat1(1,1)=handles.DATA_CATEGORIES(1,get(handles.cat1, 'value')-1);
    for i=1:size(handles.DATA_CATEGORIES,1)
        
        if ismember(temp_cat1(:,1), handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1))==0
            
            temp_cat1=[temp_cat1; handles.DATA_CATEGORIES(i,get(handles.cat1, 'value')-1)];
            
        end
    end
    
    temp_cat2(1,1)=handles.DATA_CATEGORIES(1,get(handles.cat2, 'value')-1);
    for i=1:size(handles.DATA_CATEGORIES,1)
        
        if ismember(temp_cat2(:,1), handles.DATA_CATEGORIES(i,get(handles.cat2, 'value')-1))==0
            
            temp_cat2=[temp_cat2; handles.DATA_CATEGORIES(i,get(handles.cat2, 'value')-1)];
            
        end
    end
    
    
    if size(temp_cat1,1)<=size(handles.color_code, 1) & size(temp_cat2,1)<16
        
        nseries=0;
        for i=1:size(temp_cat1,1)
            
            for j=1:size(temp_cat2, 1)
                
                angry=0;toplotdata=[];
                for k=1:size(handles.DATA_CATEGORIES, 1)
                    
                    if find(ismember(handles.DATA_CATEGORIES(k, get(handles.cat1, 'value')-1), temp_cat1(i,1))==1) ...
                            & find(ismember(handles.DATA_CATEGORIES(k, get(handles.cat2, 'value')-1), temp_cat2(j,1))==1)
                        
                        angry=angry+1;
                        toplotdata(angry,1:3)=[handles.S(k,get(handles.PC1, 'value')), handles.S(k,get(handles.PC2, 'value')), handles.S(k,get(handles.PC3, 'value'))];
                        
                    end
                    
                end
                
                
                if isempty(toplotdata)==0;
                    
                    nseries=nseries+1;
                    legendlabel(nseries,:)={[char(temp_cat1(i)), ' ', char(temp_cat2(j))]};
                    
                    switch j
                        
                        case 1
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), 'o', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 2
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), 'd', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                            
                        case 3
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), 's', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 4
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), 'h', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 5
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), 'p', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 6
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), '^', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 7
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), '<', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 8
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), '>', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 9
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), 'v', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 10
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), '>', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                        case 11
                            
                            figure(4);plot3(toplotdata(:,1), toplotdata(:,2), toplotdata(:,3), 'v', 'markersize', 8, 'color', 'k', 'markerfacecolor', handles.color_code(i, 1:3));hold on
                            
                    end
                end
                
                
            end
        end
        
    else
        msgbox(['THE CURRENT SET UP ALLOWS ONLY ', num2str(size(handles.color_code, 1)), ' COLOURS AND 9 SYMBOLS TO BE DISPLAYED']);return
    end
    
    legend(legendlabel, 'location','EastOutside');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


set(figure(4), 'position', [360   146   780   552]); grid on;
xlabel(['PC' num2str(get(handles.PC1, 'value')), ' Explained variance:', num2str(handles.Eigenvalue(3, get(handles.PC1, 'value'))), '%'])
ylabel(['PC' num2str(get(handles.PC2, 'value')), ' Explained variance:', num2str(handles.Eigenvalue(3, get(handles.PC2, 'value'))), '%'])
zlabel(['PC' num2str(get(handles.PC3, 'value')), ' Explained variance:', num2str(handles.Eigenvalue(3, get(handles.PC3, 'value'))), '%'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPRESENT PCA FACTORS COLOR-CODED
%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%
function gene_chip_Callback(hObject, eventdata, handles)

if isempty(handles.F)==1
    warndlg(['THE PCA ANALYSIS HAS NOT BEEN PERFORMED'], 'NO PCA DATA');
    return
end

if get(handles.REORDER_DATA, 'value')>1
    [data, variable_rank_index]=sortrows(handles.F, get(handles.REORDER_DATA, 'value')-1);
else
    data=handles.F; variable_rank_index=linspace(1,size(handles.F, 1),size(handles.F, 1))';
end

X=linspace(1,get(handles.N_PC_DISPLAY,'value')+1,get(handles.N_PC_DISPLAY,'value')+1)';
Y=linspace(1,size(handles.F, 1)+1,size(handles.F, 1)+1)';
C=[data(:, 1:get(handles.N_PC_DISPLAY,'value')+1); data(1, 1:get(handles.N_PC_DISPLAY,'value')+1)];

figure(9); set(gcf,'color','w');pcolor(X,Y,C)

%shading interp
set(gca,'XTick',linspace(1.5, 0.5+get(handles.N_PC_DISPLAY,'value'), get(handles.N_PC_DISPLAY,'value')));
for i=1:get(handles.N_PC_DISPLAY,'value');
    xlabels(i,:)={['PC',  num2str(i), ' (' num2str(round(handles.Eigenvalue(3, i))) '%)']};
end
set(gca,'XTickLabel',xlabels,'FontSize', 12, 'FontWeight','bold');

%handles.DATA_HEADING_VAR=handles.DATA_CATEGORIES(:,1)';
set(gca,'YTick',linspace(1, size(data,1), size(data,1)));
DATA_HEADING_VAR=handles.DATA_HEADING_VAR(2:size(handles.DATA_HEADING_VAR, 2));
set(gca,'YTickLabel',DATA_HEADING_VAR(variable_rank_index), 'FontSize', 6, 'FontWeight','normal');

switch get(handles.color_map_choice, 'value')
    
    case 1
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [255/255 124/255 128/255], [255/255 29/255 29/255]);
    case 2
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255],[255/255 255/255 0/255], [252/255 252/255 161/255], [255/255 124/255 128/255], [255/255 29/255 29/255]);
    case 3
        C = usercolormap([0/255 255/255 0/255], [140/255 255/255 140/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255]);
    case 4
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255]);
    case 5
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [234/255 248/255 252/255], [1 1 1], [1 1 1],[1 1 1], [229/255 209/255 218/255 ], [255/255 124/255 128/255], [255/255 29/255 29/255]);
    case 6
        C = usercolormap([69/255 69/255 69/255], [152/255 152/255 152/255], [200/255 200/255 200/255], [1 1 1], [1 1 1],[1 1 1], [229/255 209/255 218/255 ], [255/255 124/255 128/255], [255/255 29/255 29/255]);
end

%C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255])
%C = usercolormap([0/255 255/255 0/255], [140/255 255/255 140/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255])
colormap(C);
colorbar('location','EastOutside');

set(figure(9), 'position', [291    36   120+get(handles.N_PC_DISPLAY,'value')*120   690])
title(['PCA; ', num2str(size(DATA_HEADING_VAR,2)) 'VARIABLES -- ', handles.FILENAME(1:max(size(handles.FILENAME(:,:)))-4)]), , 'FontSize', 32, 'FontWeight','normal'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPRESENT PCA PCA FACTORS COLOR-CODED FROM MULTIPLE ANIMALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function color_plot_Callback(hObject, eventdata, handles)

if get(handles.color_plot_onset,'value')>get(handles.color_plot_end,'value')
    warndlg(['THE FIRST SELECTED COLUMN IS LOCATED AFTER THE LAST SELECTED COLUMN'], 'VARIABLE SELECTION ERROR');
    return
    
end

datatoplot=[handles.DATA(:, get(handles.color_plot_onset,'value'):get(handles.color_plot_end,'value')), handles.DATA(:, get(handles.color_plot_end,'value'))];
datatoplot(size(datatoplot,1)+1,:)=datatoplot(size(datatoplot,1),:);

figure(9);pcolor(datatoplot); set(gcf,'color','w');
ncol=get(handles.color_plot_end,'value')-get(handles.color_plot_onset,'value');

%shading interp
set(gca,'XTick',linspace(1.5, 0.5+ncol+1, ncol+1));
for i=get(handles.color_plot_onset,'value'):get(handles.color_plot_end,'value')
    xlabels(i-get(handles.color_plot_onset,'value')+1,:)=handles.DATA_HEADING(get(handles.TXT_Col,'value')+i-1);
end

set(gca,'XTickLabel',xlabels,'FontSize', 5, 'FontWeight','bold');

set(gca,'YTick',linspace(1, size(handles.DATA,1), size(handles.DATA,1)));
DATA_CATEGORIES=handles.DATA_CATEGORIES(1:size(handles.DATA_CATEGORIES, 1));
set(gca,'YTickLabel',DATA_CATEGORIES, 'FontSize', 5, 'FontWeight','normal');

switch get(handles.color_map_choice, 'value')
    
    case 1
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [255/255 124/255 128/255], [255/255 29/255 29/255])
    case 2
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255],[255/255 255/255 0/255], [252/255 252/255 161/255], [255/255 124/255 128/255], [255/255 29/255 29/255])
    case 3
        C = usercolormap([0/255 255/255 0/255], [140/255 255/255 140/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255])
    case 4
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255])
    case 5
        C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [234/255 248/255 252/255], [1 1 1], [1 1 1],[1 1 1], [229/255 209/255 218/255 ], [255/255 124/255 128/255], [255/255 29/255 29/255])
    case 6
        C = usercolormap([69/255 69/255 69/255], [152/255 152/255 152/255], [200/255 200/255 200/255], [1 1 1], [1 1 1],[1 1 1], [229/255 209/255 218/255 ], [255/255 124/255 128/255], [255/255 29/255 29/255])
end

colormap(C);
colorbar('location','EastOutside');

set(figure(9), 'position', [291    36   220+get(handles.N_PC_DISPLAY,'value')*220   690]);
%title([handles.FILENAME(1:max(size(handles.FILENAME(:,:)))-4)], 'FontSize', 32, 'FontWeight','normal');
%title([''], 'FontSize', 16, 'FontWeight','normal');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HISTO PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function histo_plot_Callback(hObject, eventdata, handles)

if get(handles.var_meanplot, 'value')==1
    
    for i=1:size(handles.DATA, 2)
        
        plotting=histo_plot_function(...
            handles.DATA, ...
            i, ...
            handles.DATA_HEADING(get(handles.TXT_Col,'value'):size(handles.DATA_HEADING,2)), ...
            handles.DATA_CATEGORIES, ...
            handles.DATA_HEADING(1:get(handles.TXT_Col,'value')-1), ...
            get(handles.cat1, 'value'), ...
            get(handles.cat2, 'value'),...
            get(handles.average_by, 'value'), ...
            get(handles.error_type, 'value'), ...
            handles.color_code, ...
            4+i)
    end
else
    
    plotting=histo_plot_function(handles.DATA, get(handles.var_meanplot, 'value')-1, handles.DATA_HEADING(get(handles.TXT_Col,'value'):size(handles.DATA_HEADING,2)), handles.DATA_CATEGORIES, handles.DATA_HEADING(1:get(handles.TXT_Col,'value')-1), get(handles.cat1, 'value'), get(handles.cat2, 'value'),get(handles.average_by, 'value'), get(handles.error_type, 'value'), handles.color_code, 5)
    
end

% --- Evaluate statistics
col = get(handles.var_meanplot, 'value');
data_name = handles.DATA_HEADING_VAR(col);

groups_col = get(handles.cat1, 'value')-1;
group_name = handles.DATA_HEADING_CAT(  groups_col + 1 );

save test_groups
stats_function(handles.dataStr, data_name, group_name);



function extract_groups(handles, cat1)


% --- Determine classes and data points belonging to each class
classes = unique(handles.DATA_CATEGORIES(:,cat1))

for Nclasses = 1:size(classes,1)
    
    index_tmp = [];
    for kl = 1:size(handles.DATA,1)
        if( strcmp( handles.DATA_CATEGORIES{kl,cat1} , classes(Nclasses)) )
            index_tmp = [index_tmp , kl];
        end
    end
    
    index{Nclasses}=index_tmp;
end
index



% --- Determine animals
col_anim_id = 0;
for klp = 1:length(handles.DATA_HEADING_CAT)
    if strcmp( handles.DATA_HEADING_CAT(1,klp),'animal') == 1
        col_anim_id =  klp;
    end
end
col_anim_id;



if ( col_anim_id > 0 )
    
    
    % --- Index for each animal
    anims = unique(handles.DATA_CATEGORIES(:,col_anim_id-1))
    
    clear index_anims
    mean_anims = [];
    for Nanims = 1:size(anims,1)
        
        index_tmp = [];
        for kl = 1:size(handles.S,1)
            if( strcmp( handles.DATA_CATEGORIES{kl,col_anim_id-1} , anims(Nanims)) )
                index_tmp = [index_tmp , kl];
            end
        end
        
        index_anims{Nanims}=index_tmp;
        mean_anims = [mean_anims ; mean( handles.DATA(index_tmp,:) )];
    end
    index_anims
    mean_anims;
    
    
    
    % --- Determine belonging of animals to groups
    group_anim = [];
    
    % Go through each group
    for kg = 1:length(index)
        
        % Look at each animal
        for ka = 1:length(index_anims)
            
            matAnim = index_anims{ka};
            if ( find(index{kg} == matAnim(1)) > 0 )
                % animal belongs to group
                %group_anim = [group_anim ; {kg , anims{ka}}];
                group_anim = [group_anim ; [kg , ka]];
            end
        end
    end
    group_anim
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORRELATION PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotXY_Callback(hObject, eventdata, handles)

plotting=correlation_plot_function(handles.DATA, get(handles.varX, 'value'), get(handles.varY, 'value'), handles.DATA_HEADING(get(handles.TXT_Col,'value'):size(handles.DATA_HEADING,2)), handles.DATA_CATEGORIES, handles.DATA_HEADING(1:get(handles.TXT_Col,'value')-1), get(handles.cat1, 'value'), get(handles.cat2, 'value'),get(handles.fitting_order, 'value'), handles.color_code)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORRELATION PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_pca_output_Callback(hObject, eventdata, handles)

score_headers=handles.DATA_HEADING(1:get(handles.TXT_Col,'value')-1);

for i=1:size(handles.S, 2)
    score_headers(get(handles.TXT_Col,'value')-1+i)={['PC' num2str(i)]};
end

success = save_file([handles.PATHNAME, handles.FILENAME(1:size(handles.FILENAME,2)-4), '_SCORE.txt'], score_headers, handles.DATA_CATEGORIES, handles.S);

factor_headers(1)={['VARIABLES']};
for i=1:size(handles.F, 2)
    factor_headers(1+i)={['PC' num2str(i)]};
end
success = save_file([handles.PATHNAME, handles.FILENAME(1:size(handles.FILENAME,2)-4), '_FACTOR.txt'], factor_headers, handles.DATA_HEADING(get(handles.TXT_Col,'value'):size(handles.DATA_HEADING,2))', handles.F);

eigenvalue_headers(1)={['PARAMETERS']};
eigenvalue_Col_headers(1)={['PC #']};
eigenvalue_Col_headers(2)={['Eigenvalue']};
eigenvalue_Col_headers(3)={['Explained Variance (%)']};
eigenvalue_Col_headers(4)={['Cumulated Explained Variance (%)']};

for i=1:size(handles.Eigenvalue, 2)
    eigenvalue_headers(i+1)={['PC' num2str(i)]};
end
success = save_file([handles.PATHNAME, handles.FILENAME(1:size(handles.FILENAME,2)-4), '_EIGENVALUES.txt'], eigenvalue_headers, eigenvalue_Col_headers', handles.Eigenvalue);

msgbox('ALL THE SUMMARY FILES HAVE BEEN WRITTEN SUCCESSFULLY');








% --- JUNK
function cat1_Callback(hObject, eventdata, handles)

cat1 = get(handles.cat1, 'value')-1;
classes = unique(handles.DATA_CATEGORIES(:,cat1));
set(handles.MainBasis, 'string', classes);



function cat1_CreateFcn(hObject, eventdata, handles)
function TXT_Col_Callback(hObject, eventdata, handles)
function TXT_Col_CreateFcn(hObject, eventdata, handles)
function filename_TXT_Callback(hObject, eventdata, handles)
function filename_TXT_CreateFcn(hObject, eventdata, handles)
function error_type_Callback(hObject, eventdata, handles)
function error_type_CreateFcn(hObject, eventdata, handles)
function var_meanplot_Callback(hObject, eventdata, handles)
function var_meanplot_CreateFcn(hObject, eventdata, handles)
function pushbutton8_Callback(hObject, eventdata, handles)
function cat2_Callback(hObject, eventdata, handles)
function cat2_CreateFcn(hObject, eventdata, handles)
function cat3_Callback(hObject, eventdata, handles)
function cat3_CreateFcn(hObject, eventdata, handles)
function cat4_Callback(hObject, eventdata, handles)
function cat4_CreateFcn(hObject, eventdata, handles)
function rotation_Callback(hObject, eventdata, handles)
function rotation_CreateFcn(hObject, eventdata, handles)
function popupmenu21_Callback(hObject, eventdata, handles)
function popupmenu21_CreateFcn(hObject, eventdata, handles)
function pushbutton15_Callback(hObject, eventdata, handles)
function pushbutton14_Callback(hObject, eventdata, handles)
function pushbutton13_Callback(hObject, eventdata, handles)
function pushbutton12_Callback(hObject, eventdata, handles)
function pushbutton16_Callback(hObject, eventdata, handles)
function pushbutton17_Callback(hObject, eventdata, handles)
function PC1_CreateFcn(hObject, eventdata, handles)
function PC2_Callback(hObject, eventdata, handles)
function PC2_CreateFcn(hObject, eventdata, handles)
function PC3_Callback(hObject, eventdata, handles)
function PC3_CreateFcn(hObject, eventdata, handles)
function pushbutton11_Callback(hObject, eventdata, handles)
function N_PC_DISPLAY_Callback(hObject, eventdata, handles)
function N_PC_DISPLAY_CreateFcn(hObject, eventdata, handles)
function REORDER_DATA_Callback(hObject, eventdata, handles)
function REORDER_DATA_CreateFcn(hObject, eventdata, handles)
function varY_Callback(hObject, eventdata, handles)
function varY_CreateFcn(hObject, eventdata, handles)
function varX_CreateFcn(hObject, eventdata, handles)
function varX_Callback(hObject, eventdata, handles)
function fitting_order_Callback(hObject, eventdata, handles)
function fitting_order_CreateFcn(hObject, eventdata, handles)
function color_plot_onset_Callback(hObject, eventdata, handles)
function color_plot_onset_CreateFcn(hObject, eventdata, handles)
function color_plot_end_CreateFcn(hObject, eventdata, handles)
function color_plot_end_Callback(hObject, eventdata, handles)
function color_map_choice_Callback(hObject, eventdata, handles)
function color_map_choice_CreateFcn(hObject, eventdata, handles)
function PC_ALL_Callback(hObject, eventdata, handles)
function PC_ALL_CreateFcn(hObject, eventdata, handles)
function average_by_Callback(hObject, eventdata, handles)
function average_by_CreateFcn(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESET MULTIPLE RAT DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reset_DATAALL_Callback(hObject, eventdata, handles)

handles.N_all=0;
handles.DATA_ALL=[];
handles.F_ALL=[];
handles.S_ALL=[];
handles.Eigenvalue_ALL=[];
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KEEP  MULTIPLE RAT DATA IN MEMORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function keep_data_Callback(hObject, eventdata, handles)

handles.N_all=handles.N_all+1;
handles.DATA_ALL=[handles.DATA_ALL; handles.DATA];
handles.F_ALL(:,:,handles.N_all)=handles.F(:,1:10);
handles.Eigenvalue_ALL(:,:,handles.N_all)=handles.Eigenvalue(:,1:10);

guidata(hObject, handles);

warndlg(['CURRENT DATABASE INCLUDES DATA FROM ' num2str(handles.N_all) ' DATASET(S)'], '# DATA');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MULTIPLE DATA IN COLOR CODED PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PLOT_ALL_Callback(hObject, eventdata, handles)

if size(handles.F_ALL,3)<2
    warndlg(['NOT ENOUGH DATA'], 'NO PCA DATA');
    return
end

%PREPARE ALL DATA FROM ONE PC
data=[];
for i=1:size(handles.F_ALL, 3)
    
    %correct = inputdlg(['DATASET #' char(num2str(i)) ' -- CHANGE AXIS TO: [ENTER IF NOT NEEDED]'],'INVERSE PC SIGN')
    
    data(:,i)=handles.F_ALL(:,get(handles.PC_ALL,'value'),i);
    
    %if isempty(char(correct))==0
    %    data(:,i)=handles.F_ALL(:,str2num(char(correct)),i);
    %else
    %    data(:,i)=handles.F_ALL(:,get(handles.PC_ALL,'value'),i);
    %end
end


col=0;
while isempty(char(col))==0
    col = inputdlg('ENTER THE DATASET # THAT NEED TO BE INVERSED [ENTER IF NOT NEEDED]','INVERSE PC SIGN')
    if isempty(char(col))==0
        data(:,str2num(char(col)))=-data(:,str2num(char(col)));
    end
end

ave_type=2 % true average (2) PCA on all data (1) true average on ABS VALUES (3)

switch ave_type
    
    case 1
        
        % RUN PCA ON ALL DATA
        [trash, F, trash]=anfactpcwod(handles.DATA_ALL, get(handles.rotation, 'value'))
        data(:,size(data, 2)+1)=F(:,get(handles.PC_ALL,'value'));
        data(:,size(data, 2)+1)=F(:,get(handles.PC_ALL,'value'));
        
    case 2
        
        % RUN PCA ON ALL DATA
        data(:,size(data, 2)+1)=mean(data(:,:),2);
        data(:,size(data, 2)+1)=mean(data(:,:),2);
        
    case 3
        
        % RUN PCA ON ALL DATA
        data(:,size(data, 2)+1)=mean(abs(data(:,:)),2);
        data(:,size(data, 2)+1)=mean(abs(data(:,:)),2);
end



variable_rank_index=linspace(1,size(handles.F_ALL, 1),size(handles.F_ALL, 1))';
X=linspace(1,size(handles.F_ALL, 3)+2,size(handles.F_ALL, 3)+2)';
Y=linspace(1,size(handles.F_ALL, 1)+1,size(handles.F_ALL, 1)+1)';
C=[data(:, 1:size(handles.F_ALL, 3)+2); data(1, 1:size(handles.F_ALL, 3)+2)];

%COLOR-CODED PLOT
figure(99);pcolor(X,Y,C)

%shading interp
set(gca,'XTick',linspace(1.5, 0.5+size(handles.F_ALL, 3)+1, size(handles.F_ALL, 3)+1));
for i=1:size(handles.F_ALL, 3);
    xlabels(i,:)={['#',  num2str(i), ' (' num2str(round(handles.Eigenvalue_ALL(3,get(handles.PC_ALL,'value') ,i))) '%)']};
end
xlabels(size(handles.F_ALL, 3)+1,:)={['MEAN']};

set(gca,'XTickLabel',xlabels,'FontSize', 12, 'FontWeight','bold');

%handles.DATA_HEADING_VAR=handles.DATA_CATEGORIES(:,1)';
set(gca,'YTick',linspace(1, size(data,1), size(data,1)));
DATA_HEADING_VAR=handles.DATA_HEADING_VAR(2:size(handles.DATA_HEADING_VAR, 2));
set(gca,'YTickLabel',DATA_HEADING_VAR(variable_rank_index), 'FontSize', 5, 'FontWeight','normal');

%C = usercolormap([50/255 70/255 255/255], [102/255 153/255 255/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255])
C = usercolormap([0/255 255/255 0/255], [140/255 255/255 140/255], [0.5 0.5 0.5], [0.25 0.25 0.25], [0 0 0],[0.25 0.25 0.25], [0.5 0.5 0.5], [255/255 124/255 128/255], [255/255 29/255 29/255])
colormap(C);
colorbar('location','EastOutside');

titre = inputdlg('ENTER A TITLE','TITTLE')
set(figure(99), 'position', [291    36   120+get(handles.N_PC_DISPLAY,'value')*120   690])
title(['PCA; ', num2str(size(DATA_HEADING_VAR,2)) 'VARIABLES -- ', char(titre)]), , 'FontSize', 32, 'FontWeight','normal'


% --- Executes on button press in create_movie.
function create_movie_Callback(hObject, eventdata, handles)
result=video_3D_plots(handles.FILENAME, 30, 230, 5)
%filename, debut, fin, increment)

% --- Executes on selection change in transparence.
function transparence_Callback(hObject, eventdata, handles)
% hObject    handle to transparence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns transparence contents as
% cell array
%        contents{get(hObject,'Value')} returns selected item from transparence


% --- Executes during object creation, after setting all properties.
function transparence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transparence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MainBasis.
function MainBasis_Callback(hObject, eventdata, handles)
% hObject    handle to MainBasis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MainBasis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MainBasis


% --- Executes during object creation, after setting all properties.
function MainBasis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainBasis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function dataStr = createStruct(DATA_HEADING, DATA_CATEGORIES, DATA)
%% Create a structure with all the data
% -----------------------------------------------------------------------
% Use: dataStr.(field)
% The first N colums are organised by (1) raw data, (2) elems (unique
% elements) and (3) their corresponding indexing (to access them easily);
% -----------------------------------------------------------------------



% ***** Fist N colums with characteristics of data point *****

for k = 1:size(DATA_CATEGORIES,2)
    
    % --- Raw data
    heading = [regexprep( DATA_HEADING{k}, {' ','%','=','-','&','$'}, {'','perc','','','',''} )]; %remove weird symbols
    data_column = DATA_CATEGORIES(:,k);
    % store
    dataStr.(char(heading)).rawdata = data_column;
    
    
    % --- Non-repeated elements
    elems = unique(DATA_CATEGORIES(:,k));
    % store
    dataStr.(char(heading)).elems = elems;
    
    
    clear index;
    % --- Index of appearance of each elem
    for Nelems = 1:length(elems)
        
        index_tmp = [];
        for kl = 1:length(data_column)
            if( strcmp( data_column(kl) , elems(Nelems)) )
                index_tmp = [index_tmp , kl];
            end
        end
        
        index{Nelems}=index_tmp;
    end
    
    % store
    dataStr.(char(heading)).index = index;
end



% ***** Values of data point  *****

for k = size(DATA_CATEGORIES,2)+1 : size(DATA,2)+size(DATA_CATEGORIES,2)
    heading = [regexprep( DATA_HEADING{k}, {' ','%','=','-','&','$'}, {'','perc','','','',''} )]; %remove weird symbols
    dataStr.(char(heading)) = DATA(:,k-size(DATA_CATEGORIES,2));
end


dataStr;






function stats_function(dataStr, data_name, group_name)
%% Statistical analysis for data, organised in the desired groups 


 %remove weird symbols from data
data_name = regexprep( data_name, {' ','%','=','-','&','$'}, {'','perc','','','',''} );
group_name = regexprep( group_name, {' ','%','=','-','&','$'}, {'','perc','','','',''} ); 

% Get data and names into 'useable' variables
dataVals = dataStr.(char(data_name));
elems_group = dataStr.(char(group_name)).elems;

% Correspondence with animals
corr = arrange2groups(dataStr, group_name, 'animal');

% To store
groupR = [];
X = [];
errors = [];


for kl = 1:length(elems_group)
    
    % Display name of group
    elems_group{kl}
    
    % extract indexes for animals in this group
    group_animal_indexes = corr.(char(['index4elem',num2str(kl)])).index
    
    for ka = 1:length(group_animal_indexes)
        
        if isempty( group_animal_indexes{ka} ) == 0
            
            % Display name of animal
            corr.(char(['index4elem',num2str(kl)])).elem_name(ka)
            
            % get values from data
            vals = dataVals(group_animal_indexes{ka});
            
            % stats for the animal
            X = [X , mean(vals) ];
            
            % store corresponding group name
            groupR= [groupR ; elems_group(kl)];
        end
    end
    
    %disp('paused...'); pause()
end

groupR
X
errors

% _____________ One-way Anova followed by post-hoc analysis
alpha = 0.05;

figure(23); clf; set(gcf,'color','w')
[P,ANOVATAB,STATS]=anova1(X,groupR,'off');
[c,m,h] = multcompare(STATS,alpha,'on','bonferroni');
set(gca,'Fontsize',14)
title([char(data_name),'. alpha = ', num2str(alpha),' (anova P=',num2str(P),')']);

%KRUSKALWALLIS(X,groupR,'on')

 % ________ Barplots 
 %{
hold off;
figure(33)
%bar(X,errors); hold on
errorb(X,errors,'top')
legend(char(groups(1)),char(groups(2)),char(groups(3)),char(groups(4)))
set(gca,'fontsize',16)
set(gca,'XtickLabel',[{'left'};{'right'};{'Bilateral'}])
box off
ylabel('Fiber Density','fontsize',16)
%}
