function [ P ] = permutationTest(stimLocked, spont, numReps)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


T=mean(stimLocked)-mean(spont);

pooled=vertcat(stimLocked,spont);

for t=1:numReps
    [A,inds]=datasample(pooled,length(stimLocked),'Replace',false);
    B=pooled;
    B(inds)=[];
    PT(t)=mean(A)-mean(B);   
end


if T>=0
    P=sum(PT>T)/length(PT); %for positive going cell
else
    P=sum(PT<T)/length(PT); %for negative going cell
end


end  % end of function

