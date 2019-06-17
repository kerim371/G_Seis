function g_scale(hParent)
handles = guidata(hParent);
% load input sesmic
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;

if strcmp(handles.r_path,handles.s_path) && strcmp(handles.r_file,handles.s_file) % если файл-опен равен файлу-сэйв
    r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
        'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',true);
    r_m.Data.seis(r_f.nh+1:end,:) = r_m.Data.seis(r_f.nh+1:end,:)*handles.scale_num;
else
    r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
        'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);
    
    s_fileID = fopen([handles.s_path handles.s_file '.bin'],'w'); % сохранять бинарные трассы и заголовки трасс
    
    if s_fileID <=0
        errordlg('The  SAVE-file is busy with another process!','Error saving file');
        fclose all;
        return
    end
    
    for n = 1:r_f.ntr
        fwrite(s_fileID,[r_m.Data.seis(1:r_f.nh,n); r_m.Data.seis(r_f.nh+1:end,n)*handles.scale_num],'single');
    end
end

seismic = r_f;
seismic.param = handles;
save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;