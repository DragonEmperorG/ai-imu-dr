function [MAE,RMSE] = evaluateRVE(rV,pV)
% converts lat/lon coordinates to mercator coordinates using mercator scale
dt = 60;

tT = length(rV);

tRelativeTimeSectionHead = (1:(tT-dt))';
tRelativeTimeSectionTail = tRelativeTimeSectionHead + dt;

pDeltaV = pV(tRelativeTimeSectionTail) - pV(tRelativeTimeSectionHead);
rDeltaV = rV(tRelativeTimeSectionTail) - rV(tRelativeTimeSectionHead);

dDeltaV = pDeltaV - rDeltaV;

MAE = mean(abs(dDeltaV));
RMSE = rms(dDeltaV);