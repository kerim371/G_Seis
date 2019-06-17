% ДО ТРЕХ СЛОЕВ РАБОТАЕТ!!!!!
function g_decomposition_time(hParent)
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
if strcmp(handles.restr_by_off_picks,'offset')
    if ~isempty(handles.min_offset_1) && isempty(handles.min_offset_2) && isempty(handles.min_offset_3) && isempty(handles.min_offset_4) && isempty(handles.min_offset_5)
        indL = find(abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1);
        layers = 1;
    elseif ~isempty(handles.min_offset_1) && ~isempty(handles.min_offset_2) && isempty(handles.min_offset_3) && isempty(handles.min_offset_4) && isempty(handles.min_offset_5)
        indL = find(abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1 ...,
            | abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2);
        layers = 2;
    elseif ~isempty(handles.min_offset_1) && ~isempty(handles.min_offset_2) && ~isempty(handles.min_offset_3) && isempty(handles.min_offset_4) && isempty(handles.min_offset_5)
        indL = find(abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1 ...,
            | abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2 ...,
            | abs(L) >= handles.min_offset_3 & abs(L) <= handles.max_offset_3);
        layers = 3;
    elseif ~isempty(handles.min_offset_1) && ~isempty(handles.min_offset_2) && ~isempty(handles.min_offset_3) && ~isempty(handles.min_offset_4) && isempty(handles.min_offset_5)
        indL = find(abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1 ...,
            | abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2 ...,
            | abs(L) >= handles.min_offset_3 & abs(L) <= handles.max_offset_3 ...,
            | abs(L) >= handles.min_offset_4 & abs(L) <= handles.max_offset_4);
        layers = 4;
    elseif ~isempty(handles.min_offset_1) && ~isempty(handles.min_offset_2) && ~isempty(handles.min_offset_3) && ~isempty(handles.min_offset_4) && ~isempty(handles.min_offset_5)
        indL = find(abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1 ...,
            | abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2 ...,
            | abs(L) >= handles.min_offset_3 & abs(L) <= handles.max_offset_3 ...,
            | abs(L) >= handles.min_offset_4 & abs(L) <= handles.max_offset_4 ...,
            | abs(L) >= handles.min_offset_5 & abs(L) <= handles.max_offset_5);
        layers = 5;
    else
        errordlg('Look at min max offsets. There must be a mistake!','Error');
        fclose all;
        return
    end
elseif strcmp(handles.restr_by_off_picks,'picks')
    indL = true(1,r_f.ntr);
end

L = L(indL);
s_xy = r_m.Data.seis(22:23,indL)';
r_xy = r_m.Data.seis(24:25,indL)';
cdp_xy = r_m.Data.seis(72:73,indL)';
s_el = r_m.Data.seis(14,indL)';
r_el = r_m.Data.seis(13,indL)';

