function[sigCellsOnewhisk,sigStim_ind,basicSummary]=basicSummary_simple(lostStim,permTestResults, whisk, traceByStim,framesEvoked,numPermu)
%% multicontrol, NOTICE the lostStim don't have pval in permutation results
cellNames=fieldnames(traceByStim);    % names of ROIs
allStim=(fieldnames(traceByStim.(cellNames{1})))';  % names of stimuli
respStim=allStim(~lostStim); % all stimuli with sufficient repetition, including sound
respWhisk=whisk(~lostStim(1:length(whisk))); % all stimuli with sufficient repetition, whisker deflection only
sigStim_ind=false(length(cellNames),length(allStim)); % establish significant index matrix
for i=1:length(cellNames)
     cn=cellNames{i};
     pvals=cellfun(@(x)permTestResults.(cn).(x),respStim,'Uni',1);  %find p values for all stimuli, need to use respStim because lostStim don't have pvals in permutation result
     sig_inds_stim=MultControl(pvals,0.05,'FDR'); % multicontorl over all response stimuli

     sigStim_indTemp(i,:)=sig_inds_stim; % make multicontrol result a separate array
     sig_inds(i)=sum(sig_inds_stim)>0;  % find cells with at least one significant response (including sound and multi-whisker) after multicontrol
     sig_indsOnewhisk(i)=sum(sig_inds_stim(1:length(respWhisk)))>0; % find cells with at least one single whisker-evoked significant response after multicontrol, need to use respWhisk because lostStim don't have pvals in permutation result
end
sigStim_ind(:,(~lostStim))=sigStim_indTemp; % note the lostStim column stays 'false'

