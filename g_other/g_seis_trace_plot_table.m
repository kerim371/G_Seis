% PLOT TRACE AND ITS HEADER
function g_seis_trace_plot_table(hParent)
handles = guidata(hParent);

r_m = memmapfile([handles.r_path handles.r_file '.bin'],...
    'Format',{'single',[handles.r_f.nh+handles.r_f.ns handles.r_f.ntr],'seis'},'Writable',false);
trc_hdr = r_m.Data.seis(1:handles.r_f.nh,handles.k);
trace = r_m.Data.seis(handles.r_f.nh+1:end,handles.k);

t = 0:handles.r_f.dt/1000:(handles.r_f.ns-1)*handles.r_f.dt/1000;
plot(handles.ax2,trace,t);
set(handles.ax2,'XDir','normal','YDir','reverse',...
    'XGrid','on','YGrid','on','YLim',[t(1) t(end)]);
set(handles.ax2.Title,'String',['Trace: ' num2str(handles.k)]);

if isobject(handles.trc_hdr_table)
    if isvalid(handles.trc_hdr_table)
        set(handles.trc_hdr_table,'Data',[handles.r_f.trc_hdr_info num2cell(trc_hdr)]);
    elseif ~isvalid(handles.trc_hdr_table)
        handles.trc_hdr_table = uitable(handles.f2,'Data',[handles.r_f.trc_hdr_info num2cell(trc_hdr)],'ColumnName',{'Description';'Abbreviation'; 'Start byte'; 'Length byte'; 'Value'},...
            'Units','Normalized','Position',[0 0 0.6  1],'RearrangeableColumns','off');
    end
elseif ~isobject(handles.trc_hdr_table)
    handles.trc_hdr_table = uitable(handles.f2,'Data',[handles.r_f.trc_hdr_info num2cell(trc_hdr)],'ColumnName',{'Description';'Abbreviation'; 'Start byte'; 'Length byte'; 'Value'},...
        'Units','Normalized','Position',[0 0 0.6  1],'RearrangeableColumns','off');
end
clear;