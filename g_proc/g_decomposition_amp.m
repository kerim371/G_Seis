function g_decomposition_amp(hParent)
handles = guidata(hParent);
% load input sesmic
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);
s_fileID = fopen([handles.s_path handles.s_file '.bin'],'w'); % сохранять трассы и их заголовки
if s_fileID <=0
    errordlg('The  SAVE-file is busy with another process!','Error saving file');
    fclose all;
    return
end

L = r_m.Data.seis(12,:);
if isempty(handles.min_offset)
    handles.min_offset = 0;
end
if isempty(handles.max_offset)
    handles.max_offset = max(abs(L));
end
indL = find(abs(L) >= handles.min_offset & abs(L) <= handles.max_offset); % only FIND can return Linearindes
L = L(indL);
s_xy = r_m.Data.seis(22:23,indL)';
r_xy = r_m.Data.seis(24:25,indL)';
cdp_xy = r_m.Data.seis(72:73,indL)';

if strcmp(handles.restr,'Equation')
    hrz_hdr = r_m.Data.seis(22:25,indL)'; % sx sy rx ry
    trc_hdr = hrz_hdr;
    hrz_t = handles.a*L.^handles.b+handles.c;
elseif strcmp(handles.restr,'Horizon')
    mat_hrz = load([handles.hrz_path handles.hrz_file]);
    %mat_hrz = matfile([handles.hrz_path handles.hrz_file],'Writable',false);
    col_names = mat_hrz.col_names;
    hrz_hdr = [];
    trc_hdr = [];
    for n = 1:length(col_names)
        if ~isempty(str2num(col_names{n}))
            hrz_hdr = [hrz_hdr mat_hrz.hrz(:,n)];
            trc_hdr = [trc_hdr r_m.Data.seis(str2num(col_names{n}),:)'];
        elseif strcmp(col_names{n},'t')
            hrz_t = mat_hrz.hrz(:,n);
        end
    end
    trc_hdr = trc_hdr(indL,:);
elseif strcmp(handles.restr,'Horizon (to) & Velocity')
    hrz = load([handles.hrz_path handles.hrz_file]);
    v_f = load([handles.vel_path handles.vel_file]);
    v_f = v_f.seismic;
    vel_m = memmapfile([handles.vel_path handles.vel_file '.bin'],...
        'Format',{'single',[v_f.nh+v_f.ns v_f.ntr],'seis'},'Writable',false);
    hrz_hdr = [];
    trc_hdr = [];
    vel_hdr = [];
    for n = 1:length(hrz.col_names)
        if ~isempty(str2num(hrz.col_names{n}))
            hrz_hdr = [hrz_hdr hrz.hrz(:,n)];
            trc_hdr = [trc_hdr r_m.Data.seis(str2num(hrz.col_names{n}),:)'];
            vel_hdr = [vel_hdr vel_m.Data.seis(str2num(hrz.col_names{n}),:)'];
        elseif strcmp(hrz.col_names{n},'t')
            hrz_t = hrz.hrz(:,n);
        end
    end
    Hrz_hdr = zeros(size(trc_hdr,1),2);
    Hrz_t = zeros(size(trc_hdr,1),1);
    for n = 1:length(hrz_t)
        ind_trc = all(trc_hdr == hrz_hdr(n,:),2);
        ind_vel = all(vel_hdr == hrz_hdr(n,:),2);
        if any(ind_trc) && any(ind_vel)
            v = vel_m.Data.seis(round(v_f.nh+hrz_t(n)*1000/v_f.dt),ind_vel);
            Hrz_hdr(ind_trc,:) = [trc_hdr(ind_trc,:) r_m.Data.seis(12,ind_trc)'];
            Hrz_t(ind_trc,:) = sqrt(hrz_t(n)^2 + (r_m.Data.seis(12,ind_trc)/v*1000).^2);
        end
    end
    hrz_hdr = Hrz_hdr;
    hrz_t = Hrz_t;
    clear Hrz_hdr Hrz_t ind_trc ind_vel;
    ind = hrz_t >= 0 & hrz_t <= (r_f.ns-1)*r_f.dt/1000;
    hrz_hdr = hrz_hdr(ind,:);
    hrz_t = hrz_t(ind,:);
    trc_hdr = [trc_hdr(indL,:) r_m.Data.seis(12,indL)'];
end
hrz_t = hrz_t(:);
trc_num = 1:size(r_m.Data.seis,2);
trc_num = trc_num(:);
trc_num = trc_num(indL);
                                              
[~,ia,ib] = intersect(trc_hdr,hrz_hdr,'rows','stable');

L = L(ia);
s_xy = s_xy(ia,:);
r_xy = r_xy(ia,:);
cdp_xy = cdp_xy(ia,:);
trc_num = trc_num(ia);
hrz_hdr = hrz_hdr(ib,:);
hrz_t = hrz_t(ib,:);

[Us_xy,~,~] = unique(s_xy,'sorted','rows'); % SORTED
[Ur_xy,~,~] = unique(r_xy,'sorted','rows');
[Ucdp_xy,~,~] = unique(cdp_xy,'sorted','rows');

if ~isempty(handles.spec_cond_2)
    y1 = movmean(Ucdp_xy(:,1),round(length(Ucdp_xy(:,1))/100));
    y2 = movmean(Ucdp_xy(:,2),round(length(Ucdp_xy(:,2))/100));
    len_Ucdp_xy_old = sum(sqrt(diff(y1).^2 + diff(y2).^2));
    n_bins = round(len_Ucdp_xy_old./handles.spec_cond_2(1));
    Ucdp_xy = interparc(n_bins,y1,y2,'linear');
end
len_Ucdp_xy = size(Ucdp_xy,1);

if strcmp(handles.decomposition_type,'spectrum')
    win_len = length(handles.win_above:r_f.dt/1000:handles.win_below);
    if mod(win_len,2) == 0
        frq = linspace(0,0.5/r_f.dt*10^6,win_len/2+1);
    elseif mod(win_len,2) ~= 0
        frq = linspace(0,0.5/r_f.dt*10^6,(win_len+1)/2);
    end
    if strcmp(handles.spec_approx,'non_approximate_spec')
        f = zeros(length(ia),length(frq));
        D = [];
    elseif strcmp(handles.spec_approx,'approximate_spec')
        f = zeros(length(ia),handles.basis_num+1);
        w1 = 0.5;
        w2 = 110;
        w(:,1) = linspace(w1,w2,length(frq));
        w = repmat(w,1,handles.basis_num+1);
        n_n = 0:handles.basis_num;
        n_n = repmat(n_n,length(frq),1);
        D = cos(n_n.*pi.*(w-w1)./(w2-w1)); % Denisov matrice
    end
elseif strcmp(handles.decomposition_type,'amplitude')
    frq = [];
    f = zeros(length(ia),1);
    D = [];
end

if handles.sc_model_num == 1 || handles.sc_model_num == 5 % SP RP
    As = sparse(length(ia),size(Us_xy,1));
    Ar = sparse(length(ia),size(Ur_xy,1));
    Aoff = sparse(length(ia),1);
    [coord_xy,factors_ind,x] = sp_rp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,s_xy,r_xy,r_f,hrz_t,trc_num,r_m,D,frq,As,Ar,Aoff,f);
elseif handles.sc_model_num == 2 || handles.sc_model_num == 6 % SP RP OFFSET
    As = sparse(length(ia),size(Us_xy,1));
    Ar = sparse(length(ia),size(Ur_xy,1));
    if isempty(handles.spec_cond_4)
        Aoff = sparse(length(ia),size(Ucdp_xy,1));
        off_frq = [];
    elseif ~isempty(handles.spec_cond_4)
        Aoff = zeros(length(ia),handles.spec_cond_4(1));
        off_frq = linspace(0,1/2,handles.spec_cond_4(1));
    end
    [coord_xy,factors_ind,x] = sp_rp_off_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,As,Ar,Aoff,f,off_frq);
elseif handles.sc_model_num == 3 || handles.sc_model_num == 7 % SP RP OFFSET CDP
    As = sparse(length(ia),size(Us_xy,1));
    Ar = sparse(length(ia),size(Ur_xy,1));
    if isempty(handles.spec_cond_4)
        Aoff = sparse(length(ia),size(Ucdp_xy,1));
        Acdp = sparse(length(ia),size(Ucdp_xy,1));
        off_frq = [];
        cdp_frq = [];
    elseif ~isempty(handles.spec_cond_4)
        Aoff = zeros(length(ia),handles.spec_cond_4(1));
        Acdp = zeros(length(ia),handles.spec_cond_4(2));
        off_frq = linspace(0,1/2,handles.spec_cond_4(1));
        cdp_frq = linspace(0,1/2,handles.spec_cond_4(2));
    end
    [coord_xy,factors_ind,x] = sp_rp_off_cdp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,As,Ar,Aoff,Acdp,f,off_frq,cdp_frq);
elseif handles.sc_model_num == 4 || handles.sc_model_num == 8 % OFFSET CDP
    if isempty(handles.spec_cond_4)
        Aoff = sparse(length(ia),size(Ucdp_xy,1));
        Acdp = sparse(length(ia),size(Ucdp_xy,1));
        off_frq = [];
        cdp_frq = [];
    elseif ~isempty(handles.spec_cond_4)
        Aoff = zeros(length(ia),handles.spec_cond_4(1));
        Acdp = zeros(length(ia),handles.spec_cond_4(2));
        off_frq = linspace(0,1/2,handles.spec_cond_4(1));
        cdp_frq = linspace(0,1/2,handles.spec_cond_4(2));
    end
    [coord_xy,factors_ind,x] = off_cdp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,Aoff,Acdp,f,off_frq,cdp_frq);
elseif handles.sc_model_num == 9 % SP RP CDP
    As = sparse(length(ia),size(Us_xy,1));
    Ar = sparse(length(ia),size(Ur_xy,1));
    if isempty(handles.spec_cond_4)
        Acdp = sparse(length(ia),size(Ucdp_xy,1));
        cdp_frq = [];
    elseif ~isempty(handles.spec_cond_4)
        Acdp = zeros(length(ia),handles.spec_cond_4(1));
        cdp_frq = linspace(0,1/2,handles.spec_cond_4(1));
    end
    [coord_xy,factors_ind,x] = sp_rp_cdp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,As,Ar,Acdp,f,cdp_frq);