sigCells=cellNames(sig_inds);  % cells with at least one significant stimulation
sigCellsOnewhisk=cellNames(sig_indsOnewhisk); % cells with at least one significant whisker stimulation
sigStim_ind(:,size(sigStim_ind,2)+1)=1; % add spontaneous tags (every cell has it) for plotting use
sigStims=sigStim_ind(sig_inds,:); % stimulaitons that evoke significant responses
%% construct basicSummary
for i=1:length(cellNames)
    cn=cellNames{i};
    ROI_Ind=strcmp(cn,sigCells); % does this ROI has at least one significant stimulation, including sound?
    ROI_IndOnewhisk=strcmp(cn,sigCellsOnewhisk); % does this ROI has at least one significant whisker stimulation?

    if sum(ROI_Ind)==1      % this ROI has statistically significant response   
        basicSummary.(cn).significance=1;
        if sum(ROI_IndOnewhisk)==1
            basicSummary.(cn).significanceOnewhisk=1; % this ROI has statistically significant response to whisker deflection
        else
            basicSummary.(cn).significanceOnewhisk=0; % this ROI has only sound response
        end
        sig_Stims=sigStims(ROI_Ind,1:(end-1));% the last sigStims are spon, so (end-1)
        basicSummary.(cn).SigStimulations=allStim(:,sig_Stims);
        basicSummary.(cn).Sigwhiskers=allStim(:,sig_Stims(1:length(whisk)));  % we keep the list of whisker stimulations BEFORE other stimulaitons        
    else
        basicSummary.(cn).significance=0;
        basicSummary.(cn).significanceOnewhisk=0;
        basicSummary.(cn).SigStimulations=[];
        basicSummary.(cn).Sigwhiskers=[];
    end
    
    basicSummary.(cn).pvals=ones(1,length(allStim));
    pvalsTemp=cellfun(@(x)permTestResults.(cn).(x),respStim,'Uni',1);
    basicSummary.(cn).pvals(~lostStim)=pvalsTemp;  % the p value of lostwhisker will be 1

    for j=1:length(allStim)
        if lostStim(j)==0  % if the stimulus was not lost
            wholeTraces=traceByStim.(cn).(allStim{j});
            evokedTraces=wholeTraces(:,framesEvoked);            
            %calculate values of max and max +/- 1 frames (absolute
            % amplitude)
            aveTrace=mean(evokedTraces,1);   % obtain averaged trace
            meanDF(j)=mean(aveTrace); % mean postStim deltaF
            [~,maxInd]=max(abs(aveTrace),[],2); % find peak, abs because considering negative going
            avePeakDF(j)=aveTrace(maxInd); % amplitude of peak of averaged trace, can be negative
            frameAvePeak(j)=maxInd+(framesEvoked(1))-1;  % change back to index in whole trace (nth frame since beginning of whole trace)
            %(do this because the last or first frame of evoked response can be max)
            aveWholeTrace=mean(wholeTraces,1);
            dFaroundPeak=aveWholeTrace(:,(frameAvePeak(j)-1):(frameAvePeak(j)+1));
            meanAroundPeak(j)=mean(dFaroundPeak); % amplitude of the average of 3 frames around peak            
            medianDF(j)=median(aveTrace);% median (absolute amplitude)
        else
            meanDF(j)=NaN;
            medianDF(j)=NaN;
            avePeakDF(j)=NaN; 
            meanAroundPeak(j)=NaN; %amplitude of the average of 3 frames around peak
            frameAvePeak(j)=NaN; % time of peak, counting from the first frame in baseline
        end
        
        % assign to structure array
        basicSummary.(cn).meanDF(j)=meanDF(j);  
        basicSummary.(cn).avePeakDF(j)=avePeakDF(j);% amplitude of the peak of averaged trace
        basicSummary.(cn).meanAroundPeak(j)=meanAroundPeak(j);%the average of 3 frames around the peak of averaged trace
        basicSummary.(cn).frameAvePeak(j)=frameAvePeak(j);% time of peak, counting from the first frame in baseline
        basicSummary.(cn).medianDF(j)=medianDF(j);
    end
    
    if basicSummary.(cn).significanceOnewhisk==1
        basicSummary.(cn).meanDFSigwhisk=basicSummary.(cn).meanDF(sig_Stims(1:length(whisk))); % mean responses of significant whiskers
    else
        basicSummary.(cn).meanDFSigwhisk=[];
    end
              
    %%%%%%%%%%%  this part is for calculating the BW and eBW, so only%%%%
    %%%%%%%%%%%  consider individual whiskers %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%  for positive and pos_ind, also only consider whiskers %%
    
    if ~isempty(basicSummary.(cn).meanDFSigwhisk) % has significant whiskers
        % find BW 
        [MmeanTmpSigW,ImeanTmpSigW]=sort(basicSummary.(cn).meanDFSigwhisk,'descend');
        basicSummary.(cn).meanDFSigwhiskdescend=MmeanTmpSigW;
        basicSummary.(cn).meanDFSigwhiskdescend_ind=ImeanTmpSigW;
        basicSummary.(cn).BW=basicSummary.(cn).Sigwhiskers{ImeanTmpSigW(1)};

        % find equvalent BW
        whiskerToCompare=basicSummary.(cn).Sigwhiskers;
        if length(whiskerToCompare)==1 % only one significant whisker
            basicSummary.(cn).eBW=[];
        else
            BWresponses=mean(traceByStim.(cn).(basicSummary.(cn).BW)(:,framesEvoked),2);
            remaining_whisker=setdiff(basicSummary.(cn).Sigwhiskers,basicSummary.(cn).BW);
            for k=1:length(remaining_whisker)
                Wresponses=mean(traceByStim.(cn).(remaining_whisker{k})(:,framesEvoked),2);
                tmpPVal(k)=permutationTest(BWresponses,Wresponses,numPermu);
            end
            basicSummary.(cn).eBW=remaining_whisker(tmpPVal>0.05);
            clear tmpPVal;
        end
    else  % no significant whiskers
        basicSummary.(cn).meanDFSigwhiskdescend=[];
        basicSummary.(cn).meanDFSigwhiskdescend_ind=[];
        basicSummary.(cn).BW=[];
        basicSummary.(cn).eBW=[];
    end
    %%%%%%%%%%%%%%%%%%%%  end of BW and eBW  %%%%%%%%%%%%%%%%
end
end % end of function