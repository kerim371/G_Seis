% PLOT TRACE AND ITS HEADER
function g_trace_plot_table(hParent)
handles = guidata(hParent);
pos_format_str = {'4-byte IBM floating point';... % possible formats of SEGY
    '4-byte two, complement integer';...
    '2-byte two, complement integer';...
    '4-byte fixed point with gain (obsolete)';...
    '4-byte IEEE floating point';...
    'Not used yet';...
    'Not used yet';...
    '1-byte two, complement integer'};
pos_format_str(:,2) = {' ';...
    'int32';...
    'int16';...
    ' ';...
    'single';...
    ' ';...
    ' ';...
    'int8'};
% % файл для чтения
r_file = handles.r_file;
r_path = handles.r_path;
r_fileID = fopen([r_path r_file],'r');
% чтение бинарного заголовка
[bin_hdr, hParent] = scr_read_bin_hdr(r_fileID,hParent,pos_format_str);
handles = guidata(hParent);
% если есть дополнительные текстовые заголовки
if bin_hdr{29,4} > 0 
    for n = 1:bin_hdr{29,4}
        fseek(r_fileID,3200,'cof');
    end
end
% расчет количества отсчетов в трассах
r_info = dir([r_path r_file]);
nbytes = r_info.bytes;
if bin_hdr{29,4} >= 0
    ntr = (nbytes-400-3200*(bin_hdr{29,4}+1))/(bin_hdr{8,4}*handles.r_format_bytes+240); % байты перевожу в отсчеты 32битной трассы
elseif bin_hdr{29,4} < 0
    ntr = (nbytes-400-3200)/(bin_hdr{8,4}*handles.r_format_bytes+240);
end

% считывание и запись трасс и их заголовков, и запись остальных заголовков
handles = scr_read_traces(r_fileID,bin_hdr,hParent,pos_format_str,ntr);
guidata(hParent, handles);
fclose all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read BIN header
function [bin_hdr, hParent] = scr_read_bin_hdr(r_fileID,hParent,pos_format_str)
tic
handles = guidata(hParent);
bin_hdr_info = g_get_bin_hdr_info;

fseek(r_fileID,3200,'bof');
pos = ftell(r_fileID);
if strcmp(handles.r_select,'From binary header') % BIG ENDIAN
    four_bytes = fread(r_fileID,100,'integer*4','ieee-be');
    fseek(r_fileID,pos,'bof');
    two_bytes = fread(r_fileID,200,'integer*2','ieee-be');
    bin_hdr = [four_bytes(1:3); two_bytes(7:30); two_bytes(152:153)];
    bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
    if sum(bin_hdr{10,4} == 1:3) || sum(bin_hdr{10,4} == 5) || sum(bin_hdr{10,4} == 8)
        handles.r_format = pos_format_str{bin_hdr{10,4}};
        handles.endian = 'Big endian';
    else % LITTLE ENDIAN
        four_bytes = fread(r_fileID,100,'integer*4','ieee-le');
        fseek(r_fileID,pos,'bof');
        two_bytes = fread(r_fileID,200,'integer*2','ieee-le');
        bin_hdr = [four_bytes(1:3); two_bytes(7:30); two_bytes(152:153)];
        bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
        if sum(bin_hdr{10,4} == 1:3) || sum(bin_hdr{10,4} == 5) || sum(bin_hdr{10,4} == 8)
            handles.r_format = pos_format_str{bin_hdr{10,4}};
            handles.endian = 'Little endian';
        else
            errordlg('SEGY-unrecognized SEGY format!','Error reading file')
            return
        end
    end
    if bin_hdr{10,4} == 1 | bin_hdr{10,4} == 2 | bin_hdr{10,4} == 2 | bin_hdr{10,4} == 4 | bin_hdr{10,4} == 5
        handles.r_format_bytes = 4;
    elseif bin_hdr{10,4} == 3
        handles.r_format_bytes = 2;
    elseif bin_hdr{10,4} == 8
        handles.r_format_bytes = 1;
    end
