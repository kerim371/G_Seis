function g_read_segyGUI
% Create a figure and axes
hParent = figure('Name','Read SEGY','NumberTitle','off',...
    'Position',[100 500 290 250],'ToolBar','none',...
    'MenuBar', 'none','Resize','off');

handles = guidata(hParent);
handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.r_select = 'From binary header';
handles.r_format = '4-byte IEEE floating point';
handles.r_format_bytes = 4;
handles.endian = 'Big endian';
handles.trc_hdr_table = [];
guidata(hParent, handles);

p1 = uipanel('Title','Input/Output files','FontWeight','bold',...
    'Units','pixels','Position',[0 75 290 175]);

% Add a text uicontrol to label the slider GET FILE
txt1 = uicontrol(p1,'Style','text','FontAngle','italic',...
    'Position',[80 120 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','SEGY Filename to read...');

% Create push button GET FILE
btn1 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 120 70 30],...
    'Callback', {@open_f, hParent, txt1});

% Add a text uicontrol to label the slider SAVE FILE
txt2 = uicontrol(p1,'Style','text','FontAngle','italic',...
    'Position',[80 70 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn2 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 70 70 30],...
    'Callback', {@save_f, hParent, txt2});

% Create push button START READING
btn3 = uicontrol(p1,'Style', 'pushbutton', 'String', 'RUN',...
    'Position', [10 20 70 30],'Callback', {@read_f, hParent});

% Create push button PARFOR COMPUTATION
btn4 = uicontrol(p1,'Style', 'pushbutton', 'String', 'Parallel RUN',...
    'Position', [100 20 70 30],'Callback', {@parfor_f, hParent});

% Create push button VIEW DATA
tgl1 = uicontrol(p1,'Style', 'togglebutton', 'String', 'View data',...
    'Position', [190 20 70 30],...
    'Callback', {@view_f, hParent});

% Create buttongroup
bg1 = uibuttongroup('Visible','on','Title','SEGY parameters',...
                  'FontWeight','bold','Units','pixels','Position',[0 0 290 75],...
                  'SelectionChangedFcn',{@bselection1, hParent, p1});
              
% Create two radio buttons in the button group.
r1 = uicontrol(bg1,'Style',...
                  'radiobutton',...
                  'String','From binary header','Units','Normalized',...
                  'Position',[0.02 0.6 0.8 0.3],...
                  'HandleVisibility','off');
              
r2 = uicontrol(bg1,'Style','radiobutton',...
                  'String','Set manually','Units','Normalized',...
                  'Position',[0.02 0.2 0.8 0.3],...
                  'HandleVisibility','off');
              


function open_f(hObject, eventdata, hParent, txt1)
handles = guidata(hParent);
[r_file,r_path] = uigetfile({'*.seg; *.sgy; *.segy'});
if ~strcmp(num2str(r_file),num2str(0)) && ~strcmp(num2str(r_path),num2str(0))
    handles.r_file = r_file;
    handles.r_path = r_path;
    guidata(hParent, handles);
    set(txt1,'String',[r_path r_file]);
end

function save_f(hObject, eventdata, hParent, txt2)
handles = guidata(hParent);
if isfield(handles,'r_file')
    s_file = strsplit(handles.r_file,'.');
    s_file = s_file{1};
    [s_file,s_path] = uiputfile('*.mat',[],s_file);
else
    [s_file,s_path] = uiputfile('*.mat');
end
if ~strcmp(num2str(s_file),num2str(0)) && ~strcmp(num2str(s_path),num2str(0))
    s_file = strsplit(s_file,'.');
    if length(handles.r_file) > 1
        s_file = [s_file{1:end-1}];
    end
    handles.s_file = s_file;
    handles.s_path = s_path;
    guidata(hParent, handles);
    set(txt2,'String',[s_path s_file '.mat']);
end

% READ SEGY
function read_f(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file]))
    errordlg('SEGY-file not found!','Error opening file')
    return
elseif strcmp(num2str(handles.s_file),num2str(0)) && strcmp(num2str(handles.s_path),num2str(0))
    errordlg('Set output file!','Error saving file')
    return
end
tic
g_read_segy(hParent);
toc

% READ SEGY PARFOR
function parfor_f(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file]))
    errordlg('SEGY-file not found!','Error opening file')
    return