end
if strcmp(handles.decomposition_type,'spectrum') && strcmp(handles.spec_approx,'approximate_spec')
    x = D*x';
else
    x = x';
end
if strcmp(handles.decomposition_type,'spectrum') && ~isempty(handles.trap_filt)
    y = trapmf(frq,handles.trap_filt);
    Y = repmat(y(:),1,size(x,2));
    x = Y.*x;
    clear y Y;
end

s_hdr = zeros(size(r_f.trc_hdr_info,1),size(x,2));
Ufactors_ind = unique(factors_ind,'stable');
for n = 1:length(Ufactors_ind)
    if Ufactors_ind(n) == 1
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(22:23,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    elseif Ufactors_ind(n) == 2
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(24:25,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    elseif Ufactors_ind(n) == 3
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(72:73,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    elseif Ufactors_ind(n) == 4
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(72:73,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    elseif Ufactors_ind(n) == 13
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(72:73,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    elseif Ufactors_ind(n) == 23
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(72:73,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    end
end

s_hdr = single(s_hdr);
x = single(x);
fwrite(s_fileID,[s_hdr; x],'single');
seismic = r_f;
seismic.ntr = size(x,2);
seismic.ns = size(x,1);
seismic.param = handles;

if strcmp(handles.decomposition_type,'amplitude') && strcmp(handles.survey_type,'2D Survey')
    seismic.plot_type = 'line';
elseif strcmp(handles.decomposition_type,'amplitude') && strcmp(handles.survey_type,'3D Survey')
    seismic.plot_type = 'imagesc-scatter';
elseif strcmp(handles.decomposition_type,'spectrum')
    seismic.plot_type = 'imagesc';
end
save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;

% 'SP+RP+const|OFFSET|^1'
function [coord_xy,factors_ind,x] = sp_rp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,s_xy,r_xy,r_f,hrz_t,trc_num,r_m,D,frq,As,Ar,Aoff,f)
if handles.sc_model_num == 1
    k = 1;
    model_type = 'SP+RP+const|OFFSET|^1';
elseif handles.sc_model_num == 5
    k = 2;
    model_type = 'SP+RP+const|OFFSET|^2';
end

for n = 1:length(ia)
    [~, ind] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
    As(n,ind) = 1;
    [~, ind] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
    Ar(n,ind) = 1;
    Aoff(n,1) = abs(L(n)).^k;
    win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
    f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
end
if ~isempty(handles.spec_cond_1)
    As1 = sparse(size(Us_xy,1),size(Us_xy,1));
    Ar1 = sparse(size(Us_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_1 * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_1 * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        As1(n,:) = in_s'./(sum(in_s));
        Ar1(n,:) = in_r'./(sum(in_r));
    end
    As1 = As1(~any(isnan(As1),2),:);
    Ar1 = Ar1(~any(isnan(Ar1),2),:);
    As1 = As1(~any(isinf(As1),2),:);
    Ar1 = Ar1(~any(isinf(Ar1),2),:);
    As = [As; As1];
    Ar = [Ar; -Ar1];
    f1 = zeros(size(As1,1),size(f,2));
    f = [f; f1];
end
if ~isempty(handles.spec_cond_5_SP)
    As2 = zeros(size(Us_xy,1),size(Us_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_5_SP * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_5_SP * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        As2(n,:) = ones(1,size(As2,2))./size(As2,2) - in_s'./(sum(in_s));
    end
    As2 = As2(~any(isnan(As2),2),:);
    As2 = As2(~any(isinf(As2),2),:);
    As2 = sparse(As2);
    Ar2 = sparse(size(As2,1),size(Ar,2));
    As = [As; As2];
    Ar = [Ar; Ar2];
    f2 = zeros(size(As2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_RP)
    Ar2 = zeros(size(Ur_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ur_xy,1)
        xv = handles.spec_cond_5_RP * cos(th) + Ur_xy(n,1);
        yv = handles.spec_cond_5_RP * sin(th) + Ur_xy(n,2);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        Ar2(n,:) = ones(1,size(Ar2,2))./size(Ar2,2) - in_r'./(sum(in_r));
    end
    Ar2 = Ar2(~any(isnan(Ar2),2),:);
    Ar2 = Ar2(~any(isinf(Ar2),2),:);
    Ar2 = sparse(Ar2);
    As2 = sparse(size(Ar2,1),size(As,2));
    Ar = [Ar; Ar2];
    As = [As; As2];
    f2 = zeros(size(Ar2,1),size(f,2));
    f = [f; f2];
end
Aoff = [Aoff; zeros(size(As,1)-size(Aoff,1),1)];
A = [As Ar Aoff];
ind1 = any(A,2) & ~any(isnan(A),2) & ~any(isinf(A),2);
ind2 = any(A,1);
A = A(ind1,ind2);
f = f(ind1,:);

x = solve_mtx(A,f,handles);

coord_xy = [Us_xy' Ur_xy' ones(2,1)];
coord_xy = coord_xy(:,ind2);
factors_ind = [ones(1,size(As,2)) 2*ones(1,size(Ar,2)) 3*ones(1,size(Aoff,2))];
factors_ind = factors_ind(:,ind2);

% 'SP+RP+|OFFSET|^1'
function [coord_xy,factors_ind,x] = sp_rp_off_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,As,Ar,Aoff,f,off_frq)
if handles.sc_model_num == 2
    k = 1;
    model_type = 'SP+RP+|OFFSET|^1';
elseif handles.sc_model_num == 6
    k = 2;
    model_type = 'SP+RP+|OFFSET|^2';
end

if isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, inds] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,inds) = 1;
        [~, indr] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,indr) = 1;
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,ind) = abs(L(n)).^k;
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
elseif ~isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, ind] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,ind) = 1;
        [~, ind] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,ind) = 1;
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,:) = cos(off_frq.*ind).*abs(L(n)).^k;
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
    Aoff = sparse(Aoff);
end
if ~isempty(handles.spec_cond_1)
    As1 = sparse(size(Us_xy,1),size(Us_xy,1));
    Ar1 = sparse(size(Us_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_1 * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_1 * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        if any(in_s)
            As1(n,:) = in_s'./(sum(in_s));
        end
        if any(in_r)
            Ar1(n,:) = in_r'./(sum(in_r));
        end
    end
    As1 = As1(~any(isnan(As1),2),:);
    Ar1 = Ar1(~any(isnan(Ar1),2),:);
    As1 = As1(~any(isinf(As1),2),:);
    Ar1 = Ar1(~any(isinf(Ar1),2),:);
    Aoff1 = sparse(size(As1,1),size(Aoff,2));
    As = [As; As1];
    Ar = [Ar; -Ar1];
    Aoff = [Aoff; Aoff1];
    f1 = zeros(size(As1,1),size(f,2));
    f = [f; f1];
end
if ~isempty(handles.spec_cond_5_SP)
    As2 = zeros(size(Us_xy,1),size(Us_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_5_SP * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_5_SP * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        As2(n,:) = ones(1,size(As2,2))./size(As2,2) - in_s'./(sum(in_s));
    end
    As2 = As2(~any(isnan(As2),2),:);
    As2 = As2(~any(isinf(As2),2),:);
    As2 = sparse(As2);
    Ar2 = sparse(size(As2,1),size(Ar,2));
    Aoff2 = sparse(size(As2,1),size(Aoff,2));
    As = [As; As2];
    Ar = [Ar; Ar2];
    Aoff = [Aoff; Aoff2];
    f2 = zeros(size(As2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_RP)
    Ar2 = zeros(size(Ur_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ur_xy,1)
        xv = handles.spec_cond_5_RP * cos(th) + Ur_xy(n,1);
        yv = handles.spec_cond_5_RP * sin(th) + Ur_xy(n,2);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        Ar2(n,:) = ones(1,size(Ar2,2))./size(Ar2,2) - in_r'./(sum(in_r));
    end
    Ar2 = Ar2(~any(isnan(Ar2),2),:);
    Ar2 = Ar2(~any(isinf(Ar2),2),:);
    Ar2 = sparse(Ar2);
    As2 = sparse(size(Ar2,1),size(As,2));
    Aoff2 = sparse(size(Ar2,1),size(Aoff,2));
    Ar = [Ar; Ar2];
    As = [As; As2];
    Aoff = [Aoff; Aoff2];
    f2 = zeros(size(Ar2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_OFFSET) && isempty(handles.spec_cond_4)
    Aoff2 = zeros(size(Ucdp_xy,1),size(Ucdp_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ucdp_xy,1)
        xv = handles.spec_cond_5_OFFSET * cos(th) + Ucdp_xy(n,1);
        yv = handles.spec_cond_5_OFFSET * sin(th) + Ucdp_xy(n,2);
        in_offset = inpolygon(Ucdp_xy(:,1),Ucdp_xy(:,2),xv,yv);
        Aoff2(n,:) = ones(1,size(Aoff2,2))./size(Aoff2,2) - in_offset'./(sum(in_offset));
    end
    Aoff2 = Aoff2(~any(isnan(Aoff2),2),:);
    Aoff2 = Aoff2(~any(isinf(Aoff2),2),:);
    Aoff2 = sparse(Aoff2);
    As2 = sparse(size(Aoff2,1),size(As,2));
    Ar2 = sparse(size(Aoff2,1),size(Ar,2));
    Aoff = [Aoff; Aoff2];
    As = [As; As2];
    Ar = [Ar; Ar2];
    f2 = zeros(size(Aoff2,1),size(f,2));
    f = [f; f2];
end
A = [As Ar Aoff];
ind1 = any(A,2) & ~any(isnan(A),2) & ~any(isinf(A),2);
ind2 = any(A,1);
A = A(ind1,ind2);
f = f(ind1,:);
if ~isempty(handles.spec_cond_4)
    ind2(size(As,2)+size(Ar,2)+1:size(As,2)+size(Ar,2)+len_Ucdp_xy) = true;
end
x = solve_mtx(A,f,handles);
if ~isempty(handles.spec_cond_4)
    profil = 1:size(Ucdp_xy,1);
    D5 = cos(repmat(off_frq,size(Ucdp_xy,1),1).*repmat(profil',1,length(off_frq)));
    x_off = D5*x(end-handles.spec_cond_4+1:end);
    x = [x(1:size(As,2)+size(Ar,2)); x_off];
end

coord_xy = [Us_xy' Ur_xy' Ucdp_xy'];
factors_ind = [ones(1,size(As,2)) 2*ones(1,size(Ar,2)) 3*ones(1,len_Ucdp_xy)];
coord_xy = coord_xy(:,ind2);
factors_ind = factors_ind(:,ind2);

% 'SP+RP+|OFFSET|^1+CDP'
function [coord_xy,factors_ind,x] = sp_rp_off_cdp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,As,Ar,Aoff,Acdp,f,off_frq,cdp_frq)
if handles.sc_model_num == 3
    k = 1;
    model_type = 'SP+RP+|OFFSET|^1+CDP';
elseif handles.sc_model_num == 7
    k = 2;
    model_type = 'SP+RP+|OFFSET|^2+CDP';
end

if isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, inds] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,inds) = 1;
        [~, indr] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,indr) = 1;
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,ind) = abs(L(n)).^k;
        Acdp(n,ind) = 1;
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
elseif ~isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, ind] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,ind) = 1;
        [~, ind] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,ind) = 1;
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,:) = cos(off_frq.*ind).*abs(L(n)).^k;
        Acdp(n,:) = cos(cdp_frq.*ind);
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
    Aoff = sparse(Aoff);
    Acdp = sparse(Acdp);
end
if ~isempty(handles.spec_cond_1)
    As1 = sparse(size(Us_xy,1),size(Us_xy,1));
    Ar1 = sparse(size(Us_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_1 * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_1 * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        if any(in_s)
            As1(n,:) = in_s'./(sum(in_s));
        end
        if any(in_r)
            Ar1(n,:) = in_r'./(sum(in_r));
        end
    end
    As1 = As1(~any(isnan(As1),2),:);
    Ar1 = Ar1(~any(isnan(Ar1),2),:);
    As1 = As1(~any(isinf(As1),2),:);
    Ar1 = Ar1(~any(isinf(Ar1),2),:);
    Aoff1 = sparse(size(As1,1),size(Aoff,2));
    Acdp1 = sparse(size(As1,1),size(Acdp,2));
    As = [As; As1];
    Ar = [Ar; -Ar1];
    Aoff = [Aoff; Aoff1];
    Acdp = [Acdp; Acdp1];
    f1 = zeros(size(As1,1),size(f,2));
    f = [f; f1];
end
if ~isempty(handles.spec_cond_5_SP)
    As2 = zeros(size(Us_xy,1),size(Us_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_5_SP * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_5_SP * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        As2(n,:) = ones(1,size(As2,2))./size(As2,2) - in_s'./(sum(in_s));
    end
    As2 = As2(~any(isnan(As2),2),:);
    As2 = As2(~any(isinf(As2),2),:);
    As2 = sparse(As2);
    Ar2 = sparse(size(As2,1),size(Ar,2));
    Aoff2 = sparse(size(As2,1),size(Aoff,2));
    Acdp2 = sparse(size(As2,1),size(Acdp,2));
    As = [As; As2];
    Ar = [Ar; Ar2];
    Aoff = [Aoff; Aoff2];
    Acdp = [Acdp; Acdp2];
    f2 = zeros(size(As2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_RP)
    Ar2 = zeros(size(Ur_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ur_xy,1)
        xv = handles.spec_cond_5_RP * cos(th) + Ur_xy(n,1);
        yv = handles.spec_cond_5_RP * sin(th) + Ur_xy(n,2);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        Ar2(n,:) = ones(1,size(Ar2,2))./size(Ar2,2) - in_r'./(sum(in_r));
    end
    Ar2 = Ar2(~any(isnan(Ar2),2),:);
    Ar2 = Ar2(~any(isinf(Ar2),2),:);
    Ar2 = sparse(Ar2);
    As2 = sparse(size(Ar2,1),size(As,2));
    Aoff2 = sparse(size(Ar2,1),size(Aoff,2));
    Acdp2 = sparse(size(Ar2,1),size(Acdp,2));
    Ar = [Ar; Ar2];
    As = [As; As2];
    Aoff = [Aoff; Aoff2];
    Acdp = [Acdp; Acdp2];
    f2 = zeros(size(Ar2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_OFFSET) && isempty(handles.spec_cond_4)
    Aoff2 = zeros(size(Ucdp_xy,1),size(Ucdp_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ucdp_xy,1)
        xv = handles.spec_cond_5_OFFSET * cos(th) + Ucdp_xy(n,1);
        yv = handles.spec_cond_5_OFFSET * sin(th) + Ucdp_xy(n,2);
        in_offset = inpolygon(Ucdp_xy(:,1),Ucdp_xy(:,2),xv,yv);
        Aoff2(n,:) = ones(1,size(Aoff2,2))./size(Aoff2,2) - in_offset'./(sum(in_offset));
    end
    Aoff2 = Aoff2(~any(isnan(Aoff2),2),:);
    Aoff2 = Aoff2(~any(isinf(Aoff2),2),:);
    Aoff2 = sparse(Aoff2);
    As2 = sparse(size(Aoff2,1),size(As,2));
    Ar2 = sparse(size(Aoff2,1),size(Ar,2));
    Acdp2 = sparse(size(Aoff2,1),size(Acdp,2));
    Aoff = [Aoff; Aoff2];
    As = [As; As2];
    Ar = [Ar; Ar2];
    Acdp = [Acdp; Acdp2];
    f2 = zeros(size(Aoff2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_CDP) && isempty(handles.spec_cond_4)
    Acdp2 = zeros(size(Ucdp_xy,1),size(Ucdp_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ucdp_xy,1)
        xv = handles.spec_cond_5_CDP * cos(th) + Ucdp_xy(n,1);
        yv = handles.spec_cond_5_CDP * sin(th) + Ucdp_xy(n,2);
        in_cdp = inpolygon(Ucdp_xy(:,1),Ucdp_xy(:,2),xv,yv);
        Acdp2(n,:) = ones(1,size(Acdp2,2))./size(Acdp2,2) - in_cdp'./(sum(in_cdp));
    end
    Acdp2 = Acdp2(~any(isnan(Acdp2),2),:);
    Acdp2 = Acdp2(~any(isinf(Acdp2),2),:);
    Acdp2 = sparse(Acdp2);
    As2 = sparse(size(Acdp2,1),size(As,2));
    Ar2 = sparse(size(Acdp2,1),size(Ar,2));
    Aoff2 = sparse(size(Acdp2,1),size(Aoff,2));
    Acdp = [Acdp; Acdp2];
    As = [As; As2];
    Ar = [Ar; Ar2];
    Aoff = [Aoff; Aoff2];
    f2 = zeros(size(Acdp2,1),size(f,2));
    f = [f; f2];
end
A = [As Ar Aoff Acdp];
ind1 = any(A,2) & ~any(isnan(A),2) & ~any(isinf(A),2);
ind2 = any(A,1);
A = A(ind1,ind2);
f = f(ind1,:);

x = solve_mtx(A,f,handles);
if ~isempty(handles.spec_cond_4)
    profil = 1:size(Ucdp_xy,1);
    D5 = cos(repmat(off_frq,size(Ucdp_xy,1),1).*repmat(profil',1,length(off_frq)));
    x_off = D5*x(end-2*handles.spec_cond_4+1:end-handles.spec_cond_4);
    D5 = cos(repmat(cdp_frq,size(Ucdp_xy,1),1).*repmat(profil',1,length(cdp_frq)));
    x_cdp = D5*x(end-handles.spec_cond_4+1:end);
    x = [x(1:size(As,2)+size(Ar,2)); x_off; x_cdp];
end

coord_xy = [Us_xy' Ur_xy' Ucdp_xy' Ucdp_xy'];

if ~isempty(handles.spec_cond_4)
    factors_ind = [ones(1,size(As,2)) 2*ones(1,size(Ar,2)) 3*ones(1,length(x_off)) 4*ones(1,length(x_cdp))];
elseif isempty(handles.spec_cond_4)
    factors_ind = [ones(1,size(As,2)) 2*ones(1,size(Ar,2)) 3*ones(1,size(Aoff,2)) 4*ones(1,size(Acdp,2))];
    coord_xy = coord_xy(:,ind2);
    factors_ind = factors_ind(:,ind2);
end


% '|OFFSET|^1+CDP'
function [coord_xy,factors_ind,x] = off_cdp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,Aoff,Acdp,f,off_frq,cdp_frq)
if handles.sc_model_num == 4
    k = 1;
    model_type = '|OFFSET|^1+CDP';
elseif handles.sc_model_num == 8
    k = 2;
    model_type = '|OFFSET|^2+CDP';
end

if isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,ind) = abs(L(n)).^k;
        Acdp(n,ind) = 1;
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
elseif ~isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,:) = cos(off_frq.*ind).*abs(L(n)).^k;
        Acdp(n,:) = cos(cdp_frq.*ind);
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
    Aoff = sparse(Aoff);
    Acdp = sparse(Acdp);
end
if ~isempty(handles.spec_cond_5_OFFSET) && isempty(handles.spec_cond_4)
    Aoff2 = zeros(size(Ucdp_xy,1),size(Ucdp_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ucdp_xy,1)
        xv = handles.spec_cond_5_OFFSET * cos(th) + Ucdp_xy(n,1);
        yv = handles.spec_cond_5_OFFSET * sin(th) + Ucdp_xy(n,2);
        in_offset = inpolygon(Ucdp_xy(:,1),Ucdp_xy(:,2),xv,yv);
        Aoff2(n,:) = ones(1,size(Aoff2,2))./size(Aoff2,2) - in_offset'./(sum(in_offset));
    end
    Aoff2 = Aoff2(~any(isnan(Aoff2),2),:);
    Aoff2 = Aoff2(~any(isinf(Aoff2),2),:);
    Aoff2 = sparse(Aoff2);
    Acdp2 = sparse(size(Aoff2,1),size(Acdp,2));
    Aoff = [Aoff; Aoff2];
    Acdp = [Acdp; Acdp2];
    f2 = zeros(size(Aoff2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_CDP) && isempty(handles.spec_cond_4)
    Acdp2 = zeros(size(Ucdp_xy,1),size(Ucdp_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ucdp_xy,1)
        xv = handles.spec_cond_5_CDP * cos(th) + Ucdp_xy(n,1);
        yv = handles.spec_cond_5_CDP * sin(th) + Ucdp_xy(n,2);
        in_cdp = inpolygon(Ucdp_xy(:,1),Ucdp_xy(:,2),xv,yv);
        Acdp2(n,:) = ones(1,size(Acdp2,2))./size(Acdp2,2) - in_cdp'./(sum(in_cdp));
    end
    Acdp2 = Acdp2(~any(isnan(Acdp2),2),:);
    Acdp2 = Acdp2(~any(isinf(Acdp2),2),:);
    Acdp2 = sparse(Acdp2);
    Aoff2 = sparse(size(Acdp2,1),size(Aoff,2));
    Acdp = [Acdp; Acdp2];
    Aoff = [Aoff; Aoff2];
    f2 = zeros(size(Acdp2,1),size(f,2));
    f = [f; f2];
end
A = [Aoff Acdp];
ind1 = any(A,2) & ~any(isnan(A),2) & ~any(isinf(A),2);
ind2 = any(A,1);
A = A(ind1,ind2);
f = f(ind1,:);

x = solve_mtx(A,f,handles);
if ~isempty(handles.spec_cond_4)
    profil = 1:size(Ucdp_xy,1);
    D5 = cos(repmat(off_frq,size(Ucdp_xy,1),1).*repmat(profil',1,length(off_frq)));
    x_off = D5*x(end-2*handles.spec_cond_4+1:end-handles.spec_cond_4);
    D5 = cos(repmat(cdp_frq,size(Ucdp_xy,1),1).*repmat(profil',1,length(cdp_frq)));
    x_cdp = D5*x(end-handles.spec_cond_4+1:end);
    x = [x(1:size(As,2)+size(Ar,2)); x_off; x_cdp];
end

coord_xy = [Ucdp_xy' Ucdp_xy'];

if ~isempty(handles.spec_cond_4)
    factors_ind = [3*ones(1,length(x_off)) 4*ones(1,length(x_cdp))];
elseif isempty(handles.spec_cond_4)
    factors_ind = [3*ones(1,size(Aoff,2)) 4*ones(1,size(Acdp,2))];
    coord_xy = coord_xy(:,ind2);
    factors_ind = factors_ind(:,ind2);
end


% 'F(i,j) = S(i)+R(j)+G(cdp)'
function [coord_xy,factors_ind,x] = sp_rp_cdp_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,len_Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,D,frq,As,Ar,Acdp,f,cdp_frq);
model_type = 'SP+RP+CDP';

if isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, inds] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,inds) = 1;
        [~, indr] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,indr) = 1;
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Acdp(n,ind) = 1;
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
elseif ~isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, ind] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,ind) = 1;
        [~, ind] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,ind) = 1;
        [~, ind] = min(sqrt((Ucdp_xy(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Acdp(n,:) = cos(cdp_frq.*ind);
        win = round((hrz_t(n)+handles.win_above:r_f.dt/1000:hrz_t(n)+handles.win_below)./(r_f.dt/1000));
        f(n,:) = right_side(handles,win,r_m,r_f,trc_num(n),frq,D);
    end
    Acdp = sparse(Acdp);
end
if ~isempty(handles.spec_cond_1)
    As1 = sparse(size(Us_xy,1),size(Us_xy,1));
    Ar1 = sparse(size(Us_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_1 * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_1 * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        if any(in_s)
            As1(n,:) = in_s'./(sum(in_s));
        end
        if any(in_r)
            Ar1(n,:) = in_r'./(sum(in_r));
        end
    end
    As1 = As1(~any(isnan(As1),2),:);
    Ar1 = Ar1(~any(isnan(Ar1),2),:);
    As1 = As1(~any(isinf(As1),2),:);
    Ar1 = Ar1(~any(isinf(Ar1),2),:);
    Acdp1 = sparse(size(As1,1),size(Acdp,2));
    As = [As; As1];
    Ar = [Ar; -Ar1];
    Acdp = [Acdp; Acdp1];
    f1 = zeros(size(As1,1),size(f,2));
    f = [f; f1];
end
if ~isempty(handles.spec_cond_5_SP)
    As2 = zeros(size(Us_xy,1),size(Us_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Us_xy,1)
        xv = handles.spec_cond_5_SP * cos(th) + Us_xy(n,1);
        yv = handles.spec_cond_5_SP * sin(th) + Us_xy(n,2);
        in_s = inpolygon(Us_xy(:,1),Us_xy(:,2),xv,yv);
        As2(n,:) = ones(1,size(As2,2))./size(As2,2) - in_s'./(sum(in_s));
    end
    As2 = As2(~any(isnan(As2),2),:);
    As2 = As2(~any(isinf(As2),2),:);
    As2 = sparse(As2);
    Ar2 = sparse(size(As2,1),size(Ar,2));
    Acdp2 = sparse(size(As2,1),size(Acdp,2));
    As = [As; As2];
    Ar = [Ar; Ar2];
    Acdp = [Acdp; Acdp2];
    f2 = zeros(size(As2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_RP)
    Ar2 = zeros(size(Ur_xy,1),size(Ur_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ur_xy,1)
        xv = handles.spec_cond_5_RP * cos(th) + Ur_xy(n,1);
        yv = handles.spec_cond_5_RP * sin(th) + Ur_xy(n,2);
        in_r = inpolygon(Ur_xy(:,1),Ur_xy(:,2),xv,yv);
        Ar2(n,:) = ones(1,size(Ar2,2))./size(Ar2,2) - in_r'./(sum(in_r));
    end
    Ar2 = Ar2(~any(isnan(Ar2),2),:);
    Ar2 = Ar2(~any(isinf(Ar2),2),:);
    Ar2 = sparse(Ar2);
    As2 = sparse(size(Ar2,1),size(As,2));
    Acdp2 = sparse(size(Ar2,1),size(Acdp,2));
    Ar = [Ar; Ar2];
    As = [As; As2];
    Acdp = [Acdp; Acdp2];
    f2 = zeros(size(Ar2,1),size(f,2));
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_CDP) && isempty(handles.spec_cond_4)
    Acdp2 = zeros(size(Ucdp_xy,1),size(Ucdp_xy,1));
    th = 0:pi/50:2*pi;
    for n = 1:size(Ucdp_xy,1)
        xv = handles.spec_cond_5_CDP * cos(th) + Ucdp_xy(n,1);
        yv = handles.spec_cond_5_CDP * sin(th) + Ucdp_xy(n,2);
        in_cdp = inpolygon(Ucdp_xy(:,1),Ucdp_xy(:,2),xv,yv);
        Acdp2(n,:) = ones(1,size(Acdp2,2))./size(Acdp2,2) - in_cdp'./(sum(in_cdp));
    end
    Acdp2 = Acdp2(~any(isnan(Acdp2),2),:);
    Acdp2 = Acdp2(~any(isinf(Acdp2),2),:);
    Acdp2 = sparse(Acdp2);
    As2 = sparse(size(Acdp2,1),size(As,2));
    Ar2 = sparse(size(Acdp2,1),size(Ar,2));
    Acdp = [Acdp; Acdp2];
    As = [As; As2];
    Ar = [Ar; Ar2];
    f2 = zeros(size(Acdp2,1),size(f,2));
    f = [f; f2];
end
A = [As Ar Acdp];
ind1 = any(A,2) & ~any(isnan(A),2) & ~any(isinf(A),2);
ind2 = any(A,1);
A = A(ind1,ind2);
f = f(ind1,:);

x = solve_mtx(A,f,handles);
if ~isempty(handles.spec_cond_4)
    profil = 1:size(Ucdp_xy,1);
    D5 = cos(repmat(cdp_frq,size(Ucdp_xy,1),1).*repmat(profil',1,length(cdp_frq)));
    x_cdp = D5*x(end-handles.spec_cond_4+1:end);
    x = [x(1:size(As,2)+size(Ar,2)); x_cdp];
end

coord_xy = [Us_xy' Ur_xy' Ucdp_xy'];

if ~isempty(handles.spec_cond_4)
    factors_ind = [ones(1,size(As,2)) 2*ones(1,size(Ar,2)) 4*ones(1,length(x_cdp))];
elseif isempty(handles.spec_cond_4)
    factors_ind = [ones(1,size(As,2)) 2*ones(1,size(Ar,2)) 4*ones(1,size(Acdp,2))];
    coord_xy = coord_xy(:,ind2);
    factors_ind = factors_ind(:,ind2);
end

function x = solve_mtx(A,f,handles)
if strcmp(handles.sol_method,'Matlab solver for sparse matrice')
    x = A\f;
elseif strcmp(handles.sol_method,'Gauss-Seidel method')
    x = gauss_seidel(A,f,handles.n_iter);
elseif strcmp(handles.sol_method,'Jacobi method')
    x = jacobi_solve(A,f,handles.n_iter);
end

function f = right_side(handles,win,r_m,r_f,trc_num,frq,D)
if strcmp(handles.decomposition_type,'amplitude')
    f = log(rms(r_m.Data.seis(r_f.nh+win,trc_num)));
elseif strcmp(handles.decomposition_type,'spectrum')
    aspec = abs(fft(r_m.Data.seis(r_f.nh+win,trc_num)));
    if strcmp(handles.spec_approx,'non_approximate_spec')
        f = log(aspec(1:length(frq)));
    elseif strcmp(handles.spec_approx,'approximate_spec')
        laspec = log(aspec(1:length(frq)));
        f = D\laspec;
    end
end