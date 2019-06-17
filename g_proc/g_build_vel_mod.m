function g_build_vel_mod(hParent)
handles = guidata(hParent);
% load input FACTORS
r_f_fact = load([handles.r_factors_path handles.r_factors_file]);
r_f_fact = r_f_fact.seismic;
if ~isfield(r_f_fact,'layers') && ~isfield(r_f_fact,'vel')
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

    s_xy = r_m.Data.seis(22:23,:)';
    r_xy = r_m.Data.seis(24:25,:)';
    [Us_xy,ias,~] = unique(s_xy,'sorted','rows');
    [Ur_xy,iar,~] = unique(r_xy,'sorted','rows');
    U_xy = [Us_xy; Ur_xy];
    [Do(1),min_ind] = min(U_xy(:,1));
    Do(2) = U_xy(min_ind,2);

    Us_dist = sqrt((Us_xy(:,1)-Do(1)).^2+(Us_xy(:,2)-Do(2)).^2);
    Ur_dist = sqrt((Ur_xy(:,1)-Do(1)).^2+(Ur_xy(:,2)-Do(2)).^2);

    Us_el = r_m.Data.seis(14,ias)'; % Рельеф ПВ
    Ur_el = r_m.Data.seis(13,iar)'; % Рельеф ПП
    Us_h = r_m.Data.seis(14,ias)'-r_m.Data.seis(15,ias)'; % Положение ПВ

    fact_ID = r_m_fact.Data.seis(1,:);
    Ufact_ID = unique(fact_ID,'stable');
    N = [1:10:41 3:10:43 2:10:42];
    for n = 1:length(N)
        ind = fact_ID == N(n);
        if N(n) == 1 && any(ind)
            s{1,1} = r_m_fact.Data.seis([22:23 r_f_fact.nh+1],ind)';
            s{1,1}(:,4) = sqrt((s{1}(:,1)-Do(1)).^2+(s{1}(:,2)-Do(2)).^2);
            s{1,1}(:,5) = Us_h;
        elseif N(n) == 11 && any(ind)
            s{2,1} = r_m_fact.Data.seis([22:23 r_f_fact.nh+1],ind)';
            s{2,1}(:,4) = sqrt((s{2}(:,1)-Do(1)).^2+(s{2}(:,2)-Do(2)).^2);
        elseif N(n) == 21 && any(ind)
            s{3,1} = r_m_fact.Data.seis([22:23 r_f_fact.nh+1],ind)';
            s{3,1}(:,4) = sqrt((s{3}(:,1)-Do(1)).^2+(s{3}(:,2)-Do(2)).^2);
        elseif N(n) == 31 && any(ind)
            s{4,1} = r_m_fact.Data.seis([22:23 r_f_fact.nh+1],ind)';
            s{4,1}(:,4) = sqrt((s{4}(:,1)-Do(1)).^2+(s{4}(:,2)-Do(2)).^2);
        elseif N(n) == 41 && any(ind)
            s{5,1} = r_m_fact.Data.seis([22:23 r_f_fact.nh+1],ind)';
            s{5,1}(:,4) = sqrt((s{5}(:,1)-Do(1)).^2+(s{5}(:,2)-Do(2)).^2);
        elseif N(n) == 2 && any(ind)
            r{1,1} = r_m_fact.Data.seis([24:25 r_f_fact.nh+1],ind)';
            r{1,1}(:,4) = sqrt((r{1}(:,1)-Do(1)).^2+(r{1}(:,2)-Do(2)).^2);
            r{1,1}(:,5) = Ur_el;
        elseif N(n) == 12 && any(ind)
            r{2,1} = r_m_fact.Data.seis([24:25 r_f_fact.nh+1],ind)';
            r{2,1}(:,4) = sqrt((r{2}(:,1)-Do(1)).^2+(r{2}(:,2)-Do(2)).^2);
            % with time from Layer 1 (this time is not a thickness of Layer 1, but it is a residual time)
            r{2,1}(:,5) = (interp1(r{1}(:,4),r{1}(:,5),r{2}(:,4),'linear','extrap')+interp1(s{1}(:,4),s{1}(:,5),r{2}(:,4),'linear','extrap')-...
                (interp1(r{1}(:,4),r{1}(:,3),r{2}(:,4),'linear','extrap')+interp1(s{1}(:,4),s{1}(:,3),r{2}(:,4),'linear','extrap')+...
                r{2,1}(:,3)+interp1(s{2}(:,4),s{2}(:,3),r{2}(:,4),'linear','extrap')).*...
                interp1(v{1}(:,4),v{1}(:,3),r{2}(:,4),'linear','extrap'))./2;
            % without time from Layer 1 (this time is not a thickness of Layer 1, but it is a residual time)
    %         r{2,1}(:,5) = (interp1(r{1}(:,4),r{1}(:,5),r{2}(:,4),'linear','extrap')+interp1(s{1}(:,4),s{1}(:,5),r{2}(:,4),'linear','extrap')-...
    %             (r{2,1}(:,3)+interp1(s{2}(:,4),s{2}(:,3),r{2}(:,4),'linear','extrap')).*...
    %             interp1(v{1}(:,4),v{1}(:,3),r{2}(:,4),'linear','extrap'))./2;
        elseif N(n) == 22 && any(ind)
            r{3,1} = r_m_fact.Data.seis([24:25 r_f_fact.nh+1],ind)';
            r{3,1}(:,4) = sqrt((r{3}(:,1)-Do(1)).^2+(r{3}(:,2)-Do(2)).^2);
            r{3,1}(:,5) = interp1(r{2}(:,4),r{2}(:,5),r{3}(:,4),'linear','extrap')-...
                (r{3}(:,3)+interp1(s{3}(:,4),s{3}(:,3),r{3}(:,4),'linear','extrap')).*...
                interp1(v{2}(:,4),v{2}(:,3),r{3}(:,4),'linear','extrap')./2;
        elseif N(n) == 32 && any(ind)
            r{4,1} = r_m_fact.Data.seis([24:25 r_f_fact.nh+1],ind)';
            r{4,1}(:,4) = sqrt((r{4}(:,1)-Do(1)).^2+(r{4}(:,2)-Do(2)).^2);
            r{4,1}(:,5) = interp1(r{3}(:,4),r{3}(:,5),r{4}(:,4),'linear','extrap')-...
                (r{4}(:,3)+interp1(s{4}(:,4),s{4}(:,3),r{4}(:,4),'linear','extrap')).*...
                interp1(v{3}(:,4),v{3}(:,3),r{4}(:,4),'linear','extrap')./2;
        elseif N(n) == 42 && any(ind)
            r{5,1} = r_m_fact.Data.seis([24:25 r_f_fact.nh+1],ind)';
            r{5,1}(:,4) = sqrt((r{5}(:,1)-Do(1)).^2+(r{5}(:,2)-Do(2)).^2);
            r{5,1}(:,5) = interp1(r{4}(:,4),r{4}(:,5),r{5}(:,4),'linear','extrap')-...
                (r{5}(:,3)+interp1(s{5}(:,4),s{5}(:,3),r{5}(:,4),'linear','extrap')).*...
                interp1(v{4}(:,4),v{4}(:,3),r{5}(:,4),'linear','extrap')./2;
        elseif N(n) == 3 && any(ind)
            v{1,1} = r_m_fact.Data.seis([72:73 r_f_fact.nh+1],ind)';
            v{1,1}(:,4) = sqrt((v{1}(:,1)-Do(1)).^2+(v{1}(:,2)-Do(2)).^2);
        elseif N(n) == 13 && any(ind)
            v{2,1} = r_m_fact.Data.seis([72:73 r_f_fact.nh+1],ind)';
            v{2,1}(:,4) = sqrt((v{2}(:,1)-Do(1)).^2+(v{2}(:,2)-Do(2)).^2);
        elseif N(n) == 23 && any(ind)
            v{3,1} = r_m_fact.Data.seis([72:73 r_f_fact.nh+1],ind)';
            v{3,1}(:,4) = sqrt((v{3}(:,1)-Do(1)).^2+(v{3}(:,2)-Do(2)).^2);
        elseif N(n) == 33 && any(ind)
            v{4,1} = r_m_fact.Data.seis([72:73 r_f_fact.nh+1],ind)';
            v{4,1}(:,4) = sqrt((v{4}(:,1)-Do(1)).^2+(v{4}(:,2)-Do(2)).^2);
        elseif N(n) == 43 && any(ind)
            v{5,1} = r_m_fact.Data.seis([72:73 r_f_fact.nh+1],ind)';
            v{5,1}(:,4) = sqrt((v{5}(:,1)-Do(1)).^2+(v{5}(:,2)-Do(2)).^2);
        end
    end
    min_h = min(r{end}(:,5));
    max_h = max(r{1}(:,5));
    min_x = min(r{1}(:,4));
    max_x = max(r{1}(:,4));
    N = length(Ur_dist);
    verts1 = [Ur_dist Ur_el; Ur_dist repmat(min_h,N,1)];
    faces1 = [1:N-1; 2:N; 2+N:N+N; 1+N:N-1+N];
    faces1 = faces1';

    if ~isempty(findobj('Type','figure','Name','Vel model'))
        close 'Vel model' % закрыть figure
    end
    figure('Name','Vel model');

    % context menu when right click on object
    uic_ax1 = uicontextmenu;
    uic_ax2 = uicontextmenu;
    uic_patch = uicontextmenu;
    uic_line = uicontextmenu;

    uic_ax1.Tag = 'uic_ax1';
    uic_ax2.Tag = 'uic_ax2';
    uic_patch.Tag = 'uic_patch';
    uic_line.Tag = 'uic_line';

    subplot(2,1,1);
    title('Velocity model');
    xlabel('Distance, m'); ylabel('Elevation, m');
    ax1 = gca;
    ax1.FontName = 'Agency FB';
    ax1.XLim = [min_x max_x];
    ax1.YLim = [min_h max_h];
    ax1.Tag = 'ax1';
    ax1.UserData = 0; % NUMBER OF FICTIVE LAYERS!!!
    ax1.UIContextMenu = uic_ax1;
    c1 = interp1(v{1}(:,4),v{1}(:,3),Ur_dist,'linear','extrap');
    p_surface = patch(ax1,'Faces',faces1,'Vertices',verts1,'EdgeColor', 'none',...
        'FaceVertexCData',[c1; c1],'FaceColor','interp','PickableParts','visible',...
        'UIContextMenu',uic_patch,'Tag','Patch_v_1',...
        'UserData','Layer 1','ButtonDownFcn',@disp_layer_number);
    hold on;
    grid on;
    colormap jet;

    subplot(2,1,2);
    xlabel('Distance, m'); ylabel('Velocity, m/ms');
    ax2 = gca;
    ax2.FontName = 'Agency FB';
    ax2.XLim = [min_x max_x];
    ax2.Tag = 'ax2';
    ax2.UIContextMenu = uic_ax2;
    hold on;
    grid on;
    plot(ax2,v{1}(:,4),v{1}(:,3),'-o','MarkerSize',2,...
        'UIContextMenu',uic_line,'Tag','Line_v_1',...
        'UserData','Layer 1');
    leg_txt = cell(size(r));
    leg_txt{1} = 'Layer 1';

    linkaxes([ax1 ax2] ,'x');
    for n = 2:size(r,1)
        N = size(r{n},1);
        verts2 = [r{n}(:,4) r{n}(:,5); r{n}(:,4) repmat(min_h,N,1)];
        faces2 = [1:N-1; 2:N; 2+N:N+N; 1+N:N-1+N];
        faces2 = faces2';

        c2 = interp1(v{n}(:,4),v{n}(:,3),r{n}(:,4),'linear','extrap');
        p_layer = patch(ax1,'Faces',faces2,'Vertices',verts2,'EdgeColor', 'none',...
            'FaceVertexCData',[c2; c2],'FaceColor','interp','PickableParts','visible',...
            'UIContextMenu',uic_patch,'Tag',['Patch_v_' num2str(n)],...
            'UserData',['Layer ' num2str(n)],'ButtonDownFcn',@disp_layer_number);

        plot(ax2,v{n}(:,4),v{n}(:,3),'-o','MarkerSize',2,...
            'UIContextMenu',uic_line,'Tag',['Line_v_' num2str(n)],...
            'UserData',['Layer ' num2str(n)]);
        leg_txt{n} = ['Layer ' num2str(n)];
        if n == size(r,1) % plot SP hole depth
            plot(ax1,Us_dist,Us_h,'g.',...
                'UIContextMenu',uic_line,'Tag','Line_hole_elevation');
            p_surface.Vertices(end/2+1:end,2) = ax1.YLim(1);
            p_layer.Vertices(end/2+1:end,2) = ax1.YLim(1);
            fig_pan = pan(gcf);
            fig_pan.ActionPostCallback = @(x,y) Ax_lim_control(ax1);
        end
    end
    legend(leg_txt,'Tag','line_legend');
