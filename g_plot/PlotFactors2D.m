function PlotFactors2D(hParent)

handles = guidata(hParent);
r_f = load([handles.r_path handles.r_file]);
r_f = r_f.seismic;
r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[r_f.nh+r_f.ns r_f.ntr],'seis'},'Writable',false);

if ~isempty(handles.s_key1) && ~isempty(handles.s_key2)
    x = [r_m.Data.seis(handles.p_key{1},:);...
        r_m.Data.seis(handles.s_key1{1},:);...
        r_m.Data.seis(handles.s_key2{1},:)];
elseif ~isempty(handles.s_key1) && isempty(handles.s_key2)
    x = [r_m.Data.seis(handles.p_key{1},:);...
        r_m.Data.seis(handles.s_key1{1},:)];
elseif isempty(handles.s_key1) && ~isempty(handles.s_key2)
    errordlg('If you use either S_KEY1 or S_KEY2, then use S_KEY1','Error')
    return
else
    x = r_m.Data.seis(handles.p_key{1},:);
end

% [x,x_inds] = sortrows(x');
% x = x';
% x_inds = x_inds';

if isempty(handles.pkey_min) == 1
    handles.pkey_min = 0;
end
if isempty(handles.pkey_max) == 1
    handles.pkey_max = max(abs(x(1,:)));
end
if isempty(handles.skey1_min) && ~isempty(handles.s_key1)
    handles.skey1_min = 0;
end
if isempty(handles.skey1_max) && ~isempty(handles.s_key1)
    handles.skey1_max = max(abs(x(2,:)));
end
if isempty(handles.skey2_min) && ~isempty(handles.s_key2)
    handles.skey2_min = 0;
end
if isempty(handles.skey2_max) && ~isempty(handles.s_key2)
    handles.skey2_max = max(abs(x(3,:)));
end

if size(x,1) == 1
    xx_ind = abs(x) >= abs(handles.pkey_min) & abs(x) <= abs(handles.pkey_max);
elseif size(x,1) == 2
    xx_ind = abs(x(1,:)) >= abs(handles.pkey_min) & abs(x(1,:)) <= abs(handles.pkey_max) &...
        abs(x(2,:)) >= abs(handles.skey1_min) & abs(x(2,:)) <= abs(handles.skey1_max);
elseif size(x,1) == 3
    xx_ind = abs(x(1,:)) >= abs(handles.pkey_min) & abs(x(1,:)) <= abs(handles.pkey_max) &...
        abs(x(2,:)) >= abs(handles.skey1_min) & abs(x(2,:)) <= abs(handles.skey1_max) &...
        abs(x(3,:)) >= abs(handles.skey2_min) & abs(x(3,:)) <= abs(handles.skey2_max);
end
x = x(:,xx_ind);
y = r_m.Data.seis(r_f.nh+1,xx_ind);
% x_inds = x_inds(xx_ind);
x(end+1,:) = 1:size(x,2);
xx_ind = [];

% Record the handles.
h_figure = figure();
if size(x,1) == 2
    h1_axes = axes('Position',[0.13 0.1 0.775 0.8]);
elseif size(x,1) == 3
    h1_axes = axes('Position',[0.13 0.1 0.775 0.7]);
    h2_axes = axes('Position',[0.13 0.9 0.775 0],'XAxisLocation','Top');
elseif size(x,1) == 4
    h1_axes = axes('Position',[0.13 0.1 0.775 0.6]);
    h2_axes = axes('Position',[0.13 0.8 0.775 0],'XAxisLocation','Top');
    h3_axes = axes('Position',[0.13 0.9 0.775 0],'XAxisLocation','Top');
end

% Get the axes width once.
[width,height] = get_axes_widthKer(h1_axes);
last_width = width;
last_height = height;
last_xlims  = [-inf inf];
last_ylims  = [-inf inf];

% Plot it!
if size(x,1) == 2
    axes(h1_axes); % to set as GCA
    h_plot = plot(x(end,:),y);
    grid on;
    set(h1_axes,'XLim',[x(end,1) x(end,end)],'XAxisLocation','Top');
    xtick = get(h1_axes,'XTick');
    set(h1_axes,'XTick',xtick,'XTickLabel',x(1,xtick));
    xlabel(h1_axes,handles.p_key{2});
    ylabel(h1_axes,'Amplitude');
elseif size(x,1) == 3
    axes(h1_axes); % to set as GCA
    h_plot = plot(x(end,:),y);
    grid on;
    set(h1_axes,'XLim',[x(end,1) x(end,end)],'XAxisLocation','Top');
    xtick = get(h1_axes,'XTick');
    set(h1_axes,'XTick',xtick,'XTickLabel',x(2,xtick));
    axes(h2_axes); % to set as GCA
    set(h2_axes,'XLim',[x(end,1) x(end,end)],...
        'XTick',xtick,'XTickLabel',x(1,xtick));
    linkaxes([h1_axes h2_axes],'x');
    xlabel(h1_axes,handles.s_key1{2});
    ylabel(h1_axes,'Amplitude');
    xlabel(h2_axes,handles.p_key{2});
elseif size(x,1) == 4
    axes(h1_axes); % to set as GCA
    h_plot = plot(x(end,:),y);
    grid on;
    set(h1_axes,'XLim',[x(end,1) x(end,end)],'XAxisLocation','Top');
    xtick = get(h1_axes,'XTick');
    set(h1_axes,'XTick',xtick,'XTickLabel',x(3,xtick));
    axes(h2_axes); % to set as GCA
    set(h2_axes,'XLim',[x(end,1) x(end,end)],...
        'XTick',xtick,'XTickLabel',x(2,xtick));
    axes(h3_axes); % to set as GCA
    set(h3_axes,'XLim',[x(end,1) x(end,end)],...
        'XTick',xtick,'XTickLabel',x(1,xtick));
    linkaxes([h1_axes h2_axes h3_axes],'x');
    xlabel(h1_axes,handles.s_key2{2});
    ylabel(h1_axes,'Amplitude');
    xlabel(h2_axes,handles.s_key1{2});
    xlabel(h3_axes,handles.p_key{2});
end