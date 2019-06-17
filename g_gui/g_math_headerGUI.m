function g_math_headerGUI
% Create a figure
hParent = figure('Name','SC header math','NumberTitle','off',...
    'Position',[200 300 490 400],'ToolBar','none','SizeChangedFcn',@listen_fun,...
    'MenuBar', 'none','Resize','on');

handles = guidata(hParent);
handles.r_path = '0';
handles.r_file = '0';
handles.hdr_clc = 1; % заголовок который будет отредактирован
handles.equation = ' ';
handles.hdr_min = [];
handles.hdr_max = [];
handles.trc_hdr_table = [];
handles.table_pos = [0 0 490 270];
guidata(hParent, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input parameters','FontWeight','bold',...
    'Units','Pixels','Position',[0 270 490 130]);

% Add a text uicontrol to label the slider GET FILE
txt1 = uicontrol(p1,'Style','text','FontAngle','italic','Units','Pixels',...
    'Position',[80 80 400 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Seismic Filename to read...');

% Create push button GET FILE
btn1 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Open','Units','Pixels',...
    'Position',[10 80 70 30],'Callback', {@open_f, hParent, txt1});

% Create popup menu HEADER TO CALC
[hdr, ~] = g_get_trc_hdr_info;
pop1 = uicontrol(p1,'Style', 'popup','String',hdr(:,2),'Units','Pixels',...
    'FontName','Courier New','FontSize',9,'Position',[10 50 100 20],'Callback', {@pop1_hdr_clc, hParent});

% Add a text uicontrol to label EQUAL TO (=)
txt2 = uicontrol(p1,'Style','text','Units','Pixels','FontName','Courier New','FontSize',15,...
    'Position',[110 50 30 20],'String','=');

% Create EDIT EQUATION
ed1 = uicontrol(p1,'Style','edit','Units','Pixels','Position',[140 50 340 20],...
    'FontName','Courier New','FontSize',9,'Enable','on','Callback', {@ed1_equation, hParent});

% Create push button PLOT TABLE
btn2 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Plot Table',...
    'Units','Pixels','Position', [110 10 70 30],'Enable','on',...
    'Callback', {@plot_table, hParent});

% Add a text uicontrol to label FIRST TRACE HEADER TO PLOT
txt3 = uicontrol(p1,'Style','text','Units','Pixels','HorizontalAlignment','Right',...
    'Position',[190 17.5 70 15],'String','From trace:','FontWeight','bold');

% Create EDIT MIN HEADER TO TABLE
ed2 = uicontrol(p1,'Style', 'edit','Units','Pixels',...
    'Position', [265 15 70 20],'Enable','on',...
    'Callback', {@ed2_min_hdr, hParent});

% Add a text uicontrol to label FIRST TRACE HEADER TO PLOT
txt4 = uicontrol(p1,'Style','text','Units','Pixels','HorizontalAlignment','Right',...
    'Position',[335 17.5 70 15],'String','To trace:','FontWeight','bold');

% Create EDIT MAX HEADER TO TABLE
ed3 = uicontrol(p1,'Style', 'edit','Units','Pixels',...
    'Position', [410 15 70 20],'Enable','on',...
    'Callback', {@ed3_max_hdr, hParent});

% Create push button RUN CALCULATIONS
btn3 = uicontrol(p1,'Style', 'pushbutton', 'String', 'RUN',...
    'Units','Pixels','Position', [10 10 70 30],'Enable','on',...
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

% HEADER TO CALCULATE popup menu
function pop1_hdr_clc(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.hdr_clc = hObject.Value;
guidata(hParent, handles);

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
if isempty(dir([handles.r_path handles.r_file '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
end
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',true);
g_seis_trc_hdr_table(hParent,r_f,r_m,r_f.trc_hdr_info(:,2));

% button RUN CALCULATIONS
function run_calc(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
end
g_math_header(hParent);

% LISTENER TO FIGURE POSITION
function listen_fun(hObject, eventdata)
ch_panel = findobj(hObject.Children,'Type','uipanel');
if ~isempty(ch_panel)
    ch_txt_open = findobj(ch_panel.Children,'Style','text','FontAngle','italic');
    ch_ed_equation = findobj(ch_panel.Children,'Style','edit','FontName','Courier New','FontSize',9);
    
    pos_fig = hObject.Position;
    pos_panel = ch_panel.Position;
    pos_txt = ch_txt_open.Position;
    pos_ed = ch_ed_equation.Position;
    
    set(ch_panel,'Position',[pos_panel(1) pos_fig(4)-pos_panel(4) pos_fig(3) pos_panel(4)]);
    if ch_panel.Position(3)-pos_txt(1)-10 <= 0
        set(ch_txt_open,'Position',[pos_txt(1) pos_txt(2) 1 pos_txt(4)]);
    else
        set(ch_txt_open,'Position',[pos_txt(1) pos_txt(2) ch_panel.Position(3)-pos_txt(1)-10 pos_txt(4)]);
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