elseif isfield(r_f_fact,'layers') && isfield(r_f_fact,'vel')
    if ~isempty(findobj('Type','figure','Name','Vel model'))
        close 'Vel model' % закрыть figure
    end
    figure('Name','Vel model');

    % context menu when right click on object
    uic_ax1 = uicontextmenu;
    uic_ax2 = uicontextmenu;
    uic_patch = uicontextmenu;
    uic_line = uicontextmenu;

    uic_ax1.Tag = 'uic_ax1';
    uic_ax2.Tag = 'uic_ax2';
    uic_patch.Tag = 'uic_patch';
    uic_line.Tag = 'uic_line';

    subplot(2,1,1);
    title('Velocity model');
    xlabel('Distance, m'); ylabel('Elevation, m');
    ax1 = gca;
    ax1.FontName = 'Agency FB';
    ax1.Tag = 'ax1';
    ax1.UserData = 0; % NUMBER OF FICTIVE LAYERS!!!
    ax1.UIContextMenu = uic_ax1;
        hold on;
        grid on;
        colormap jet;
    subplot(2,1,2);
    xlabel('Distance, m'); ylabel('Velocity, m/ms');
    ax2 = gca;
    ax2.FontName = 'Agency FB';
    ax2.Tag = 'ax2';
    ax2.UIContextMenu = uic_ax2;
        hold on;
        grid on;
    min_x = min(r_f_fact.layers{1,1}(:,1));
    max_x = max(r_f_fact.layers{1,1}(:,1));
    min_h = min(r_f_fact.layers{1,1}(:,2));
    max_h = max(r_f_fact.layers{1,1}(:,2));
    for n = 1:size(r_f_fact.layers,1)
        p_surface = patch(ax1,'Faces',r_f_fact.layers{n,3},'Vertices',r_f_fact.layers{n,2},'EdgeColor', 'none',...
            'FaceVertexCData',r_f_fact.layers{n,4},'FaceColor','interp','PickableParts','visible',...
            'UIContextMenu',uic_patch,'Tag',r_f_fact.tags{n,1},...
            'UserData',['Layer ' num2str(n)],'ButtonDownFcn',@disp_layer_number);
        
        plot(ax2,r_f_fact.vel{n,1}(:,1),r_f_fact.vel{n,1}(:,2),'-o','MarkerSize',2,...
            'UIContextMenu',uic_line,'Tag',r_f_fact.tags{n,2},...
            'UserData',['Layer ' num2str(n)]);
        leg_txt{n} = ['Layer ' num2str(n)];
        if strcmp(r_f_fact.tags{n,1}(1:7),'Fictive')
            ax1.UserData = ax1.UserData+1;
        end
        if min_x > min(r_f_fact.layers{n,1}(:,1))
            min_x = min(r_f_fact.layers{n,1}(:,1));
        end
        if max_x < max(r_f_fact.layers{n,1}(:,1))
            max_x = max(r_f_fact.layers{n,1}(:,1));
        end
        if min_h > min(r_f_fact.layers{n,1}(:,2))
            min_h = min(r_f_fact.layers{n,1}(:,2));
        end
        if max_h < max(r_f_fact.layers{n,1}(:,2))
            max_h = max(r_f_fact.layers{n,1}(:,2));
        end
        if n == size(r_f_fact.layers,1) % plot SP hole depth
            plot(ax1,r_f_fact.hole_elevation(:,1),r_f_fact.hole_elevation(:,2),'g.',...
                'UIContextMenu',uic_line,'Tag','Line_hole_elevation');
            fig_pan = pan(gcf);
            fig_pan.ActionPostCallback = @(x,y) Ax_lim_control(ax1);
        end
    end
    legend(leg_txt,'Tag','line_legend');
    linkaxes([ax1 ax2] ,'x');
    
    ax1.XLim = [min_x max_x];
    ax1.YLim = [min_h max_h];
    
    s = r_f_fact.old.s;
    r = r_f_fact.old.r;
    v = r_f_fact.old.v;
