function g_math_traceGUI
% Create a figure
hParent = figure('Name','SC trace math','NumberTitle','off',...
    'Position',[200 300 490 400],'ToolBar','none','SizeChangedFcn',@listen_fun,...
    'MenuBar', 'none','Resize','on');

handles = guidata(hParent);
handles.r_path_1 = '0';
handles.r_file_1 = '0';
handles.r_path_2 = '0';
handles.r_file_2 = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.equation = ' ';
handles.hdr_min = [];
handles.hdr_max = [];
handles.trc_hdr_table = [];
handles.table_pos = [0 0 490 190];
guidata(hParent, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input parameters','FontWeight','bold',...
    'Units','Pixels','Position',[0 190 490 210]);

% Add a text uicontrol to label the slider GET FILE_1
txt1 = uicontrol(p1,'Style','text','FontAngle','italic','Units','Pixels',...
    'Position',[80 160 400 30],'BackgroundColor',[0.9 0.91 0.92],'Tag','r_file1',...
    'String','FILE_1');

% Create push button GET FILE_1
btn1 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Open','Units','Pixels',...
    'Position',[10 160 70 30],'Callback', {@open_f1, hParent, txt1});

% Add a text uicontrol to label the slider GET FILE_2
txt2 = uicontrol(p1,'Style','text','FontAngle','italic','Units','Pixels',...
    'Position',[80 120 400 30],'BackgroundColor',[0.9 0.91 0.92],'Tag','r_file2',...
    'String','FILE_2');

% Create push button GET FILE_2
btn2 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Open','Units','Pixels',...
    'Position',[10 120 70 30],'Callback', {@open_f2, hParent, txt2});

% Add a text uicontrol to label SAVE FILE
txt3 = uicontrol(p1,'Style','text','FontAngle','italic',...
    'Position',[80 80 400 30],'BackgroundColor',[0.9 0.91 0.92],'Tag','s_file',...
    'String','Save as...');

% Create push button SAVE FILE
btn3 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 80 70 30],'Callback', {@save_f, hParent, txt3});

% Add a text uicontrol to label EQUAL TO (=)
txt4 = uicontrol(p1,'Style','text','Units','Pixels','FontName','Courier New','FontSize',15,...
    'Position',[10 50 100 20],'String','OUTPUT =');

% Create EDIT EQUATION
ed1 = uicontrol(p1,'Style','edit','Units','Pixels','Position',[120 50 360 20],...
    'FontName','Courier New','FontSize',9,'Enable','on','Callback', {@ed1_equation, hParent});

% Create push button PLOT TABLE
btn4 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Plot Table',...
    'Units','Pixels','Position', [110 10 70 30],'Enable','on',...
    'Callback', {@plot_table, hParent});

% Add a text uicontrol to label FIRST TRACE HEADER TO PLOT
txt5 = uicontrol(p1,'Style','text','Units','Pixels','HorizontalAlignment','Right',...
    'Position',[190 17.5 70 15],'String','From trace:','FontWeight','bold');

% Create EDIT MIN HEADER TO TABLE
ed2 = uicontrol(p1,'Style', 'edit','Units','Pixels',...
    'Position', [265 15 70 20],'Enable','on',...
    'Callback', {@ed2_min_hdr, hParent});

% Add a text uicontrol to label FIRST TRACE HEADER TO PLOT
txt6 = uicontrol(p1,'Style','text','Units','Pixels','HorizontalAlignment','Right',...
    'Position',[335 17.5 70 15],'String','To trace:','FontWeight','bold');

% Create EDIT MAX HEADER TO TABLE
ed3 = uicontrol(p1,'Style', 'edit','Units','Pixels',...
    'Position', [410 15 70 20],'Enable','on',...
    'Callback', {@ed3_max_hdr, hParent});

% Create push button RUN CALCULATIONS
btn5 = uicontrol(p1,'Style', 'pushbutton', 'String', 'RUN',...
    'Units','Pixels','Position', [10 10 70 30],'Enable','on',...
    'Callback', {@run_calc, hParent});


% OPEN seismic file_1
function open_f1(hObject, eventdata, hParent, txt1)
handles = guidata(hParent);
[r_file,r_path] = uigetfile('*.mat');
if ~strcmp(num2str(r_file),num2str(0)) && ~strcmp(num2str(r_path),num2str(0))
    handles.r_file_1 = r_file;
    handles.r_file_1 = strsplit(handles.r_file_1,'.');
    if length(handles.r_file_1) > 1
        handles.r_file_1 = [handles.r_file_1{1:end-1}];
    end
    handles.r_path_1 = r_path;
    guidata(hParent, handles);
    set(txt1,'String',[r_path r_file]);
end

% OPEN seismic file_2
function open_f2(hObject, eventdata, hParent, txt2)
handles = guidata(hParent);
[r_file,r_path] = uigetfile('*.mat');
if ~strcmp(num2str(r_file),num2str(0)) && ~strcmp(num2str(r_path),num2str(0))
    handles.r_file_2 = r_file;
    handles.r_file_2 = strsplit(handles.r_file_2,'.');
    if length(handles.r_file_2) > 1
        handles.r_file_2 = [handles.r_file_2{1:end-1}];
    end
    handles.r_path_2 = r_path;
    guidata(hParent, handles);
    set(txt2,'String',[r_path r_file]);
