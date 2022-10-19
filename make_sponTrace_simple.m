function [ sponTrace ] = make_sponTrace_simple( stimBlank, Stimuli, Metadata, deltaF, bl_length, timePostStim)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fns=fieldnames(deltaF);
cellNames=fieldnames(deltaF.(fns{1}));

for i=1:length(cellNames) %for all ROIs
    cn=cellNames{i};
    sponTrace.(cn)=[]; % for concatenation
end

for K=1:length(fns)
    fn=fns{K};
    sampRate=1/(Metadata.(fn).acqNumAveragedFrames*Metadata.(fn).acqScanFramePeriod);
    
    % find stim times for aligning to imaging data
    stimFrames=floor(Stimuli.(fns{K}).Time*sampRate);
    stimOrder=Stimuli.(fn).Label(stimFrames(1:end)>0);
    stimFrames=stimFrames(stimFrames>0);
        
    % index stimtimes by whisker identity 
    bl_im=ceil(bl_length*sampRate); %pre-stim baseline in frames
    frames_postStim=ceil(timePostStim*sampRate); %post-stim period to include   

    sponInds=stimOrder==stimBlank; % because igor is zero-start   
    sponFrames=stimFrames(sponInds);
        
    sponFrames=sponFrames(sponFrames>ceil(bl_im) & sponFrames<(length(deltaF.(fn).(cellNames{1}))-frames_postStim));
    
    for j=1:length(cellNames)
        cn=cellNames{j};
        sponBlock=arrayfun(@(x)deltaF.(fn).(cn)((x-bl_im):(x+frames_postStim))-mean(deltaF.(fn).(cn)((x-(bl_im)):x)),sponFrames,'Uni',0);
        sponTrace.(cn)=[sponTrace.(cn); sponBlock'];
    end
end


for j=1:length(cellNames)
    cn=cellNames{j};
    sponTrace.(cn)=horzcat(sponTrace.(cn){:})';
end



end    % end of function