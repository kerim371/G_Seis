function g_sortGUI
% Create a figure
hParent = figure('Name','SC sort','NumberTitle','off',...
    'Position',[200 100 380 600],'ToolBar','none','MenuBar','none','Resize','off');

handles = guidata(hParent);
handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.sort_type = 'ascend';
handles.hdr_selected = [];
guidata(hParent, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input/Output','FontWeight','bold',...
    'Units','Pixels','Position',[0 490 380 110]);

% Add a text uicontrol to label the slider GET FILE
txt1 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 550 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Seismic Filename to read...');

% Create push button GET FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 550 70 30],'Callback', {@open_f, hParent, txt1});

% Add a text uicontrol to label SAVE FILE
txt2 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 500 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 500 70 30],'Callback', {@save_f, hParent, txt2});

% Create push button RUN CALCULATIONS
btn3 = uicontrol('Style', 'pushbutton', 'String', 'RUN',...
    'Units','Pixels','Position', [300 500 70 30],'Enable','on',...
    'Callback', {@run_calc, hParent});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create buttongroup
bg = uibuttongroup('Title','Parameters','Visible','on','Units','pixels',...
                  'FontWeight','bold','Position',[0 450 380 40],...
                  'SelectionChangedFcn',{@bselection,hParent});
              
% Create radio buttons in the button group.
r1 = uicontrol(bg,'Style','radiobutton',...
                  'String','Ascend','Units','pixels',...
                  'Position',[10 5 80 20]);
              
% Create radio buttons in the button group.
r2 = uicontrol(bg,'Style','radiobutton',...
                  'String','Descend','Units','pixels',...
                  'Position',[100 5 80 20]);

% Create listbox ALL HEADERS
[hdr, ~] = g_get_trc_hdr_info;
ls1 = uicontrol('Style','list','String',hdr(:,1),'Units','pixels','Position',[0 0 250 450],...
                 'HorizontalAlign','left','Tag','LS1','Callback', {@fun_list1,hParent,hdr});

% Create listbox CHOSEN HEADERS
ls2 = uicontrol('Style','list','Units','pixels','Position',[270 0 110 450],...
                 'HorizontalAlign','left','Tag','LS2','Callback', {@fun_list2,hParent,hdr});


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

% radiobutton FIRWARD OR REVERSE GEOMETRICAL DIVERGENCE
function bselection(source,event,hParent)
handles = guidata(hParent);
sort_type = source.SelectedObject.String;
if strcmp(sort_type,'Ascend')
    handles.sort_type = 'ascend';
elseif strcmp(sort_type,'Descend')
    handles.sort_type = 'descend';
end
guidata(hParent, handles);

% FUNCTION FOR LISTBOX 1
function fun_list1(hObject, eventdata, hParent,hdr)
handles = guidata(hParent);
selected_ind = hObject.Value;
str1 = hObject.String;
if isempty(selected_ind)
    return
elseif strcmp(str1{selected_ind},'<HTML><FONT COLOR="red"> ***SELECTED*** </HTML>')
    return
end
str1{selected_ind} = '<HTML><FONT COLOR="red"> ***SELECTED*** </HTML>';
set(hObject,'String',str1);
ls2 = findobj(gcf,'Style','list','Tag','LS2');
str2 = ls2.String;
set(ls2,'String',[str2; hdr(selected_ind,2)]);
handles.hdr_selected = [str2; hdr(selected_ind,2)];
guidata(hParent, handles);

% FUNCTION FOR LISTBOX 2
function fun_list2(hObject, eventdata, hParent,hdr)
handles = guidata(hParent);
selected_ind = hObject.Value;
if isempty(selected_ind)
    hObject.Value = 1;
    return
end
str2 = hObject.String;
hdr_selected_ind = strcmp(hdr(:,2),str2{selected_ind});
ls1 = findobj(gcf,'Style','list','Tag','LS1');
str1 = ls1.String;
str1{hdr_selected_ind} = hdr{hdr_selected_ind,1};
set(ls1,'String',str1);
str2(selected_ind) = [];
if hObject.Value > 1
    hObject.Value = hObject.Value - 1; % or an error appears
end
set(hObject,'String',str2);
handles.hdr_selected = str2;
guidata(hParent, handles);

% button RUN CALCULATIONS
function run_calc(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
elseif strcmp(num2str(handles.s_file),num2str(0)) && strcmp(num2str(handles.s_path),num2str(0))
    errordlg('Set output file!','Error saving file')
    return
elseif isempty(handles.hdr_selected)
    errordlg('Chose headers to sort!','Error')
    return
end
tic
g_sort(hParent);
toc