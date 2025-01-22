function [MAE,RMSE] = evaluateAPE(rSE,pSE)
% 

n = size(rSE,3);
tAPE = zeros(n,1);
for i = 1:n
    dSE = pSE(:,:,i) \ rSE(:,:,i);
    tAPE(i) = norm(dSE(1:3,4));
end

MAE = mean(abs(tAPE));
RMSE = rms(tAPE);