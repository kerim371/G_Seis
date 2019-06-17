% READ SEGY FILE AND SAVE AS MATLAB FILE
function g_read_segy(hParent)
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
% % файл дл€ чтени€
r_file = handles.r_file;
r_path = handles.r_path;
r_fileID = fopen([r_path r_file],'r');
% файл дл€ сохранени€
s_file = handles.s_file;
s_path = handles.s_path;
s_fileID = fopen([s_path s_file '.bin'],'w'); % сохран€ть бинарные трассы и их заголовки
if s_fileID <=0
    errordlg('The  SAVE-file is busy with another process!','Error saving file');
    fclose all;
    return
end
% чтение текстового заголовка
txt_hdr = g_read_text_hdr(r_fileID);
% чтение бинарного заголовка
[bin_hdr, hParent] = g_read_bin_hdr(r_fileID,hParent,pos_format_str);
handles = guidata(hParent);
% если есть дополнительные текстовые заголовки
if bin_hdr{29,4} > 0 
    for n = 1:bin_hdr{29,4}
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
    warndlg('¬еро€тно трассы имеют разную длительность, поэтому информаци€ о количестве отсчетов беретс€ из заголовков трасс','Warning');
end
% считывание и запись трасс и их заголовков, и запись остальных заголовков
g_read_traces(r_fileID,r_file,r_path,s_fileID,s_file,s_path,bin_hdr,txt_hdr,ntr,handles,pos_format_str);

fclose all;


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
guidata(hParent, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read TRACES and their HEADERS, save ALL headers
function g_read_traces(r_fileID,r_file,r_path,s_fileID,s_file,s_path,bin_hdr,txt_hdr,ntr,handles,pos_format_str)

pos = ftell(r_fileID);

[trc_hdr_info,ind] = g_get_trc_hdr_info; % функци€ возвращает информацию о загловках трасс
ns = bin_hdr{8,4}; % количество отсчетов
dt = bin_hdr{6,4}; % шаг дискретизации, мс

trc_hdr4 = zeros(size(trc_hdr_info,1),1);
k = 1;

r_info = dir([r_path r_file]); % информаци€ о считываемом —≈√¬ј… файле

if strcmp(handles.endian,'Big endian')
    endian = 'ieee-be';
elseif strcmp(handles.endian,'Little endian')
    endian = 'ieee-le';
end

f = waitbar(0,'SEGY reading process: 1 %','Name','Reading',... % WAITBAR
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0); % set CANCEL button 

if strcmp(handles.r_select,'From binary header')
    if bin_hdr{10,4} == 1 % IBM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if mod(ntr,round(ntr)) == 0 % если количество отсчетов ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = ibm2single(fread(r_fileID,ns,'uint32=>uint32',endian)); % длина трассы из бинарного заголовка
                %trace = ibm2ieee(fread(r_fileID,bin_hdr{8,4},'uint',endian)); % тоже работает
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        elseif mod(ntr,round(ntr)) ~= 0 % если количество отсчетов Ќ≈ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = ibm2single(fread(r_fileID,trc_hdr(39,k),'uint32=>uint32',endian)); % длина трассы из заголовка трассы
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif sum(bin_hdr{10,4} == 2:3) ||  bin_hdr{10,4} == 5 || bin_hdr{10,4} == 8 % IEEE OR OTHER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        r_format = pos_format_str{bin_hdr{10,4},2};
        if mod(ntr,round(ntr)) == 0 % если количество отсчетов ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = single(fread(r_fileID,ns,r_format,endian)); % длина трассы из бинарного заголовка
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        elseif mod(ntr,round(ntr)) ~= 0 % если количество отсчетов Ќ≈ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = single(fread(r_fileID,trc_hdr(39,k),r_format,endian)); % длина трассы из заголовка трассы
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
elseif strcmp(handles.r_select,'Set manually')
    if strcmp(handles.r_format,'4-byte IBM floating point')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if mod(ntr,round(ntr)) == 0 % если количество отсчетов ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = ibm2single(fread(r_fileID,ns,'uint32=>uint32',endian)); % длина трассы из бинарного заголовка
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        elseif mod(ntr,round(ntr)) ~= 0 % если количество отсчетов Ќ≈ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = ibm2single(fread(r_fileID,trc_hdr(39,k),'uint32=>uint32',endian)); % длина трассы из заголовка трассы
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else % если любой другой формат при ручном определении формата
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ќпредел€ю формат дл€ чтени€
        for n = 1:8
            trig = strcmp(pos_format_str{n,1},handles.r_format);
            if trig == 1
                r_format = pos_format_str{n,2};
                break
            end
        end
        if mod(ntr,round(ntr)) == 0 % если количество отсчетов ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = single(fread(r_fileID,ns,r_format,endian)); % длина трассы из бинарного заголовка
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        elseif mod(ntr,round(ntr)) ~= 0 % если количество отсчетов Ќ≈ѕќ—“ќяЌЌќ≈
            while ~isempty(trc_hdr4)
                trc_hdr4 = fread(r_fileID,60,'int32',endian);
                if isempty(trc_hdr4)
                    break
                end
                fseek(r_fileID,pos,'bof');
                trc_hdr2 = fread(r_fileID,120,'int16',endian);
                trc_hdr_col = [trc_hdr4; trc_hdr2];
                trc_hdr = single(trc_hdr_col(ind));
                trace = single(fread(r_fileID,trc_hdr(39),r_format,endian)); % длина трассы из заголовка трассы
                to = trc_hdr(36);
                pos = ftell(r_fileID);
                fwrite(s_fileID,[trc_hdr(:); trace(:)],'single');
                if k == 10^4
                    k = 0;
                    % Update WAITBAR and message
                    waitbar(pos/r_info.bytes,f,sprintf('SEGY reading progress: %.f %s',pos/r_info.bytes*100,'%'));
                end
                k = k+1;
                % Check for clicked Cancel button of WAITBAR
                if getappdata(f,'canceling')
                    warndlg('Process was terminated by user','Warning');
                    fclose all;
                    break
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
seismic.txt_hdr = txt_hdr;
seismic.bin_hdr = bin_hdr;
seismic.trc_hdr_info = trc_hdr_info;
seismic.nh = size(trc_hdr_info,1);
seismic.ntr = ntr;
seismic.ns = ns;
seismic.dt = dt;
seismic.to = to;
seismic.plot_type = 'imagesc';
seismic.domain = 'Time';
save([s_path s_file '.mat'],'seismic');
delete(f);
clear;

% «ј –џ“№ ¬—≈ ќ Ќј Ќј —Ћ”„ј…, ≈—Ћ» WAITBAR «ј“”ѕ»Ћ!!!!!!!!!
% set(groot,'ShowHiddenHandles','on')
% delete(get(groot,'Children'))