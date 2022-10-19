function g_decomposition_timeGUI
% Create a figure
hParent = figure('Name','SC time decomposition','NumberTitle','off',...
    'Position',[200 200 600 540],'ToolBar','none',...
    'MenuBar', 'none','Resize','off');

handles = guidata(hParent);
handles.decomposition_type = 'time';
handles.survey_type = '2D Survey';
handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.hrz_path = '0';
handles.hrz_file = '0';
handles.restr_by_off_picks = 'offset';
handles.min_offset_1 = [];
handles.max_offset_1 = [];
handles.min_offset_2 = [];
handles.max_offset_2 = [];
handles.min_offset_3 = [];
handles.max_offset_3 = [];
handles.min_offset_4 = [];
handles.max_offset_4 = [];
handles.min_offset_5 = [];
handles.max_offset_5 = [];
handles.sc_model_num = 1;
handles.sol_method = 'Matlab solver for sparse matrice';
handles.n_iter = 20;
handles.spec_cond_1 = [];
handles.spec_cond_2 = [];
handles.spec_cond_4 = [];
handles.spec_cond_5_SP = [];
handles.spec_cond_5_RP = [];
handles.spec_cond_5_OFFSET = [];
handles.spec_cond_5_CDP = [];
handles.trc_hdr_table = [];
guidata(hParent, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input/Output files','FontWeight','bold',...
    'Units','Normalized','Position',[0 0 0.5 1]);

% Add a text uicontrol to label the slider GET FILE
txt1 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 490 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Seismic Filename to read...');

% Create push button GET FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 490 70 30],...
    'Callback', {@open_f, hParent, txt1});

% Add a text uicontrol to label SAVE FILE
txt2 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 440 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 440 70 30],...
    'Callback', {@save_f, hParent, txt2});

% Add a text uicontrol SP XY
txt21 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 412.5 150 15],'Enable','off',...
    'String','Source XY coordinates:');

% Create EDIT SP XY
ed21 = uicontrol('Style', 'edit','String','22 23',...
    'Position', [160 410 50 20],'Enable','off',...
    'Callback', {@ed21_sp_xy, hParent});

% Add a text uicontrol RP XY
txt22 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 392.5 150 15],'Enable','off',...
    'String','Receiver XY coordinates:');

% Create EDIT RP XY
ed22 = uicontrol('Style', 'edit','String','24 25',...
    'Position', [160 390 50 20],'Enable','off',...
    'Callback', {@ed22_rp_xy, hParent});

% Add a text uicontrol CDP XY
txt23 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 372.5 150 15],'Enable','off',...
    'String','CDP XY coordinates:');

% Create EDIT CDP XY
ed23 = uicontrol('Style', 'edit','String','72 73',...
    'Position', [160 370 50 20],'Enable','off',...
    'Callback', {@ed23_cdp_xy, hParent});

% Add a text uicontrol OFFSET
txt24 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 352.5 150 15],'Enable','off',...
    'String','OFFSET position:');

% Create EDIT OFFSET
ed24 = uicontrol('Style', 'edit','String','12',...
    'Position', [160 350 50 20],'Enable','off',...
    'Callback', {@ed24_offset, hParent});

% Add a text uicontrol IL XL
txt25 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 332.5 150 15],'Enable','off',...
    'String','IL XL position (3D survey):');

% Create EDIT IL XL
ed25 = uicontrol('Style', 'edit','String','74 75',...
    'Position', [160 330 50 20],'Enable','off',...
    'Callback', {@ed25_il_xl, hParent});

% Create EDIT TRACE TO PLOT
ed26 = uicontrol('Style', 'edit','String','1',...
    'Position', [220 390 60 20],'Enable','off',...
    'Callback', {@ed25_trace2plot, hParent});

% Create push button NEXT TRACE
btn21 = uicontrol('Style', 'pushbutton', 'String', '>>','Enable','off',...
    'Position', [250 410 30 20],'Callback', {@next_trace, hParent, ed26});

% Create push button PREVIOUS TRACE
btn22 = uicontrol('Style', 'pushbutton', 'String', '<<','Enable','off',...
    'Position', [220 410 30 20],'Callback', {@previous_trace, hParent, ed26});
              
