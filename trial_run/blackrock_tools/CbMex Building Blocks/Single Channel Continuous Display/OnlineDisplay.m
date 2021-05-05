function varargout = OnlineDisplay(varargin)
% ONLINEDISPLAY MATLAB code for OnlineDisplay.fig
%      ONLINEDISPLAY, by itself, creates a new ONLINEDISPLAY or raises the existing
%      singleton*.
%
%      H = ONLINEDISPLAY returns the handle to a new ONLINEDISPLAY or the handle to
%      the existing singleton*.
%
%      ONLINEDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONLINEDISPLAY.M with the given input arguments.
%
%      ONLINEDISPLAY('Property','Value',...) creates a new ONLINEDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OnlineDisplay_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OnlineDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OnlineDisplay

% Last Modified by GUIDE v2.5 28-Jul-2014 08:41:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OnlineDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @OnlineDisplay_OutputFcn, ...
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


% --- Executes just before OnlineDisplay is made visible.
function OnlineDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OnlineDisplay (see VARARGIN)

% Choose default command line output for OnlineDisplay
handles.output = hObject;

% --- Begin My Code ---

% Create a timer object that will be used to grab data and refresh
% analysis/plotting
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', 0.1, ...                      % Initial period is 100 ms
    'TimerFcn', {@updateDisplay,hObject}, ... % callback function.  Pass the figure handle
    'StartFcn', {@startTimer,hObject}, ...
    'StopFcn',  {@stopTimer,hObject})     % callback to execute when timer starts


handles.cbmexStatus = 'closed';

% Update handles structure
guidata(hObject, handles);

clc
clear all

% UIWAIT makes OnlineDisplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OnlineDisplay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ----------------------------------------------------------------------- %
% ----                                                                --- %
% ----        Figure Objects Create and Callback Functions            --- %
% ----                                                                --- %
% ----------------------------------------------------------------------- %

% --- Executes on button press in cmd_cbmexOpen.
function cmd_cbmexOpen_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_cbmexOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use a TRY-CATCH in case cbmex is already open.  If you try to open it
% when it's already open, Matlab throws a 'MATLAB:unassignedOutputs'
% MException.
try
    cbmex('open');
catch ME
    if strcmp(ME.identifier,'MATLAB:unassignedOutputs')
        % Dont need to do anything because cbmex is already open and it
        % already sends a message stating that
    else
        disp(ME)
    end
end
handles.cbmexStatus = 'open';

cbmex('trialconfig',1,'absolute')
pause(0.1)

% Acquire some data to get channel information.  Determine which channels
% are enabled
[spikeEvents, time, continuousData] = cbmex('trialdata',1);
handles.channelList = [continuousData{:,1}];
% set channel popup meno to hold channels
set(handles.pop_channels,'String',handles.channelList);

% Set the Start/Stop toggle button to stopped state (String is 'Start' and
% Value is 1)
set(handles.tgl_StartStop,'String','Start', 'Value',1)

guidata(hObject,handles)

% --- Executes on button press in cmd_cbmexClose.
function cmd_cbmexClose_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_cbmexClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cbmex('close')
handles.cbmexStatus = 'closed';
guidata(hObject,handles)

function txt_display_Callback(hObject, eventdata, handles)
% hObject    handle to txt_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_display as text
%        str2double(get(hObject,'String')) returns contents of txt_display as a double
settingChange(hObject)

% --- Executes during object creation, after setting all properties.
function txt_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tgl_StartStop.
function tgl_StartStop_Callback(hObject, eventdata, handles)
% hObject    handle to tgl_StartStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tgl_StartStop

handles = guidata(hObject);

% if Start
if get(hObject,'Value') == 0
    
    % Check to make sure cbmex connection is open
    if strcmp(handles.cbmexStatus,'closed')
        errordlg('No cbmex connection.  Open connection before starting','Not Connected')
        return
    end
    
    set(hObject,'String','Stop');

    % This starts the timer and also executes the StartFnc which grabs the
    % data, creates the buffer and plots the first bit of data
    start(handles.timer)
    
% Stop
else
    set(hObject,'String','Start')
    stop(handles.timer)
end

% --- Executes on selection change in pop_channels.
function pop_channels_Callback(hObject, eventdata, handles)
% hObject    handle to pop_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_channels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_channels
settingChange(hObject)

% --- Executes during object creation, after setting all properties.
function pop_channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cbmex('close')
stop(handles.timer)
delete(handles.timer)
% Hint: delete(hObject) closes the figure
delete(hObject);


