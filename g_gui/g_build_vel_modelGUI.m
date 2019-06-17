function g_build_vel_modelGUI
% Create a figure
hParent = figure('Name','SC build vel model','NumberTitle','off',...
    'Position',[400 400 290 220],'ToolBar','none',...
    'MenuBar', 'none','Resize','off');

handles = guidata(hParent);
handles.r_factors_file = '0';
handles.r_factors_path = '0';
handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
guidata(hParent, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input/Output files','FontWeight','bold',...
    'Units','Normalized','Position',[0 0 1 1]);

% Add a text uicontrol to label the slider GET FACTORS FILE
txt4 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 170 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Time Factors Filename to read or velocity model file...');

% Create push button GET FACTORS FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 170 70 30],...
    'Callback', {@open_factors, hParent, txt4});

% Add a text uicontrol to label the slider GET FILE
txt5 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 120 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Seismic Filename to read...');

% Create push button GET FILE
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 120 70 30],...
    'Callback', {@open_f, hParent, txt5});

% Add a text uicontrol to label SAVE FILE
txt6 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 70 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn3 = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 70 70 30],...
    'Callback', {@save_f, hParent, txt6});

% Create push button RUN
btn5 = uicontrol('Style', 'pushbutton', 'String', 'RUN',...
    'Position', [230 10 50 50],...
    'Callback', {@run_calc, hParent});




% OPEN FACTORS file
function open_factors(hObject, eventdata, hParent,txt4)
handles = guidata(hParent);
[r_factors_file,r_factors_path] = uigetfile('*.mat');
if ~strcmp(num2str(r_factors_file),num2str(0)) && ~strcmp(num2str(r_factors_path),num2str(0))
    r_f_fact = load([r_factors_path r_factors_file]);
    r_f_fact = r_f_fact.seismic;
    if isfield(r_f_fact,'param')
        if ~strcmp(r_f_fact.param.decomposition_type, 'time') || ~strcmp(r_f_fact.param.decomposition_type, 'Time')
        end
        if ~isfield(r_f_fact.param,'decomposition_type')
            errordlg('A chosen file does not contain decomposed factors!','Error')
            return
        end
    elseif ~isfield(r_f_fact,'param')
        errordlg('A chosen file does not contain decomposed factors!','Error')
        return
    end
    handles.r_factors_file = r_factors_file;
    handles.r_factors_file = strsplit(handles.r_factors_file,'.');
    if length(handles.r_factors_file) > 1
        handles.r_factors_file = [handles.r_factors_file{1:end-1}];
    end
    handles.r_factors_path = r_factors_path;
    guidata(hParent, handles);
    set(txt4,'String',[r_factors_path r_factors_file]);
end

% OPEN seismic file
function open_f(hObject, eventdata, hParent, txt5)
handles = guidata(hParent);
[r_file,r_path] = uigetfile('*.mat');
if ~strcmp(num2str(r_file),num2str(0)) && ~strcmp(num2str(r_path),num2str(0))
    handles.r_file = r_file;
    handles.r_file = strsplit(handles.r_file,'.');
    if length(handles.r_file) > 1
        handles.r_file = [handles.r_file{1:end-1}];
    end
    handles.r_path = r_path;
    guidata(hParent, handles);
    set(txt5,'String',[r_path r_file]);
end

% SAVE file
function save_f(hObject, eventdata, hParent, txt6)
handles = guidata(hParent);
[s_file,s_path] = uiputfile('*.mat');
if ~strcmp(num2str(s_file),num2str(0)) && ~strcmp(num2str(s_path),num2str(0))
    s_file = strsplit(s_file,'.');
    s_file = s_file{1};
    handles.s_file = s_file;
    handles.s_path = s_path;
    guidata(hParent, handles);
    set(txt6,'String',[s_path s_file '.mat']);
end

% EDIT FILTER LENGTH
function ed_filt_len(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.filt_len = str2num(hObject.String);
if (isempty(handles.filt_len) || length(handles.filt_len) > 1 || handles.filt_len <= 0) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.filt_len = [];
    errordlg('Enter a single number > 0 that indicates length of filter in ms!','Error')
end
guidata(hParent, handles);

% EDIT FILTER NOISE
function ed_filt_noise(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.filt_noise = str2num(hObject.String);
if (isempty(handles.filt_noise) || length(handles.filt_noise) > 1 || handles.filt_noise <= 0) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.filt_noise = [];
    errordlg('Enter a single number > 0 that indicates noise percentage %!','Error')
end
guidata(hParent, handles);

% RUN CALCULATIONS
function run_calc(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_factors_path handles.r_factors_file '.mat']))
    errordlg('Factors-file not found!','Error opening file')
    return
elseif isempty(dir([handles.r_path handles.r_file '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
elseif strcmp(num2str(handles.s_file),num2str(0)) && strcmp(num2str(handles.s_path),num2str(0))
    errordlg('Set output file!','Error saving file')
    return
end
g_build_vel_mod(hParent);
msgbox(['Use <mouse 1> and <mouse 2> buttons to modify ',...
    'layers properties and hole depth. ',...
    'The meaning of <Adjust time-depth connection> option ',...
    'is to correct the thickness of a layer so the travel-time '...
    'is equal to the previously computed time for that layer. ',...
    'Computed travel-time doesnt concern newly created layers. ',...
    'So new layers could be used to specify permafrost thickness for example.']);