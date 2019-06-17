function [x_reduced,y_reduced,z_reduced,x,y] = reduce_to_widthKer(r_f,x,y,z,x_inds,y_inds,width,height,x_lims,y_lims)

nw_points = 2*width;
nh_points = 2*height;

[~, ind_xmin] = min(abs(x(end,:)-x_lims(1))); % ближайшее значение к x_lims(1)
[~, ind_xmax] = min(abs(x(end,:)-x_lims(2))); % ближайшее значение к x_lims(2)
ind_xmin = single(ind_xmin);
ind_xmax = single(ind_xmax);
d_indx = ind_xmax-ind_xmin;
[~, ind_ymin] = min(abs(y(end,:)-y_lims(1))); % ближайшее значение к y_lims(1)
[~, ind_ymax] = min(abs(y(end,:)-y_lims(2))); % ближайшее значение к y_lims(2)
d_indy = ind_ymax-ind_ymin;
ind_ymin = single(ind_ymin);
ind_ymax = single(ind_ymax);

% If the data is already small, there's no need to reduce.
if d_indx < nw_points || d_indy < nh_points
    if d_indx < nw_points && d_indy > 2*nh_points
        ind_y = unique(round(linspace(ind_ymin,ind_ymax,2*height)));
        [X,Y] = meshgrid(ind_xmin:ind_xmax,y(end,ind_y));
        z = z.Data.seis(r_f.nh+y_inds(ind_y),x_inds(ind_xmin:ind_xmax));
    elseif d_indx > 2*nw_points && d_indy < nh_points
        ind_x = unique(round(linspace(ind_xmin,ind_xmax,2*width)));
        [X,Y] = meshgrid(x(end,ind_x),ind_ymin:ind_ymax);
        z = z.Data.seis(r_f.nh+y_inds(ind_ymin:ind_ymax),x_inds(ind_x));
    else
        [X,Y] = meshgrid(ind_xmin:ind_xmax,ind_ymin:ind_ymax);
        z = z.Data.seis(r_f.nh+y_inds(ind_ymin:ind_ymax),x_inds(ind_xmin:ind_xmax));
    end
    [Xq,Yq] = meshgrid(linspace(ind_xmin,ind_xmax,nw_points),linspace(ind_ymin,ind_ymax,nh_points));
    x_reduced = Xq(1,:);
    y_reduced = Yq(:,1);
    z_reduced = interp2(X,Y,z,Xq,Yq,'linear');
    x = x(:,ind_xmin:ind_xmax);
    y = y(:,ind_ymin:ind_ymax);
    xtick_step = unique(round(linspace(1,size(x,2),width/50)));
    ytick_step = unique(round(linspace(1,size(y,2),height/25)));
    if size(x,2) > length(xtick_step)
        x = x(:,xtick_step);
        y = y(:,ytick_step);
    end
    return;
end

step_indx = 0;
for n = 2:-0.1:1
    if step_indx <= 0
        step_indx = floor((ind_xmax-ind_xmin)./(n*width));
        if step_indx > 0
            break
        end
    end
    if step_indx <= 0 && n == 1
        step_indx = 1;
    end
end
ind_x = ind_xmin:step_indx:ind_xmax;
x_reduced = x(end,ind_x);

step_indy = 0;
for n = 2:-0.1:1
    if step_indy <= 0
        step_indy = floor((ind_ymax-ind_ymin)./(n*height));
        if step_indy > 0
            break
        end
    end
    if step_indy <= 0 && n == 1
        step_indy = 1;
    end
end
ind_y = ind_ymin:step_indy:ind_ymax;
y_reduced = y(end,ind_y);

z_reduced = z.Data.seis(r_f.nh+y_inds(ind_y),x_inds(ind_x));

x = x(:,ind_x);
y = y(:,ind_y);
xtick_step = unique(round(linspace(1,size(x,2),width/50)));
ytick_step = unique(round(linspace(1,size(y,2),height/25)));
if size(x,2) > length(xtick_step)
    x = x(:,xtick_step);
    y = y(:,ytick_step);
end