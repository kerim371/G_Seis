function g_restr_by_picks(hParent)
handles = guidata(hParent);
% load input sesmic
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);

s_xy = r_m.Data.seis(22:23,:)';
r_xy = r_m.Data.seis(24:25,:)';

mat_hrz = load([handles.hrz_path handles.hrz_file]);
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
[~,ia,ib] = intersect(trc_hdr,hrz_hdr,'rows','stable');
s_xy = s_xy(ia,:);
r_xy = r_xy(ia,:);
hrz_hdr = hrz_hdr(ib,:);
hrz_t = hrz_t(ib,:);
[Us_xy,ias,ibs] = unique(s_xy,'sorted','rows');
[Ur_xy,iar,ibr] = unique(r_xy,'sorted','rows');
U_xy = [Us_xy; Ur_xy];
[Do(1),min_ind] = min(U_xy(:,1));
Do(2) = U_xy(min_ind,2);

Us_dist = sqrt((Us_xy(:,1)-Do(1)).^2+(Us_xy(:,2)-Do(2)).^2);
Ur_dist = sqrt((Ur_xy(:,1)-Do(1)).^2+(Ur_xy(:,2)-Do(2)).^2);

s_dist = sqrt((s_xy(:,1)-Do(1)).^2+(s_xy(:,2)-Do(2)).^2);
r_dist = sqrt((r_xy(:,1)-Do(1)).^2+(r_xy(:,2)-Do(2)).^2);

Uc = rand(length(Ur_dist),1);
c = Uc(ibs);

if ~isempty(findobj('Type','figure','Name','Layer picking'))
    close 'Layer picking' % закрыть figure
end
figure('Name','Layer picking','Units','normalized','Position',[0 0.5 1 0.3]);

uic_ax = uicontextmenu;
uic_scatter = uicontextmenu;
uic_line = uicontextmenu;

scatter(r_dist,hrz_t,[],c,'.','UIContextMenu',uic_scatter,...
    'ButtonDownFcn',{@highlight_line,s_dist,r_dist,hrz_t});
grid on;
colormap jet;
title('First break Picks');
xlabel('Receiver point distance, m'); ylabel('Time, ms');
ax = gca;
ax.FontName = 'Agency FB';
ax.UIContextMenu = uic_ax;

% Create push button SAVE FILE
btn = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Units','pixels','Position', [10 10 70 30],...
    'Callback', {@save_hrz,handles,mat_hrz,s_dist,r_dist,hrz_t,ib});

uimenu(uic_ax,'Label','Add Layer','Callback',{@context_menu_fun,uic_ax,uic_scatter,uic_line});
uimenu(uic_scatter,'Label','Add Layer','Callback',{@context_menu_fun,uic_ax,uic_scatter,uic_line});
uimenu(uic_line,'Label','Remove Layer','Callback',{@context_menu_fun,uic_ax,uic_scatter,uic_line});

function highlight_line(hObject,eventdata,s_dist,r_dist,hrz_t)
if eventdata.Button == 1
    ax = gca;
    hold on;
    l_obj = findobj(ax,'Type','line','Tag','Temporal line');
    delete(l_obj);

    r_ind = r_dist==eventdata.IntersectionPoint(1) & hrz_t==eventdata.IntersectionPoint(2);
    ind = s_dist == min(s_dist(r_ind));

    plot(ax,r_dist(ind),hrz_t(ind),'k','LineWidth',2,'Tag','Temporal line');
    hold off;
end

function context_menu_fun(source,callbackdata,uic_ax,uic_scatter,uic_line)
ax = gca;
switch source.Label
    case 'Add Layer'
        prompt = {'Layer number (layers should have an increasing numeration. The nearsurface layer should have the smallest value):'};
        dlgtitle = 'Layer number';
        dims = [1 25];
        answer = inputdlg(prompt,dlgtitle,dims);
        if isempty(answer)
            return;
        elseif ~isempty(answer)
            if isempty(str2num(answer{1}))
                return;
            end
        end
        s_obj = findobj(ax,'Type','Scatter');
        ax.UIContextMenu = '';
        s_obj.UIContextMenu = '';
        lay_num = str2num(answer{1});
        for n = 1:length(ax.Children)
            ax.Children(n).PickableParts = 'none';
        end
        ax.ButtonDownFcn = {@draw_layer,lay_num,uic_ax,uic_scatter,uic_line};
    case 'Remove Layer'
        obj = gco;
        l_obj = findobj(ax,'Type','line','UserData',obj.UserData);
        p_obj = findobj(ax,'Type','patch','UserData',obj.UserData);
        txt_obj = findobj(ax,'Type','text','UserData',obj.UserData);
        delete(l_obj);
        delete(p_obj);
        delete(txt_obj);
