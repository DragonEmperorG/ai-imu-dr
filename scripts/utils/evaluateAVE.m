function [MAE,RMSE] = evaluateAVE(rV,pV)
% converts lat/lon coordinates to mercator coordinates using mercator scale

dV = pV - rV;

MAE = mean(abs(dV));
RMSE = rms(dV);