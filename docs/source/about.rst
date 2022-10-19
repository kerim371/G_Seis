About
=====

Simple 2D-Seismic data processing GUI application

Functionality
-------------

#. SEGY read/write (reads to binary file of format single)
#. visualize data with three keys sorting
#. surface-consistent first arrival (or amplitude) decomposition according to 2, 3, 4 factor model
#. interactively build velocity model based on decomposed arrival picks
#. perform static, amplitude and spectrum correction (deconvolution)
#. perform some basic header and data arithmetic

Usage
-----
The main file is **G_Seis.m** 

Before running the application one should:

#. set path to the root folder and include all the folders inside it
#. build mex function in /g_other folder. Commands **>> mex -setup** and **>> mex typecastx.c** (or **>> mex g_other/typecastx.c** depending on current path) may help
#. run the app: **>> G_Seis**