end

function draw_layer(hObject,eventdata,lay_num,uic_ax,uic_scatter,uic_line)
ax = gca;
s_obj = findobj(ax,'Type','Scatter');
hold on;
pos = get(gca,'CurrentPoint');
obj = findobj(ax,'Type','line','UserData',lay_num);
if eventdata.Button == 1
    if isempty(obj)
        obj = plot(ax,pos(1,1),pos(1,2),'-*','MarkerSize',5,...
            'LineWidth',1.5,'Tag','Layer','UserData',lay_num,...
            'ButtonDownFcn',{@fill_line,uic_line},'UIContextMenu',uic_line);
    else
        obj.XData(end+1) = pos(1,1);
        obj.YData(end+1) = pos(1,2);
    end
    obj.PickableParts = 'none';
elseif eventdata.Button == 3
    if isempty(obj)
        ax.ButtonDownFcn = '';
        pause(1);
        ax.UIContextMenu = uic_ax;
        s_obj.UIContextMenu = uic_scatter;
    else
        obj.XData(end+1) = obj.XData(1);
        obj.YData(end+1) = obj.YData(1);
        txt = text(pos(1,1),pos(1,2),['Layer ' num2str(lay_num)],...
            'FontWeight','bold','FontSize',10,'PickableParts','none');
        txt.UserData = lay_num;
        ax.ButtonDownFcn = '';
        pause(1);
        ax.UIContextMenu = uic_ax;
        s_obj.UIContextMenu = uic_scatter;
    end
    for n = 1:length(ax.Children)
        if ~strcmp(ax.Children(n).Type,'text')
            ax.Children(n).PickableParts = 'visible';
        end
    end
end
hold off;

function fill_line(hObject,eventdata,uic_line)
if eventdata.Button == 1
    ax = gca;
    obj = gco;
    hold on;
    p_obj = findobj(ax,'Type','Patch','UserData',obj.UserData);
    if isempty(p_obj)
        p_obj = fill(obj.XData,obj.YData,obj.Color,'FaceAlpha',0.3,...
            'ButtonDownFcn',@fill_line,'UIContextMenu',uic_line);
        p_obj.UserData = obj.UserData;
    else
        delete(p_obj);
    end
    hold off;
end

function save_hrz(hObject,eventdata,handles,mat_hrz,s_dist,r_dist,hrz_t,ib)
ax = gca;
l_obj = findobj(ax,'Type','line','Tag','Layer');
lay_num = zeros(1,length(l_obj));
for n = 1:length(l_obj)
    lay_num(n) = l_obj(n).UserData;
end
[lay_num,i_lay] = sort(lay_num); % sort in increasing layers
ind = false(length(r_dist),length(l_obj));
for n = 1:length(l_obj)
    ind(:,n) = inpolygon(r_dist,hrz_t,l_obj(i_lay(n)).XData,l_obj(i_lay(n)).YData);
end

n = 1:size(ind,2)-1;
N = sum(n);
n = 2;
m = 1;
for k = 1:N % exclude points that are in several polygons and leave them in first
    r1_min = min(r_dist(ind(:,m)));
    r1_max = max(r_dist(ind(:,m)));
    i1 = r_dist >= r1_min & r_dist <= r1_max;
    
    
    r2_min = min(r_dist(ind(:,n)));
    r2_max = max(r_dist(ind(:,n)));
    i2 = r_dist >= r2_min & r_dist <= r2_max;
    
    ind(i1 & i2,m) = true;
    if n == size(ind,2)
        m = m+1;
        n = m+1;
    else
        n = n+1;
    end
end

col_ind = [];
for n = 1:length(mat_hrz.col_names)
    if ~strcmp(mat_hrz.col_names{n},'Layer')
        col_ind(end+1) = n;
    end
end
col_names = mat_hrz.col_names(:,col_ind);
hrz = mat_hrz.hrz(:,col_ind);
col_names(end+1:end+size(ind,2)) = {'Layer'};
%hrz = [hrz(ib,:) ind];
hrz = [hrz(ib,:) repmat(1:length(lay_num),length(r_dist),1).*ind];
save([handles.hrz_path handles.hrz_file],'col_names','hrz');
msgbox(['Horizon file: ' [handles.hrz_path handles.hrz_file] ' updated!'],'Success');