function g_apply_time(hParent)
handles = guidata(hParent);
% load input FACTORS
r_f_fact = load([handles.r_factors_path handles.r_factors_file]);
r_f_fact = r_f_fact.seismic;
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

s_xy = r_m.Data.seis(22:23,:)';
r_xy = r_m.Data.seis(24:25,:)';
[Us_xy,ias,~] = unique(s_xy,'sorted','rows');
[Ur_xy,iar,~] = unique(r_xy,'sorted','rows');
U_xy = [Us_xy; Ur_xy];
[Do(1),min_ind] = min(U_xy(:,1));
Do(2) = U_xy(min_ind,2);

s_dist = sqrt((s_xy(:,1)-Do(1)).^2+(s_xy(:,2)-Do(2)).^2);
r_dist = sqrt((r_xy(:,1)-Do(1)).^2+(r_xy(:,2)-Do(2)).^2);

s_h = zeros(length(s_dist),size(r_f_fact.layers,1));
r_h = zeros(length(r_dist),size(r_f_fact.layers,1));
s_v = zeros(length(s_dist),size(r_f_fact.vel,1));
r_v = zeros(length(r_dist),size(r_f_fact.vel,1));
for n = size(r_f_fact.layers,1):-1:1
    s_h(:,n) = interp1(r_f_fact.layers{n,1}(:,1),r_f_fact.layers{n,1}(:,2),s_dist,'linear','extrap');
    r_h(:,n) = interp1(r_f_fact.layers{n,1}(:,1),r_f_fact.layers{n,1}(:,2),r_dist,'linear','extrap');
    s_v(:,n) = interp1(r_f_fact.vel{n,1}(:,1),r_f_fact.vel{n,1}(:,2),s_dist,'linear','extrap');
    r_v(:,n) = interp1(r_f_fact.vel{n,1}(:,1),r_f_fact.vel{n,1}(:,2),r_dist,'linear','extrap');
    if n ~=size(r_f_fact.layers,1)
        ind = s_h(:,n) < s_h(:,n+1);
        s_h(ind,n) = s_h(ind,n+1);
        ind = r_h(:,n) < r_h(:,n+1);
        r_h(ind,n) = r_h(ind,n+1);
    end
end
s_h(:,1) = interp1(r_f_fact.hole_elevation(:,1),r_f_fact.hole_elevation(:,2),s_dist,'linear','extrap');

stat_down = sum(diff(s_h(:,1:handles.lay_rep+1),[],2)./s_v(:,1:handles.lay_rep),2)+...
            sum(diff(r_h(:,1:handles.lay_rep+1),[],2)./r_v(:,1:handles.lay_rep),2);
        
stat_up = (handles.datum-s_h(:,handles.lay_rep+1))./handles.vel_rep+...
          (handles.datum-r_h(:,handles.lay_rep+1))./handles.vel_rep;

stat = stat_down + stat_up;

t = 0:r_f.dt./1000:r_f.dt*(r_f.ns-1)./1000;
t_new = 0:r_f.dt./1000:handles.trc_len;

tic
for n = 1:size(r_m.Data.seis,2)
    trace(:,1) = interp1(t+stat(n),r_m.Data.seis(r_f.nh+1:end,n),t_new,'linear',0);
    trace(isnan(trace) | isinf(trace)) = 0;
    fwrite(s_fileID,[r_m.Data.seis(1:r_f.nh,n); trace],'single');
end
toc
seismic = r_f;
seismic.ns = length(t_new);
seismic.param = handles;
seismic.plot_type = 'imagesc';

save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');