end
% Create buttongroup
bg1 = uibuttongroup('Title','Use residual time:','BorderWidth',1,'Units','pixels',...
                  'Tag','bg1 residual time','FontWeight','bold','Position',[90 10 120 35]);
              
% Create radio buttons in the button group.
uicontrol(bg1,'Style','radiobutton',...
                  'String','Yes','Units','pixels',...
                  'Position',[10 0 40 20]);
              
% Create radio buttons in the button group.
uicontrol(bg1,'Style','radiobutton',...
                  'String','No','Units','pixels',...
                  'Position',[60 0 40 20]);

% Create push button SAVE FILE
btn = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Units','pixels','Position', [10 10 70 30],...
    'Callback', {@save_vel_model,r_f_fact,handles,s,r,v});

% Create child menu items for the uicontextmenu
uimenu(uic_ax1,'Label','Stop Action','Callback',{@context_menu_fun,[],[]});
uimenu(uic_ax2,'Label','Stop Action','Callback',{@context_menu_fun,[],[]});
uimenu(uic_patch,'Label','Set Active','Callback',{@context_menu_fun,[],[]});
uimenu(uic_patch,'Label','Smooth Line','Callback',{@context_menu_fun,[],[]});
uimenu(uic_patch,'Label','Vary Grid','Callback',{@context_menu_fun,[],[]});
uimenu(uic_patch,'Label','Add Layer','Callback',{@context_menu_fun,[],[]});
uimenu(uic_patch,'Label','Remove Layer','Callback',{@context_menu_fun,[],[]});
topmenu1 = uimenu('Parent',uic_patch,'Label','Adjust time-depth connection');
uimenu('Parent',topmenu1,'Label','to the chosen layer','Callback',{@context_menu_fun,s,r});
uimenu('Parent',topmenu1,'Label','to all layers','Callback',{@context_menu_fun,s,r});
topmenu2 = uimenu('Parent',uic_patch,'Label','Slam Layer');
uimenu('Parent',topmenu2,'Label','to the top','Callback',{@context_menu_fun,[],[]});
uimenu('Parent',topmenu2,'Label','to the bottom','Callback',{@context_menu_fun,[],[]});
uimenu(uic_line,'Label','Set Active','Callback',{@context_menu_fun,[],[]});
uimenu(uic_line,'Label','Smooth Line','Callback',{@context_menu_fun,[],[]});
uimenu(uic_line,'Label','Vary Grid','Callback',{@context_menu_fun,[],[]});


