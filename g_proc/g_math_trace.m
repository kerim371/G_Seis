function g_math_trace(hParent)
handles = guidata(hParent);
% load input sesmic
if ~strcmp(num2str(handles.r_file_1),num2str(0)) && ~strcmp(num2str(handles.r_path_1),num2str(0))
    r_f1 = load([handles.r_path_1 handles.r_file_1]);
    r_f1 = r_f1.seismic;
    r_m1 = memmapfile([handles.r_path_1 handles.r_file_1 '.bin'],...
    'Format',{'single',[r_f1.nh+r_f1.ns r_f1.ntr],'seis'},'Writable',false);
end
if ~strcmp(num2str(handles.r_file_2),num2str(0)) && ~strcmp(num2str(handles.r_path_2),num2str(0))
    r_f2 = load([handles.r_path_2 handles.r_file_2]);
    r_f2 = r_f2.seismic;
    r_m2 = memmapfile([handles.r_path_2 handles.r_file_2 '.bin'],...
    'Format',{'single',[r_f2.nh+r_f2.ns r_f2.ntr],'seis'},'Writable',false);
end
s_fileID = fopen([handles.s_path handles.s_file '.bin'],'w'); % сохранять бинарные трассы и их заголовки
if s_fileID <= 0
    errordlg('The SAVE-file is busy with another process!','Error saving file');
    fclose all;
    clear;
    return
end

[hdr, ~] = g_get_trc_hdr_info;

fun = [];
eq_var = cell(0);
fun_expr = 'fun(';
for n = 1:size(hdr,1)
    trig_1 = contains(handles.equation,[hdr{n,2} '_1']);
    if trig_1 == 1
        eq_var{1,end+1} = [hdr{n,2} '_1'];
        fun_expr = [fun_expr 'r_m1.Data.seis(' num2str(n) ',:),'];
    end
    trig_2 = contains(handles.equation,[hdr{n,2} '_2']);
    if trig_2 == 1
        eq_var{1,end+1} = [hdr{n,2} '_2'];
        fun_expr = [fun_expr 'r_m2.Data.seis(' num2str(n) ',:),'];
    end
end
if contains(handles.equation,'FILE_1')
    eq_var{1,end+1} = 'FILE_1';
    fun_expr = [fun_expr 'r_m1.Data.seis,'];
end
if contains(handles.equation,'FILE_2')
    eq_var{1,end+1} = 'FILE_2';
    fun_expr = [fun_expr 'r_m2.Data.seis,'];
end

eq_var = strjoin(eq_var,',');
eq_var = ['@(' eq_var ',n) ' handles.equation]; % окончательная запись функции
fun_expr = [fun_expr 'n)'];

fun = str2func(eq_var); % запись функции в переменную "fun"

if ~strcmp(num2str(handles.r_file_1),num2str(0)) && ~strcmp(num2str(handles.r_path_1),num2str(0))
    N = size(r_m1.Data.seis,2);
else
    N = size(r_m2.Data.seis,2);
end
tic
for n = 1:N
    x = eval([fun_expr ';']); % вызов функции "fun"
    if isnumeric(x)
        fwrite(s_fileID,[r_m1.Data.seis(1:r_f1.nh,n); x(:)],'single');
    end
end
toc
seismic = r_f1;
seismic.param = handles;
save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;