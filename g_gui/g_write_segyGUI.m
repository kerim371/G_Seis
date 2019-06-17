function g_write_segyGUI(hParent)
% Create a figure
hParent = figure('Name','SC write SEGY','NumberTitle','off',...
    'Position',[400 400 290 230],'ToolBar','none',...
    'MenuBar', 'none','Resize','off');

handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.s_format = '4-byte IEEE floating point';
handles.s_format_num = 5;
handles.endian = 'ieee-be';
guidata(hParent, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input/Output files','FontWeight','bold',...
    'Units','Normalized','Position',[0 0.5 1 0.5]);

% Add a text uicontrol to label the slider GET FILE
txt1 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 180 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Seismic Filename to read...');

% Create push button GET FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 180 70 30],...
    'Callback', {@open_f, hParent, txt1});

% Add a text uicontrol to label SAVE FILE
txt2 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 130 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 130 70 30],...
    'Callback', {@save_f, hParent, txt2});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create buttongroup
bg1 = uibuttongroup('Title','Format','Visible','on',...
                  'FontWeight','bold','Position',[0 0 0.76 0.5],...
                  'SelectionChangedFcn',{@bselection1,hParent});
              
% Create radio buttons in the button group.
r1 = uicontrol(bg1,'Style','radiobutton',...
                  'String','4-byte IEEE floating point','Units','Normalized',...
                  'Position',[0.02 0.8 1 0.25]);
              
% Create radio buttons in the button group.
r2 = uicontrol(bg1,'Style','radiobutton','Enable','off',...
                  'String','4-byte IBM floating point','Units','Normalized',...
                  'Position',[0.02 0.6 1 0.25]);
              
% Create radio buttons in the button group.
r3 = uicontrol(bg1,'Style','radiobutton',...
                  'String','4-byte two, complement integer','Units','Normalized',...
                  'Position',[0.02 0.4 1 0.25]);
              
% Create radio buttons in the button group.
r4 = uicontrol(bg1,'Style','radiobutton',...
                  'String','2-byte two, complement integer','Units','Normalized',...
                  'Position',[0.02 0.2 1 0.25]);
              
% Create radio buttons in the button group.
r5 = uicontrol(bg1,'Style','radiobutton',...
                  'String','1-byte two, complement integer','Units','Normalized',...
                  'Position',[0.02 0 1 0.25]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create buttongroup
bg2 = uibuttongroup('Title','Endian','Visible','on',...
                  'FontWeight','bold','Position',[0.76 0 0.24 0.5],...
                  'SelectionChangedFcn',{@bselection2,hParent});
              
% Create radio buttons in the button group.
r6 = uicontrol(bg2,'Style','radiobutton',...
                  'String','Big','Units','Normalized',...
                  'Position',[0.02 0.7 1 0.25]);
              
% Create radio buttons in the button group.
r7 = uicontrol(bg2,'Style','radiobutton',...
                  'String','Little','Units','Normalized',...
                  'Position',[0.02 0.45 1 0.25]);


% Create push button RUN
btn3 = uicontrol('Style', 'pushbutton', 'String', 'RUN',...
    'Position', [230 10 50 30],...
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
if isfield(handles,'r_file')
    s_file = strsplit(handles.r_file,'.');
    s_file = s_file{1};
    [s_file,s_path] = uiputfile('*.sgy',[],s_file);
else
    [s_file,s_path] = uiputfile('*.sgy');
end
if ~strcmp(num2str(s_file),num2str(0)) && ~strcmp(num2str(s_path),num2str(0))
    s_file = strsplit(s_file,'.');
    s_file = s_file{1};
    handles.s_file = s_file;
    handles.s_path = s_path;
    guidata(hParent, handles);
    set(txt2,'String',[s_path s_file '.sgy']);
end

% radiobutton FORMAT
function bselection1(source,event,hParent)
handles = guidata(hParent);
s_format = source.SelectedObject.String;
if strcmp(s_format,'4-byte IEEE floating point')
    s_format = '4-byte IEEE floating point';
    s_format_num = 5;
elseif strcmp(s_format,'4-byte IBM floating point')
    s_format = '4-byte IBM floating point';
    s_format_num = 1;
elseif strcmp(s_format,'4-byte two, complement integer')
    s_format = '4-byte two, complement integer';
    s_format_num = 2;
elseif strcmp(s_format,'2-byte two, complement integer')
    s_format = '2-byte two, complement integer';
    s_format_num = 3;
elseif strcmp(s_format,'1-byte two, complement integer')
    s_format = '1-byte two, complement integer';
    s_format_num = 8;
end
handles.s_format = s_format;
handles.s_format_num = s_format_num;
guidata(hParent, handles);

% radiobutton ENDIAN
function bselection2(source,event,hParent)
handles = guidata(hParent);
endian = source.SelectedObject.String;
if strcmp(endian,'Big')
    endian = 'ieee-be';
elseif strcmp(endian,'Little')
    endian = 'ieee-le';
end
handles.endian = endian;
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
g_write_segy(hParent);
toc