elseif strcmp(num2str(handles.s_file),num2str(0)) && strcmp(num2str(handles.s_path),num2str(0))
    errordlg('Set output file!','Error saving file')
    return
end
tic
g_read_segy_parfor(hParent);
toc

% radiobutton IBM or IEEE
function bselection1(source, event, hParent, p1)
handles = guidata(hParent);
handles.r_format = '4-byte IEEE floating point';
handles.endian = 'Big endian';
r_select = source.SelectedObject.String;
handles.r_select = r_select;
f_pos = hParent.Position;
if strcmp(r_select,'Set manually')
    set(hParent,'Position',[f_pos(1) f_pos(2)-125 f_pos(3) f_pos(4)+125]);
    set(p1,'Position',[p1.Position(1) p1.Position(2)+125 p1.Position(3) p1.Position(4)]);
    set(source,'Position',[source.Position(1) source.Position(2)+125 source.Position(3) source.Position(4)]);
    
    % Create buttongroup IBM or IEEE
    handles.bg2 = uibuttongroup('Visible','on',...
        'Units','pixels','Position',[0 0 203 115],...
        'SelectionChangedFcn',{@bselection2, hParent});

    % Create two radio buttons in the button group.
    r3 = uicontrol(handles.bg2,'Style',...
                      'radiobutton',...
                      'String','4-byte IEEE floating point',...
                      'Units','Normalized',...
                      'Position',[0.02 0.79 1 0.2],...
                      'HandleVisibility','off');

    r4 = uicontrol(handles.bg2,'Style','radiobutton',...
                      'String','4-byte IBM floating point',...
                      'Units','Normalized',...
                      'Position',[0.02 0.59 1 0.2],...
                      'HandleVisibility','off');
                  
    r5 = uicontrol(handles.bg2,'Style','radiobutton',...
                      'String','4-byte two, complement integer',...
                      'Units','Normalized',...
                      'Position',[0.02 0.39 1 0.2],...
                      'HandleVisibility','off');
                  
    r6 = uicontrol(handles.bg2,'Style','radiobutton',...
                      'String','2-byte two, complement integer',...
                      'Units','Normalized',...
                      'Position',[0.02 0.19 1 0.2],...
                      'HandleVisibility','off');
                  
    r7 = uicontrol(handles.bg2,'Style','radiobutton',...
                      'String','1-byte two, complement integer',...
                      'Units','Normalized',...
                      'Position',[0.02 0 1 0.2],...
                      'HandleVisibility','off');
    
    % Create buttongroup BIG ENDIAN or LITTLE ENDIAN
    if isfield(handles,'p2')
        set(handles.p2,'Position',[handles.p2.Position(1) handles.p2.Position(2)+125 handles.p2.Position(3) handles.p2.Position(4)]);
        
        handles.bg3 = uibuttongroup('Visible','on',...
                      'Units','pixels','Position',[203 0 277 115],...
                      'SelectionChangedFcn',{@bselection3, hParent});
    elseif ~isfield(handles,'p2')
        handles.bg3 = uibuttongroup('Visible','on',...
                      'Units','pixels','Position',[203 0 87 115],...
                      'SelectionChangedFcn',{@bselection3, hParent});
    end

    % Create two radio buttons in the button group.
    r9 = uicontrol(handles.bg3,'Style',...
                      'radiobutton',...
                      'String','Big endian',...
                      'Units','Normalized',...
                      'Position',[0.02 0.47 1 0.3],...
                      'HandleVisibility','off');

    r6 = uicontrol(handles.bg3,'Style','radiobutton',...
                      'String','Little endian',...
                      'Units','Normalized',...
                      'Position',[0.02 0.2 1 0.3],...
                      'HandleVisibility','off');
elseif strcmp(r_select,'From binary header')
    delete([handles.bg2 handles.bg3]);
    handles = rmfield(handles,{'bg2', 'bg3'});
    set(hParent,'Position',[f_pos(1) f_pos(2)+125 f_pos(3) f_pos(4)-125]);
    set(p1,'Position',[p1.Position(1) p1.Position(2)-125 p1.Position(3) p1.Position(4)]);
    set(source,'Position',[source.Position(1) source.Position(2)-125 source.Position(3) source.Position(4)]);
    if isfield(handles,'p2')
        set(handles.p2,'Position',[handles.p2.Position(1) handles.p2.Position(2)-125 handles.p2.Position(3) handles.p2.Position(4)]);
    end
