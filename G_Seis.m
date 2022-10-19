function G_Seis
% Create a figure
if ~isempty(findobj('Type','figure','Name','G_Seis'))
    close 'G_Seis' % ������� figure
end
hParent = figure('Name','G_Seis','NumberTitle','off',...
    'Position',[200 200 325 460],'ToolBar','none','MenuBar','none','Resize','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p1 = uipanel('Title','Read/Write','FontWeight','bold',...
    'Units','Pixels','Position',[0 320 325 140]);

% Create push button 
uicontrol(p1,'Style', 'pushbutton', 'String', 'Read SEGY',...
    'Position', [5 70 150 50],'Callback', {@read_SEGY_GUI});

% Create push button 
uicontrol(p1,'Style', 'pushbutton', 'String', 'Write SEGY',...
    'Position', [165 70 150 50],'Callback', {@write_SEGY_GUI});

% Create push button 
uicontrol(p1,'Style', 'pushbutton', 'String', 'Read Horizon',...
    'Position', [5 10 150 50],'Callback', {@read_hrz_GUI});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p2 = uipanel('Title','Modules','FontWeight','bold',...
    'Units','Pixels','Position',[0 0 325 320]);

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'Header Math',...
    'Position', [5 250 150 50],'Callback', {@header_math_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'Trace Math',...
    'Position', [165 190 150 50],'Callback', {@trace_math_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'Scale Data',...
    'Position', [5 190 150 50],'Callback', {@scale_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'SC Decomposition',...
    'Position', [5 130 150 50],'Callback', {@decomposition_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'SC Apply',...
    'Position', [165 130 150 50],'Callback', {@apply_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'SC Time Decomposition',...
    'Position', [5 70 150 50],'Callback', {@decomposition_time_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'SC Build Vel Model',...
    'Position', [165 70 150 50],'Callback', {@build_vel_model_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'Sort Traces',...
    'Position', [5 10 150 50],'Callback', {@sort_GUI});

% Create push button 
uicontrol(p2,'Style', 'pushbutton', 'String', 'Plot Data',...
    'Position', [165 10 150 50],'Callback', {@plot_GUI});



% pushbutton READ SEGY
function read_SEGY_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','Read SEGY'))
    close 'Read SEGY' % ������� figure
end
g_read_segyGUI;

% pushbutton WRITE SEGY
function write_SEGY_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC write SEGY'))
    close 'SC write SEGY' % ������� figure
end
g_write_segyGUI;

% pushbutton READ HORIZON
function read_hrz_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','Read Horizon'))
    close 'Read Horizon' % ������� figure
end
g_read_hrzGUI;

% pushbutton HEADER MATH
function header_math_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC header math'))
    close 'SC header math' % ������� figure
end
g_math_headerGUI;
msgbox(['It is very simple to use. For example, you can ',...
    'define the CDP_X coordinate as follows: <CDP_X=(SRCX+GRPX)./2>. ',...
    'Dont forget to use matlab syntaxis.']);

% pushbutton TRACE MATH
function trace_math_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC trace math'))
    close 'SC trace math' % ������� figure
end
g_math_traceGUI;
msgbox(['It is very simple to use and it provides matlab functionality in accordance with your matlab abilities ',...
    'to perform trace-by-trace calculations on FILE_1 or FILE_2 or both of them. ',...
    'Since first 78 numbers are the trace headers, to sum two traces you ',...
    'should write: FILE_1(79:end,n)+FILE_2(79:end,n) where <n> is a cycle variable. To filter the data: ',...
    'filter(ones(5,1)./5,5,FILE_1(79:end,n)). This is an example of moving ',...
    'average filter of windowsize 5.']);

% pushbutton SCALE
function scale_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC scale'))
    close 'SC scale' % ������� figure
end
g_scaleGUI;

% pushbutton SC DECOMPOSITION
function decomposition_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC decomposition'))
    close 'SC decomposition' % ������� figure
end
g_decomposition_ampGUI;

% pushbutton SC APPLY
function apply_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC apply'))
    close 'SC apply' % ������� figure
end
g_applyGUI

% pushbutton SC TIME DECOMPOSITION
function decomposition_time_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC time decomposition'))
    close 'SC time decomposition' % ������� figure
end
g_decomposition_timeGUI;

% pushbutton SC TIME APPLY
function apply_time_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC time apply'))
    close 'SC time apply' % ������� figure
end
g_apply_timeGUI

% pushbutton SC BUILD VEL MODEL
function build_vel_model_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC build vel model'))
    close 'SC build vel model' % ������� figure
end
g_build_vel_modelGUI

% pushbutton SORT TRACES
function sort_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','SC sort'))
    close 'SC sort' % ������� figure
end
g_sortGUI;

% pushbutton PARAMETERS TO PLOT
function plot_GUI(source,event)
if ~isempty(findobj('Type','figure','Name','Parameters to plot'))
    close 'Parameters to plot' % ������� figure
end
g_plotGUI;
msgbox(['You can plot not only seismic-files but factors-files as well. ',...
    'Information about the factor is in the SEQWL header. ',...
    'P_KEY 1, 11, 21 - is for Shot factor for layer 1, 2, 3. ',...
    'P_KEY 2, 12, 22 - is for Receiver factor for layer 1, 2, 3. ',...
    'P_KEY 3, 13, 23 - is for Offset factor for layer 1, 2, 3. ',...
    'P_KEY 4, 14, 24 - is for CDP factor for layer 1, 2, 3. ',...
    'You can view headers of any data with <Header math> tool.']);