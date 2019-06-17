function g_math_header(hParent)
handles = guidata(hParent);
% load input sesmic
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;

r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',true);

[hdr, ~] = g_get_trc_hdr_info;

fun = [];
eq_var = cell(0);
fun_expr = 'fun(';
for n = 1:size(hdr,1)
    trig = contains(handles.equation,hdr{n,2});
    if trig == 1
        eq_var{1,end+1} = hdr{n,2};
        fun_expr = [fun_expr 'r_m.Data.seis(' num2str(n) ',:),'];
    end
end
eq_var = strjoin(eq_var,',');
eq_var = ['@(' eq_var ') ' handles.equation]; % окончательная запись функции
if strcmp(fun_expr,'fun(')
    fun_expr(end+1) = ')';
elseif ~strcmp(fun_expr,'fun(')
    fun_expr(end) = ')';
end

fun = str2func(eq_var); % запись функции в переменную "fun"

x = eval([fun_expr ';']); % вызов функции "fun"
if isnumeric(x)
    r_m.Data.seis(handles.hdr_clc,:) = x;
    g_seis_trc_hdr_table(hParent,r_f,r_m,r_f.trc_hdr_info(:,2))
end