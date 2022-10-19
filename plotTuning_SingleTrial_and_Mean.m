function [h]=plotTuning_SingleTrial_and_Mean(cellsToPlot, whisk, traceByStim, sponTrace, sampRate, framesEvoked, sigWhisks_inds, lostStim)
%PLOTTUNINGV2 9-whisker tuning curves, plotted by individual cell

cellNames=fieldnames(traceByStim);
cellNamesInds=ismember(cellNames,cellsToPlot);
sigWhisksToPlot=sigWhisks_inds(cellNamesInds,:);
sigWhisksToPlot(:,[length(whisk)+1 length(whisk)+2])=[];  % remove sound stimulation
for J=1:length(cellsToPlot)
    cn=cellsToPlot{J};
    f=figure;
    f.Position=[280 47 960 740];
    whiskStimulations=fieldnames(traceByStim.(cn));
    sizeAll=vertcat(cellfun(@(x)size(traceByStim.(cn).(x),1),whiskStimulations,'Uni',1),size(sponTrace.(cn),1));
    maxSize=max(sizeAll);
    tBStemp=rmfield(traceByStim.(cn),whiskStimulations(logical(lostStim)));
    minIntensity=min(structfun(@(x)min(min(x,[],1),[],2),tBStemp));
    for k=1:length(whiskStimulations)
        if isempty(traceByStim.(cn).(whiskStimulations{k}))
            traceRep{k}=(minIntensity)*ones(maxSize,size(sponTrace.(cn),2));
        else
            traceRep{k}=vertcat(traceByStim.(cn).(whiskStimulations{k}),(minIntensity)*ones((maxSize-size(traceByStim.(cn).(whiskStimulations{k}),1)),size(traceByStim.(cn).(whiskStimulations{k}),2)));
        end
    end
    % when only 9 single whisker stimulations were used
    traceRep{10}=(minIntensity)*ones(maxSize,size(sponTrace.(cn),2));
    traceRep{11}=(minIntensity)*ones(maxSize,size(sponTrace.(cn),2));
    %
    traceRepSpon=vertcat( sponTrace.(cn) , (minIntensity)*ones((maxSize-size(sponTrace.(cn),1)),size(sponTrace.(cn),2)));

    cRow=horzcat(traceRep{9}, traceRep{8},traceRep{7},traceRepSpon);
    dRow=horzcat(traceRep{6}, traceRep{5},traceRep{4},traceRep{10});
    eRow=horzcat(traceRep{3}, traceRep{2},traceRep{1},traceRep{11});
    allRows=vertcat(cRow,dRow,eRow);

    subplot(1,2,1)
    imagesc(allRows);
    colormap gray
    vline([size(traceByStim.(cn).(whiskStimulations{1}),2) 2*size(traceByStim.(cn).(whiskStimulations{1}),2) 3*size(traceByStim.(cn).(whiskStimulations{1}),2)])
    hline([maxSize 2*maxSize 3*maxSize]);
    xtick=floor(size(allRows,2))/8;
    ytick=floor(size(allRows,1))/6;
    ax=gca;
    set(ax,'XTick',[xtick 3*xtick 5*xtick])
    set(ax,'XTickLabel',{'1','2','3'},'FontWeight','bold')
    set(ax,'YTick',[ytick 3*ytick 5*ytick])
    set(ax,'YTickLabel',{'C','D','E'},'FontWeight','bold')
    leftLim=ax.YLim;

    yyaxis right
    set(gca,'YLim',leftLim);
    set(gca,'YTick',[5*ytick]);
    set(gca,'YTickLabel',{'spon'},'FontWeight','bold');
    set(gca,'YColor','k');
    axis square

    
    
    clear exampleTraces

    for k=1:length(whisk)
        if ~isempty(traceByStim.(cn).(whisk{k}))
            exampleTraces{k}=mean(traceByStim.(cn).(whisk{k}),1);
            exampleTraces{k}=exampleTraces{k}(1:framesEvoked(end));
        else
            exampleTraces=[];
        end
    end
    tempSponTrace=mean(sponTrace.(cn),1);
    exampleTraces{(length(exampleTraces)+1)}=tempSponTrace(1:framesEvoked(end));
  
    exampleTracesResp=exampleTraces(~cellfun(@isempty,exampleTraces));
    maxY=max(cellfun(@max,exampleTracesResp));
    minY=min(cellfun(@min,exampleTracesResp));
    
    subplot(1,2,2)
    freezeColors
    cmap=brewermap(length(whisk)+2,'RdYlBu');
    cmap=vertcat(cmap(1:ceil(length(whisk)/2),:),cmap((end-(length(whisk)-ceil(length(whisk)/2)-1)):end,:));
    cmap((size(cmap,1)+1),:)=[0 0 0];
    set(gca,'ColorOrder',cmap);
    hold all
    time=(1:length(exampleTracesResp{1}))/sampRate-0.5;
    xlabel('Time since stim (sec)')
    ylabel('Mean dF/F')

    set(gca,'XLim',[time(1) time(end)])
    set(gca,'YLim',[(minY-0.05*(maxY-minY)) (maxY+0.05*(maxY-minY))])

    h=cellfun(@(x)plot(time,x,'LineWidth',2),exampleTracesResp,'Uni',0);
    sigWhisksSingle=horzcat(sigWhisksToPlot(:,1:length(whisk)),sigWhisksToPlot(:,end));  % last column is blank
    sigWhisksResp=sigWhisksSingle(:,~cellfun(@isempty,exampleTraces));
    
    for k=1:length(exampleTracesResp)
            if sigWhisksResp(J,k)==0
                set(h{k},'LineWidth',0.5);
            end
    end
    
    

    V=vline ([0 0.1 0.2 0.3 0.4], 'k');
    p=patch([0 0 1 1],[(minY-0.05*(maxY-minY)) (maxY+0.05*(maxY-minY)) (maxY+0.05*(maxY-minY)) (minY-0.05*(maxY-minY))],'m');
    p.EdgeColor='none';
    p.FaceAlpha=0.2;

    whisklegend={'e3' 'e2' 'e1' 'd3' 'd2' 'd1' 'c3' 'c2' 'c1' 'spon'};
    whisklegendResp=whisklegend(~cellfun(@isempty,exampleTraces));
    L=legend(whisklegendResp);
    L.FontSize=10;
    L.Position=[0.88 0.67 0.073 0.25];
    axis square

end  % end of function

