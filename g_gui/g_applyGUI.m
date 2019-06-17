function g_applyGUI
% Create a figure
hParent = figure('Name','SC apply','NumberTitle','off',...
    'Position',[400 400 310 360],'ToolBar','none',...
    'MenuBar', 'none','Resize','off');

handles = guidata(hParent);
handles.r_factors_file = '0';
handles.r_factors_path = '0';
handles.r_path = '0';
handles.r_file = '0';
handles.s_path = '0';
handles.s_file = '0';
handles.filt_len = [];
handles.filt_noise = 0.1;
handles.datum = [];
handles.vel_rep = [];
handles.lay_rep = [];
handles.trc_len = [];
handles.factors_rem = []; % what factors to remove
guidata(hParent, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p3 = uipanel('Title','Deconvolution parameters','FontWeight','bold',...
    'Units','Normalized','Position',[0 0 1 0.21]);

% Add a text uicontrol FILTER LENGTH
txt1 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 30 90 15],'String','Filter length, ms:','Enable','off');
              
% Create FILTER LENGTH
ed1 = uicontrol('Style', 'edit',...
    'Position', [100 27.5 50 20],'Enable','off',...
    'Callback', {@ed_filt_len, hParent});

% Add a text uicontrol NOISE
txt2 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 10 90 15],'String','Noise, %:','Enable','off');
              
% Create NOISE
ed2 = uicontrol('Style', 'edit','String',0.1,...
    'Position', [100 7.5 50 20],'Enable','off',...
    'Callback', {@ed_filt_noise, hParent});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p2 = uipanel('Title','Static parameters','FontWeight','bold',...
    'Units','Normalized','Position',[0 0.21 1 0.21]);

% Add a text uicontrol DATUM
txt7 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 110 90 15],'String','Datum:','Enable','off');
              
% Create FILTER LENGTH
ed3 = uicontrol('Style', 'edit',...
    'Position', [100 107.5 50 20],'Enable','off',...
    'Callback', {@ed_datum, hParent});

% Add a text uicontrol REPLACEMENT VELOCITY
txt8 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[10 80 90 30],'String','Replacement velocity:','Enable','off');
              
% Create REPLACEMENT VELOCITY
ed4 = uicontrol('Style', 'edit',...
    'Position', [100 87.5 50 20],'Enable','off',...
    'Callback', {@ed_vel_replace, hParent});

% Add a text uicontrol LAYERS TO REPLACE
txt9 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[160 110 90 30],'String','Number of layers to replace:','Enable','off');
              
% Create LAYERS TO REPLACE
ed5 = uicontrol('Style', 'edit',...
    'Position', [250 107.5 50 20],'Enable','off',...
    'Callback', {@ed_lay_replace, hParent});

% Add a text uicontrol TRACE LENGTH
txt10 = uicontrol('Style','text','HorizontalAlignment','left',...
    'Position',[160 80 90 30],'String','New trace length, ms:','Enable','off');
              
% Create TRACE LENGTH
ed6 = uicontrol('Style', 'edit',...
    'Position', [250 87.5 50 20],'Enable','off',...
    'Callback', {@ed_trace_len, hParent});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Input/Output files','FontWeight','bold',...
    'Units','Normalized','Position',[0 0.41 1 0.79]);

% Add a text uicontrol to label FACTORS TO EXCLUDE FROM DATA
txt3 = uicontrol('Style','text','HorizontalAlignment','left','Enable','on',...
    'Position',[10 180 150 15],'String','Factors to exclude from data:');

% Add a checkbox uicontrol SHOT
chk1 = uicontrol('Style','checkbox','HorizontalAlignment','left',...
    'Position',[10 160 50 10],'Value',0,'String','SHOT','Enable','off');

% Add a checkbox uicontrol RECEIVER
chk2 = uicontrol('Style','checkbox','HorizontalAlignment','left',...
    'Position',[70 160 70 10],'Value',0,'String','RECEIVER','Enable','off');

% Add a checkbox uicontrol OFFSET
chk3 = uicontrol('Style','checkbox','HorizontalAlignment','left',...
    'Position',[150 160 60 10],'Value',0,'String','OFFSET','Enable','off');

