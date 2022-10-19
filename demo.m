%% demo for Ca2+ signal analysis
tic
%% set parameters
bl_length = 0.5; % pre-stim baseline in seconds
timePostStim = 1.5; % time to include post-stim in 'traceByStim'; seconds, for showing trace data only
timeEvoked = 1;  % time post-stimulus to include for measures of whisker response statistic testing; seconds 

% numbers in the Igor file for each type of stimuli
stimWhisk =  [0 1 2 3 4 5 6 7 8];   % first 9 stimuli is single whisker deflections, start with 0 due to Igor setting
stimBlank = 10;  % no deflection blank
stimReward = 9; % 10th stimulus is simultaneous deflection of 9 whiskers
stimSound = [11 12]; % 12th and 13th stimuli are two tones
stimToTest = horzcat(stimWhisk, stimSound);

% Identity of each type of stimuli
whisk = {'e3' 'e2' 'e1' 'd3' 'd2' 'd1' 'c3' 'c2' 'c1' }; % set of single whiskers deflected
% rewardCue = {'nineW'};
testTone = {'lowTone' 'highTone'};
toTest = horzcat (whisk, testTone);

numPermu = 10000;  % for permutation test to test for significant response
repetition_threshold=30; % at least how many repetitions for a stimulus
% percentile_baseline=25; 

%% load some demo data
load deltaF_demo          % example dF/F from 14 cells, dF/F was obtained by CaImAn algorithm
load Stimuli_demo         % files including the timing and frames when stimuli began in each trial
load Metadata_demo.mat    % meta data of movies

%% make CR traceByStim
% define which frames were considered as Ca2+ signal response
framesEvoked=(ceil(bl_length*sampRate(1))+1):(ceil(bl_length*sampRate(1))+ceil(timeEvoked*sampRate(1)));  % turn pre-set bl_length and timeEvoked to frame numbers

% make stimuli-locked Ca2+ responses, sorted by stimulation identity
% only use correct rejection (CR, no lick) trials
[ traceByStim ] = make_traceByStim_simple( toTest, stimToTest, Stimuli_demo,Metadata_demo, deltaF_demo, bl_length, timePostStim); % make stimuli-sorted Ca2+ traces

% indexing which stimuli had few repetitions and need to be exclude
% the minimal requirement of repetitions was defined by repetition_threshold
lostStim=arrayfun(@(x)size(traceByStim.ROI1.(toTest{x}),1)<repetition_threshold,1:length(toTest),'Uni',1);

%% make blank traces
% make Ca2+ responses to blank (no stimulation)
[ sponTrace ] = make_sponTrace_simple( stimBlank,Stimuli_demo,Metadata_demo,deltaF_demo,bl_length,timePostStim);

%% permutation test
% determine the p-value of responses using permutation test
[ permTestResults ] = permuteTest_whisk( sponTrace,traceByStim,numPermu,framesEvoked,lostStim);

%% basic data summary 
% determine the significance of responses by multi-comparison
% also pre-calculate some parameters for further analysis and plotting
[sigCellsOnewhisk,sigStim_ind,basicSummary_simple]=basicSummary_simple(lostStim, permTestResults, whisk, traceByStim, framesEvoked, numPermu);

%% plot individual trials and mean traces
plotTuning_SingleTrial_and_Mean(cellNames, whisk, traceByStim, sponTrace, sampRate(1), framesEvoked, sigStim_ind, lostStim);

%% plot tuning curve
plot_tuning_curve(cellNames, traceByStim, framesEvoked, whisk);
%%
toc



