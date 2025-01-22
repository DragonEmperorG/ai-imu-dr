function [MAE,RMSE] = evaluateRVEDeltaDist(rV,pV,dD)
% converts lat/lon coordinates to mercator coordinates using mercator scale

tT = length(rV);

tRelativeTimeSectionHead = dD(:,1);
tRelativeTimeSectionTail = dD(:,2);
tRelativeDistance = dD(:,8) * 1e-3;

pDeltaV = pV(tRelativeTimeSectionTail) - pV(tRelativeTimeSectionHead);
rDeltaV = rV(tRelativeTimeSectionTail) - rV(tRelativeTimeSectionHead);

dDeltaV = pDeltaV - rDeltaV;
dDeltaVPerDistance = dDeltaV;
% dDeltaVPerDistance = dDeltaV ./ tRelativeDistance;


MAE = mean(abs(dDeltaVPerDistance));
RMSE = rms(dDeltaVPerDistance);