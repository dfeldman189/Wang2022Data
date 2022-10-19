function [ pvals ] = permuteTest_whisk( sponTrace,traceByStim,numPermu,framesEvoked,lostStim)
%UNTITLED4 Summary of this function goes here

cellNames=fieldnames(sponTrace);  % ROIs
whisk=fieldnames(traceByStim.(cellNames{1}));  % stimulations

for K=1:length(cellNames)  % for every ROI
     sponMeans=mean(sponTrace.(cellNames{K})(:,framesEvoked),2);    %average value of every spontaneous trace
     cn=cellNames{K};

     for J=1:length(whisk)
         if lostStim(J)==0
         whiskMeans{J}=mean(traceByStim.(cn).(whisk{J})(:,framesEvoked),2); % average value of every response to one whisker
         else
         end
     end
     
     parfor J=1:length(whisk)
         if lostStim(J)==0         
             tmpPVal(J)=permutationTest(whiskMeans{J},sponMeans,numPermu);
         else
         end
     end
     
     for J=1:length(whisk)
         if lostStim(J)==0
         pvals.(cn).(whisk{J}) = tmpPVal(J);
         else
         end
     end
    
end




end  % end of function