function Ax_lim_control(ax1)
p_obj = findobj(ax1,'Type','Patch');
for n = length(p_obj):-1:1
    obj = p_obj(n);
    if ax1.YLim(1) < min(obj.Vertices(1:end/2,2))
        obj.Vertices(end/2+1:end,2) = ax1.YLim(1);
    end
end

function context_menu_fun(source,callbackdata,s,r)
obj = gco;
switch source.Label
    case 'Stop Action'
        for n = 1:length(obj.Children)
            obj.Children(n).PickableParts = 'visible';
            obj.Children(n).Selected  = 'off';
        end
        set(gca,'ButtonDownFcn','');
    case 'Set Active'
        ax = gca;
        for n = 1:length(ax.Children)
            ax.Children(n).Selected = 'off';
            ax.Children(n).PickableParts = 'none';
        end
        obj.Selected  = 'on';
        obj_udata = obj.UserData;
        p_obj = findobj('Type','Patch','UserData',obj_udata);
        set(ax,'ButtonDownFcn',{@Vel_mod_drag_point, obj, p_obj});
    case 'Smooth Line'
        prompt = {['Now data contains: ' num2str(length(obj.XData)) ' points. Enter smooth-range of points:']};
        dlgtitle = 'Smooth Line';
        dims = [1 25];
        answer = inputdlg(prompt,dlgtitle,dims);
        if isempty(answer)
            return;
        elseif ~isempty(answer)
            if isempty(str2num(answer{1}))
                return;
            end
        end
        if strcmp(obj.Type,'line')
            obj.YData = smooth(obj.YData,str2num(answer{1}),'moving');
            if ~strcmp(obj.Tag,'Line_hole_elevation')
                obj_udata = obj.UserData;
                p_obj = findobj('Type','Patch','UserData',obj_udata);
                len = size(p_obj.Vertices,1);
                p_obj.FaceVertexCData = interp1(obj.XData,obj.YData,p_obj.Vertices(:,1),'linear','extrap');
            end
        elseif strcmp(obj.Type,'patch')
            len = size(obj.Vertices,1);
            obj.Vertices(1:len/2,2) = smooth(obj.Vertices(1:len/2,2),str2num(answer{1}),'moving');
        end
    case 'Vary Grid'
        if strcmp(obj.Type,'line')
            prompt = {['Now data contains: ' num2str(length(obj.XData)) ' points. Enter new value:']};
            dlgtitle = 'Vary Grid';
            dims = [1 25];
            answer = inputdlg(prompt,dlgtitle,dims);
            if isempty(answer)
                return;
            elseif ~isempty(answer)
                if isempty(str2num(answer{1}))
                    return;
                end
            end
            N = str2num(answer{1});
            dist = linspace(obj.XData(1),obj.XData(end),N);
            v = interp1(obj.XData,obj.YData,dist,'linear','extrap');
            obj.XData = dist;
            obj.YData = v;
        elseif strcmp(obj.Type,'patch')
            prompt = {['Now data contains: ' num2str(length(obj.XData)) ' points. Enter new value:']};
            dlgtitle = 'Vary Grid';
            dims = [1 25];
            answer = inputdlg(prompt,dlgtitle,dims);
            if isempty(answer)
                return;
            elseif ~isempty(answer)
                if isempty(str2num(answer{1}))
                    return;
                end
            end
            len = size(obj.Vertices,1);
            N = str2num(answer{1});
            dist = linspace(obj.Vertices(1,1),obj.Vertices(len/2,1),N);
            h = interp1(obj.Vertices(1:len/2,1),obj.Vertices(1:len/2,2),dist,'linear','extrap');
            verts = [dist' h'; dist' repmat(obj.Vertices(end,2),N,1)];
            faces = [1:N-1; 2:N; 2+N:N+N; 1+N:N-1+N];
            faces = faces';
            c = interp1(obj.Vertices(1:len/2,1),obj.FaceVertexCData(1:len/2),dist,'linear','extrap');
            obj.Faces = faces; % Faces first, then other
            obj.Vertices = verts;
            obj.FaceVertexCData = [c'; c'];
        end
	case 'Add Layer'
        prompt = {'Depth:'; 'Velocity:'};
        dlgtitle = 'New Layer';
        dims = [1 25];
        answer = inputdlg(prompt,dlgtitle,dims);
        if isempty(answer)
            return;
        elseif ~isempty(answer)
            if isempty(str2num(answer{1})) || isempty(str2num(answer{2}))
                return;
            end
        end
        obj = gco;
        lay_num = str2num(obj.UserData(end));
        tag_num = str2num(obj.Tag(end));
        ax1 = gca;
        p_obj = findobj(ax1,'Type','Patch');
        for n = 1:length(p_obj)
            if lay_num < str2num(p_obj(n).UserData(end))
                p_obj(n).UserData(end) = num2str(str2num(p_obj(n).UserData(end))+1);
            end
        end
        len = size(obj.Vertices,1);
        verts = obj.Vertices;
        verts(1:len/2,2) = str2num(answer{1});
        faces = obj.Faces;
        c = repmat(str2num(answer{2}),size(obj.FaceVertexCData));
        uic_patch = findobj(gcf,'Type','uicontextmenu','Tag','uic_patch');
        
        p_layer = patch(ax1,'Faces',faces,'Vertices',verts,'EdgeColor', 'none',...
            'FaceVertexCData',c,'FaceColor','interp','PickableParts','visible',...
            'UIContextMenu',uic_patch,'Tag',['Fictive_patch_' num2str(ax1.UserData+1)],...
            'UserData',['Layer ' num2str(lay_num+1)],'ButtonDownFcn',@disp_layer_number);
        
        ax1.UserData = ax1.UserData+1; % UPDATE NUMBER OF FICTIVE LAYERS
        txt_obj = findobj(ax1,'Type','Text');
        l_obj = findobj(ax1,'Type','Line');
        p_obj = findobj(ax1,'Type','Patch');
        comp = [txt_obj l_obj];
        for n = length(p_obj):-1:1
            comp = [comp findobj(ax1,'Type','Patch','UserData',['Layer ' num2str(n)])];
        end
        ax1.Children = comp;
        
        ax2 = findobj('Type','Axes','Tag','ax2');
        l_obj = findobj(ax2,'Type','Line');
        for n = 1:length(l_obj)
            if lay_num < str2num(l_obj(n).UserData(end))
                l_obj(n).UserData(end) = num2str(str2num(l_obj(n).UserData(end))+1);
            end
        end
        obj = findobj(ax2,'Type','Line','UserData',obj.UserData);
        uic_line = findobj(gcf,'Type','uicontextmenu','Tag','uic_line');
        plot(ax2,obj.XData,repmat(str2num(answer{2}),size(obj.XData)),'-o','MarkerSize',2,...
            'UIContextMenu',uic_line,'Tag',['Fictive_line_' num2str(ax1.UserData)],...
            'UserData',['Layer ' num2str(lay_num+1)]);
        l_obj = findobj(ax2,'Type','Line');
        leg_txt = cell(1,length(l_obj));
        for n = 1:length(l_obj)
            leg_txt{n} = l_obj(n).UserData;
        end
        legend(ax2,flip(leg_txt),'Tag','line_legend');
	case 'Remove Layer'
        obj = gco;
        obj_tag = obj.Tag;
        if ~strcmp(obj_tag(1:7),'Fictive')
            warndlg('You can only remove newly created layers!','Warning');
            return;
        end
        lay_num = str2num(obj.UserData(end));
        tag_num = str2num(obj.Tag(end));
        ax1 = gca;
        p_obj = findobj(ax1,'Type','Patch');
        for n = 1:length(p_obj)
            if lay_num < str2num(p_obj(n).UserData(end))
                p_obj(n).UserData(end) = num2str(str2num(p_obj(n).UserData(end))-1);
            end
            if strcmp(p_obj(n).Tag(1:7),'Fictive') && tag_num < str2num(p_obj(n).Tag(end))
                p_obj(n).Tag(end) = num2str(tag_num);
            end
        end
        ax1.UserData = ax1.UserData-1;
        delete(obj);
        
        ax2 = findobj('Type','Axes','Tag','ax2');
        obj = findobj(ax2,'Type','Line','UserData',['Layer ' num2str(lay_num)]);
        delete(obj);
        l_obj = findobj(ax2,'Type','Line');
        for n = 1:length(l_obj)
            if lay_num < str2num(l_obj(n).UserData(end))
                l_obj(n).UserData(end) = num2str(str2num(l_obj(n).UserData(end))-1);
            end
            if strcmp(l_obj(n).Tag(1:7),'Fictive') && tag_num < str2num(l_obj(n).Tag(end))
                l_obj(n).Tag(end) = num2str(tag_num);
            end
        end
        l_obj = findobj(ax2,'Type','Line');
        leg_txt = cell(1,length(l_obj));
        for n = 1:length(l_obj)
            leg_txt{n} = l_obj(n).UserData;
        end
        legend(ax2,flip(leg_txt),'Tag','line_legend');
    case 'to the chosen layer'
        obj = gco;
        ax = gca;
        lay_num = str2num(obj.UserData(end));
        tag_num = str2num(obj.Tag(end));
        if isempty(findobj(ax,'Type','Patch','UserData',['Layer ' num2str(lay_num+1)])) || strcmp(obj.Tag(1:7),'Fictive')
            warndlg('Last and newly created layers are not permitted!','Warning');
            return;
        end
        p_obj = findobj(ax,'Type','Patch');
        l_obj = findobj(ax,'Type','Line','Tag','Line_hole_elevation');
        
        t(:,1) = r{tag_num}(:,4);
        bg_obj = findobj(gcf,'Tag','bg1 residual time');
        if lay_num == 1
            if strcmp(bg_obj.SelectedObject.String,'Yes')
                t(:,2) = r{tag_num}(:,3)+interp1(s{tag_num}(:,4),s{tag_num}(:,3),r{tag_num}(:,4),'linear','extrap')+...
                    r{tag_num+1}(:,3)+interp1(s{tag_num+1}(:,4),s{tag_num+1}(:,3),r{tag_num}(:,4),'linear','extrap');
            elseif strcmp(bg_obj.SelectedObject.String,'No')
                t(:,2) = r{tag_num+1}(:,3)+interp1(s{tag_num+1}(:,4),s{tag_num+1}(:,3),r{tag_num}(:,4),'linear','extrap');
            end
        else
            t(:,2) = r{tag_num+1}(:,3)+interp1(s{tag_num+1}(:,4),s{tag_num+1}(:,3),r{tag_num}(:,4),'linear','extrap');
        end
        obj1 = findobj(ax,'Type','Patch','Tag',['Patch_v_' num2str(tag_num+1)]);
        lay_num1 = str2num(obj1.UserData(end));
        
        h = zeros(size(r{1},1),lay_num1+2-lay_num);
        h(:,1) = r{1}(:,4);
        v = zeros(size(r{1},1),lay_num1+2-lay_num);
        v(:,1) = r{1}(:,4);
        h_v_desr = zeros(1,lay_num1+2-lay_num);
        N = size(r{1},1);
        faces = [1:N-1; 2:N; 2+N:N+N; 1+N:N-1+N];
        faces = faces';
        for n = lay_num:lay_num1
            p_obj(n-lay_num+1) = findobj(ax,'Type','Patch','UserData',['Layer ' num2str(n)]);
            len = size(p_obj(n-lay_num+1).Vertices,1);
            h(:,n-lay_num+2) = interp1(p_obj(n-lay_num+1).Vertices(1:len/2,1),p_obj(n-lay_num+1).Vertices(1:len/2,2),r{tag_num}(:,4),'linear','extrap');
            if n > lay_num
                ind = h(:,n-lay_num+2) > h(:,n-lay_num+1);
                h(ind,n-lay_num+1) = h(ind,n-lay_num+2);
                p_obj(n-lay_num).Vertices(ind,2) = h(ind,n-lay_num+1);
            end
            v(:,n-lay_num+2) = interp1(p_obj(n-lay_num+1).Vertices(1:len/2,1),p_obj(n-lay_num+1).FaceVertexCData(1:len/2),r{tag_num}(:,4),'linear','extrap');
            p_obj(n-lay_num+1).Faces = faces;
            p_obj(n-lay_num+1).Vertices = [h(:,[1 n-lay_num+2]); h(:,1) repmat(p_obj(n-lay_num+1).Vertices(end,2),N,1)];
            p_obj(n-lay_num+1).FaceVertexCData = [v(:,n-lay_num+2); v(:,n-lay_num+2)];
            if strcmp(p_obj(n-lay_num+1).Tag(1:7),'Fictive')
                h_v_desr(1,n-lay_num+2) = 1;
            end
        end
        
        h_old = h;
        h_hole = interp1(l_obj.XData,l_obj.YData,r{1}(:,4),'linear','extrap');
        el = r{1}(:,5);
        for n = lay_num1:-1:lay_num+1
            dh_1 = -diff(h(:,lay_num1-n+2:lay_num+n-1),1,2);
            if lay_num == 1
                dt = t(:,2) - 2.*sum(dh_1./v(:,lay_num1-n+2:lay_num+n-2),2) + (el-h_hole)./v(:,2);
            else
                if ~isempty(dh_1)
                    dh_1(:,1) = dh_1(:,1) - (el - h_hole);
                end
                dt = t(:,2) - 2.*sum(dh_1./v(:,lay_num1-n+2:lay_num+n-2),2);
            end
            dh = v(:,n).*dt./2;
            dh(dh < 0) = 0;
            for m = n:lay_num1
                if m ~= lay_num1 & m == n
                    ind = (p_obj(m-lay_num+2).Vertices(1:end/2,2) ~= h_old(:,m-lay_num+3)) &...
                        p_obj(m-lay_num+1).Vertices(1:end/2,2) == p_obj(m-lay_num+2).Vertices(1:end/2,2);
                    p_obj(m-lay_num+1).Vertices(ind,2) = p_obj(m-lay_num).Vertices(ind,2) - dh(ind);
                elseif m == lay_num1 & n == lay_num1 % first cycle
                    p_obj(m-lay_num+1).Vertices(1:end/2,2) = p_obj(m-lay_num).Vertices(1:end/2,2) - dh;
                elseif m ~= n & n ~= lay_num1
                    dh_changed = p_obj(m-lay_num).Vertices(1:end/2,2) - h(:,m-lay_num+1);
                    p_obj(m-lay_num+1).Vertices(1:end/2,2) = p_obj(m-lay_num+1).Vertices(1:end/2,2) + dh_changed;
                end
            end
            h_old(:,m-lay_num+2) = h(:,m-lay_num+2);
            h(:,m-lay_num+2) = p_obj(m-lay_num+1).Vertices(1:end/2,2);
        end
    case 'to all layers'
        ax = gca;
        p_obj = findobj(ax,'Type','Patch');
        for l = 1:length(p_obj)-1
            obj = findobj(p_obj,'UserData',['Layer ' num2str(l)]);
            if strcmp(obj.Tag(1:8),'Patch_v_') % if not a Fictive layer
                lay_num = str2num(obj.UserData(end));
                tag_num = str2num(obj.Tag(end));
                if isempty(findobj(ax,'Type','Patch','UserData',['Layer ' num2str(lay_num+1)])) || strcmp(obj.Tag(1:7),'Fictive')
                    warndlg('Last and newly created layers are not permitted!','Warning');
                    return;
                end
                l_obj = findobj(ax,'Type','Line','Tag','Line_hole_elevation');

                t(:,1) = r{tag_num}(:,4);
                bg_obj = findobj(gcf,'Tag','bg1 residual time');
                if lay_num == 1
                    if strcmp(bg_obj.SelectedObject.String,'Yes')
                        t(:,2) = r{tag_num}(:,3)+interp1(s{tag_num}(:,4),s{tag_num}(:,3),r{tag_num}(:,4),'linear','extrap')+...
                            r{tag_num+1}(:,3)+interp1(s{tag_num+1}(:,4),s{tag_num+1}(:,3),r{tag_num}(:,4),'linear','extrap');
                    elseif strcmp(bg_obj.SelectedObject.String,'No')
                        t(:,2) = r{tag_num+1}(:,3)+interp1(s{tag_num+1}(:,4),s{tag_num+1}(:,3),r{tag_num}(:,4),'linear','extrap');
                    end
                else
                    t(:,2) = r{tag_num+1}(:,3)+interp1(s{tag_num+1}(:,4),s{tag_num+1}(:,3),r{tag_num}(:,4),'linear','extrap');
                end
                obj1 = findobj(ax,'Type','Patch','Tag',['Patch_v_' num2str(tag_num+1)]);
                lay_num1 = str2num(obj1.UserData(end));

                h = zeros(size(r{1},1),lay_num1+2-lay_num);
                h(:,1) = r{1}(:,4);
                v = zeros(size(r{1},1),lay_num1+2-lay_num);
                v(:,1) = r{1}(:,4);
                h_v_desr = zeros(1,lay_num1+2-lay_num);
                N = size(r{1},1);
                faces = [1:N-1; 2:N; 2+N:N+N; 1+N:N-1+N];
                faces = faces';
                for n = lay_num:lay_num1
                    p_obj(n-lay_num+1) = findobj(ax,'Type','Patch','UserData',['Layer ' num2str(n)]);
                    len = size(p_obj(n-lay_num+1).Vertices,1);
                    h(:,n-lay_num+2) = interp1(p_obj(n-lay_num+1).Vertices(1:len/2,1),p_obj(n-lay_num+1).Vertices(1:len/2,2),r{tag_num}(:,4),'linear','extrap');
                    if n > lay_num
                        ind = h(:,n-lay_num+2) > h(:,n-lay_num+1);
                        h(ind,n-lay_num+1) = h(ind,n-lay_num+2);
                        p_obj(n-lay_num).Vertices(ind,2) = h(ind,n-lay_num+1);
                    end
                    v(:,n-lay_num+2) = interp1(p_obj(n-lay_num+1).Vertices(1:len/2,1),p_obj(n-lay_num+1).FaceVertexCData(1:len/2),r{tag_num}(:,4),'linear','extrap');
                    p_obj(n-lay_num+1).Faces = faces;
                    p_obj(n-lay_num+1).Vertices = [h(:,[1 n-lay_num+2]); h(:,1) repmat(p_obj(n-lay_num+1).Vertices(end,2),N,1)];
                    p_obj(n-lay_num+1).FaceVertexCData = [v(:,n-lay_num+2); v(:,n-lay_num+2)];
                    if strcmp(p_obj(n-lay_num+1).Tag(1:7),'Fictive')
                        h_v_desr(1,n-lay_num+2) = 1;
                    end
                end

                h_old = h;
                h_hole = interp1(l_obj.XData,l_obj.YData,r{1}(:,4),'linear','extrap');
                el = r{1}(:,5);
                for n = lay_num1:-1:lay_num+1
                    dh_1 = -diff(h(:,lay_num1-n+2:lay_num+n-1),1,2);
                    if lay_num == 1
                        dt = t(:,2) - 2.*sum(dh_1./v(:,lay_num1-n+2:lay_num+n-2),2) + (el-h_hole)./v(:,2);
                    else
                        if ~isempty(dh_1)
                            dh_1(:,1) = dh_1(:,1) - (el - h_hole);
                        end
                        dt = t(:,2) - 2.*sum(dh_1./v(:,lay_num1-n+2:lay_num+n-2),2);
                    end
                    dh = v(:,n).*dt./2;
                    dh(dh < 0) = 0;
                    for m = n:lay_num1
                        if m ~= lay_num1 & m == n
                            ind = (p_obj(m-lay_num+2).Vertices(1:end/2,2) ~= h_old(:,m-lay_num+3)) &...
                                p_obj(m-lay_num+1).Vertices(1:end/2,2) == p_obj(m-lay_num+2).Vertices(1:end/2,2);
                            p_obj(m-lay_num+1).Vertices(ind,2) = p_obj(m-lay_num).Vertices(ind,2) - dh(ind);
                        elseif m == lay_num1 & n == lay_num1 % first cycle
                            p_obj(m-lay_num+1).Vertices(1:end/2,2) = p_obj(m-lay_num).Vertices(1:end/2,2) - dh;
                        elseif m ~= n & n ~= lay_num1
                            dh_changed = p_obj(m-lay_num).Vertices(1:end/2,2) - h(:,m-lay_num+1);
                            p_obj(m-lay_num+1).Vertices(1:end/2,2) = p_obj(m-lay_num+1).Vertices(1:end/2,2) + dh_changed;
                        end
                    end
                    h_old(:,m-lay_num+2) = h(:,m-lay_num+2);
                    h(:,m-lay_num+2) = p_obj(m-lay_num+1).Vertices(1:end/2,2);
                end
            end
        end
    case 'to the top'
        obj1 = gco;
        if strcmp(obj1.UserData,'Layer 1')
            warndlg('You cannot slam Layer 1!','Warning');
            return;
        end
        ax1 = gca;
        for n = 1:length(ax1.Children)
            ax1.Children(n).Selected = 'off';
            ax1.Children(n).PickableParts = 'none';
        end
        obj1.Selected  = 'on';
        obj2 = findobj(ax1,'Type','Patch','UserData',['Layer ' num2str(str2num(obj1.UserData(end))-1)]);
        ax1.ButtonDownFcn = {@points_to_slam,ax1,obj1,obj2};
	case 'to the bottom'
        obj1 = gco;
        ax1 = gca;
        p_obj = findobj(ax1,'Type','Patch');
        if strcmp(obj1.UserData,'Layer 1') || str2num(obj1.UserData(end)) == length(p_obj)
            warndlg('You cannot slam First and Last layers!','Warning');
            return;
        end
        
        for n = 1:length(ax1.Children)
            ax1.Children(n).Selected = 'off';
            ax1.Children(n).PickableParts = 'none';
        end
        obj1.Selected  = 'on';
        obj2 = findobj(ax1,'Type','Patch','UserData',['Layer ' num2str(str2num(obj1.UserData(end))+1)]);
        ax1.ButtonDownFcn = {@points_to_slam,ax1,obj1,obj2};
end

function Vel_mod_drag_point(hObject, eventdata, obj, p_obj)
if strcmp(obj.Type,'line') && eventdata.Button == 1
    [~, ind] = min(abs(obj.XData - eventdata.IntersectionPoint(1)));
    obj.YData(ind) = eventdata.IntersectionPoint(2);
    if ~strcmp(obj.Tag,'Line_hole_elevation')
        p_obj.FaceVertexCData = interp1(obj.XData,obj.YData,p_obj.Vertices(:,1),'linear','extrap');
    end
elseif strcmp(obj.Type,'patch') && eventdata.Button == 1
    [~, ind] = min(abs(obj.Vertices(1:end/2,1) - eventdata.IntersectionPoint(1)));
    obj.Vertices(ind,2) = eventdata.IntersectionPoint(2);
end

function disp_layer_number(hObject, eventdata)
ax = gca;
txt_obj = findobj(ax,'Type','Text');
delete(txt_obj);

obj = gco;
pos = get(gca,'CurrentPoint');
text(pos(1,1),pos(1,2),obj.UserData);

function points_to_slam(hObject,eventdata,ax1,obj1,obj2)
if eventdata.Button == 1
    ax1.ButtonDownFcn = '';
    pos1 = get(gca,'CurrentPoint');
    l = plot(ax1,pos1(1,1),pos1(1,2),'k*','MarkerSize',5);
    w = waitforbuttonpress;
    pos2 = get(gca,'CurrentPoint');
    
    verts2 = obj2.Vertices;
    faces2 = obj2.Faces;
    len1 = size(obj1.Vertices,1);
    len2 = size(verts2,1);
    
    verts1 = verts2;
    verts1(1:len2/2,2) = interp1(obj1.Vertices(1:len1/2,1),obj1.Vertices(1:len1/2,2),verts2(1:len2/2,1),'linear','extrap');
    c1(1:len2/2,1) = interp1(obj1.Vertices(1:len1/2,1),obj1.FaceVertexCData(1:len1/2),verts2(1:len2/2,1),'linear','extrap');
    
    ind = verts1(:,1) >= min(pos1(1,1),pos2(1,1)) & verts1(:,1) <= max(pos1(1,1),pos2(1,1));
    verts1(ind,2) = verts2(ind,2);
    obj1.Faces = faces2; % Faces first, then other
    obj1.Vertices = verts1;
    obj1.FaceVertexCData = [c1; c1];
    delete(l);
    ax1.ButtonDownFcn = {@points_to_slam,ax1,obj1,obj2};
end

function save_vel_model(hObject,eventdata,r_f_fact,handles,s,r,v)
fig = gcf;
ax1 = findobj(fig,'Type','axes','Tag','ax1');
ax2 = findobj(fig,'Type','axes','Tag','ax2');
l_obj = findobj(ax1,'Type','line','Tag','Line_hole_elevation');
p_obj = findobj(ax1,'Type','patch');
v_obj = findobj(ax2,'Type','line');
layers = cell(size(p_obj,1),4);
vel = cell(size(p_obj,1),1);
tags = cell(size(p_obj,1),2);
for n = 1:length(p_obj)
    pp_obj = findobj(p_obj,'UserData',['Layer ' num2str(n)]);
    layers{n,1} = pp_obj.Vertices(1:end/2,:);
    layers{n,2} = pp_obj.Vertices;
    layers{n,3} = pp_obj.Faces;
    layers{n,4} = pp_obj.FaceVertexCData;
    vv_obj = findobj(v_obj,'UserData',['Layer ' num2str(n)]);
    vel{n} = [vv_obj.XData' vv_obj.YData'];
    tags{n,1} = pp_obj.Tag;
    tags{n,2} = vv_obj.Tag;
end
hole_elevation = [l_obj.XData' l_obj.YData'];
seismic.old.descr{1,1} = 's';
seismic.old.descr{2,1} = 'x y t dist hole_elevation';
seismic.old.descr{3,1} = 'r';
seismic.old.descr{4,1} = 'x y t dist layer_elevation';
seismic.old.descr{5,1} = 'v';
seismic.old.descr{6,1} = 'x y v dist';
seismic.layers = layers;
seismic.vel = vel;
seismic.tags = tags;
seismic.hole_elevation = hole_elevation;
seismic.old.s = s;
seismic.old.r = r;
seismic.old.v = v;
seismic.descr{1,1} = 'layers';
seismic.descr{2,1} = 'dist elevation';
seismic.descr{2,2} = 'Vertices';
seismic.descr{2,3} = 'Faces';
seismic.descr{2,4} = 'FaceVertexCData';
seismic.descr{3,1} = 'vel';
seismic.descr{4,1} = 'dist velocity';
seismic.descr{5,1} = 'hole_elevation';
seismic.descr{6,1} = 'dist elevation';
seismic.descr{7,1} = 'tags';
seismic.descr{8,1} = 'patch_tag';
seismic.descr{8,2} = 'line_tag';
seismic.param = r_f_fact.param;
save([handles.s_path handles.s_file '.mat'],'seismic');
fclose all;
msgbox(['Saved to: ' handles.s_path handles.s_file],'Success');
clear;