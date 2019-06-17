function g_write_segy(hParent)
handles = guidata(hParent);
% load input SEISMIC
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);

s_hdr_fileID = fopen([handles.s_path handles.s_file '.sgy'],'w',handles.endian); % сохранять SEGY
if s_hdr_fileID <=0
    errordlg('The  SAVE-file is busy with another process!','Error saving file');
    fclose all;
    return
end

r_f.bin_hdr{10,4} = handles.s_format_num; % формат записи в СЕГВАЙ

fwrite(s_hdr_fileID,r_f.txt_hdr','uchar',handles.endian); % ASCII

fwrite(s_hdr_fileID,int32(cell2mat(r_f.bin_hdr(1:3,4))),'int32');
fwrite(s_hdr_fileID,int16(cell2mat(r_f.bin_hdr(4:27,4))),'int16');
fwrite(s_hdr_fileID,int16(zeros(121,1)),'int16');
fwrite(s_hdr_fileID,int16(cell2mat(r_f.bin_hdr(28:29,4))),'int16');
fwrite(s_hdr_fileID,int16(zeros(47,1)),'int16');

for n = 1:r_f.ntr
    hdr = r_m.Data.seis(1:r_f.nh,n);
    fwrite(s_hdr_fileID,int32(hdr(1:7)),'int32');
    fwrite(s_hdr_fileID,int16(hdr(8:11)),'int16');
    fwrite(s_hdr_fileID,int32(hdr(12:19)),'int32');
    fwrite(s_hdr_fileID,int16(hdr(20:21)),'int16');
    fwrite(s_hdr_fileID,int32(hdr(22:25)),'int32');
    fwrite(s_hdr_fileID,int16(hdr(26:71)),'int16');
    fwrite(s_hdr_fileID,int32(hdr(72:76)),'int32');
    fwrite(s_hdr_fileID,int16(hdr(77:78)),'int16');
    fwrite(s_hdr_fileID,int16(zeros(18,1)),'int16'); 
    
    trace = r_m.Data.seis(r_f.nh+1:end,n);
    if strcmp(handles.s_format,'4-byte IEEE floating point')
        fwrite(s_hdr_fileID,trace,'single');
    elseif strcmp(handles.s_format,'4-byte IBM floating point')
        fwrite(s_hdr_fileID,ieee2ibm(single(trace)),'single');
    elseif strcmp(handles.s_format,'4-byte two, complement integer')
        fwrite(s_hdr_fileID,trace,'int32');
    elseif strcmp(handles.s_format,'2-byte two, complement integer')
        fwrite(s_hdr_fileID,trace,'int16');
    elseif strcmp(handles.s_format,'1-byte two, complement integer')
        fwrite(s_hdr_fileID,trace,'int8');
    end
end

fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;