% Add a checkbox uicontrol CDP
chk4 = uicontrol('Style','checkbox','HorizontalAlignment','left',...
    'Position',[220 160 40 10],'Value',0,'String','CDP','Enable','off');

% Add a text uicontrol to label the slider GET FACTORS FILE
txt4 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 310 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Factors Filename to read...');

% Create push button GET FACTORS FILE
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 310 70 30],...
    'Callback', {@open_factors, hParent,txt1,txt2,txt4,txt7,txt8,txt9,txt10,ed1,ed2,ed3,ed4,ed5,ed6,chk1,chk2,chk3,chk4});

% Add a text uicontrol to label the slider GET FILE
txt5 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 260 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Seismic Filename to read...');

% Create push button GET FILE
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Open',...
    'Position', [10 260 70 30],...
    'Callback', {@open_f, hParent, txt5});

% Add a text uicontrol to label SAVE FILE
txt6 = uicontrol('Style','text','FontAngle','italic',...
    'Position',[80 210 200 30],'BackgroundColor',[0.9 0.91 0.92],...
    'String','Save as...');

% Create push button SAVE FILE
btn3 = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [10 210 70 30],...
    'Callback', {@save_f, hParent, txt6});

% Create push button RUN
btn5 = uicontrol('Style', 'pushbutton', 'String', 'RUN',...
    'Position', [250 10 50 50],...
    'Callback', {@run_calc, hParent, chk1,chk2,chk3,chk4});




% OPEN FACTORS file
function open_factors(hObject, eventdata, hParent,txt1,txt2,txt4,txt7,txt8,txt9,txt10,ed1,ed2,ed3,ed4,ed5,ed6,chk1,chk2,chk3,chk4)
handles = guidata(hParent);
[r_factors_file,r_factors_path] = uigetfile('*.mat');
if ~strcmp(num2str(r_factors_file),num2str(0)) && ~strcmp(num2str(r_factors_path),num2str(0))
    r_f_fact = load([r_factors_path r_factors_file]);
    r_f_fact = r_f_fact.seismic;
    if isfield(r_f_fact,'param')
        if isfield(r_f_fact.param,'decomposition_type')
            if strcmp(r_f_fact.param.decomposition_type,'amplitude')
                set(txt1,'Enable','off');
                set(txt2,'Enable','off');
                set(txt7,'Enable','off');
                set(txt8,'Enable','off');
                set(txt9,'Enable','off');
                set(txt10,'Enable','off');
                set(ed1,'Enable','off');
                set(ed2,'Enable','off');
                set(ed3,'Enable','off');
                set(ed4,'Enable','off');
                set(ed5,'Enable','off');
                set(ed6,'Enable','off');
            elseif strcmp(r_f_fact.param.decomposition_type,'spectrum')
                set(txt1,'Enable','on');
                set(txt2,'Enable','on');
                set(txt7,'Enable','on');
                set(txt8,'Enable','on');
                set(txt9,'Enable','on');
                set(txt10,'Enable','on');
                set(ed1,'Enable','on');
                set(ed2,'Enable','on');
                set(ed3,'Enable','on');
                set(ed4,'Enable','on');
                set(ed5,'Enable','on');
                set(ed6,'Enable','on');
            elseif strcmp(r_f_fact.param.decomposition_type,'time')
                set(txt1,'Enable','off');
                set(txt2,'Enable','off');
                set(txt7,'Enable','on');
                set(txt8,'Enable','on');
                set(txt9,'Enable','on');
                set(txt10,'Enable','on');
                set(ed1,'Enable','off');
                set(ed2,'Enable','off');
                set(ed3,'Enable','on');
                set(ed4,'Enable','on');
                set(ed5,'Enable','on');
                set(ed6,'Enable','on');
            end
        elseif ~isfield(r_f_fact.param,'decomposition_type')
            errordlg('A chosen file does not contain decomposed factors!','Error')
            return
        end
        if isfield(r_f_fact.param,'sc_model_num') && ~strcmp(r_f_fact.param.decomposition_type,'time')
            if r_f_fact.param.sc_model_num == 1 || r_f_fact.param.sc_model_num == 5
                set(chk1,'Enable','on');
                set(chk2,'Enable','on');
                set(chk3,'Enable','off');
                set(chk4,'Enable','off');
            elseif r_f_fact.param.sc_model_num == 2 || r_f_fact.param.sc_model_num == 6
                set(chk1,'Enable','on');
                set(chk2,'Enable','on');
                set(chk3,'Enable','on');
                set(chk4,'Enable','off');
            elseif r_f_fact.param.sc_model_num == 3 || r_f_fact.param.sc_model_num == 7
                set(chk1,'Enable','on');
                set(chk2,'Enable','on');
                set(chk3,'Enable','on');
                set(chk4,'Enable','on');
            elseif r_f_fact.param.sc_model_num == 4 || r_f_fact.param.sc_model_num == 8
                set(chk1,'Enable','off');
                set(chk2,'Enable','off');
                set(chk3,'Enable','on');
                set(chk4,'Enable','on');
            elseif r_f_fact.param.sc_model_num == 9
                set(chk1,'Enable','on');
                set(chk2,'Enable','on');
                set(chk3,'Enable','off');
                set(chk4,'Enable','on');
            end
        elseif ~isfield(r_f_fact.param,'sc_model_num')
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

