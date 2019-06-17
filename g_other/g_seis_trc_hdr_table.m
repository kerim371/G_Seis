% PLOT MANY TRACE HEADER
function g_seis_trc_hdr_table(hParent,r_f,r_m,RName)
handles = guidata(hParent);

if ~isempty(handles.hdr_min) && ~isempty(handles.hdr_max) && handles.hdr_min <= handles.hdr_max && handles.hdr_max > 0 && length(handles.hdr_min) == 1 && length(handles.hdr_max) == 1
    if handles.hdr_min < 1
        handles.hdr_min = 1;
    end
    if handles.hdr_max > r_f.ntr
        handles.hdr_max = r_f.ntr;
    end
    
    if strcmp(RName,'numbered')
        data = r_m.Data.seis(r_f.nh+1:end,handles.hdr_min:handles.hdr_max);
    else
        data = r_m.Data.seis(1:r_f.nh,handles.hdr_min:handles.hdr_max);
    end
else
    errordlg('Set <min> and <max> trace to plot!','Error')
    return
end

if isobject(handles.trc_hdr_table)
    if isvalid(handles.trc_hdr_table)
        set(handles.trc_hdr_table,'Data',data);
        set(handles.trc_hdr_table,'ColumnName',handles.hdr_min:handles.hdr_max);
    elseif ~isvalid(handles.trc_hdr_table)
        handles.trc_hdr_table = uitable(hParent,'Data',data,'RowName',RName,'ColumnName',handles.hdr_min:handles.hdr_max,...
            'Units','Pixels','Position',handles.table_pos,'RearrangeableColumns','off');
    end
elseif ~isobject(handles.trc_hdr_table)
    handles.trc_hdr_table = uitable(hParent,'Data',data,'RowName',RName,'ColumnName',handles.hdr_min:handles.hdr_max,...
        'Units','Pixels','Position',handles.table_pos,'RearrangeableColumns','off');
end

guidata(hParent, handles);