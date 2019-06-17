function g_apply_spec(hParent)
handles = guidata(hParent);
% load input FACTORS
r_f_fact = load([handles.r_factors_path handles.r_factors_file]);
r_f_fact = r_f_fact.seismic;
r_m_fact = memmapfile([handles.r_factors_path handles.r_factors_file '.bin'],...
    'Format',{'single',[r_f_fact.nh+r_f_fact.ns r_f_fact.ntr],'seis'},'Writable',false);
% load input SEISMIC
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);

s_fileID = fopen([handles.s_path handles.s_file '.bin'],'w'); % сохранять заголовки трасс
if s_fileID <=0
    errordlg('The  SAVE-file is busy with another process!','Error saving file');
    fclose all;
    return
end

fact_ID = r_m_fact.Data.seis(1,:);
s_min = min(find(fact_ID == 1));
s_max = max(find(fact_ID == 1));
r_min = min(find(fact_ID == 2));
r_max = max(find(fact_ID == 2));
off_min = min(find(fact_ID == 3));
off_max = max(find(fact_ID == 3));
cdp_min = min(find(fact_ID == 4));
cdp_max = max(find(fact_ID == 4));
mean_log(:,1) = mean(r_m_fact.Data.seis(r_f_fact.nh+1:end,fact_ID == 1),2);
mean_log(:,2) = mean(r_m_fact.Data.seis(r_f_fact.nh+1:end,fact_ID == 2),2);
mean_log(:,3) = mean(r_m_fact.Data.seis(r_f_fact.nh+1:end,fact_ID == 3),2);
mean_log(:,4) = mean(r_m_fact.Data.seis(r_f_fact.nh+1:end,fact_ID == 4),2);

win_len = length(r_f_fact.param.win_above:r_f_fact.dt/1000:r_f_fact.param.win_below);
if mod(win_len,2) == 0
    ind_fft = 2:win_len/2;
elseif mod(win_len,2) ~= 0
    ind_fft = 2:(win_len+1)/2;
end
if isempty(handles.filt_len)
    handles.filt_len = round(win_len./2);
end
if isempty(handles.filt_noise)
    handles.filt_noise = 0.1;
end
guidata(hParent, handles);
if any(r_f_fact.param.sc_model_num == [1 2 3 4])
    k = 1;
elseif any(r_f_fact.param.sc_model_num == [5 6 7 8])
    k = 2;
end

tic
ind = zeros(1,4);
for n = 1:size(r_m.Data.seis,2)
    if any(handles.factors_rem == 1)
        xy = r_m.Data.seis(22:23,n);
        [~, ind(1)] = min(sqrt((r_m_fact.Data.seis(22,s_min:s_max)-xy(1)).^2+(r_m_fact.Data.seis(23,s_min:s_max)-xy(2)).^2));
        ind(1) = ind(1)+s_min-1;
        d_fact(:,1) = r_m_fact.Data.seis(r_f_fact.nh+1:end,ind(1)) - mean_log(:,1);
    end
    if any(handles.factors_rem == 2)
        xy = r_m.Data.seis(24:25,n);
        [~, ind(2)] = min(sqrt((r_m_fact.Data.seis(24,r_min:r_max)-xy(1)).^2+(r_m_fact.Data.seis(25,r_min:r_max)-xy(2)).^2));
        ind(2) = ind(2)+r_min-1;
        d_fact(:,2) = r_m_fact.Data.seis(r_f_fact.nh+1:end,ind(2)) - mean_log(:,2);
    end
    if any(handles.factors_rem == 3)
        xy = r_m.Data.seis(72:73,n);
        [~, ind(3)] = min(sqrt((r_m_fact.Data.seis(72,off_min:off_max)-xy(1)).^2+(r_m_fact.Data.seis(73,off_min:off_max)-xy(2)).^2));
        ind(3) = ind(3)+off_min-1;
        l = r_m.Data.seis(12,n);
        d_fact(:,3) = r_m_fact.Data.seis(r_f_fact.nh+1:end,ind(3))*abs(l).^k - mean_log(:,3)*abs(l).^k;
    end
    if any(handles.factors_rem == 4)
        xy = r_m.Data.seis(72:73,n);
        [~, ind(4)] = min(sqrt((r_m_fact.Data.seis(72,cdp_min:cdp_max)-xy(1)).^2+(r_m_fact.Data.seis(73,cdp_min:cdp_max)-xy(2)).^2));
        ind(4) = ind(4)+cdp_min-1;
        d_fact(:,4) = r_m_fact.Data.seis(r_f_fact.nh+1:end,ind(4)) - mean_log(:,4);
    end
    spec = exp(sum(d_fact,2));
    %spec = sum(d_fact,2);
    autocor = double(ifft([spec; flipud(spec(ind_fft))],'symmetric'));
    autocor(1) = (handles.filt_noise/100+1)*autocor(1);
    lev = levinson(autocor(1:round(length(autocor)/2)),handles.filt_len/r_f_fact.dt*1000);
    trace = single(conv(r_m.Data.seis(r_f.nh+1:end,n),lev','full'));
    
    fwrite(s_fileID,[r_m.Data.seis(1:r_f.nh,n); trace(1:size(r_m.Data.seis,1)-r_f.nh)],'single');
end
toc
seismic = r_f;
seismic.param = handles;
seismic.plot_type = 'imagesc';

save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');