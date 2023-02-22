function varargout = LIMB_DIALOGUE(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LIMB_DIALOGUE_OpeningFcn, ...
                   'gui_OutputFcn',  @LIMB_DIALOGUE_OutputFcn, ...
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



function LIMB_DIALOGUE_OpeningFcn(hObject, eventdata, handles, varargin)

handles.gait_type=varargin{1};

if handles.gait_type == 1 % bipedal case -> disable forelimb buttons
    set(handles.BNlimbs_LFL,'Enable','off');
    set(handles.BNlimbs_RFL,'Enable','off');
end

handles.output = 1;
guidata(hObject, handles);

uiwait

function varargout = LIMB_DIALOGUE_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on button press in BNlimbs_LHL.
function BNlimbs_LHL_Callback(hObject, eventdata, handles)
handles.output=1;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in BNlimbs_RHL.
function BNlimbs_RHL_Callback(hObject, eventdata, handles)
handles.output=2;
guidata(hObject, handles);
uiresume(handles.figure1);

function BNlimbs_LFL_Callback(hObject, eventdata, handles)
handles.output=3;
guidata(hObject, handles);
uiresume(handles.figure1);

function BNlimbs_RFL_Callback(hObject, eventdata, handles)
handles.output=4;
guidata(hObject, handles);
uiresume(handles.figure1);
