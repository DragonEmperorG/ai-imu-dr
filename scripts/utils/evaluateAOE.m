function [MAE,RMSE] = evaluateAOE(rO,pO)
% converts lat/lon coordinates to mercator coordinates using mercator scale

n = size(rO,3);
dO = zeros(n,1);
for i = 1:n
    tO = (pO(:,:,i))' * rO(:,:,i);
    dO(i) = rad2deg(evaluateRotationError(tO));
end

MAE = mean(abs(dO));
RMSE = rms(dO);