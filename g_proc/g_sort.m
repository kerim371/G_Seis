function g_sort(hParent)
handles = guidata(hParent);
% load input sesmic
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);

s_fileID = fopen([handles.s_path handles.s_file '.bin'],'w'); % сохранять заголовки трасс
if s_fileID <= 0
    errordlg('The SAVE-file is busy with another process!','Error saving file');
    fclose all;
    clear;
    return
end

[hdr, ~] = g_get_trc_hdr_info;
hdrs = single(zeros(r_f.ntr,length(handles.hdr_selected))); % sort works column-wisely
for n = 1:length(handles.hdr_selected)
    ind = strcmp(hdr(:,2),handles.hdr_selected{n});
    hdrs(:,n) = r_m.Data.seis(ind,:); % in column
end
[~,ind] = sortrows(hdrs);

for n = 1:r_f.ntr
    fwrite(s_fileID,r_m.Data.seis(1:r_f.nh,ind(n)),'single');
    fwrite(s_fileID,r_m.Data.seis(r_f.nh+1:end,ind(n)),'single');
end

seismic = r_f;
seismic.param = handles;

save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;