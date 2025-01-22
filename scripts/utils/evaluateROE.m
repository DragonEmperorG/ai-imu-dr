function [MAE,RMSE] = evaluateROE(rO,pO)
% converts lat/lon coordinates to mercator coordinates using mercator scale
dt = 60;

tT = length(rO);

tRelativeTimeSectionHead = (1:(tT-dt))';
tRelativeTimeSectionTail = tRelativeTimeSectionHead + dt;

n = size(tRelativeTimeSectionHead,1);
ddO = zeros(n,1);
for i = 1:n
    tO = (pO(:,:,i))' * rO(:,:,i);
    pDeltaO = pO(:,:,tRelativeTimeSectionHead(i)) * pO(:,:,tRelativeTimeSectionTail(i));
    rDeltaO = rO(:,:,tRelativeTimeSectionHead(i)) * rO(:,:,tRelativeTimeSectionTail(i));
    dDeltaO = pDeltaO' * rDeltaO;
    ddO(i) = rad2deg(evaluateRotationError(dDeltaO));
end

MAE = mean(abs(ddO));
RMSE = rms(ddO);
