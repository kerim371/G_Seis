function g_apply_amp(hParent)
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

s_fileID = fopen([handles.s_path handles.s_file '.bin'],'w'); % сохранять тряссы и их заголовки
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
off13_min = min(find(fact_ID == 13));
off13_max = max(find(fact_ID == 13));
mean_log(1) = mean(r_m_fact.Data.seis(r_f_fact.nh+1,fact_ID == 1));
mean_log(2) = mean(r_m_fact.Data.seis(r_f_fact.nh+1,fact_ID == 2));
mean_log(3) = mean(r_m_fact.Data.seis(r_f_fact.nh+1,fact_ID == 3));
mean_log(4) = mean(r_m_fact.Data.seis(r_f_fact.nh+1,fact_ID == 4));
mean_log(5) = mean(r_m_fact.Data.seis(r_f_fact.nh+1,fact_ID == 13));

F = scatteredInterpolant(double(r_m_fact.Data.seis(72:73,off_min:off_max))',...
    double(r_m_fact.Data.seis(r_f_fact.nh+1,off_min:off_max))','linear','nearest');
tic
    %%
fwrite(s_fileID,r_m.Data.seis,'single');
s_m = memmapfile([handles.s_path handles.s_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',true);
if any(handles.factors_rem == 1)
    s_xy = r_m.Data.seis(22:23,:)';
    [Us_xy,~,~] = unique(s_xy,'stable','rows');
    for n = 1:size(Us_xy,1)
        ind_tr = Us_xy(n,1) == s_xy(:,1) & Us_xy(n,2) == s_xy(:,2);
        [~, ind_fac] = min(sqrt((r_m_fact.Data.seis(22,s_min:s_max)-Us_xy(n,1)).^2+(r_m_fact.Data.seis(23,s_min:s_max)-Us_xy(n,2)).^2));
        d_fact = r_m_fact.Data.seis(r_f_fact.nh+1,ind_fac) - mean_log(1);
        %d_fact = r_m_fact.Data.seis(r_f_fact.nh+1,ind_fac);
        s_m.Data.seis(r_f.nh+1:end,ind_tr) = s_m.Data.seis(r_f.nh+1:end,ind_tr)./exp(d_fact);
    end
end
if any(handles.factors_rem == 2)
    r_xy = r_m.Data.seis(24:25,:)';
    [Ur_xy,~,~] = unique(r_xy,'stable','rows');
    for n = 1:size(Ur_xy,1)
        ind_tr = Ur_xy(n,1) == r_xy(:,1) & Ur_xy(n,2) == r_xy(:,2);
        [~, ind_fac] = min(sqrt((r_m_fact.Data.seis(24,r_min:r_max)-Ur_xy(n,1)).^2+(r_m_fact.Data.seis(25,r_min:r_max)-Ur_xy(n,2)).^2));
        d_fact = r_m_fact.Data.seis(r_f_fact.nh+1,ind_fac) - mean_log(2);
        %d_fact = r_m_fact.Data.seis(r_f_fact.nh+1,ind_fac);
        s_m.Data.seis(r_f.nh+1:end,ind_tr) = s_m.Data.seis(r_f.nh+1:end,ind_tr)./exp(d_fact);
    end
end
if any(handles.factors_rem == 3)
    cdp = r_m.Data.seis(6,:)';
    cdp_xy = r_m.Data.seis(72:73,:)';
    L = r_m.Data.seis(12,:)';
    if any(r_f_fact.param.sc_model_num == [1 2 3 4])
        k = 1;
    elseif any(r_f_fact.param.sc_model_num == [5 6 7 8])
        k = 2;
    end
    [Ucdp,ia,~] = unique(cdp,'stable','rows');
    for n = 1:size(Ucdp,1)
        ind_tr = Ucdp(n,1) == cdp(:,1);
        d_fact = F(double(cdp_xy(ia(n),:)))*L(ind_tr).^k;
        D_fact = repmat(d_fact',r_f.ns,1);
        s_m.Data.seis(r_f.nh+1:end,ind_tr) = s_m.Data.seis(r_f.nh+1:end,ind_tr)./exp(D_fact);
    end
end
if any(handles.factors_rem == 4)
    cdp = r_m.Data.seis(6,:)';
    cdp_xy = r_m.Data.seis(72:73,:)';
    [Ucdp,ia,~] = unique(cdp,'stable','rows');
    for n = 1:size(Ucdp,1)
        ind_tr = Ucdp(n,1) == cdp(:,1);
        d_fact = F(double(cdp_xy(ia(n),:)));
        s_m.Data.seis(r_f.nh+1:end,ind_tr) = s_m.Data.seis(r_f.nh+1:end,ind_tr)./exp(d_fact);
    end
end

toc
seismic = r_f;
seismic.param = handles;
seismic.plot_type = 'imagesc';

save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;