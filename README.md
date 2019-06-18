# G_Seis
Seismic data processing software

The main file is G_Seis.m
The application uses some functions written by other authors. Here those files:
ibm2single.m (based on the algorithm of function "ibm2num" written by Brian Farrelly https://www.mathworks.com/matlabcentral/fileexchange/53109-seislab-3-02)
interparc.m (by John D'Errico https://www.mathworks.com/matlabcentral/fileexchange/34874-interparc)
PlotReduce.m (based on algorithm of Tucker McClure for 1D data https://www.mathworks.com/matlabcentral/fileexchange/40790-plot-big)
typecastx.m (James Tursa https://www.mathworks.com/matlabcentral/fileexchange/17476-typecast-and-typecastx-c-mex-functions)

Before running the application you should:
1 - set path to the root folder and include all the folders inside it
2 - build mex function in /g_other folder. Commands >> mex -setup and >> mex typecastx.c may help. 
3 - type in matlab command line: >> G_Seis

REMERMBER! All binary files created with G_Seis is binary data of format single.
Feel free to contact with me.

Best regards,
Kerim Khemraev