% EDIT DATUM
function ed_datum(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.datum = str2num(hObject.String);
if (isempty(handles.datum) || length(handles.datum) > 1) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.datum = [];
    errordlg('Enter a single number!','Error')
end
guidata(hParent, handles);

% EDIT REPLACEMENT VELOCITY
function ed_vel_replace(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.vel_rep = str2num(hObject.String);
if (isempty(handles.vel_rep) || length(handles.vel_rep) > 1 || handles.vel_rep <= 0) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.vel_rep = [];
    errordlg('Enter a single number > 0!','Error')
end
guidata(hParent, handles);

% EDIT LAYERS TO REPLACE
function ed_lay_replace(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.lay_rep = str2num(hObject.String);
if (isempty(handles.lay_rep) || length(handles.lay_rep) > 1 || handles.lay_rep < 0) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.lay_rep = [];
    errordlg('Enter a single number >= 0!','Error')
end
guidata(hParent, handles);

% EDIT TRACE LENGTH
function ed_trace_len(hObject, eventdata, hParent)
handles = guidata(hParent);
handles.trc_len = str2num(hObject.String);
if (isempty(handles.trc_len) || length(handles.trc_len) > 1 || handles.trc_len <= 0) && ~isempty(hObject.String)
    set(hObject,'String',[]);
    handles.trc_len = [];
    errordlg('Enter a single number > 0!','Error')
end
guidata(hParent, handles);

% RUN CALCULATIONS
function run_calc(hObject, eventdata, hParent,chk1,chk2,chk3,chk4)
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
handles.factors_rem = [];
if get(chk1,'Value') == 1 && strcmp(get(chk1,'Enable'),'on')
    handles.factors_rem = [handles.factors_rem 1];
end
if get(chk2,'Value') == 1 && strcmp(get(chk2,'Enable'),'on')
    handles.factors_rem = [handles.factors_rem 2];
end
if get(chk3,'Value') == 1 && strcmp(get(chk3,'Enable'),'on')
    handles.factors_rem = [handles.factors_rem 3];
end
if get(chk4,'Value') == 1 && strcmp(get(chk4,'Enable'),'on')
    handles.factors_rem = [handles.factors_rem 4];
end
guidata(hParent, handles);

r_f_fact = load([handles.r_factors_path handles.r_factors_file]);
r_f_fact = r_f_fact.seismic;
if strcmp(r_f_fact.param.decomposition_type,'amplitude')
    g_apply_amp(hParent);
elseif strcmp(r_f_fact.param.decomposition_type,'spectrum')
    g_apply_spec(hParent);
elseif strcmp(r_f_fact.param.decomposition_type,'time')
    g_apply_time(hParent);
end