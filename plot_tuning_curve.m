function [h] = plot_tuning_curve(cellsToPlot, traceByStim, framesEvoked, whisk)
%UNTITLED Summary of this function goes here
% only for regular 3 x 3 array experiment

all_curves=nan(length(cellsToPlot),length(whisk));  
figure
hold on

for j=1:length(cellsToPlot)
    cn=cellsToPlot{j};
    this_curve=nan(1,length(whisk));
    for k=1:length(whisk)
        if isfield(traceByStim.(cn),whisk{k})
            resp=traceByStim.(cn).(whisk{k});
            this_curve(k)=mean2(resp(:,framesEvoked));
        else     
        end
    end
    this_curve=sort(this_curve,'descend','MissingPlacement','last');
    this_curve=this_curve/this_curve(1);  % normalized to max
    all_curves(j,:)=this_curve;
    plot(1:length(whisk),this_curve,'Color',[0.7 0.7 0.7],'LineWidth',0.5); 
end


plot(1:length(whisk),nanmean(all_curves,1),'r','LineWidth',2);

xlabel('Whisker ranking')
ylabel('Relative response strength')
end  % end of function

