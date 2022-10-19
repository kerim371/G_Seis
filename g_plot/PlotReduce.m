classdef PlotReduce < handle
    properties
        
        % Handles
        h_figure;
        h1_axes;
        h2_axes;
        h3_axes;
        h_plot;
        
        % Original data
        z_m;
        r_m; % memmapfile with traces and their headers
        x; % p_key, s1_key, s2_key headers
        x_inds; % indexes sort
        xx_ind; % indexes comprised MIN MAX value
        y; % times
        y_inds; % indexes sort
        yy_ind; % indexes comprised MIN MAX value
        
        % Last updated state
        last_width = 0;          % We only update when the width and
        last_height = 0;
        last_xlims  = [0 0];      % limits change.
        last_ylims = [0 0];
        
        % We need to keep track of the figure listener so that we can
        % delete it later.
        figure_listener;
        n; % for ZOOM OUT
        h_zoom;
        sld_x; % slider x
        sld_y; % slider y
        origInfo;
        hP_handles; % hParent handles
        r_f; % loaded .mat file with general info from SEGY
        
        % We'll delete the figure listener once all of the plots we manage
        % have been deleted (cleared from axes, closed figure, etc.).
        deleted_plots;
        
    end
    
    methods
        
%    function o = PlotReduce(ind_x,ind_y,z)
    function o = PlotReduce(hParent)
        
        o.hP_handles = guidata(hParent);
        if o.hP_handles.plot == 'r_file'
            o.r_f = load([o.hP_handles.r_path o.hP_handles.r_file]);
            o.r_f = o.r_f.seismic;
            o.r_m = memmapfile([o.hP_handles.r_path o.hP_handles.r_file '.bin'],...
                'Format',{'single',[o.r_f.nh+o.r_f.ns o.r_f.ntr],'seis'},'Writable',false);
        elseif o.hP_handles.plot == 's_file'
            o.r_f = load([o.hP_handles.s_path o.hP_handles.s_file]);
            o.r_f = o.r_f.seismic;
            o.r_m = memmapfile([o.hP_handles.s_path o.hP_handles.s_file '.bin'],...
                'Format',{'single',[o.r_f.nh+o.r_f.ns o.r_f.ntr],'seis'},'Writable',false);
        end
        
        if ~isempty(o.hP_handles.s_key1) && ~isempty(o.hP_handles.s_key2)
            o.x = [o.r_m.Data.seis(o.hP_handles.p_key{1},:);...
                o.r_m.Data.seis(o.hP_handles.s_key1{1},:);...
                o.r_m.Data.seis(o.hP_handles.s_key2{1},:)];
        elseif ~isempty(o.hP_handles.s_key1) && isempty(o.hP_handles.s_key2)
            o.x = [o.r_m.Data.seis(o.hP_handles.p_key{1},:);...
                o.r_m.Data.seis(o.hP_handles.s_key1{1},:)];
        elseif isempty(o.hP_handles.s_key1) && ~isempty(o.hP_handles.s_key2)
            errordlg('If you use either S_KEY1 or S_KEY2, then use S_KEY1','Error')
            return
        else
            o.x = o.r_m.Data.seis(o.hP_handles.p_key{1},:);
        end
        
        [o.x,o.x_inds] = sortrows(o.x');
        o.x = o.x';
        o.x_inds = o.x_inds';
        
        if isempty(o.hP_handles.pkey_min) == 1
            o.hP_handles.pkey_min = 0;
        end
        if isempty(o.hP_handles.pkey_max) == 1
            o.hP_handles.pkey_max = max(abs(o.x(1,:)));
        end
        if isempty(o.hP_handles.skey1_min) && ~isempty(o.hP_handles.s_key1)
            o.hP_handles.skey1_min = 0;
        end
        if isempty(o.hP_handles.skey1_max) && ~isempty(o.hP_handles.s_key1)
            o.hP_handles.skey1_max = max(abs(o.x(2,:)));
        end
        if isempty(o.hP_handles.skey2_min) && ~isempty(o.hP_handles.s_key2)
            o.hP_handles.skey2_min = 0;
        end
        if isempty(o.hP_handles.skey2_max) && ~isempty(o.hP_handles.s_key2)
            o.hP_handles.skey2_max = max(abs(o.x(3,:)));
        end
        
        if size(o.x,1) == 1
            o.xx_ind = abs(o.x) >= abs(o.hP_handles.pkey_min) & abs(o.x) <= abs(o.hP_handles.pkey_max);
        elseif size(o.x,1) == 2
            o.xx_ind = abs(o.x(1,:)) >= abs(o.hP_handles.pkey_min) & abs(o.x(1,:)) <= abs(o.hP_handles.pkey_max) &...
                abs(o.x(2,:)) >= abs(o.hP_handles.skey1_min) & abs(o.x(2,:)) <= abs(o.hP_handles.skey1_max);
        elseif size(o.x,1) == 3
            o.xx_ind = abs(o.x(1,:)) >= abs(o.hP_handles.pkey_min) & abs(o.x(1,:)) <= abs(o.hP_handles.pkey_max) &...
                abs(o.x(2,:)) >= abs(o.hP_handles.skey1_min) & abs(o.x(2,:)) <= abs(o.hP_handles.skey1_max) &...
                abs(o.x(3,:)) >= abs(o.hP_handles.skey2_min) & abs(o.x(3,:)) <= abs(o.hP_handles.skey2_max);
        end
        o.x = o.x(:,o.xx_ind);
        o.x_inds = o.x_inds(o.xx_ind);
        o.x(end+1,:) = 1:size(o.x,2);
        o.xx_ind = [];
        
        if strcmp(o.r_f.domain,'Depth') || strcmp(o.r_f.domain,'depth')
            o.y = single(o.r_f.to:-o.r_f.dt:-(o.r_f.ns-1)*o.r_f.dt+o.r_f.to);
        elseif strcmp(o.r_f.domain,'Time') || strcmp(o.r_f.domain,'time')
            o.y = single(o.r_f.to:o.r_f.dt/10^3:(o.r_f.ns-1)*o.r_f.dt/10^3+o.r_f.to);
        elseif strcmp(o.r_f.domain,'Frequency') || strcmp(o.r_f.domain,'frequency')
            o.y = single(o.r_f.to:o.r_f.dt:(o.r_f.ns-1)*o.r_f.dt+o.r_f.to);
        end
        o.y_inds = 1:size(o.y,2);
        if ~isempty(o.hP_handles.time_min) && ~isempty(o.hP_handles.time_max)
            o.yy_ind = o.y >= o.hP_handles.time_min & o.y <= o.hP_handles.time_max;
        elseif ~isempty(o.hP_handles.time_min) && isempty(o.hP_handles.time_max)
            o.yy_ind = o.y >= o.hP_handles.time_min;
        elseif isempty(o.hP_handles.time_min) && ~isempty(o.hP_handles.time_max)
            o.yy_ind = o.y <= o.hP_handles.time_max;
        elseif isempty(o.hP_handles.time_min) && isempty(o.hP_handles.time_max)
            o.yy_ind = 1:size(o.y,2);
        end
        o.y = o.y(o.yy_ind);
        o.y_inds = o.y_inds(o.yy_ind);
        o.y(end+1,:) = 1:size(o.y,2);

        % Record the handles.
        o.h_figure = figure();
        if size(o.x,1) == 2
            o.h1_axes = axes('Position',[0.13 0.1 0.775 0.8]);
        elseif size(o.x,1) == 3
            o.h1_axes = axes('Position',[0.13 0.1 0.775 0.7]);
            o.h2_axes = axes('Position',[0.13 0.9 0.775 0],'XAxisLocation','Top');
        elseif size(o.x,1) == 4
            o.h1_axes = axes('Position',[0.13 0.1 0.775 0.6]);
            o.h2_axes = axes('Position',[0.13 0.8 0.775 0],'XAxisLocation','Top');
            o.h3_axes = axes('Position',[0.13 0.9 0.775 0],'XAxisLocation','Top');
        end

        % Get the axes width once.
        [width,height] = get_axes_widthKer(o.h1_axes);
        o.last_width = width;
        o.last_height = height;
        o.last_xlims  = [-inf inf];
        o.last_ylims  = [-inf inf];
        
        % Reduce the data!
        [x_r,y_r,z_r,x,y] = reduce_to_widthKer(o.r_f, o.x, o.y, o.r_m, o.x_inds, o.y_inds, ...
            width, height, [min(o.x(end,:)) max(o.x(end,:))], [min(o.y(end,:)) max(o.y(end,:))]);
        
        % Plot!
        axes(o.h1_axes); % to set as GCA
        o.h_plot = imagesc(x_r,y_r,z_r);
        caxis([-mean(mean(abs(z_r),'omitnan'),'omitnan') mean(mean(abs(z_r),'omitnan'),'omitnan')]);
        colormap gray;
        if size(o.x,1) == 2
            set(o.h1_axes,'XLim',[x_r(1) x_r(end)],'YLim',[y_r(1) y_r(end)],...
                'XAxisLocation','Top','YAxisLocation','Right',...
                'XTick',x(end,:),'XTickLabel',x(1,:),'YTick',y(end,:),'YTickLabel',y(1,:));
            xlabel(o.h1_axes,o.hP_handles.p_key{2});
            ylabel(o.h1_axes,o.r_f.domain);
        elseif size(o.x,1) == 3
            set(o.h1_axes,'XLim',[x_r(1) x_r(end)],'YLim',[y_r(1) y_r(end)],...
                'XAxisLocation','Top','YAxisLocation','Right',...
                'XTick',x(end,:),'XTickLabel',x(2,:),'YTick',y(end,:),'YTickLabel',y(1,:));
            xlabel(o.h1_axes,o.hP_handles.s_key1{2});
            ylabel(o.h1_axes,o.r_f.domain);
            set(o.h2_axes,'XLim',[x(end,1) x(end,end)],...
                'XTick',x(end,:),'XTickLabel',x(1,:));
            xlabel(o.h2_axes,o.hP_handles.p_key{2});
        elseif size(o.x,1) == 4
            set(o.h1_axes,'XLim',[x_r(1) x_r(end)],'YLim',[y_r(1) y_r(end)],...
                'XAxisLocation','Top','YAxisLocation','Right',...
                'XTick',x(end,:),'XTickLabel',x(3,:),'YTick',y(end,:),'YTickLabel',y(1,:));
            xlabel(o.h1_axes,o.hP_handles.s_key2{2});
            ylabel(o.h1_axes,o.r_f.domain);
            set(o.h2_axes,'XLim',[x(end,1) x(end,end)],...
                'XTick',x(end,:),'XTickLabel',x(2,:));
            xlabel(o.h2_axes,o.hP_handles.s_key1{2});
            set(o.h3_axes,'XLim',[x(end,1) x(end,end)],...
                'XTick',x(end,:),'XTickLabel',x(1,:));
            xlabel(o.h3_axes,o.hP_handles.p_key{2});
        end
        
        % Create slider
        set(o.h1_axes,'Units','Pixels');
        ax_pos = o.h1_axes.Position;
        o.sld_x = uicontrol('Style', 'slider',...
        'Min',0,'Max',1,'Value',0,'Units','Pixels',...
        'Position', [ax_pos(1) ax_pos(2)-21 ax_pos(3) 20],...
        'SliderStep',[0.1 1],'Callback', {@surfxlim, o});
        o.sld_y = uicontrol('Style', 'slider',...
        'Min',0,'Max',1,'Value',0,'Units','Pixels',...
        'Position', [ax_pos(1)-21 ax_pos(2) 20 ax_pos(4)],...
        'SliderStep',[0.1 1],'Callback', {@surfylim, o});
        set(o.h1_axes,'Units','Normalized');
        set(o.sld_x,'Units','Normalized');
        
        % Listen for changes to the x limits of the axes.
        if verLessThan('matlab', '8.4')
            size_cb = {'Position', 'PostSet'};
        else
            size_cb = {'SizeChanged'};
        end

        % Listen for changes on the figure itself.
        o.figure_listener = addlistener(o.h_figure, size_cb{:}, @(~,~) o.RefreshData);
        o.n = 0;
        o.h_zoom = zoom(gcf);
        o.h_zoom.ActionPostCallback = @(~,~) o.RefreshData;

        % Define DeletePlot as Nested Function, so the figure can be deleted 
        % even if LinePlotReducer.m is not on Matlab's search path anymore.
        function DeletePlot(o)
            o.deleted_plots = true;
            if all(o.deleted_plots)
                delete(o.figure_listener);
            end
        end
        
        % When all of our managed plots are deleted, we need to erase
        % ourselves, so we'll keep track when each is deleted.
        set(o.h_plot, 'DeleteFcn', @(~,~) DeletePlot(o));
        o.deleted_plots = false(1, length(o.h_plot));
    end
    end
    
    methods
        
        % Redraw all of the data.
        function RefreshData(o)
            if o.hP_handles.plot == 'r_file'
                o.r_f = load([o.hP_handles.r_path o.hP_handles.r_file]);
                o.r_f = o.r_f.seismic;
                o.r_m = memmapfile([o.hP_handles.r_path o.hP_handles.r_file '.bin'],...
                    'Format',{'single',[o.r_f.nh+o.r_f.ns o.r_f.ntr],'seis'},'Writable',false);
            elseif o.hP_handles.plot == 's_file'
                o.r_f = load([o.hP_handles.s_path o.hP_handles.s_file]);
                o.r_f = o.r_f.seismic;
                o.r_m = memmapfile([o.hP_handles.s_path o.hP_handles.s_file '.bin'],...
                    'Format',{'single',[o.r_f.nh+o.r_f.ns o.r_f.ntr],'seis'},'Writable',false);
            end
            if strcmp(o.r_f.domain,'Depth')
                o.y = single(o.r_f.to:-o.r_f.dt:-(o.r_f.ns-1)*o.r_f.dt+o.r_f.to);
            elseif strcmp(o.r_f.domain,'Time')
                o.y = single(o.r_f.to:o.r_f.dt/10^3:(o.r_f.ns-1)*o.r_f.dt/10^3+o.r_f.to);
            elseif strcmp(o.r_f.domain,'Frequency') || strcmp(o.r_f.domain,'frequency')
                o.y = single(o.r_f.to:o.r_f.dt:(o.r_f.ns-1)*o.r_f.dt+o.r_f.to);
            end
            o.y_inds = 1:size(o.y,2);
            if ~isempty(o.hP_handles.time_min) && ~isempty(o.hP_handles.time_max)
                o.yy_ind = o.y >= o.hP_handles.time_min & o.y <= o.hP_handles.time_max;
            elseif ~isempty(o.hP_handles.time_min) && isempty(o.hP_handles.time_max)
                o.yy_ind = o.y >= o.hP_handles.time_min;
            elseif isempty(o.hP_handles.time_min) && ~isempty(o.hP_handles.time_max)
                o.yy_ind = o.y <= o.hP_handles.time_max;
            elseif isempty(o.hP_handles.time_min) && isempty(o.hP_handles.time_max)
                o.yy_ind = 1:size(o.y,2);
            end
            o.y = o.y(o.yy_ind);
            o.y_inds = o.y_inds(o.yy_ind);
            o.y(end+1,:) = 1:size(o.y,2);
            
            % Get axes width in pixels.
            [width,height] = get_axes_widthKer(o.h1_axes);
            if width ~= o.last_width || height ~= o.last_height
                set(o.h1_axes,'Units','Pixels');
                set(o.sld_x,'Units','Pixels');
                ax_pos = o.h1_axes.Position;
                pause(10^-10); % ��� ����� �� ��������
                set(o.sld_x,'Position',[ax_pos(1) ax_pos(2)-21 ax_pos(3) 20]);
                set(o.sld_y,'Position',[ax_pos(1)-21 ax_pos(2) 20 ax_pos(4)]);
                set(o.h1_axes,'Units','Normalized');
                set(o.sld_x,'Units','Normalized');
            end
            o.last_width = width;
            o.last_height = height;
            
            x_lims = get(o.h1_axes, 'XLim');
            y_lims = get(o.h1_axes, 'YLim');
            
            % ZOOM
            o.origInfo = getappdata(o.h1_axes, 'matlab_graphics_resetplotview');
            if strcmp(o.h_zoom.Direction,'in') && strcmp(o.h_zoom.Enable,'on')
                o.n = 0;
                if x_lims(1) < o.origInfo.XLim(1)
                    x_lims(1) = o.origInfo.XLim(1);
                end
                if x_lims(2) > o.origInfo.XLim(2)
                    x_lims(2) = o.origInfo.XLim(2);
                end
                if y_lims(1) < o.origInfo.YLim(1)
                    y_lims(1) = o.origInfo.YLim(1);
                end
                if y_lims(2) > o.origInfo.YLim(2)
                    y_lims(2) = o.origInfo.YLim(2);
                end
                o.last_xlims = x_lims;
                o.last_ylims = y_lims;
                set(o.h1_axes,'XLim',x_lims);
                set(o.h1_axes,'YLim',y_lims);
            elseif strcmp(o.h_zoom.Direction,'out') && strcmp(o.h_zoom.Enable,'on')
                o.n = o.n+1;
                if o.n > 2
                    return
                elseif o.n == 1
                    x_lims = get(o.h1_axes, 'XLim');
                    y_lims = o.origInfo.YLim;
                elseif o.n == 2
                    x_lims = o.origInfo.XLim;
                    y_lims = get(o.h1_axes, 'YLim');
                end
                o.last_xlims = x_lims;
                o.last_ylims = y_lims;
                set(o.h1_axes,'XLim',x_lims);
                set(o.h1_axes,'YLim',y_lims);
            else
                o.last_xlims = x_lims;
                o.last_ylims = y_lims;
            end
            
            % Reduce the data.
            [x_r,y_r,z_r,x,y] = reduce_to_widthKer(o.r_f, o.x, o.y, o.r_m, o.x_inds, o.y_inds, ...
                width, height, x_lims, y_lims);
            
            % Update the plot.
            set(o.h_plot, 'XData', x_r, 'YData', y_r, 'CData', z_r);
            if size(o.x,1) == 2
                set(o.h1_axes,'XLim',[x_r(1) x_r(end)],'YLim',[y_r(1) y_r(end)],...
                    'XTick',x(end,:),'XTickLabel',x(1,:),...
                    'YTick',y(end,:),'YTickLabel',y(1,:));
            elseif size(o.x,1) == 3
                set(o.h1_axes,'XLim',[x_r(1) x_r(end)],'YLim',[y_r(1) y_r(end)],...
                    'XTick',x(end,:),'XTickLabel',x(2,:),...
                    'YTick',y(end,:),'YTickLabel',y(1,:));
                set(o.h2_axes,'XLim',[x(end,1) x(end,end)],...
                    'XTick',x(end,:),'XTickLabel',x(1,:));
            elseif size(o.x,1) == 4
                set(o.h1_axes,'XLim',[x_r(1) x_r(end)],'YLim',[y_r(1) y_r(end)],...
                    'XTick',x(end,:),'XTickLabel',x(3,:),...
                    'YTick',y(end,:),'YTickLabel',y(1,:));
                set(o.h2_axes,'XLim',[x(end,1) x(end,end)],...
                    'XTick',x(end,:),'XTickLabel',x(2,:));
                set(o.h3_axes,'XLim',[x(end,1) x(end,end)],...
                    'XTick',x(end,:),'XTickLabel',x(1,:));
            end
            
            % SLIDER X
            if ~isempty(o.origInfo)
                sx_step1 = 1/size(o.x,2);
                sx_step2 = abs((x_lims(2)-x_lims(1))./(o.origInfo.XLim(2)-o.origInfo.XLim(1)));
                if sx_step2 < sx_step1
                    sx_step2 = sx_step1;
                end
                set(o.sld_x,'SliderStep',[double(sx_step1) double(sx_step2)]); % without DOUBLE it gets an error, because it was SINGLE VALUE
                val_x = abs((x_lims(1)-o.origInfo.XLim(1))./(o.origInfo.XLim(2)-(x_lims(2)-x_lims(1))-o.origInfo.XLim(1)));
                if isnan(val_x)
                    val_x = 0;
                elseif val_x < 0
                    val_x = 0;
                elseif val_x > 1
                    val_x = 1;
                end
                set(o.sld_x,'Value',val_x);
                
                % SLIDER Y
                sy_step1 = 1/size(o.x,2);
                sy_step2 = abs((y_lims(2)-y_lims(1))./(o.origInfo.YLim(2)-o.origInfo.YLim(1)));
                if sy_step2 < sy_step1
                    sy_step2 = sy_step1;
                end
                set(o.sld_y,'SliderStep',[double(sy_step1) double(sy_step2)]); % without DOUBLE it gets an error, because it was SINGLE VALUE
                val_y = abs((o.origInfo.YLim(2)-y_lims(2))./(o.origInfo.YLim(2)-(y_lims(2)-y_lims(1))-o.origInfo.YLim(1)));
                if isnan(val_y)
                    val_y = 0;
                elseif val_y < 0
                    val_y = 0;
                elseif val_y > 1
                    val_y = 1;
                end
                set(o.sld_y,'Value',val_y);
            end
        end       
    end
end

function surfxlim(source,event,o)
if isempty(o.origInfo)
    set(o.sld_x,'Value',0);
    return
end
val = source.Value;
x_orig = o.origInfo.XLim;
dx = o.h1_axes.XLim(2)-o.h1_axes.XLim(1);
x1 = val*(x_orig(2)-dx-x_orig(1))+x_orig(1);
x2 = x1+dx;
set(o.h1_axes,'XLim',[x1 x2]);
RefreshData(o);
end

function surfylim(source,event,o)
if isempty(o.origInfo)
    set(o.sld_y,'Value',1);
    return
end
val = source.Value;
y_orig = o.origInfo.YLim;
dy = o.h1_axes.YLim(2)-o.h1_axes.YLim(1);
y2 = y_orig(2)-val*(y_orig(2)-dy-y_orig(1));
y1 = y2-dy;
set(o.h1_axes,'YLim',[y1 y2]);
RefreshData(o);
end