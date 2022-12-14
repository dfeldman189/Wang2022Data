function [ traceByStim] = make_traceByStim_simple( toTest, stimNumber, Stimuli, Metadata, deltaF, bl_length, timePostStim) 
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% DF this generates a list of frame numbers for all stimuli (not referenced to the stimulus number or
%  trial outcome...)  Also compresses across all movie fields to generate the structure traceByStim, 
%  which is used to display stimulus-aligned deltaF traces for all repetitions of each whisker. 
% These two aspects of the function don't go together and should be separated.  stimFramesAll should be
% calculated during HW_MakeStimuli().
fns=fieldnames(deltaF);
cellNames=fieldnames(deltaF.(fns{1}));
for i=1:length(cellNames)   %ROI names
    cn=cellNames{i};
    for j=1:length(toTest)   % whisker names
        whisker=toTest{j};
        traceByStim.(cn).(whisker)=[];  % for concatenation 
    end
end

for K=1:length(fns)   % # of frames
    fn=fns{K};
    sampRate=1/(Metadata.(fn).acqNumAveragedFrames*Metadata.(fn).acqScanFramePeriod);
    % find stim times for aligning to imaging data
    stimFrames=floor(Stimuli.(fns{K}).Time*sampRate);  % frame number for each trial (includes only CR stimuli)
    stimOrder=Stimuli.(fn).Label(stimFrames(1:end)>0); % IgorStimulusNUMBER for each trial
    stimFrames=stimFrames(stimFrames>0);

    % index stimtimes by whisker identity
    bl_im=ceil(bl_length*sampRate); % pre-stim baseline in frames, how many frames in baseline
    frames_postStim=ceil(timePostStim*sampRate); % post-stim period to include, how many frames in postStim
         
    for i=1:length(toTest)   % create index for stimulations
        stimInds{i}=(stimOrder==stimNumber(i)); %logic array of which stimuli belongs to whiskNum piezo
    end

    stimFrames_whisk=cellfun(@(x)stimFrames(x),stimInds,'Uni',0); % use logic array and stimframes to find the stimframe for a particular piezo
  
    for w=1:length(toTest)
        stimFrames_thisWhisk=stimFrames_whisk{w}; 
        stimFrames_thisWhisk=stimFrames_thisWhisk((stimFrames_thisWhisk>ceil(bl_im)) & (stimFrames_thisWhisk<(length(deltaF.(fn).(cellNames{1}))-frames_postStim))); % make sure the stimframe is within range of a moviestack
        whisker=toTest{w};
        for j=1:length(cellNames)
            cn=cellNames{j};
            % subtract mean baseline deltaF from all points
            stimBlock=arrayfun(@(x)deltaF.(fn).(cn)((x-bl_im):(x+frames_postStim))-mean(deltaF.(fn).(cn)((x-(bl_im)):x)),stimFrames_thisWhisk,'Uni',0);
            % append this trace as next row of traceByStim array
            traceByStim.(cn).(whisker)=[traceByStim.(cn).(whisker); stimBlock']; % save baseline subtraction data according to whisker, as cell array
        end
    end
end  % for each movie filename

% convert traceByStim from separate cells (for each trial) containing separate vertical vectors
% to single cell containing multiple horizontal trial vectors. 

for j=1:length(cellNames)
    cn=cellNames{j};
    for i=1:length(toTest)
        whisker=toTest{i};        
        traceByStim.(cn).(whisker)=horzcat(traceByStim.(cn).(whisker){:})';
    end
end



end % function
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          