mat_hrz = load([handles.hrz_path handles.hrz_file]);
%mat_hrz = matfile([handles.hrz_path handles.hrz_file],'Writable',false);
col_names = mat_hrz.col_names;
hrz_hdr = [];
trc_hdr = [];
layer_ind = [];
for n = 1:length(col_names)
    if ~isempty(str2num(col_names{n}))
        hrz_hdr = [hrz_hdr mat_hrz.hrz(:,n)];
        trc_hdr = [trc_hdr r_m.Data.seis(str2num(col_names{n}),:)'];
    elseif strcmp(col_names{n},'t')
        hrz_t = mat_hrz.hrz(:,n);
    elseif strcmp(col_names{n},'Layer')
        layer_ind = [layer_ind mat_hrz.hrz(:,n)];
    end
end
trc_hdr = trc_hdr(indL,:);

hrz_t = hrz_t(:);
trc_num = 1:size(r_m.Data.seis,2);
trc_num = trc_num(:);
trc_num = trc_num(indL);
                                              
[~,ia,ib] = intersect(trc_hdr,hrz_hdr,'rows','stable');

L = L(ia);
s_xy = s_xy(ia,:);
r_xy = r_xy(ia,:);
cdp_xy = cdp_xy(ia,:);
s_el = s_el(ia,:)';
r_el = r_el(ia,:)';
trc_num = trc_num(ia);
hrz_hdr = hrz_hdr(ib,:);
hrz_t = hrz_t(ib,:);
if strcmp(handles.restr_by_off_picks,'offset')
    layer_ind = zeros(size(hrz_t,layers));
    if layers == 1
        i1 = abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1;
        layer_ind(i1,1) = 1;
    elseif layers == 2
        i1 = abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1;
        i2 = abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2;
        layer_ind(i1 | i2,1) = 1;
        layer_ind(i2,2) = 2;
    elseif layers == 3
        i1 = abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1;
        i2 = abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2;
        i3 = abs(L) >= handles.min_offset_3 & abs(L) <= handles.max_offset_3;
        layer_ind(i1 | i2 | i3,1) = 1;
        layer_ind(i2 | i3,2) = 2;
        layer_ind(i3,3) = 3;
    elseif layers == 4
        i1 = abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1;
        i2 = abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2;
        i3 = abs(L) >= handles.min_offset_3 & abs(L) <= handles.max_offset_3;
        i4 = abs(L) >= handles.min_offset_4 & abs(L) <= handles.max_offset_4;
        layer_ind(i1 | i2 | i3 | i4,1) = 1;
        layer_ind(i2 | i3 | i4,2) = 2;
        layer_ind(i3 | i4,3) = 3;
        layer_ind(i4,4) = 4;
    elseif layers == 5
        i1 = abs(L) >= handles.min_offset_1 & abs(L) <= handles.max_offset_1;
        i2 = abs(L) >= handles.min_offset_2 & abs(L) <= handles.max_offset_2;
        i3 = abs(L) >= handles.min_offset_3 & abs(L) <= handles.max_offset_3;
        i4 = abs(L) >= handles.min_offset_4 & abs(L) <= handles.max_offset_4;
        i5 = abs(L) >= handles.min_offset_5 & abs(L) <= handles.max_offset_5;
        layer_ind(i1 | i2 | i3 | i4 | i5,1) = 1;
        layer_ind(i2 | i3 | i4 | i5,2) = 2;
        layer_ind(i3 | i4 | i5,3) = 3;
        layer_ind(i4 | i5,4) = 4;
        layer_ind(i5,5) = 5;
    end
elseif strcmp(handles.restr_by_off_picks,'picks')
    layers = size(layer_ind,2);
end

if strcmp(handles.survey_type,'2D Survey')
    [Us_xy,isou,~] = unique(s_xy,'sorted','rows'); % SORTED
    [Ur_xy,irec,~] = unique(r_xy,'sorted','rows');
    [Ucdp_xy,icdp,~] = unique(cdp_xy,'sorted','rows');
elseif strcmp(handles.survey_type,'3D Survey')
    [Us_xy,~,~] = unique(s_xy,'stable','rows'); % STABLE, лучше так оставить для 3D
    [Ur_xy,~,~] = unique(r_xy,'stable','rows');
    [Ucdp_xy,~,~] = unique(cdp_xy,'stable','rows');
end
iL = r_m.Data.seis(74,indL);
xL = r_m.Data.seis(75,indL);
iL = iL(ia);
xL = xL(ia);
UiL = iL(isou);
UxL = iL(irec);
Us_el = s_el(isou);
Ur_el = r_el(isou);

[A,f,coord_xy,factors_ind,model_type,x] = sp_rp_off_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,iL,xL,UiL,UxL,layers,layer_ind,s_el,r_el,Us_el,Ur_el);

% f(isnan(f)) = 0;
% f(isinf(f)) = 0;
% if strcmp(handles.sol_method,'Matlab solver for sparse matrice') && isempty(handles.spec_cond_4)
%     x = A\f;
% elseif strcmp(handles.sol_method,'Gauss-Seidel method') && isempty(handles.spec_cond_4)
%     x = gauss_seidel(A,f,handles.n_iter);
% elseif strcmp(handles.sol_method,'Jacobi method') && isempty(handles.spec_cond_4)
%     x = jacobi_solve(A,f,handles.n_iter);
% end
x = x';