% Create push button PLOT TRACE
btn23 = uicontrol('Style', 'pushbutton', 'String', 'Plot trace',...
    'Position', [220 370 60 20],'Callback', {@plot_trace, hParent, ed26, btn21, btn22});

% Add a checkbox uicontrol STANDARD SP RP CDP XY
chk1 = uicontrol('Style','checkbox','HorizontalAlignment','left',...
    'Position',[10 310 280 15],'Value',1,...
    'String','Standard header position',...
    'Callback', {@check1_xy,hParent,txt21,txt22,txt23,txt24,txt25,ed21,ed22,ed23,ed24,ed25});

% Create buttongroup
bg1 = uibuttongroup(p1,'Visible','on','BorderWidth',0,...
                  'FontWeight','bold','Position',[0 0.53 1 0.05],...
                  'SelectionChangedFcn',{@bselection,hParent,chk1,txt25,ed25});
              
% Create radio buttons in the button group.
r21 = uicontrol(bg1,'Style','radiobutton',...
                  'String','2D Survey','Units','Normalized',...
                  'Position',[0.02 0 0.25 1]);
              
% Create radio buttons in the button group.
r22 = uicontrol(bg1,'Style','radiobutton',...
                  'String','3D Survey','Units','Normalized',...
                  'Position',[0.4 0 0.25 1]);
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a text uicontrol to label GET HORIZON
txt3 = uicontrol('Style','text','FontAngle','italic','Enable','on',...
    'Position',[80 250 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Horizon (.mat) to read...');

% Create push button GET FILE
btn3 = uicontrol('Style', 'pushbutton', 'String', 'Horizon',...
    'Position', [10 250 70 30],'Enable','on',...
    'Callback', {@open_hrz, hParent, txt3});

% Create push button BTN RESTRICT BY PICKS
btn4 = uicontrol('Style', 'pushbutton', 'String', 'Restr picks',...
    'Position', [200 180 70 30],'Enable','off',...
    'Callback', {@fun_restr_by_picks, hParent, txt1, txt3});

% Create buttongroup
bg3 = uibuttongroup(p1,'Visible','on','BorderWidth',1,...
                  'FontWeight','bold','Position',[0 0.41 1 0.05],...
                  'SelectionChangedFcn',{@bselection3,hParent,btn4});
              
% Add a text RESTRICT BY OFFSET & PICKS
uicontrol(bg3,'Style','text','HorizontalAlignment','left','Enable','on',...
    'Units','Normalized','Position',[0.02 0 0.25 0.85],'String','Restrict by:');

% Create radio buttons in the button group.
r31 = uicontrol(bg3,'Style','radiobutton',...
                  'String','Offset','Units','Normalized',...
                  'Position',[0.32 0 0.25 1]);
              
% Create radio buttons in the button group.
r32 = uicontrol(bg3,'Style','radiobutton',...
                  'String','Picks','Units','Normalized',...
                  'Position',[0.7 0 0.25 1]);

% Add a text |MIN| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 192.5 130 15],'String',{'LAYER_1 |MIN| Offset:'; '|MAX| Offset:'});

% Create |MIN| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 190 50 20],'Enable','on',...
    'Callback', {@min_offset_1, hParent});

% Add a text |MAX| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 172.5 130 15],'String',{'LAYER_1 |MAX| Offset:'; '|MAX| Offset:'});

% Create  |MAX| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 170 50 20],'Enable','on',...
    'Callback', {@max_offset_1, hParent});

% Add a text |MIN| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 152.5 130 15],'String',{'LAYER_2 |MIN| Offset:'; '|MAX| Offset:'});

% Create |MIN| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 150 50 20],'Enable','on',...
    'Callback', {@min_offset_2, hParent});

% Add a text |MAX| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 132.5 130 15],'String',{'LAYER_2 |MAX| Offset:'; '|MAX| Offset:'});

% Create  |MAX| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 130 50 20],'Enable','on',...
    'Callback', {@max_offset_2, hParent});

