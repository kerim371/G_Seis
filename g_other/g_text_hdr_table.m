% VIEW BIN HEADER IN TABLE
function g_text_hdr_table(hParent)
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
% чтение текстового заголовка
txt_hdr = scr_read_text_hdr(r_fileID);
% чтение бинарного заголовка
[bin_hdr, handles] = scr_read_bin_hdr(r_fileID,handles,pos_format_str);
% если есть дополнительные текстовые заголовки
if bin_hdr{29,4} > 0 
    for n = 1:bin_hdr(29)
        text_hdr2 = scr_read_text_hdr(r_fileID);
        txt_hdr = [txt_hdr; text_hdr2];
    end
end

f1_pos = hParent.Position;
if isfield(handles,'bg2')
    f2_pos = [f1_pos(1)+f1_pos(3)+16 f1_pos(2)-205 450  580];
elseif ~isfield(handles,'bg2')
    f2_pos = [f1_pos(1)+f1_pos(3)+16 f1_pos(2)-330 450  580];
end
f2 = figure('Name','Text header','NumberTitle','off',...
    'ToolBar','none','MenuBar', 'none','Resize','on',...
    'Position',f2_pos);

handles.text_hdr_table = uicontrol(f2,'Style','text','String',txt_hdr,...
    'Units','Normalized','Position',[0 0 1  1],'HorizontalAlignment','left');
guidata(hParent, handles);

fclose all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read TEXT header
function txt_hdr = scr_read_text_hdr(r_fileID)
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
function [bin_hdr, handles] = scr_read_bin_hdr(r_fileID,handles,pos_format_str)
tic
bin_hdr_info = g_get_bin_hdr_info;

pos = ftell(r_fileID);
if strcmp(handles.r_select,'From binary header') % BIG ENDIAN
    four_bytes = fread(r_fileID,100,'integer*4','ieee-be');
    fseek(r_fileID,pos,'bof');
    two_bytes = fread(r_fileID,200,'integer*2','ieee-be');
    bin_hdr = [four_bytes(1:3); two_bytes(7:32)];
    bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
    if sum(bin_hdr{10,4} == 1:3) || sum(bin_hdr{10,4} == 5) || sum(bin_hdr{10,4} == 8)
        handles.r_format = pos_format_str{bin_hdr{10,4}};
        handles.endian = 'Big endian';
    else % LITTLE ENDIAN
        four_bytes = fread(r_fileID,100,'integer*4','ieee-le');
        fseek(r_fileID,pos,'bof');
        two_bytes = fread(r_fileID,200,'integer*2','ieee-le');
        bin_hdr = [four_bytes(1:3); two_bytes(7:32)];
        bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
        if sum(bin_hdr{10,4} == 1:3) || sum(bin_hdr{10,4} == 5) || sum(bin_hdr{10,4} == 8)
            handles.r_format = pos_format_str{bin_hdr{10,4}};
            handles.endian = 'Little endian';
        else
            errordlg('SEGY-unrecognized SEGY format!','Error reading file')
            return
        end
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
    bin_hdr = [four_bytes(1:3); two_bytes(7:32)];
    bin_hdr = [bin_hdr_info num2cell(bin_hdr)];
end