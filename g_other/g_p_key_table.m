function g_p_key_table(hParent, txt2, f1)
handles = guidata(hParent);
[trc_hdr_info,~] = g_get_trc_hdr_info;

if isfield(handles,'P_KEY_table')
    delete(handles.pkey_table); % удалить таблицу чтобы они не нагромождались
end
pkey_table = uitable(f1,'Data',trc_hdr_info(:,1:2),'ColumnName',{'Description','Abbreviation'},...
    'Units','Normalized','Position',[0 0 1  1],'RearrangeableColumns','off',...
    'ColumnWidth',{180, 60},'CellSelectionCallback', {@cell_cbk, hParent, trc_hdr_info, txt2});

function cell_cbk(hObject, eventdata, hParent, trc_hdr_info, txt2)
handles = guidata(hParent);
p_key = eventdata.Indices;
handles.p_key = {p_key(1) trc_hdr_info{p_key(1),2}};
guidata(hParent,handles);
set(txt2,'String',handles.p_key{2});
delete(gcf);
