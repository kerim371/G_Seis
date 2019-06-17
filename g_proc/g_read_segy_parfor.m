% READ SEGY FILE AND SAVE AS MATLAB FILE
function g_read_segy_parfor(hParent)
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
% файл для сохранения
s_file = handles.s_file;
s_path = handles.s_path;
% чтение текстового заголовка
txt_hdr = g_read_text_hdr(r_fileID);
% чтение бинарного заголовка
[bin_hdr, hParent] = g_read_bin_hdr(r_fileID,hParent,pos_format_str);
handles = guidata(hParent);
% если есть дополнительные текстовые заголовки
if bin_hdr{29,4} > 0 
    for n = 1:bin_hdr(29)
        text_hdr2 = g_read_text_hdr(r_fileID);
        txt_hdr = [txt_hdr; text_hdr2];
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

if mod(ntr,round(ntr)) ~= 0
    warndlg('Вероятно трассы имеют разную длительность, поэтому информация о количестве отсчетов берется из заголовков трасс','Warning');
end
% считывание и запись трасс и их заголовков, и запись остальных заголовков
g_read_traces(r_file,r_path,s_file,s_path,bin_hdr,txt_hdr,ntr,handles,pos_format_str,r_info);

fclose all;
clear;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read TEXT header
function txt_hdr = g_read_text_hdr(r_fileID)
txt_hdr = fread(r_fileID,3200,'uchar');
txt_hdr = reshape(txt_hdr,80,40)';
table = [   1,   2,   3, 156,   9, 134, 127, 151, 141, ...
        142,  11,  12,  13,  14,  15,  16,  17,  18,  19, ...
        157, 133,   8, 135,  24,  25, 146, 143,  28,  29, ...
         30,  31, 128, 129, 130, 131, 132,  10,  23,  27, ...
        136, 137, 138, 139, 140,   5,   6,   7, 144, 145, ...
         22, 147, 148, 149, 150,   4, 152, 153, 154, 155, ...
         20,  21, 158,  26,  32, 160, 161, 162, 163, 164, ...
        165, 166, 167, 168,  91,  46,  60,  40,  43,  33, ...
         38, 169, 170, 171, 172, 173, 174, 175, 176, 177, ...
         93,  36,  42,  41,  59,  94,  45,  47, 178, 179, ...
        180, 181, 182, 183, 184, 185, 124,  44,  37,  95, ...
         62,  63, 186, 187, 188, 189, 190, 191, 192, 193, ...
        194,  96,  58,  35,  64,  39,  61,  34, 195,  97, ...
         98,  99, 100, 101, 102, 103, 104, 105, 196, 197, ...
        198, 199, 200, 201, 202, 106, 107, 108, 109, 110, ...
        111, 112, 113, 114, 203, 204, 205, 206, 207, 208, ...
        209, 126, 115, 116, 117, 118, 119, 120, 121, 122, ...
        210, 211, 212, 213, 214, 215, 216, 217, 218, 219, ...
        220, 221, 222, 223, 224, 225, 226, 227, 228, 229, ...
        230, 231, 123,  65,  66,  67,  68,  69,  70,  71, ...
         72,  73, 232, 233, 234, 235, 236, 237, 125,  74, ...
         75,  76,  77,  78,  79,  80,  81,  82, 238, 239, ...
        240, 241, 242, 243,  92, 159,  83,  84,  85,  86, ...
         87,  88,  89,  90, 244, 245, 246, 247, 248, 249, ...
         48,  49,  50,  51,  52,  53,  54,  55,  56,  57, ...
        250, 251, 252, 253, 254, 255];

ascii_txt = char(txt_hdr);
if strcmp(ascii_txt(1,1),'C') == 1 && strcmp(ascii_txt(2,1),'C') == 1 && strcmp(ascii_txt(3,1),'C') == 1
    txt_hdr = char(txt_hdr);
else
    txt_hdr = double(txt_hdr);
    txt_hdr(txt_hdr < 1) = 1;
    txt_hdr(txt_hdr > length(table)) = length(table);
    txt_hdr = char(table(txt_hdr));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read BIN header
function [bin_hdr, hParent] = g_read_bin_hdr(r_fileID,hParent,pos_format_str)
handles = guidata(hParent);
bin_hdr_info = g_get_bin_hdr_info;

