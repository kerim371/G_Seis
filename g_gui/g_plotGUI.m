function g_plotGUI
hParent = figure('Name','Parameters to plot','NumberTitle','off',...
    'Position',[600 200 300 500],'ToolBar','none',...
    'MenuBar', 'none','Resize','off');

handles = guidata(hParent);
handles.plot = 'r_file';
handles.r_path = [];
handles.r_file = [];
handles.p_key = [];
handles.s_key1 = [];
handles.s_key2 = [];
handles.pkey_min = [];
handles.pkey_max = [];
handles.skey1_min = [];
handles.skey1_max = [];
handles.skey2_min = [];
handles.skey2_max = [];
handles.time_min = [];
handles.time_max = [];
guidata(hParent, handles);

p1 = uipanel('Title','Input binary file','FontWeight','bold',...
    'Units','Normalized','Position',[0 0.315 1 0.685]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a text uicontrol to label GET FILE
txt1 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 445 210 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Choose .mat file containing binary headers');

% Create push button GET FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 445 70 30],...
    'Callback', {@open_f, hParent, txt1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a text uicontrol to label P_KEY
txt2 = uicontrol('Style','text','FontWeight','bold','FontSize',16,...
    'Position',[80 395 120 30],'BackgroundColor',[0.9 0.91 0.92]);

% Create push button CHOOSE P_KEY
btn2 = uicontrol('Style', 'pushbutton', 'String', 'P_KEY',...
    'Position', [10 395 70 30],...
    'Callback', {@p_key, hParent, txt2});

% Add a text uicontrol to label MIN and MAX P_KEY
txt3 = uicontrol('Style','text',...
    'Position',[10 345 100 30],...
    'String','Set |MIN| and |MAX| value for P_KEY:');

% Create push button EDIT P_KEY MIN
ed1 = uicontrol('Style', 'edit',...
'Position', [130 345 70 30],'Enable','on');

% Create push button EDIT P_KEY MAX
ed2 = uicontrol('Style', 'edit',...
'Position', [220 345 70 30],'Enable','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a text uicontrol to label S_KEY1
txt4 = uicontrol('Style','text','FontWeight','bold','FontSize',16,...
    'Position',[80 295 120 30],'BackgroundColor',[0.9 0.91 0.92]);

% Create push button CHOOSE S_KEY1
btn3 = uicontrol('Style', 'pushbutton', 'String', 'S_KEY1',...
    'Position', [10 295 70 30],...
    'Callback', {@s_key1, hParent, txt4});

% Add a text uicontrol to label MIN and MAX S_KEY1
txt5 = uicontrol('Style','text',...
    'Position',[10 245 100 30],...
    'String','Set |MIN| and |MAX| value for S_KEY1:');

% Create push button EDIT S_KEY1 MIN
ed3 = uicontrol('Style', 'edit',...
'Position', [130 245 70 30],'Enable','on');

% Create push button EDIT S_KEY1 MAX
ed4 = uicontrol('Style', 'edit',...
'Position', [220 245 70 30],'Enable','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a text uicontrol to label S_KEY2
txt6 = uicontrol('Style','text','FontWeight','bold','FontSize',16,...
    'Position',[80 195 120 30],'BackgroundColor',[0.9 0.91 0.92]);

% Create push button CHOOSE S_KEY2
btn4 = uicontrol('Style', 'pushbutton', 'String', 'S_KEY2',...
    'Position', [10 195 70 30],...
    'Callback', {@s_key2, hParent, txt6});

% Add a text uicontrol to label MIN and MAX S_KEY2
txt7 = uicontrol('Style','text',...
    'Position',[10 145 100 30],...
    'String','Set |MIN| and |MAX| value for S_KEY2:');

% Create push button EDIT S_KEY2 MIN
ed5 = uicontrol('Style', 'edit',...
'Position', [130 145 70 30],'Enable','on');

% Create push button EDIT S_KEY2 MAX
ed6 = uicontrol('Style', 'edit',...
'Position', [220 145 70 30],'Enable','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a text uicontrol to label MIN and MAX TIME
txt8 = uicontrol('Style','text',...
    'Position',[10 95 100 30],...
    'String','Set |MIN| and |MAX| value for TIME, ms:');

% Create push button EDIT TIME MIN
ed7 = uicontrol('Style', 'edit',...
'Position', [130 95 70 30],'Enable','on');

% Create push button EDIT TIME MAX
ed8 = uicontrol('Style', 'edit',...
'Position', [220 95 70 30],'Enable','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create push button PLOT
btn5 = uicontrol('Style', 'pushbutton', 'String', 'PLOT',...
    'Position', [220 45 70 30],'FontWeight','bold',...
    'Callback', {@plot_it, hParent, ed1, ed2, ed3, ed4, ed5, ed6, ed7, ed8});

% choose file
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

% choose P_KEY
function p_key(hObject, eventdata, hParent, txt2)
handles = guidata(hParent);
f1 = figure('Name','Pick primary header','NumberTitle','off',...
    'ToolBar','none','MenuBar', 'none','Resize','on',...
    'Position',[600 100 300 600],'CloseRequestFcn',{@closereq_pkey, hParent, txt2});
guidata(hParent, handles);
g_p_key_table(hParent, txt2, f1);

% choose S_KEY1
function s_key1(hObject, eventdata, hParent, txt4)
handles = guidata(hParent);
f1 = figure('Name','Pick secondary header 1','NumberTitle','off',...
    'ToolBar','none','MenuBar', 'none','Resize','on',...
    'Position',[600 100 300 600],'CloseRequestFcn',{@closereq_skey1, hParent, txt4});
guidata(hParent, handles);
g_s_key1_table(hParent, txt4, f1);

% choose S_KEY2
function s_key2(hObject, eventdata, hParent, txt6)
handles = guidata(hParent);
f1 = figure('Name','Pick secondary header 2','NumberTitle','off',...
    'ToolBar','none','MenuBar', 'none','Resize','on',...
    'Position',[600 100 300 600],'CloseRequestFcn',{@closereq_skey2, hParent, txt6});
guidata(hParent, handles);
g_s_key2_table(hParent, txt6, f1);

% PLOT
function plot_it(hObject, eventdata, hParent, ed1, ed2, ed3, ed4, ed5, ed6, ed7, ed8)
handles = guidata(hParent);
if isempty(handles.r_file)
    errordlg('BIN-file not found!','Error opening file')
    return
elseif isempty(handles.p_key)
    errordlg('Choose at least P_KEY!','Error')
    return
end
handles.pkey_min = str2num(ed1.String);
handles.pkey_max = str2num(ed2.String);
handles.skey1_min = str2num(ed3.String);
handles.skey1_max = str2num(ed4.String);
handles.skey2_min = str2num(ed5.String);
handles.skey2_max = str2num(ed6.String);
handles.time_min = str2num(ed7.String);
handles.time_max = str2num(ed8.String);
guidata(hParent,handles);
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
if strcmp(r_f.plot_type,'imagesc')
    PlotReduce(hParent);
elseif strcmp(r_f.plot_type,'line')
    PlotFactors2D(hParent);
end

% ������� ������������� ��� ������� �� ������ �������� ��������� (�������)
function closereq_pkey(hObject, eventdata, hParent, txt2)
handles = guidata(hParent);
handles.p_key = [];
guidata(hParent,handles);
set(txt2,'String',[]);
delete(gcf);

% ������� ������������� ��� ������� �� ������ �������� ��������� (�������)
function closereq_skey1(hObject, eventdata, hParent, txt4)
handles = guidata(hParent);
handles.s_key1 = [];
guidata(hParent,handles);
set(txt4,'String',[]);
delete(gcf);

% ������� ������������� ��� ������� �� ������ �������� ��������� (�������)
function closereq_skey2(hObject, eventdata, hParent, txt6)
handles = guidata(hParent);
handles.s_key2 = [];
guidata(hParent,handles);
set(txt6,'String',[]);
delete(gcf);