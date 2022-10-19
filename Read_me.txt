software: Matlab(MathWorks, R2019b) operated in Windows 10 or Mac OS X 11

installation: No installation is required (excpet Matlab)

code demo: this demonstration script will allow the user to go through the process of sorting stimulus-locked Ca2+ activity, test for signficance, and draw traces and tuing curve. 

To run the code using the demo data:

open the demo.m script in Matlab

the pre-set parameters were the same as analysis in this paper

load the demo data: 
deltaF_demo.mat: 
containing 
1) example dF/F from 14 cells. dF/F was obtained by CaImAn algorithm (F_dff). Data were arranged as structure array: deltaF.(movie name).(cell name) = N(dF/F of each frame) x 1 array

2) fns, name of movies in cell array ,N(each movie) x 1 array

3) sampRate, image acquisition frequency for each movie, as 1*N(each movie) array

Stimuli_demo.mat: 
files including the timing and frames when stimuli began in each trial, transformed from stimulus generation program Igor. Data were arranged as structure array: 
Stimuli.(movie name).label = identity of stimulus, N(stimuli)*1 array
Stimuli.(movie name).Time = stimulus onset time, in sec, N(stimuli)*1 array

Metadata_demo.mat:
meta data of Ca2+ imaging movies. Data were arranged as structure array:
Metadata.(movie name).properties=value
 
follow the script to obtain array 
traceByStim: containing stimulus-locked Ca2+ activity. Data were arranged as structure array:
traceByStim.(cell name).(stimulus name)=M*N array, where M = number of trials with this particulat stimulus, and N = Ca2+ signal in each frame from 500ms before stimulus onset to 1500ms after stimulus onset 

sponTrace: activity in blank trials. Data were arranged as structure array:
sponTrace.(cell name)=M*N array, where M = number of blank trials, and N = Ca2+ signal in each frame from time points corresppounding to stimulus case.

followed by determination of the significance of responses using permutation test and some plotting

final output:
sigCellsOnewhisk: names of all cells having at least one significantly responsive whisker, N*1 cell array

plot1: plots containing the Ca2+ traces of individual trials, and the mean trace of significantly responsve cells

plot2: plots containing individual 9-whisker tuning curves of significantly responsve cells and mean curve.

expected output from demo data: all cells should be significantly responsve cells

expected run time: within 5 minutes for demo data.

codes obtained from matlab exchange:
freezeColors.m: John Iversen, 2005-10 
john_iversen@post.harvard.edu

vline.m: Brandon Kuczenski for Kensington Labs, 2001.
brandon_kuczenski@kensingtonlabs.com

hline.m: Brandon Kuczenski for Kensington Labs, 2001.
brandon_kuczenski@kensingtonlabs.com

brewermap.m: Stephen Cobeldick, 2016 http://colorbrewer.org/