end
guidata(hParent, handles);

% radiobutton IBM or IEEE
function bselection2(source, event, hParent)
handles = guidata(hParent);
r_format = source.SelectedObject.String;
if strcmp(r_format,'4-byte IEEE floating point')
    r_format = '4-byte IEEE floating point';
    r_format_bytes = 4;
elseif strcmp(r_format,'4-byte IBM floating point')
    r_format = '4-byte IBM floating point';
    r_format_bytes = 4;
elseif strcmp(r_format,'4-byte two, complement integer')
    r_format = '4-byte two, complement integer';
    r_format_bytes = 4;
elseif strcmp(r_format,'2-byte two, complement integer')
    r_format = '2-byte two, complement integer';
    r_format_bytes = 2;
elseif strcmp(r_format,'1-byte two, complement integer')
    r_format = '1-byte two, complement integer';
    r_format_bytes = 1;
end
handles.r_format = r_format;
handles.r_format_bytes = r_format_bytes;
guidata(hParent, handles);
    
% radiobutton BIG or LITTLE endian
function bselection3(source, event, hParent)
handles = guidata(hParent);
endian = source.SelectedObject.String;
if strcmp(endian,'Big endian')
    endian = 'Big endian';
elseif strcmp(endian,'Little endian')
    endian = 'Little endian';
end
handles.endian = endian;
guidata(hParent, handles);

% VIEW data
function view_f(hObject, eventdata, hParent)
handles = guidata(hParent);
f_pos = hParent.Position;
h = get(hObject,'Value');
if h == 1
    set(hParent,'Position',[f_pos(1) f_pos(2) f_pos(3)+190  f_pos(4)]);
    if isfield(handles,'bg2')
        handles.p2 = uipanel('Title','Plot Data','FontWeight','bold',...
            'Units','pixels','Position',[f_pos(3)+10 125 180 f_pos(4)-125]);
    elseif ~isfield(handles,'bg2')
        handles.p2 = uipanel('Title','Plot Data','FontWeight','bold',...
            'Units','pixels','Position',[f_pos(3)+10 0 180 f_pos(4)]);
    end

    % Create push button VIEW BIN HEADER
    btn5 = uicontrol(handles.p2,'Style', 'pushbutton', 'String', 'Bin header',...
    'Position', [10 195 70 30],...
    'Callback', {@view_bin_hdr, hParent});

    % Create push button EDIT TRACE NUMBER
    ed1 = uicontrol(handles.p2,'Style', 'edit', 'String', '1',...
    'Position', [100 150 70 20],'Enable','off',...
    'Callback', {@ed1_trace2plot, hParent});

    set(hParent,'KeyPressFcn',{@trc_keyPress, hParent, ed1}); % эта опция должна быть после ed1

    % Create push button VIEW PREVIOUS TRACE
    btn7 = uicontrol(handles.p2,'Style', 'pushbutton', 'String', '<<Previous',...
    'Position', [10 100 70 20],'Enable','off',...
    'Callback', {@previous_trace, hParent, ed1});

    % Create push button VIEW NEXT TRACE
    btn8 = uicontrol(handles.p2,'Style', 'pushbutton', 'String', 'Next>>',...
    'Position', [100 100 70 20],'Enable','off',...
    'Callback', {@next_trace, hParent, ed1},...
    'KeyPressFcn',{@next_trace, hParent, ed1});

    % Create push button PLOT TRACE
    btn6 = uicontrol(handles.p2,'Style', 'pushbutton', 'String', 'Plot trace',...
    'Position', [10 145 70 30],...
    'Callback', {@plot_trace, hParent, btn7, btn8, ed1}); % именно сздесь она должна стоять

    % Create push button VIEW TEXT HEADER
    btn9 = uicontrol(handles.p2,'Style', 'pushbutton', 'String', 'Text header',...
    'Position', [100 195 70 30],...
    'Callback', {@view_txt_hdr, hParent});

    % Create push button VIEW TEXT HEADER
    txt3 = uicontrol(handles.p2,'Style','text','String',{'Or use left/right arrow on keyboard'},...
    'Units','pixels','Position',[0 10 180  70],'HorizontalAlignment','center');
