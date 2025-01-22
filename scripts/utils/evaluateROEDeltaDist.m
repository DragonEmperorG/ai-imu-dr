function [MAE,RMSE,fMAEunit,fRMSEunit] = evaluateROEDeltaDist(rO,pO,dD)
% converts lat/lon coordinates to mercator coordinates using mercator scale

tT = length(rO);

tRelativeTimeSectionHead = dD(:,1);
tRelativeTimeSectionTail = dD(:,2);
tRelativeDistance = dD(:,8) * 1e-3;

n = size(tRelativeTimeSectionHead,1);
ddO = zeros(n,1);
for i = 1:n
    pDeltaO = pO(:,:,tRelativeTimeSectionHead(i))' * pO(:,:,tRelativeTimeSectionTail(i));
    rDeltaO = rO(:,:,tRelativeTimeSectionHead(i))' * rO(:,:,tRelativeTimeSectionTail(i));
    dDeltaO = pDeltaO' * rDeltaO;
    ddO(i) = rad2deg(evaluateRotationError(dDeltaO));
end

dDeltaOPerDistance = ddO ./ tRelativeDistance;

MAE = mean(abs(dDeltaOPerDistance));
RMSE = rms(dDeltaOPerDistance);

fMAEunit = mean(abs(ddO));
fRMSEunit = rms(ddO);