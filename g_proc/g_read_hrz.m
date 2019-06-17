function m = g_read_hrz(hParent,N)
handles = guidata(hParent);
fid = fopen([handles.r_path handles.r_file],'r');

ind = ~strcmp(handles.col_names,'~');

if strcmp(handles.delimiter,'Space')
    delim = ' ';
elseif strcmp(handles.delimiter,'Tab')
    delim = sprintf('\t');
elseif strcmp(handles.delimiter,'Comma')
    delim = ',';
elseif strcmp(handles.delimiter,'Dot')
    delim = '.';
end

if isempty(N)
    m = matfile([handles.s_path handles.s_file '.mat'],'Writable',true);
    m.hrz = [];
end

hrz = zeros(10^4,1);
k = 1;
while ~feof(fid) % пока не закончится файл
    s = fgetl(fid); % считываем текстовую строку
    s(s == delim) = ' '; % ставим пробелы вместо разделителей
    s = str2num(s); % переводим в числа
    if ~isempty(s)
        hrz(k,1:sum(ind)) = s(ind);
        k = k+1;
    end
    if isempty(N) && k == 10^4+1 % обязательно добавить единицу, иначе нулевая строка проскочит
        m.hrz = single([m.hrz; hrz]);
        hrz = zeros(10^4,1);
        k = 1;
    end
    if k == N % если N не пустая, то это в режиме VIEW работает
        break
    end
end

ind = any(hrz,2);
hrz = hrz(ind,:);
if isempty(N)
    m.hrz = single([m.hrz; hrz]); % если на запись, то аутпут из функции matfile
elseif ~isempty(N)
    m = hrz; % если не на запись, то аутпут из функции горизонт
end

fclose all;