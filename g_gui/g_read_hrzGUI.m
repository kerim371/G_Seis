function g_read_hrzGUI
% Create a figure
hParent = figure('Name','Read Horizon','NumberTitle','off',...
    'Position',[600 200 290 500],'ToolBar','none',...
    'MenuBar', 'none','Resize','off',...
    'CloseRequestFcn',@read_hrz_closereq);

handles = guidata(hParent);
handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.delimiter = 'Space';
handles.col_names = {'~' '6' '12' 't'};
guidata(hParent, handles);

p1 = uipanel('Title','Input/Output files','FontWeight','bold',...
    'Units','Normalized','Position',[0 0.6 1 0.4]);

% Add a text uicontrol to label the slider GET FILE
txt1 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 450 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Horizon TEXT (xyz) Filename to read...');

% Create push button GET FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 450 70 30],...
    'Callback', {@open_f, hParent, txt1});

% Add a text uicontrol to label the slider SAVE FILE
txt2 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 400 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 400 70 30],...
    'Callback', {@save_f, hParent, txt2});

% Create buttongroup
bg1 = uibuttongroup('Visible','on','Title','Delimiter',...
                  'FontWeight','bold','Position',[0 0.4 0.6 0.2],...
                  'SelectionChangedFcn',{@bselection1, hParent});
              
% Create radio buttons in the button group.
r1 = uicontrol(bg1,'Style',...
                  'radiobutton',...
                  'String','Space','Units','Normalized',...
                  'Position',[0.02 0.6 0.5 0.3],...
                  'HandleVisibility','off');
              
r2 = uicontrol(bg1,'Style','radiobutton',...
                  'String','Tab','Units','Normalized',...
                  'Position',[0.02 0.2 0.5 0.3],...
                  'HandleVisibility','off');
              
r3 = uicontrol(bg1,'Style',...
                  'radiobutton',...
                  'String','Comma','Units','Normalized',...
                  'Position',[0.5 0.6 0.5 0.3],...
                  'HandleVisibility','off');
              
r4 = uicontrol(bg1,'Style','radiobutton',...
                  'String','Dot','Units','Normalized',...
                  'Position',[0.5 0.2 0.5 0.3],...
                  'HandleVisibility','off');
              
% Add a text uicontrol to label the slider SAVE FILE
txt3 = uicontrol('Style','text','Position',[10 320 200 55],'HorizontalAlignment','left',...
    'String','Space-delimited trace header indexes (push button <Headers> to find indexes needed). Column <t> indicates <time> column.');

% Create EDIT COLUMN NAMES
ed1 = uicontrol('Style', 'edit', 'String', '6 12 t',...
    'Position', [210 350 70 30],'Enable','on',...
    'Callback', {@edit_col_names, hParent});

% Create push button view TRACE HEADERS
btn3 = uicontrol('Style', 'pushbutton', 'String', 'Headers',...
    'Position', [210 315 70 30],...
    'Callback', {@view_trc_hdrs, hParent});

p2 = uipanel('Title','Run','FontWeight','bold',...
    'Units','Normalized','Position',[0.6 0.4 0.4 0.2]);

% Create push button READ 100 LINES
btn4 = uicontrol('Style', 'pushbutton', 'String', 'View',...
    'Position', [210 260 70 30],...
    'Callback', {@viewfewlines, hParent});

% Create push button READ AND SAVE ALL
btn5 = uicontrol('Style', 'pushbutton', 'String', 'Read',...
    'Position', [210 210 70 30],'FontWeight','bold',...
    'Callback', {@read_txt, hParent});

msgbox(['NOTE! Text-file must be xyz formatted. It is possible file to contain letters,',...
    'but only those lines will be read, which dont have any letter!',...
    'Use <~> (tilde) to exclude column from reading. Number of column to read should not exceed amount of column in TEXT-file.',...
    'Use <VIEW> button to check the correctness.']);