elseif strcmp(handles.r_select,'Set manually')
    if strcmp(handles.endian,'Big endian') % BIG ENDIAN
        endian = 'ieee-be';
    elseif strcmp(handles.endian,'Little endian') % BIG ENDIAN
        endian = 'ieee-le';
    end
    four_bytes = fread(r_fileID,100,'integer*4',endian);
    fseek(r_fileID,pos,'bof');
    two_bytes = fread(r_fileID,200,'integer*2',endian);
    bin_hdr = [four_bytes(1:3); two_bytes(7:30); two_bytes(152:153)];
    bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
end
guidata(hParent, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read TRACES and their HEADERS, save ALL headers
function handles = scr_read_traces(r_fileID,bin_hdr,hParent,pos_format_str,ntr)
handles = guidata(hParent);
k = handles.k;

if k <=0
    errordlg('Trace number can"t be less than one!','Error');
    handles.k = 1;
    guidata(hParent, handles);
    return
elseif k > ntr
    errordlg('End of file is reached!','Error');
    handles.k = ntr;
    guidata(hParent, handles);
    return
end

[trc_hdr_info,ind] = g_get_trc_hdr_info; % функция возвращает информацию о загловках трасс

trc_hdr4 = zeros(size(trc_hdr_info,1),1);

if  strcmp(handles.endian,'Big endian')
    endian = 'ieee-be';
elseif strcmp(handles.endian,'Little endian')
    endian = 'ieee-le';
end
if strcmp(handles.r_select,'From binary header')
    if bin_hdr{10,4} == 1 % IBM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if bin_hdr{29,4} < 0
            fseek(r_fileID,3200+400+(k-1)*(240+bin_hdr{8,4}*4),'bof');
        elseif bin_hdr{29,4} >= 0
            fseek(r_fileID,3200*(bin_hdr{29,4}+1)+400+(k-1)*(240+bin_hdr{8,4}*4),'bof');
        end
        pos = ftell(r_fileID);
        trc_hdr4 = fread(r_fileID,60,'int32',endian);
        if isempty(trc_hdr4)
            return
        end
        fseek(r_fileID,pos,'bof');
        trc_hdr2 = fread(r_fileID,120,'int16',endian);
        trc_hdr_col = [trc_hdr4; trc_hdr2];
        trc_hdr = trc_hdr_col(ind);
        trace = ibm2single(fread(r_fileID,bin_hdr{8,4},'uint32=>uint32',endian)); % длина трассы из бинарного заголовка
        %trace = ibm2ieee(fread(r_fileID,bin_hdr{8,4},'uint',endian)); % тоже работает
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif sum(bin_hdr{10,4} == 2:3) ||  bin_hdr{10,4} == 5 || bin_hdr{10,4} == 8 % IEEE OR OTHER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        r_format = pos_format_str{bin_hdr{10,4},2};
        if bin_hdr{10,4} == 2 || bin_hdr{10,4} == 5 % 4 bytes
            nb = 4;
        elseif bin_hdr{10,4} == 3 % 2 bytes
            nb = 2;
        elseif bin_hdr{10,4} == 8 % 1 byte
            nb = 1;
        end
        if bin_hdr{29,4} < 0
            fseek(r_fileID,3200+400+(k-1)*(240+bin_hdr{8,4}*nb),'bof');
        elseif bin_hdr{29,4} >= 0
            fseek(r_fileID,3200*(bin_hdr{29,4}+1)+400+(k-1)*(240+bin_hdr{8,4}*nb),'bof');
        end
        pos = ftell(r_fileID);
        trc_hdr4 = fread(r_fileID,60,'int32',endian);
        if isempty(trc_hdr4)
            return
        end
        fseek(r_fileID,pos,'bof');
        trc_hdr2 = fread(r_fileID,120,'int16',endian);
        trc_hdr_col = [trc_hdr4; trc_hdr2];
        trc_hdr = trc_hdr_col(ind);
        trace = fread(r_fileID,bin_hdr{8,4},r_format,endian); % длина трассы из бинарного заголовка
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(handles.r_select,'Set manually')
    if strcmp(handles.r_format,'4-byte IBM floating point')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if bin_hdr{29,4} < 0
            fseek(r_fileID,3200+400+(k-1)*(240+bin_hdr{8,4}*4),'bof');
        elseif bin_hdr{29,4} >= 0
            fseek(r_fileID,3200*(bin_hdr{29,4}+1)+400+(k-1)*(240+bin_hdr{8,4}*4),'bof');
        end        
        pos = ftell(r_fileID);
        trc_hdr4 = fread(r_fileID,60,'int32',endian);
        if isempty(trc_hdr4)
            return
        end
        fseek(r_fileID,pos,'bof');
        trc_hdr2 = fread(r_fileID,120,'int16',endian);
        trc_hdr_col = [trc_hdr4; trc_hdr2];
        trc_hdr = trc_hdr_col(ind);
        trace = ibm2single(fread(r_fileID,bin_hdr{8,4},'uint32=>uint32',endian)); % длина трассы из бинарного заголовка
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Определяю формат для чтения
        for n = 1:8
            trig = strcmp(pos_format_str{n,1},handles.r_format);
            if trig == 1
                r_format = pos_format_str{n,2};
                if n == 2 || n == 5 % 4 bytes
                    nb = 4;
                elseif n == 3 % 2 bytes
                    nb = 2;
                elseif n == 8 %1 byte
                    nb = 1;
                end
                break
            end
        end
        if bin_hdr{29,4} < 0
            fseek(r_fileID,3200+400+(k-1)*(240+bin_hdr{8,4}*nb),'bof');
        elseif bin_hdr{29,4} >= 0
            fseek(r_fileID,3200*(bin_hdr{29,4}+1)+400+(k-1)*(240+bin_hdr{8,4}*nb),'bof');
        end
        pos = ftell(r_fileID);
        trc_hdr4 = fread(r_fileID,60,'int32',endian);
        if isempty(trc_hdr4)
            return
        end
        fseek(r_fileID,pos,'bof');
        trc_hdr2 = fread(r_fileID,120,'int16',endian);
        trc_hdr_col = [trc_hdr4; trc_hdr2];
        trc_hdr = trc_hdr_col(ind);
        trace = fread(r_fileID,bin_hdr{8,4},r_format,endian); % длина трассы из бинарного заголовка
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

trc_hdr_info(:,end+1) =  num2cell(trc_hdr);
trc_hdr = trc_hdr_info;

t = 0:bin_hdr{6,4}/1000:(bin_hdr{8,4}-1)*bin_hdr{6,4}/1000;
plot(handles.ax2,trace,t);
set(handles.ax2,'XDir','normal','YDir','reverse',...
    'XGrid','on','YGrid','on','YLim',[t(1) t(end)]);
set(handles.ax2.Title,'String',['Trace: ' num2str(k)]);

if isobject(handles.trc_hdr_table)
    if isvalid(handles.trc_hdr_table)
        set(handles.trc_hdr_table,'Data',trc_hdr);
    elseif ~isvalid(handles.trc_hdr_table)
        handles.trc_hdr_table = uitable(handles.f2,'Data',trc_hdr,'ColumnName',{'Description';'Abbreviation'; 'Start byte'; 'Length byte'; 'Value'},...
            'Units','Normalized','Position',[0 0 0.6  1],'RearrangeableColumns','off');
    end
elseif ~isobject(handles.trc_hdr_table)
    handles.trc_hdr_table = uitable(handles.f2,'Data',trc_hdr,'ColumnName',{'Description';'Abbreviation'; 'Start byte'; 'Length byte'; 'Value'},...
        'Units','Normalized','Position',[0 0 0.6  1],'RearrangeableColumns','off');
end