% Add a text |MIN| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 112.5 130 15],'String',{'LAYER_3 |MIN| Offset:'; '|MAX| Offset:'});

% Create |MIN| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 110 50 20],'Enable','on',...
    'Callback', {@min_offset_3, hParent});

% Add a text |MAX| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 92.5 130 15],'String',{'LAYER_3 |MAX| Offset:'; '|MAX| Offset:'});

% Create  |MAX| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 90 50 20],'Enable','on',...
    'Callback', {@max_offset_3, hParent});

% Add a text |MIN| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 72.5 130 15],'String',{'LAYER_4 |MIN| Offset:'; '|MAX| Offset:'});

% Create |MIN| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 70 50 20],'Enable','on',...
    'Callback', {@min_offset_4, hParent});

% Add a text |MAX| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 52.5 130 15],'String',{'LAYER_4 |MAX| Offset:'; '|MAX| Offset:'});

% Create  |MAX| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 50 50 20],'Enable','on',...
    'Callback', {@max_offset_4, hParent});

% Add a text |MIN| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 32.5 130 15],'String',{'LAYER_5 |MIN| Offset:'; '|MAX| Offset:'});

% Create |MIN| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 30 50 20],'Enable','on',...
    'Callback', {@min_offset_5, hParent});

% Add a text |MAX| OFFSET
uicontrol('Style','text','HorizontalAlignment','left','Enable','on','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[10 12.5 130 15],'String',{'LAYER_5 |MAX| Offset:'; '|MAX| Offset:'});

% Create  |MAX| OFFSET
uicontrol('Style', 'edit',...
    'Position', [140 10 50 20],'Enable','on',...
    'Callback', {@max_offset_5, hParent});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a text uicontrol NUMBER OF ITERATIONS
txt4 = uicontrol('Style','text','HorizontalAlignment','left','Enable','off',...
    'Position',[460 402 70 30],'String','Number of Iterations:');
              
% Create NUMBER OF ITERATIONS
ed1 = uicontrol('Style', 'edit','String',20,...
    'Position', [540 405 50 20],'Enable','off',...
    'Callback', {@ed_n_iter, hParent});

% Create buttongroup
bg2 = uibuttongroup('Visible','on','Title','Computation parameters',...
                  'FontWeight','bold','Position',[0.5 0.6 0.5 0.4],...
                  'SelectionChangedFcn',{@bselection2,hParent,txt4,ed1});

% Add a text uicontrol MATHEMATICAL MODEL
uicontrol('Style','text','HorizontalAlignment','left','FontWeight','bold',...
    'Position',[307 505 200 15],'String','Selected mathematical model:');

% Create popup menu SC MODELS
sc_models = {'F(i,j) = S(i)+R(j)+M(cdp)*|i-j|';
             'F(i,j) = S(i)+R(j)+M(cdp)*|i-j|^2'};
pop1 = uicontrol('Style', 'popup','String', sc_models,...
    'FontName','Courier New','FontSize',9,...
    'Position', [310 480 282 20],'Callback', {@set_model, hParent});

% Add a text uicontrol SOLUTION METHOD
uicontrol('Style','text','HorizontalAlignment','left','FontWeight','bold',...
    'Position',[307 455 200 15],'String','Solution method:');

% Create radio buttons in the button group.
r3 = uicontrol(bg2,'Style','radiobutton',...
                  'String','Matlab solver for sparse matrice','Units','Normalized',...
                  'Position',[0.02 0.55 0.7 0.1],...
                  'HandleVisibility','off');
              
r4 = uicontrol(bg2,'Style','radiobutton',...
                  'String','Gauss-Seidel method','Units','Normalized',...
                  'Position',[0.02 0.47 0.5 0.1],...
                  'HandleVisibility','off');
              
r5 = uicontrol(bg2,'Style','radiobutton',...
                  'String','Jacobi method','Units','Normalized',...
                  'Position',[0.02 0.39 0.5 0.1],...
                  'HandleVisibility','off');

% Create push button RUN CALCULATIONS
btn5 = uicontrol('Style', 'pushbutton', 'String', 'RUN',...
    'Position', [540 440 50 30],'Enable','on',...
    'Callback', {@run_calc, hParent});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p4 = uipanel('Title','Special Conditions','FontWeight','bold',...
    'Units','Normalized','Position',[0.5 0 0.5 0.6]);

% Add a text uicontrol SPECIAL CONDITION 1
txt17 = uicontrol('Style','text','HorizontalAlignment','left','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[310 270 280 30],'String','Smoothed Source and Receiver components are equal. Moving average window length:');

% Create SPECIAL CONDITION 1 (ed_cond_smooth)
ed12 = uicontrol('Style', 'edit',...
    'Position', [540 270 50 15],'Enable','on',...
    'Callback', {@ed_cond_smooth, hParent});

% Add a text uicontrol SPECIAL CONDITION 2
txt18 = uicontrol('Style','text','HorizontalAlignment','left','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[310 230 280 30],'String','Merge neighboring CDP-points into one. New bin size in XY coordinate units FOR EACH LAYER:');

% Create SPECIAL CONDITION 2 (ed_merge_cdp)
ed13 = uicontrol('Style', 'edit',...
    'Position', [540 230 50 15],'Enable','on',...
    'Callback', {@ed_merge_cdp, hParent});

% Add a text uicontrol SPECIAL CONDITION 4
txt31 = uicontrol('Style','text','HorizontalAlignment','left','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[310 190 280 30],'String','Number of harmonics (cos) to approximate Offset factor FOR EACH LAYER (space delimited):');

% Create SPECIAL CONDITION 4 (ed_poly_decomp)
ed31 = uicontrol('Style', 'edit',...
    'Position', [540 190 50 15],'Enable','on',...
    'Callback', {@ed_poly_decomp, hParent});

% Add a text uicontrol SPECIAL CONDITION 5
txt32 = uicontrol('Style','text','HorizontalAlignment','left','BackgroundColor',[0.9 0.91 0.92],...
    'Position',[310 150 280 30],'String','Moving average is equal to a mean value of the whole line (SP, RP, OFFSET, CDP). Range of window:');

% Create SPECIAL CONDITION 5 (ed_mean_SP)
ed32 = uicontrol('Style', 'edit',...
    'Position', [310 130 50 15],'Enable','on',...
    'Callback', {@ed_mean_SP, hParent});

% Create SPECIAL CONDITION 5 (ed_mean_RP)
ed33 = uicontrol('Style', 'edit',...
    'Position', [370 130 50 15],'Enable','on',...
    'Callback', {@ed_mean_RP, hParent});

% Create SPECIAL CONDITION 5 (ed_mean_OFFSET)
ed34 = uicontrol('Style', 'edit',...
    'Position', [430 130 50 15],'Enable','on',...
    'Callback', {@ed_mean_OFFSET, hParent});

% Create SPECIAL CONDITION 5 (ed_mean_CDP)
ed35 = uicontrol('Style', 'edit',...
    'Position', [490 130 50 15],'Enable','on',...
    'Callback', {@ed_mean_CDP, hParent});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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

% EDIT SP XY
function ed21_sp_xy(hObject, eventdata, hParent)
ind_sp_xy = str2num(hObject.String);
if length(ind_sp_xy) == 2 && sum(~isinf(ind_sp_xy) & floor(ind_sp_xy) == ind_sp_xy) == 2 % ����� �����
    quest = ['Do you want exchange trace header positions 22-' num2str(ind_sp_xy(1)) 'and 23-' num2str(ind_sp_xy(2))];
    answer = questdlg(quest);
    switch answer
    case 'Yes'
        hdr_exchange(hParent,[22 23],ind_sp_xy)
        set(hObject,'String','22 23');
    otherwise
        set(hObject,'String','22 23');
    end
else
    errordlg('Enter two space delimited integer numbers for X and Y coordinate!','Error')
end

% EDIT RP XY
function ed22_rp_xy(hObject, eventdata, hParent)
ind_rp_xy = str2num(hObject.String);
if length(ind_rp_xy) == 2 && sum(~isinf(ind_rp_xy) & floor(ind_rp_xy) == ind_rp_xy) == 2 % ����� �����
    quest = ['Do you want exchange trace header positions 24-' num2str(ind_rp_xy(1)) 'and 25-' num2str(ind_rp_xy(2))];
    answer = questdlg(quest);
    switch answer
    case 'Yes'
        hdr_exchange(hParent,[24 25],ind_rp_xy)
        set(hObject,'String','24 25');
    otherwise
        set(hObject,'String','24 25');
    end
else
    errordlg('Enter two space delimited integer numbers for X and Y coordinate!','Error')
end

% EDIT CDP XY
function ed23_cdp_xy(hObject, eventdata, hParent)
ind_cdp_xy = str2num(hObject.String);
if length(ind_cdp_xy) == 2 && sum(~isinf(ind_cdp_xy) & floor(ind_cdp_xy) == ind_cdp_xy) == 2 % ����� �����
    quest = ['Do you want exchange trace header positions 72-' num2str(ind_cdp_xy(1)) 'and 73-' num2str(ind_cdp_xy(2))];
    answer = questdlg(quest);
    switch answer
    case 'Yes'
        hdr_exchange(hParent,[72 73],ind_cdp_xy)
        set(hObject,'String','72 73');
    otherwise
        set(hObject,'String','72 73');
    end
else
    errordlg('Enter two space delimited integer numbers for X and Y coordinate!','Error')
end

% EDIT OFFSET
function ed24_offset(hObject, eventdata, hParent)
ind_offset = str2num(hObject.String);
if length(ind_offset) == 1 && sum(~isinf(ind_offset) & floor(ind_offset) == ind_offset) == 1 % ����� �����
    quest = ['Do you want exchange trace header positions 72-' num2str(ind_offset) '?'];
    answer = questdlg(quest);
    switch answer
    case 'Yes'
        hdr_exchange(hParent,12,ind_offset)
        set(hObject,'String','12');
    otherwise
        set(hObject,'String','12');
    end
else
    errordlg('Enter single number for offset position in trace headers!','Error')
end

% EDIT IL XL
function ed25_il_xl(hObject, eventdata, hParent)
ind_il_xl = str2num(hObject.String);
if length(ind_il_xl) == 2 && sum(~isinf(ind_il_xl) & floor(ind_il_xl) == ind_il_xl) == 2 % ����� �����
    quest = ['Do you want exchange trace header positions 74-' num2str(ind_il_xl(1)) 'and 75-' num2str(ind_il_xl(2))];
    answer = questdlg(quest);
    switch answer
    case 'Yes'
        hdr_exchange(hParent,[72 73],ind_il_xl)
        set(hObject,'String','74 75');
    otherwise
        set(hObject,'String','74 75');
    end
else
    errordlg('Enter two space delimited integer numbers for Inline and Crossline position!','Error')
end

% EDIT trace to plot
function ed25_trace2plot(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.k = str2num(hObject.String);
if isempty(handles.k) || length(str2num(hObject.String)) > 1
    set(hObject,'String',1);
    handles.k = 1;
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);
g_seis_trace_plot_table(hParent);

% PREVIOUS trace
function previous_trace(hObject, eventdata, hParent, ed26)
handles = guidata(hParent);
handles.k = handles.k - 1;
guidata(hParent, handles);
ed26.String = handles.k;
g_seis_trace_plot_table(hParent);

% NEXT trace
function next_trace(hObject, eventdata, hParent, ed26)
handles = guidata(hParent);
handles.k = handles.k + 1;
guidata(hParent, handles);
ed26.String = handles.k;
g_seis_trace_plot_table(hParent);

% PLOT trace
function plot_trace(hObject, eventdata, hParent,ed26,btn21,btn22)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
end
ed26.Enable = 'on';
btn21.Enable = 'on';
btn22.Enable = 'on';

f1_pos = hParent.Position;
f2_pos = [f1_pos(1)+f1_pos(3)+16 f1_pos(2)-130 700  523];

if isempty(findobj('Type','figure','Name','Seismic trace and its header'))
    f2 = figure('Name','Seismic trace and its header','NumberTitle','off',...
        'ToolBar','figure','MenuBar', 'none','Resize','on',...
        'Position',f2_pos,'CloseRequestFcn',{@trc_closereq, hParent, ed26, btn21, btn22},...
        'KeyPressFcn',{@trc_keyPress, hParent, ed26});
    ax2 = axes('OuterPosition',[0.6 0.0 0.4 1]);
    handles.ax2 = ax2;
    handles.f2 = f2;
end
handles.k = 1;
ed25.String = '1';
% load input sesmic
handles.r_f = load([handles.r_path handles.r_file]);
handles.r_f = handles.r_f.seismic;
guidata(hParent, handles);
% PLOT
tic
g_seis_trace_plot_table(hParent);
toc

% CHECKBOX ENABLE/DISABLE EDIT SP RP CDP XY
function check1_xy(hObject, eventdata,hParent,txt21,txt22,txt23,txt24,txt25,ed21,ed22,ed23,ed24,ed25)
handles = guidata(hParent);
if hObject.Value == 1
    set(txt21,'Enable','off');
    set(txt22,'Enable','off');
    set(txt23,'Enable','off');
    set(txt24,'Enable','off');
    set(ed21,'Enable','off');
    set(ed22,'Enable','off');
    set(ed23,'Enable','off');
    set(ed24,'Enable','off');
    set(txt25,'Enable','off');
    set(ed25,'Enable','off');
elseif hObject.Value == 0
    set(txt21,'Enable','on');
    set(txt22,'Enable','on');
    set(txt23,'Enable','on');
    set(txt24,'Enable','on');
    set(ed21,'Enable','on');
    set(ed22,'Enable','on');
    set(ed23,'Enable','on');
    set(ed24,'Enable','on');
    if strcmp(handles.survey_type,'3D Survey')
        set(txt25,'Enable','on');
        set(ed25,'Enable','on');
    end
end
guidata(hParent, handles);

% radiobutton SURVEY TYPE
function bselection(source,event,hParent,chk1,txt25,ed25)
handles = guidata(hParent);
survey_type = source.SelectedObject.String;
if strcmp(survey_type,'2D Survey')
    handles.survey_type = '2D Survey';
    if chk1.Value == 0
        set(txt25,'Enable','off');
        set(ed25,'Enable','off');
    end
elseif strcmp(survey_type,'3D Survey')
    obj = findobj(source.Children,'String','2D Survey');
    source.SelectedObject = obj;
    handles.survey_type = '2D Survey';
    if chk1.Value == 0
        set(txt25,'Enable','off');
        set(ed25,'Enable','off');
    end
    warndlg('It doesnt work with 3D data yet!');
%     handles.survey_type = '3D Survey';
%     if chk1.Value == 0
%         set(txt25,'Enable','on');
%         set(ed25,'Enable','on');
%     end
end
guidata(hParent, handles);

% OPEN HORIZON
function open_hrz(hObject, eventdata, hParent, txt3)
handles = guidata(hParent);
[hrz_file,hrz_path] = uigetfile('*.mat');
if ~strcmp(num2str(hrz_file),num2str(0)) && ~strcmp(num2str(hrz_path),num2str(0))
    handles.hrz_file = hrz_file;
    handles.hrz_path = hrz_path;
    guidata(hParent, handles);
    set(txt3,'String',hrz_file);
end

% RESTRICT BY PICKS
function fun_restr_by_picks(hObject, eventdata, hParent, txt1, txt3)

if strcmp(txt1.String, 'Seismic Filename to read') || strcmp(txt3.String, 'Horizon (.mat) to read...')
    warndlg('Firstly you should choose a seismic-file and a horizon file!');
    return;
end
g_restr_by_picks(hParent);
msgbox(['Use <mouse 1> and <mouse 2> buttons. Remember that ',...
    'the nearsurface layers should have the smallest values. ',...
    'If a layer disappears and than appears again, then that ',...
    'should be two different layers. Dont use tha same layer '...
    'number for more than one layer.']);

% radiobutton RESTRICT BY OFFSET  OR PICKS
function bselection3(source,event,hParent,btn4)
handles = guidata(hParent);
survey_type = source.SelectedObject.String;
if strcmp(survey_type,'Offset')
    handles.restr_by_off_picks = 'offset';
    set(btn4,'Enable','off');
elseif strcmp(survey_type,'Picks')
    handles.restr_by_off_picks = 'picks';
    set(btn4,'Enable','on');
end
guidata(hParent, handles);

% |MIN| OFFSET 1
function min_offset_1(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.min_offset_1 = str2num(hObject.String);
if isempty(handles.min_offset_1) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.min_offset_1 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MAX| OFFSET 1
function max_offset_1(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.max_offset_1 = str2num(hObject.String);
if isempty(handles.max_offset_1) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.max_offset_1 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MIN| OFFSET 2
function min_offset_2(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.min_offset_2 = str2num(hObject.String);
if isempty(handles.min_offset_2) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.min_offset_2 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MAX| OFFSET 2
function max_offset_2(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.max_offset_2 = str2num(hObject.String);
if isempty(handles.max_offset_2) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.max_offset_2 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MIN| OFFSET 3
function min_offset_3(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.min_offset_3 = str2num(hObject.String);
if isempty(handles.min_offset_3) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.min_offset_3 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MAX| OFFSET 3
function max_offset_3(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.max_offset_3 = str2num(hObject.String);
if isempty(handles.max_offset_3) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.max_offset_3 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MIN| OFFSET 4
function min_offset_4(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.min_offset_4 = str2num(hObject.String);
if isempty(handles.min_offset_4) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.min_offset_4 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MAX| OFFSET 4
function max_offset_4(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.max_offset_4 = str2num(hObject.String);
if isempty(handles.max_offset_4) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.max_offset_4 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MIN| OFFSET 5
function min_offset_5(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.min_offset_5 = str2num(hObject.String);
if isempty(handles.min_offset_5) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.min_offset_5 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% |MAX| OFFSET 5
function max_offset_5(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.max_offset_5 = str2num(hObject.String);
if isempty(handles.max_offset_5) && ~isempty(hObject.String) || length(str2num(hObject.String)) > 1
    set(hObject,'String',[]);
    handles.max_offset_5 = [];
    errordlg('Enter a number, NOT a letter!','Error')
end
guidata(hParent, handles);

% SET MODEL popup menu
function set_model(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.sc_model_num = hObject.Value;
guidata(hParent, handles);

% radiobutton SOLUTION METHOD
function bselection2(source,event,hParent,txt4,ed1)
handles = guidata(hParent);
sol_method = source.SelectedObject.String;
if strcmp(sol_method,'Matlab solver for sparse matrice')
    handles.sol_method = 'Matlab solver for sparse matrice';
    set(txt4,'Enable','off');
    set(ed1,'Enable','off');
elseif strcmp(sol_method,'Gauss-Seidel method')
    handles.sol_method = 'Gauss-Seidel method';
    set(txt4,'Enable','on');
    set(ed1,'Enable','on');
elseif strcmp(sol_method,'Jacobi method')
    handles.sol_method = 'Jacobi method';
    set(txt4,'Enable','on');
    set(ed1,'Enable','on');
end
guidata(hParent, handles);

% SPECIAL CONDITION 1
function ed_cond_smooth(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.spec_cond_1 = str2num(hObject.String);
if (isempty(handles.spec_cond_1) || length(handles.spec_cond_1) > 1 || handles.spec_cond_1 <= 0) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.spec_cond_1 = [];
    errordlg('Enter a single number > 0 that indicates radius of moving average window!','Error')
end
guidata(hParent, handles);

% SPECIAL CONDITION 2
function ed_merge_cdp(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.spec_cond_2 = str2num(hObject.String);
if (isempty(handles.spec_cond_2) || sum(handles.spec_cond_2 <= 0) > 0) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.spec_cond_2 = [];
    errordlg('Enter a single number for 2D and two numbers for 3D survey (IL XL)!','Error')
end
guidata(hParent, handles);

% SPECIAL CONDITION 4
function ed_poly_decomp(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.spec_cond_4 = str2num(hObject.String);
if (isempty(handles.spec_cond_4) || sum(handles.spec_cond_4 <= 0) > 0 || length(handles.spec_cond_4) > 2) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.spec_cond_4 = [];
    errordlg('Enter numbers of cosine decomposition!','Error')
end
guidata(hParent, handles);

% SPECIAL CONDITION 5 SP
function ed_mean_SP(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.spec_cond_5_SP = str2num(hObject.String);
if (isempty(handles.spec_cond_5_SP) || sum(handles.spec_cond_5_SP <= 0) > 0 || length(handles.spec_cond_5_SP) > 1) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.spec_cond_5_SP = [];
    errordlg('Enter numbers of averaging SP!','Error')
end
guidata(hParent, handles);

% SPECIAL CONDITION 5 RP
function ed_mean_RP(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.spec_cond_5_RP = str2num(hObject.String);
if (isempty(handles.spec_cond_5_RP) || sum(handles.spec_cond_5_RP <= 0) > 0 || length(handles.spec_cond_5_RP) > 1) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.spec_cond_5_RP = [];
    errordlg('Enter numbers of averaging RP!','Error')
end
guidata(hParent, handles);

% SPECIAL CONDITION 5 OFFSET
function ed_mean_OFFSET(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.spec_cond_5_OFFSET = str2num(hObject.String);
if (isempty(handles.spec_cond_5_OFFSET) || sum(handles.spec_cond_5_OFFSET <= 0) > 0 || length(handles.spec_cond_5_OFFSET) > 1) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.spec_cond_5_OFFSET = [];
    errordlg('Enter numbers of averaging OFFSET!','Error')
end
guidata(hParent, handles);

% SPECIAL CONDITION 5 CDP
function ed_mean_CDP(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.spec_cond_5_CDP = str2num(hObject.String);
if (isempty(handles.spec_cond_5_CDP) || sum(handles.spec_cond_5_CDP <= 0) > 0 || length(handles.spec_cond_5_CDP) > 1) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.spec_cond_5_CDP = [];
    errordlg('Enter numbers of averaging CDP!','Error')
end
guidata(hParent, handles);

% button RUN CALCULATIONS
function run_calc(hObject, eventdata, hParent)
handles = guidata(hParent);
if isempty(dir([handles.r_path handles.r_file '.mat']))
    errordlg('SEISMIC-file not found!','Error opening file')
    return
end
if strcmp(num2str(handles.s_file),num2str(0)) && strcmp(num2str(handles.s_path),num2str(0))
    errordlg('Set output file!','Error saving file')
    return
end
set(hObject,'str','BUSY...','backg',[1 .6 .6]) % Change color of button.
guidata(hParent, handles);
g_decomposition_time(hParent);
set(hObject,'str','RUN','backg',[0.94 0.94 0.94])  % Now reset the button features.

% ������� ������������� ��� ������� �� ������ �������� ��������� (�������)
function trc_closereq(hObject, eventdata, hParent, ed25, btn21, btn22)
if isvalid(hParent)
    handles = guidata(hParent);
    handles = rmfield(handles,{'r_f'});
    if isvalid(ed25)
        if  isfield(get(ed25),'Enable') && isfield(get(btn21),'Enable') && isfield(get(btn22),'Enable')
            ed25.Enable = 'off';
            btn21.Enable = 'off';
            btn22.Enable = 'off';
        end
    end
    guidata(hParent,handles);
end
delete(gcf);

% ������� ������������� ��� ������� �� ������ ������� �����/������
function trc_keyPress(hObject, eventdata, hParent, ed25)
switch eventdata.Key
    case 'leftarrow'
        previous_trace(hObject, eventdata, hParent, ed25);
    case 'rightarrow'
        next_trace(hObject, eventdata, hParent, ed25);
end

% EXCHANGE HEADER POSITIONS
function hdr_exchange(hParent,ind_old,ind_new)
handles = guidata(hParent);
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',true);
hdr_old = r_m.Data.seis(ind_old,:);
hdr_new = r_m.Data.seis(ind_new,:);
r_m.Data.seis(ind_old,:) = hdr_new;
r_m.Data.seis(ind_new,:) = hdr_old;
msgbox('Done!');
clear;