pos = ftell(r_fileID);
if strcmp(handles.r_select,'From binary header') % BIG ENDIAN
    four_bytes = fread(r_fileID,100,'integer*4','ieee-be');
    fseek(r_fileID,pos,'bof');
    two_bytes = fread(r_fileID,200,'integer*2','ieee-be');
    bin_hdr = [four_bytes(1:3); two_bytes(7:30); two_bytes(152:153)];
    bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
    if sum(bin_hdr{10,4} == 1:3) || sum(bin_hdr{10,4} == 5) || sum(bin_hdr{10,4} == 8)
        msgbox(['SEGY format: ' pos_format_str{bin_hdr{10,4}}, ', assuming BIG endian']);
        handles.r_format = pos_format_str{bin_hdr{10,4}};
        handles.endian = 'Big endian';
    else % LITTLE ENDIAN
        four_bytes = fread(r_fileID,100,'integer*4','ieee-le');
        fseek(r_fileID,pos,'bof');
        two_bytes = fread(r_fileID,200,'integer*2','ieee-le');
        bin_hdr = [four_bytes(1:3); two_bytes(7:30); two_bytes(152:153)];
        bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
        if sum(bin_hdr{10,4} == 1:3) || sum(bin_hdr{10,4} == 5) || sum(bin_hdr{10,4} == 8)
            msgbox(['SEGY format: ' pos_format_str{bin_hdr{10,4}}, ', assuming LITTLE endian']);
            handles.r_format = pos_format_str{bin_hdr{10,4}};
            handles.endian = 'Little endian';
        else
            errordlg('SEGY-unrecognized SEGY format!','Error reading file')
            return
        end
    end
    if bin_hdr{10,4} == 1 || bin_hdr{10,4} == 2 || bin_hdr{10,4} == 4 || bin_hdr{10,4} == 5
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
if bin_hdr{10,4} == 1 || bin_hdr{10,4} == 2 || bin_hdr{10,4} == 4 || bin_hdr{10,4} == 5
    handles.r_format_bytes = 4;
elseif bin_hdr{10,4} == 3
    handles.r_format_bytes = 2;
elseif bin_hdr{10,4} == 8
    handles.r_format_bytes = 1;
end
guidata(hParent, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read TRACES and their HEADERS, save ALL headers
function g_read_traces(r_file,r_path,s_file,s_path,bin_hdr,txt_hdr,ntr,handles,pos_format_str,r_info)
msg = msgbox({'Please wait until parallel pool is launched (this may take few minutes).';...
    'This window will automatically be closed when SEGY-file is read.';...
    'NOTE! Multicore SEGY reading assumes that all traces have the same size.'});

[trc_hdr_info,~] = g_get_trc_hdr_info; % функция возвращает информацию о загловках трасс
ns = bin_hdr{8,4}; % количество отсчетов
dt = bin_hdr{6,4}; % шаг дискретизации, мс
nh = size(trc_hdr_info,1); % количество считываемых заголовков трасс

jFile = java.io.RandomAccessFile([s_path s_file '.bin'], 'rw');
jFile.setLength((ntr*nh+ntr*ns)*4);
jFile.close();
clear jFile;

if bin_hdr{29,4} >= 0
    r_offset = 3200*(bin_hdr{29,4}+1)+400; % отступ если есть доп тхт хедер
elseif bin_hdr{29,4} < 0
    r_offset = 3200+400; % стандартный отступ для мемапфайл
end

if  strcmp(handles.endian,'Big endian')
    en = -1; % 'ieee-be'
elseif strcmp(handles.endian,'Little endian')
    en = 1; % 'ieee-le'
end
[~,~,pc_endian] = computer;
if strcmp(pc_endian,'B')
    en_pc = -1;
elseif strcmp(pc_endian,'L')
    en_pc = 1;
end

M = 10^4;
Ntr = 1:M:ntr;
parfor m = 1:length(Ntr)-1
    g_read_traces_loop(r_file,r_path,s_file,s_path,bin_hdr,ntr,r_offset,handles,pos_format_str,en,en_pc,ns,nh,r_info,Ntr,M,m);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Ntr(end) ~= ntr
    M = ntr - Ntr(end) + 1;
    Ntr = Ntr(end);
    m = 1;
    to = g_read_traces_loop(r_file,r_path,s_file,s_path,bin_hdr,ntr,r_offset,handles,pos_format_str,en,en_pc,ns,nh,r_info,Ntr,M,m);
end
    
seismic.txt_hdr = txt_hdr;
seismic.bin_hdr = bin_hdr;
seismic.trc_hdr_info = trc_hdr_info;
seismic.nh = nh;
seismic.ntr = ntr;
seismic.ns = ns;
seismic.dt = dt;
seismic.to = to;
seismic.plot_type = 'imagesc';
seismic.domain = 'Time';
save([s_path s_file '.mat'],'seismic');
delete(msg);
clear r_m;
clear s_trc_m;
clear s_hdr_m;
clear;

function to = g_read_traces_loop(r_file,r_path,s_file,s_path,bin_hdr,ntr,r_offset,handles,pos_format_str,en,en_pc,ns,nh,r_info,Ntr,M,m)
s_m = memmapfile([s_path s_file '.bin'],'Offset',(ns+nh)*(Ntr(m)-1)*4,'Format',...
    {'single',[ns+78 M],'seis'},'Repeat',1,'Writable',true);
r_m = memmapfile([r_path r_file],'Offset',r_offset+(r_info.bytes-r_offset)/ntr*(Ntr(m)-1),'Format',...
    {'uint8',[(r_info.bytes-r_offset)/ntr M],'sgy'},'Repeat',1,'Writable',true);
if en == en_pc
    for n = 1:7 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+1:n*4,:), 'int32');
        s_m.Data.seis(n,:) = trace;
    end
    for n = 1:4 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+29:n*2+28,:), 'int16');
        s_m.Data.seis(n+7,:) = trace;
    end
    for n = 1:8 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+37:n*4+36,:), 'int32');
        s_m.Data.seis(n+11,:) = trace;
    end
    for n = 1:2 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+69:n*2+68,:), 'int16');
        s_m.Data.seis(n+19,:) = trace;
    end
    for n = 1:4 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+73:n*4+72,:), 'int32');
        s_m.Data.seis(n+21,:) = trace;
    end
    for n = 1:46 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+89:n*2+88,:), 'int16');
        s_m.Data.seis(n+25,:) = trace;
        if n == 11
            to = trace(1);
        end
    end
    for n = 1:5 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+181:n*4+180,:), 'int32');
        s_m.Data.seis(n+71,:) = trace;
    end
    for n = 1:2 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+201:n*2+200,:), 'int16');
        s_m.Data.seis(n+76,:) = trace;
    end
