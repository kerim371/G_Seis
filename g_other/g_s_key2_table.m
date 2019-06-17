function g_s_key2_table(hParent, txt6, f1)
handles = guidata(hParent);
[trc_hdr_info,~] = g_get_trc_hdr_info;

if isfield(handles,'P_KEY_table')
    delete(handles.pkey_table); % удалить таблицу чтобы они не нагромождались
end
skey_table = uitable(f1,'Data',trc_hdr_info(:,1:2),'ColumnName',{'Description','Abbreviation'},...
    'Units','Normalized','Position',[0 0 1  1],'RearrangeableColumns','off',...
    'ColumnWidth',{180, 60},'CellSelectionCallback', {@cell_cbk, hParent, trc_hdr_info, txt6});

function cell_cbk(hObject, eventdata, hParent, trc_hdr_info, txt6)
handles = guidata(hParent);
s_key = eventdata.Indices;
handles.s_key2 = {s_key(1) trc_hdr_info{s_key(1),2}};
guidata(hParent,handles);
set(txt6,'String',handles.s_key2{2});
delete(gcf);
