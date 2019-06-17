function g_scaleGUI
% Create a figure
hParent = figure('Name','SC scale','NumberTitle','off',...
    'Position',[400 400 290 160],'ToolBar','none',...
    'MenuBar', 'none','Resize','off');

handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.scale_num = 1;
guidata(hParent, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input/Output files','FontWeight','bold',...
    'Units','Normalized','Position',[0 0.27 1 0.73]);

% Add a text uicontrol to label the slider GET FILE
txt1 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 110 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Seismic Filename to read...');

% Create push button GET FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 110 70 30],...
    'Callback', {@open_f, hParent, txt1});

% Add a text uicontrol to label SAVE FILE
txt2 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 60 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 60 70 30],...
    'Callback', {@save_f, hParent, txt2});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p2 = uipanel('Title','Scale','FontWeight','bold',...
    'Units','Normalized','Position',[0 0 1 0.27]);

% Add a text uicontrol SCALE PARAMETER
txt3 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 10 90 15],'String','Multuply data by:','Enable','on');
              
% Create SCALE PARAMETER
ed1 = uicontrol('Style', 'edit','String',1,...
    'Position', [100 07.5 50 20],'Enable','on',...
    'Callback', {@ed_scale, hParent});

% Create push button RUN
btn3 = uicontrol('Style', 'pushbutton', 'String', 'RUN',...
    'Position', [230 10 50 20],...
    'Callback', {@run_calc, hParent});


% OPEN seismic file
function open_f(hObject, eventdata, hParent, txt1)
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
    set(txt1,'String',[r_path r_file]);
end

% SAVE file
function save_f(hObject, eventdata, hParent, txt2)
handles = guidata(hParent);
[s_file,s_path] = uiputfile('*.mat');
if ~strcmp(num2str(s_file),num2str(0)) && ~strcmp(num2str(s_path),num2str(0))
    s_file = strsplit(s_file,'.');
    s_file = s_file{1};
    handles.s_file = s_file;
    handles.s_path = s_path;
    guidata(hParent, handles);
    set(txt2,'String',[s_path s_file '.mat']);
end

% EDIT SCALE PARAMETER
function ed_scale(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.scale_num = str2num(hObject.String);
if isempty(handles.scale_num) || length(handles.scale_num) > 1
    set(hObject,'String',1);
    handles.scale_num = 1;
    errordlg('Enter a single number!','Error')
end
guidata(hParent, handles);

% RUN CALCULATIONS
function run_calc(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
elseif strcmp(num2str(handles.s_file),num2str(0)) && strcmp(num2str(handles.s_path),num2str(0))
    errordlg('Set output file!','Error saving file')
    return
end
tic
g_scale(hParent);
toc