% ----------------------------------------------------------------------- %
% ----                                                                --- %
% ----          Main Loop, Runs every time the timer fires            --- %
% ----                                                                --- %
% ----------------------------------------------------------------------- %
function updateDisplay(hObject, eventdata, hfigure)
try
    
    handles = guidata(hfigure);
    if strcmp(handles.cbmexStatus,'closed')
        stop(handles.timer)
    end
    
    [events, time, continuousData] = cbmex('trialdata',1);

    if isempty(continuousData)
        return
    end
    newContinuousData = continuousData{handles.channelIndex,3};
    handles.rawDataBuffer = cycleBuffer(handles.rawDataBuffer, newContinuousData);
    handles.lastSampleProcTime = ...
        time*30000 + length(newContinuousData) * 30000/handles.fSample - 1;

    guidata(hfigure,handles)

    % update YData of ax_rawData
    set(handles.h_rawDataTrace,'YData',handles.rawDataBuffer)

    guidata(hfigure,handles)

catch ME
    getReport(ME)
    keyboard
end
    
% ----------------------------------------------------------------------- %
% ----                                                                --- %
% ----                      Timer Start Function                      --- %
% ----                                                                --- %
% ----------------------------------------------------------------------- %

% Runs once when timer starts.  It initializes plot and buffer and
% accommodates any new selection by user.
function  startTimer(hObject, eventdata, hfigure)
% Put the whole function in a try-catch block.  This makes debugging much
% easier because it captures the error and displays a report to the Matlab
% Command Window

try
    handles = guidata(hfigure);

    % Check which channel is selected and get some data to plot
    handles.channelIndex = get(handles.pop_channels,'Value');

    % get data from Central
    [events, time, continuousData] = cbmex('trialdata',1);
    
    % Check to make sure continuous sampling is enabled on at least one
    % channel
    if isempty(continuousData)
        errordlg(['Continuous acquisition not enabled.', ...
            'Select a sampling rate in Hardware Configuration'], ...
            'No Continuous Data')
        return
    end
    newContinuousData = continuousData{handles.channelIndex,3};
    handles.fSample = continuousData{handles.channelIndex,2};
    
    % Now that we know the sampling rate of the selected channel,
    % Create raw data buffer of zeros of the correct length
    handles.bufferSize = str2double(get(handles.txt_display,'String')) * handles.fSample;
    handles.rawDataBuffer = zeros(handles.bufferSize,1);

    % keep track of the proc time of the most recent data point.  This will
    % help if you want to match spike times with points in the buffer.
    % 'time' is the time at the first data point of the new chunk of
    % continuous data in seconds.
    handles.lastSampleProcTime = ...
        time*30000 + length(newContinuousData) * 30000/handles.fSample - 1;

    handles.rawDataBuffer = cycleBuffer(handles.rawDataBuffer, newContinuousData);
    xValues = linspace(-handles.bufferSize/handles.fSample,0,handles.bufferSize);
    axes(handles.ax_raw);
    handles.h_rawDataTrace = plot(xValues,handles.rawDataBuffer);

    guidata(hfigure,handles)
    
catch ME
    getReport(ME)
    keyboard
end

% ----------------------------------------------------------------------- %
% ----                                                                --- %
% ----                      Timer Stop Function                      --- %
% ----                                                                --- %
% ----------------------------------------------------------------------- %

% Runs once when timer stops.
function  stopTimer(hObject, eventdata, hfigure)
% Put the whole function in a try-catch block.  This makes debugging much
% easier because it captures the error and displays a report to the Matlab
% Command Window

try
    % Nothing for now
catch ME
    getReport(ME)
    keyboard
end
% ----------------------------------------------------------------------- %
% ----                                                                --- %
% ----                      Helper Functions                          --- %
% ----                                                                --- %
% ----------------------------------------------------------------------- %

function newBuffer = cycleBuffer(oldBuffer, newData)
N = length(newData);
if N >= length(oldBuffer)
    newBuffer = newData(end-length(oldBuffer)+1:end);
else
    newBuffer = [oldBuffer(N+1:end); newData];
end


function settingChange(hObject)
handles = guidata(hObject);

% if the timer is running, stop it and restart it (which will use the newly
% selected channel.  If the timer isn't running, don't do anything.
if strcmp(handles.timer.Running,'on')
    stop(handles.timer)
    start(handles.timer)
end