elseif h == 0
    delete(handles.p2);
    handles = rmfield(handles,'p2');
    set(hParent,'Position',[f_pos(1) f_pos(2) f_pos(3)-190 f_pos(4)]);
end
guidata(hParent, handles);

% VIEW bin header
function view_bin_hdr(hObject, eventdata, hParent)
handles = guidata(hParent);
guidata(hParent, handles);
if isempty(dir([handles.r_path handles.r_file]))
    errordlg('SEGY-file not found!','Error opening file')
    return
end
if ~isempty(findobj('Type','figure','Name','Table bin header'))
    close 'Table bin header' % закрыть figure
end
g_table_bin_hdr(hParent);

% PLOT trace
function plot_trace(hObject, eventdata, hParent, btn7, btn8, ed1)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file]))
    errordlg('SEGY-file not found!','Error opening file')
    return
end
btn7.Enable = 'on';
btn8.Enable = 'on';
ed1.Enable = 'on';

f1_pos = hParent.Position;
if isfield(handles,'bg2')
    f2_pos = [f1_pos(1)+f1_pos(3)+16 f1_pos(2)-175 700  523];
elseif ~isfield(handles,'bg2')
    f2_pos = [f1_pos(1)+f1_pos(3)+16 f1_pos(2)-300 700  523];
end

if isempty(findobj('Type','figure','Name','Trace and its header'))
    f2 = figure('Name','Trace and its header','NumberTitle','off',...
        'ToolBar','figure','MenuBar', 'none','Resize','on',...
        'Position',f2_pos,'CloseRequestFcn',{@trc_closereq, btn7, btn8, ed1},...
        'KeyPressFcn',{@trc_keyPress, hParent, ed1});
    ax2 = axes('OuterPosition',[0.6 0.0 0.4 1]);
    handles.ax2 = ax2;
    handles.f2 = f2;
end
handles.k = 1;
ed1.String = '1';
guidata(hParent, handles);
g_trace_plot_table(hParent);

% EDIT trace
function ed1_trace2plot(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.k = str2num(hObject.String);
if isempty(handles.k) || length(str2num(hObject.String)) > 1
    set(hObject,'String',1);
    handles.k = 1;
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);
trace_plot_table(hParent);

% PREVIOUS trace
function previous_trace(hObject, eventdata, hParent, ed1)
handles = guidata(hParent);
handles.k = handles.k - 1;
guidata(hParent, handles);
ed1.String = handles.k;
g_trace_plot_table(hParent);

% NEXT trace
function next_trace(hObject, eventdata, hParent, ed1)
handles = guidata(hParent);
handles.k = handles.k + 1;
guidata(hParent, handles);
ed1.String = handles.k;
g_trace_plot_table(hParent);

% VIEW text header
function view_txt_hdr(hObject, eventdata, hParent)
handles = guidata(hParent);
guidata(hParent, handles);
if isempty(dir([handles.r_path handles.r_file]))
    errordlg('SEGY-file not found!','Error opening file')
    return
end
if ~isempty(findobj('Type','figure','Name','Text header'))
    close 'Text header' % закрыть figure
end
g_text_hdr_table(hParent);

% Функция срабатывающая при нажатии на кнопку закрытия программы (крестик)
function trc_closereq(hObject, eventdata, btn7, btn8, ed1)
if isvalid(btn7) && isvalid(btn8) && isvalid(ed1)
    if  isfield(get(btn7),'Enable') && isfield(get(btn8),'Enable') && isfield(get(ed1),'Enable')
        btn7.Enable = 'off';
        btn8.Enable = 'off';
        ed1.Enable = 'off';
    end
end
delete(gcf);

% Функция срабатывающая при нажатии на кнопки стрелка влево/вправо
function trc_keyPress(hObject, eventdata, hParent, ed1)
switch eventdata.Key
    case 'leftarrow'
        previous_trace(hObject, eventdata, hParent, ed1);
    case 'rightarrow'
        next_trace(hObject, eventdata, hParent, ed1);
end

%maxNumCompThreads(1); % ОГРАНИЧИТЬ ЧИСЛО ЯДЕР

% ЗАКРЫТЬ ВСЕ ОКНА НА СЛУЧАЙ, ЕСЛИ WAITBAR ЗАТУПИЛ!!!!!!!!!
% set(groot,'ShowHiddenHandles','on')
% delete(get(groot,'Children'))