s_hdr = zeros(size(r_f.trc_hdr_info,1),size(x,2));
Ufactors_ind = unique(factors_ind,'stable');
for n = 1:length(Ufactors_ind)
    if any(Ufactors_ind(n) == 1:10:111)
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(22:23,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    elseif any(Ufactors_ind(n) == 2:10:112)
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(24:25,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
    elseif any(Ufactors_ind(n) == 3:10:113)
        ind = factors_ind == Ufactors_ind(n);
        s_hdr(72:73,ind) = coord_xy(:,ind);
        s_hdr(1,ind) = Ufactors_ind(n);
        x(ind) = 1./x(ind);
    end
end

s_hdr = single(s_hdr);
x = single(x);
fwrite(s_fileID,[s_hdr; x],'single');
seismic = r_f;
seismic.ntr = size(x,2);
seismic.ns = size(x,1);
seismic.param = handles;

seismic.plot_type = 'line';
save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;


function [A,f,coord_xy,factors_ind,model_type,x] = sp_rp_off_mtrx(handles,L,ia,ib,Us_xy,Ur_xy,Ucdp_xy,s_xy,r_xy,cdp_xy,r_f,hrz_t,trc_num,r_m,indL,iL,xL,UiL,UxL,layers,layer_ind,s_el,r_el,Us_el,Ur_el)
if handles.sc_model_num == 1
    k = 1;
    model_type = 'SP+RP+|OFFSET|^1';
elseif handles.sc_model_num == 2
    k = 2;
    model_type = 'SP+RP+|OFFSET|^2';
end

if ~isempty(handles.spec_cond_2)
    y1 = movmean(Ucdp_xy(:,1),round(length(Ucdp_xy(:,1))/100));
    y2 = movmean(Ucdp_xy(:,2),round(length(Ucdp_xy(:,2))/100));
    len_Ucdp_xy_old = sum(sqrt(diff(y1).^2 + diff(y2).^2));
    Ucdp_xy = cell(1,length(handles.spec_cond_2));
    for n = 1:length(handles.spec_cond_2)
        n_bins = round(len_Ucdp_xy_old./handles.spec_cond_2(n));
        Ucdp_xy{n} = interparc(n_bins,y1,y2,'linear');
        len_Ucdp_xy(n) = size(Ucdp_xy{n},1);
    end
elseif isempty(handles.spec_cond_2)
    len_Ucdp_xy(1:layers) = size(Ucdp_xy,1);
    Ucdp_xy = mat2cell(Ucdp_xy,size(Ucdp_xy,1),size(Ucdp_xy,2));
    Ucdp_xy = repmat(Ucdp_xy,1,layers);
end
if ~isempty(handles.spec_cond_4)
    Aoff = zeros(length(ia),sum(handles.spec_cond_4));
    fmax = 1/2;
    for n = 1:layers
        frq{n} = linspace(0,fmax,handles.spec_cond_4(n));
    end
    len_frq = handles.spec_cond_4;
elseif isempty(handles.spec_cond_4)
    col_Aoff = 0;
    for m = 1:layers
        col_Aoff = col_Aoff + size(Ucdp_xy{m},1);
    end
    Aoff = sparse(length(ia),col_Aoff);
end

As = sparse(length(ia),size(Us_xy,1)*layers);
Ar = sparse(length(ia),size(Ur_xy,1)*layers);
f = zeros(length(ia),1);
if isempty(handles.spec_cond_4)
    for n = 1:length(ia)
        [~, ind] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,ind:size(Us_xy,1):ind+size(Us_xy,1)*(layers-1)) = logical(layer_ind(n,:));
        [~, ind] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,ind:size(Ur_xy,1):ind+size(Ur_xy,1)*(layers-1)) = logical(layer_ind(n,:));
        [~, ind] = min(sqrt((Ucdp_xy{max(layer_ind(n,:))}(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy{max(layer_ind(n,:))}(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,ind+sum(len_Ucdp_xy(1:max(layer_ind(n,:))))-len_Ucdp_xy(max(layer_ind(n,:)))) = abs(L(n)).^k;
        f(n,1) = hrz_t(n);
    end
elseif ~isempty(handles.spec_cond_4) % только для одного слоя пока что
    for n = 1:length(ia)
        [~, ind] = min(sqrt((Us_xy(:,1)-s_xy(n,1)).^2+(Us_xy(:,2)-s_xy(n,2)).^2)); % find closest ind
        As(n,ind:size(Us_xy,1):ind+size(Us_xy,1)*(layers-1)) = logical(layer_ind(n,:));
        [~, ind] = min(sqrt((Ur_xy(:,1)-r_xy(n,1)).^2+(Ur_xy(:,2)-r_xy(n,2)).^2)); % find closest ind
        Ar(n,ind:size(Ur_xy,1):ind+size(Ur_xy,1)*(layers-1)) = logical(layer_ind(n,:));
        [~, ind] = min(sqrt((Ucdp_xy{max(layer_ind(n,:))}(:,1)-cdp_xy(n,1)).^2+(Ucdp_xy{max(layer_ind(n,:))}(:,2)-cdp_xy(n,2)).^2)); % find closest ind
        Aoff(n,sum(len_frq(1:max(layer_ind(n,:))-1))+1:sum(len_frq(1:max(layer_ind(n,:))))) = cos(frq{max(layer_ind(n,:))}.*ind).*abs(L(n));
        f(n,1) = hrz_t(n);
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
        if any(in_s) && any(in_r)
            As1(n,:) = in_s'./(sum(in_s));
            Ar1(n,:) = in_r'./(sum(in_r));
        end
    end
    As1 = As1(~any(isnan(As1),2),:);
    Ar1 = Ar1(~any(isnan(Ar1),2),:);
    As1 = As1(~any(isinf(As1),2),:);
    Ar1 = Ar1(~any(isinf(Ar1),2),:);
    AS1 = [As1 zeros(size(As1,1),(layers-1)*size(As1,2))];
    AR1 = [Ar1 zeros(size(Ar1,1),(layers-1)*size(Ar1,2))];
    if layers > 1
        for n = 1:layers-1
            AS1 = [AS1; circshift([As1 zeros(size(As1,1),(layers-1)*size(As1,2))],size(Us_xy,1),2)];
            AR1 = [AR1; circshift([Ar1 zeros(size(Ar1,1),(layers-1)*size(Ar1,2))],size(Us_xy,1),2)];
        end
    end
    As = [As; AS1];
    Ar = [Ar; -AR1];
    Aoff = [Aoff; zeros(size(AS1,1),size(Aoff,2))];
    f1 = zeros(size(AS1,1),1);
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
    AS2 = [As2 zeros(size(As2,1),(layers-1)*size(As2,2))];
    if layers > 1
        for n = 1:layers-1
            AS2 = [AS2; circshift([As2 zeros(size(As2,1),(layers-1)*size(As2,2))],size(Us_xy,1),2)];
        end
    end
    AR2 = sparse(size(AS2,1),size(Ar,2));
    AOFF2 = sparse(size(AS2,1),size(Aoff,2));
    As = [As; AS2];
    Ar = [Ar; AR2];
    Aoff = [Aoff; AOFF2];
    f2 = zeros(size(AS2,1),1);
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
    AR2 = [Ar2 zeros(size(Ar2,1),(layers-1)*size(Ar2,2))];
    if layers > 1
        for n = 1:layers-1
            AR2 = [AR2; circshift([Ar2 zeros(size(Ar2,1),(layers-1)*size(Ar2,2))],size(Ur_xy,1),2)];
        end
    end
    AS2 = sparse(size(AR2,1),size(As,2));
    AOFF2 = sparse(size(AR2,1),size(Aoff,2));
    Ar = [Ar; AR2];
    As = [As; AS2];
    Aoff = [Aoff; AOFF2];
    f2 = zeros(size(AR2,1),1);
    f = [f; f2];
end
if ~isempty(handles.spec_cond_5_OFFSET)
    for k = 1:layers
        Aoff2 = zeros(size(Ucdp_xy{k},1),len_Ucdp_xy(k));
        th = 0:pi/50:2*pi;
        for n = 1:size(Ucdp_xy{k},1)
            xv = handles.spec_cond_5_OFFSET * cos(th) + Ucdp_xy{k}(n,1);
            yv = handles.spec_cond_5_OFFSET * sin(th) + Ucdp_xy{k}(n,2);
            in_offset = inpolygon(Ucdp_xy{k}(:,1),Ucdp_xy{k}(:,2),xv,yv);
            Aoff2(n,:) = ones(1,len_Ucdp_xy(k))./len_Ucdp_xy(k) - in_offset'./(sum(in_offset));
        end
        Aoff2 = Aoff2(~any(isnan(Aoff2),2),:);
        Aoff2 = Aoff2(~any(isinf(Aoff2),2),:);
        if k == 1
            AOFF2 = [Aoff2 zeros(size(Aoff2,1),sum(len_Ucdp_xy)-len_Ucdp_xy(k))];
        elseif k > 1
            AOFF2 = circshift([Aoff2 zeros(size(Aoff2,1),sum(len_Ucdp_xy)-len_Ucdp_xy(k))],len_Ucdp_xy(k-1),2);
        end
        AS2 = sparse(size(AOFF2,1),size(As,2));
        AR2 = sparse(size(AOFF2,1),size(Ar,2));
        Aoff = [Aoff; AOFF2];
        As = [As; AS2];
        Ar = [Ar; AR2];
        f2 = zeros(size(AOFF2,1),1);
        f = [f; f2];
    end
end
% for m = 1:layers
%     for n = 1:size(Us_xy,1)
%         As(end+1,n+size(Us_xy,1)*(m-1)) = 1;
%         [~, ind] = min(sqrt((Us_xy(n,1)-Ur_xy(:,1)).^2+(Us_xy(:,2)-Ur_xy(n,2)).^2)); % find closest ind
%         Ar(end+1,ind+size(Ur_xy,1)*(m-1)) = -1;
%         if layers == 1 && m == 1
%             [~, ind] = min(sqrt((Us_xy(n,1)-Ucdp_xy{1}(:,1)).^2+(Us_xy(n,2)-Ucdp_xy{1}(:,2)).^2)); % find closest ind
%             Aoff(end+1,ind) =  Ur_el(ind) - Us_el(n);
%         elseif layers ~= 1 && m == 1
%             [~, ind] = min(sqrt((Us_xy(n,1)-Ucdp_xy{1}(:,1)).^2+(Us_xy(n,2)-Ucdp_xy{1}(:,2)).^2)); % find closest ind
%             Aoff(end+1,ind) =  Ur_el(ind) - Us_el(n);
%         end
%         f(end+1) = 0;
%     end
% end
A = [As Ar Aoff];
ind1 = any(A,2) & ~any(isnan(A),2) & ~any(isinf(A),2);
ind2 = any(A,1);
A = A(ind1,ind2);
f = f(ind1,:);
if ~isempty(handles.spec_cond_4)
    ind2(size(As,2)+size(Ar,2)+1:size(As,2)+size(Ar,2)+sum(len_Ucdp_xy)) = true;
end
x = solve_mtx(A,f,handles);
if ~isempty(handles.spec_cond_4)
    x_off = [];
    for n = 1:layers
        profil = 1:len_Ucdp_xy(n);
        D = cos(repmat(frq{n},size(Ucdp_xy{n},1),1).*repmat(profil',1,length(frq{n})));
        x_off = [x_off; D*x(size(As,2)+size(Ar,2)+sum(len_frq(1:n-1))+1:size(As,2)+size(Ar,2)+sum(len_frq(1:n)))];
    end
    x = [x(1:size(As,2)+size(Ar,2)); x_off];
end

fac_s_ind = [];
fac_r_ind = [];
fac_off_ind = [];
for n = 1:layers
    fac_s_ind = [fac_s_ind ones(1,size(Us_xy,1))+(n-1)*10];
    fac_r_ind = [fac_r_ind 2*ones(1,size(Ur_xy,1))+(n-1)*10];
    fac_off_ind = [fac_off_ind 3*ones(1,size(Ucdp_xy{n},1))+(n-1)*10];
end
coord_xy = [repmat(Us_xy',1,layers) repmat(Ur_xy',1,layers) cell2mat(Ucdp_xy')'];
factors_ind = [fac_s_ind fac_r_ind fac_off_ind];
coord_xy = coord_xy(:,ind2);
factors_ind = factors_ind(:,ind2);

function x = solve_mtx(A,f,handles)
if strcmp(handles.sol_method,'Matlab solver for sparse matrice')
    x = A\f;
elseif strcmp(handles.sol_method,'Gauss-Seidel method')
    x = gauss_seidel(A,f,handles.n_iter);
elseif strcmp(handles.sol_method,'Jacobi method')
    x = jacobi_solve(A,f,handles.n_iter);
end