elseif en ~= en_pc
    for n = 1:7 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+1:n*4,:), 'int32');
        s_m.Data.seis(n,:) = swapbytes(trace);
    end
    for n = 1:4 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+29:n*2+28,:), 'int16');
        s_m.Data.seis(n+7,:) = swapbytes(trace);
    end
    for n = 1:8 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+37:n*4+36,:), 'int32');
        s_m.Data.seis(n+11,:) = swapbytes(trace);
    end
    for n = 1:2 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+69:n*2+68,:), 'int16');
        s_m.Data.seis(n+19,:) = swapbytes(trace);
    end
    for n = 1:4 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+73:n*4+72,:), 'int32');
        s_m.Data.seis(n+21,:) = swapbytes(trace);
    end
    for n = 1:46 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+89:n*2+88,:), 'int16');
        s_m.Data.seis(n+25,:) = swapbytes(trace);
        if n == 11
            to = swapbytes(trace(1));
        end
    end
    for n = 1:5 % 4 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*4+181:n*4+180,:), 'int32');
        s_m.Data.seis(n+71,:) = swapbytes(trace);
    end
    for n = 1:2 % 2 bytes
        trace = typecastx(r_m.Data.sgy((n-1)*2+201:n*2+200,:), 'int16');
        s_m.Data.seis(n+76,:) = swapbytes(trace);
    end
end
if strcmp(handles.r_select,'From binary header')
    if bin_hdr{10,4} == 1 % IBM
        if en == en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), 'uint32');
                trace = ibm2single(trace);
                s_m.Data.seis(n+78,:) = trace;
            end
        elseif en ~= en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), 'uint32');
                trace = ibm2single(trace);
                s_m.Data.seis(n+78,:) = swapbytes(trace);
            end
        end
    elseif sum(bin_hdr{10,4} == 2:3) ||  bin_hdr{10,4} == 5 || bin_hdr{10,4} == 8 % IEEE OR OTHER
        r_format = pos_format_str{bin_hdr{10,4},2};
        if en == en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), r_format);
                s_m.Data.seis(n+78,:) = trace;
            end
        elseif en ~= en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), r_format);
                s_m.Data.seis(n+78,:) = swapbytes(trace);
            end
        end
    end
elseif strcmp(handles.r_select,'Set manually')
    if strcmp(handles.r_format,'4-byte IBM floating point')
        if en == en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), 'uint32');
                trace = ibm2single(trace);
                s_m.Data.seis(n+78,:) = trace;
            end
        elseif en ~= en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), 'uint32');
                trace = ibm2single(trace);
                s_m.Data.seis(n+78,:) = swapbytes(trace);
            end
        end
    else % если любой другой формат при ручном определении формата, Определяю формат для чтения
        for n = 1:8
            trig = strcmp(pos_format_str{n,1},handles.r_format);
            if trig == 1
                r_format = pos_format_str{n,2};
                break
            end
        end
        if en == en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), r_format);
                s_m.Data.seis(n+78,:) = trace;
            end
        elseif en ~= en_pc
            for n = 1:ns
                trace = typecastx(r_m.Data.sgy((n-1)*4+241:n*4+240,:), r_format);
                s_m.Data.seis(n+78,:) = swapbytes(trace);
            end
        end
    end
end
    
% ЗАКРЫТЬ ВСЕ ОКНА НА СЛУЧАЙ, ЕСЛИ WAITBAR ЗАТУПИЛ!!!!!!!!!
% set(groot,'ShowHiddenHandles','on')
% delete(get(groot,'Children'))