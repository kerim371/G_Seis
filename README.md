# G_Seis
Simple 2D-Seismic data processing GUI application

## Functionality
1) SEGY read/write (reads to binary file of format `single`)
2) visualize data with three keys sorting
3) decompose first arrival time picks (or amplitude) according to 2, 3, 4 factor model
4) interactively build velocity model based on decomposed arrival time picks
5) perform static, amplitude and spectrum correction (deconvolution)
6) perform some basic header and data arithmetic

## Usage
The main file is `G_Seis.m`
Before running the application you should:
1) set path to the root folder and include all the folders inside it
2) build mex function in /g_other folder. Commands `>> mex -setup` and `>> mex typecastx.c` may help. 
3) type in matlab command line: `>> G_Seis`