end

% SAVE file
function save_f(hObject, eventdata, hParent, txt3)
handles = guidata(hParent);
[s_file,s_path] = uiputfile('*.mat');
if ~strcmp(num2str(s_file),num2str(0)) && ~strcmp(num2str(s_path),num2str(0))
    s_file = strsplit(s_file,'.');
    s_file = s_file{1};
    handles.s_file = s_file;
    handles.s_path = s_path;
    guidata(hParent, handles);
    set(txt3,'String',[s_path s_file '.mat']);
end

% EDIT EQUATION
function ed1_equation(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.equation = hObject.String;
guidata(hParent, handles);

% MIN HDR TO TABLE
function ed2_min_hdr(hObject, eventdata, hParent)
handles = guidata(hParent);
val = str2num(hObject.String);
if length(val) == 1 && val > 0 || isempty(hObject.String)
    handles.hdr_min = val;
else 
    set(hObject,'String',[]);
    handles.hdr_min = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% MAX HDR TO TABLE
function ed3_max_hdr(hObject, eventdata, hParent)
handles = guidata(hParent);
val = str2num(hObject.String);
if length(val) == 1 && val > 0 || isempty(hObject.String)
    handles.hdr_max = val;
else 
    set(hObject,'String',[]);
    handles.hdr_max = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% button PLOT TABLE
function plot_table(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.s_path handles.s_file '.mat']))
    errordlg('Save-file is plottable and it is not found!','Error')
    return
end
r_f = load([handles.s_path handles.s_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.s_path handles.s_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);
g_seis_trc_hdr_table(hParent,r_f,r_m,'numbered');

% button RUN CALCULATIONS
function run_calc(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path_1 handles.r_file_1 '.mat'])) && isempty(dir([handles.r_path_2 handles.r_file_2 '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
end
if isempty([handles.s_path handles.s_file '.mat'])
    errordlg('Save-file not found!','Error saving file')
    return
end
g_math_trace(hParent);

% LISTENER TO FIGURE POSITION
function listen_fun(hObject, eventdata)
ch_panel = findobj(hObject.Children,'Type','uipanel');
if ~isempty(ch_panel)
    ch_txt_open1 = findobj(ch_panel.Children,'Tag','r_file1');
    ch_txt_open2 = findobj(ch_panel.Children,'Tag','r_file2');
    ch_txt_save = findobj(ch_panel.Children,'Tag','s_file');
    ch_ed_equation = findobj(ch_panel.Children,'Style','edit','FontName','Courier New','FontSize',9);
    
    pos_fig = hObject.Position;
    pos_panel = ch_panel.Position;
    pos_txt1 = ch_txt_open1.Position;
    pos_txt2 = ch_txt_open2.Position;
    pos_txt3 = ch_txt_save.Position;
    pos_ed = ch_ed_equation.Position;
    
    set(ch_panel,'Position',[pos_panel(1) pos_fig(4)-pos_panel(4) pos_fig(3) pos_panel(4)]);
    if ch_panel.Position(3)-pos_txt1(1)-10 <= 0
        set(ch_txt_open1,'Position',[pos_txt1(1) pos_txt1(2) 1 pos_txt1(4)]);
        set(ch_txt_open2,'Position',[pos_txt2(1) pos_txt2(2) 1 pos_txt2(4)]);
        set(ch_txt_open3,'Position',[pos_txt3(1) pos_txt3(2) 1 pos_txt3(4)]);
    else
        set(ch_txt_open1,'Position',[pos_txt1(1) pos_txt1(2) ch_panel.Position(3)-pos_txt1(1)-10 pos_txt1(4)]);
        set(ch_txt_open2,'Position',[pos_txt2(1) pos_txt2(2) ch_panel.Position(3)-pos_txt2(1)-10 pos_txt2(4)]);
        set(ch_txt_save,'Position',[pos_txt3(1) pos_txt3(2) ch_panel.Position(3)-pos_txt3(1)-10 pos_txt3(4)]);
    end
    if ch_panel.Position(3)-pos_ed(1)-10 <= 0
        set(ch_ed_equation,'Position',[pos_ed(1) pos_ed(2) 1 pos_ed(4)]);
    else
        set(ch_ed_equation,'Position',[pos_ed(1) pos_ed(2) ch_panel.Position(3)-pos_ed(1)-10 pos_ed(4)]);
    end
end
ch_table = findobj(hObject.Children,'Type','uitable');
if ~isempty(ch_table)
    pos_table = ch_table.Position;
    if pos_fig(4)-pos_panel(4) <= 0
        set(ch_table,'Position',[pos_table(1) pos_table(2) pos_fig(3) 20]);
    else
        set(ch_table,'Position',[pos_table(1) pos_table(2) pos_fig(3) pos_fig(4)-pos_panel(4)]);
    end
end