% OPEN text file
function open_f(hObject, eventdata, hParent, txt1)
handles = guidata(hParent);
[r_file,r_path] = uigetfile('*.*');
if ~strcmp(num2str(r_file),num2str(0)) && ~strcmp(num2str(r_path),num2str(0))
    handles.r_file = r_file;
    handles.r_path = r_path;
    guidata(hParent, handles);
    set(txt1,'String',[r_path r_file]);
end

% SAVE text file
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
    s_file = s_file{1};
    handles.s_file = s_file;
    handles.s_path = s_path;
    guidata(hParent, handles);
    set(txt2,'String',[s_path s_file '.mat']);
end

% radiobutton DELIMITER
function bselection1(source, event, hParent)
handles = guidata(hParent);
handles.delimiter = source.SelectedObject.String;
guidata(hParent, handles);

% EDIT column names
function edit_col_names(source, event, hParent)
col_names = strsplit(source.String,' ');
% for n = 1:length(col_names)
%     is_t = strcmp(col_names{n},'t');
%     if is_t == 1
%         break
%     end
% end
% if is_t == 0
%     errordlg('There must be <t> letter that specifies time column!','Error')
%     return
% end
handles = guidata(hParent);
handles.col_names = col_names;
guidata(hParent, handles);

% VIEW few lines from horizon text file
function viewfewlines(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file]))
    errordlg('TEXT-file not found!','Error opening file')
    return
end
hrz = g_read_hrz(hParent,100);
[trc_hdr_info,~] = g_get_trc_hdr_info;
col_names_table = cell(1);
k = 1;
for n = 1:length(handles.col_names)
    if ~strcmp(handles.col_names{n},'t') && ~strcmp(handles.col_names{n},'~')
        col_names_table{k} = cell2mat([trc_hdr_info(str2num(handles.col_names{n}),2) ' {' handles.col_names{n} '}']);
        k = k+1;
    elseif strcmp(handles.col_names{n},'t')
        col_names_table{k} = 't';
        k = k+1;
    end
end
if isfield(handles,'hrz_table')
    delete(handles.hrz_table); % ������� ������� ����� ��� �� ��������������
end
handles.hrz_table = uitable(hParent,'Data',hrz,'ColumnName',col_names_table,...
    'Units','Normalized','Position',[0 0 1  0.4]);
guidata(hParent, handles);

% READ text file and save as .mat
function read_txt(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file]))
    errordlg('TEXT-file not found!','Error opening file')
    return
elseif strcmp(num2str(handles.s_file),num2str(0)) && strcmp(num2str(handles.s_path),num2str(0))
    errordlg('Set output file!','Error saving file')
    return
end
msg = msgbox('Please wait...');
m = g_read_hrz(hParent,[]);
ind = ~strcmp(handles.col_names,'~');
m.col_names = handles.col_names(ind);
delete(msg);

% view TRACE HEADERS
function view_trc_hdrs(hObject, eventdata, hParent)
handles = guidata(hParent);
[trc_hdr_info,~] = g_get_trc_hdr_info;
f = findobj('Type','figure','Name','Trace headers');
if ~isempty(f)
    delete(f) % ������� figure
end
fhP_pos = hParent.Position;
f_pos = [fhP_pos(1)+fhP_pos(3)+16 fhP_pos(2) 200  fhP_pos(4)];
f = figure('Name','Trace headers','NumberTitle','off',...
    'ToolBar','figure','ToolBar','none','MenuBar', 'none','Resize','on',...
    'Position',f_pos);

uitable(f,'Data',trc_hdr_info(:,1:2),'ColumnName',{'Description';'Abbreviation'},...
    'Units','Normalized','Position',[0 0 1  1]);

% ACTION WHEN YOU CLOSE THE WINDOW
function read_hrz_closereq(hObject, eventdata)
f = findobj('Type','figure','Name','Trace headers');
if ~isempty(f)
    delete(f) % ������� figure
end
delete(gcf);
