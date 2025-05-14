function [MAE1,RMSE1,MAE2,RMSE2,MAE3,RMSE3,MAE4,RMSE4] = rSE(:,1:2)DeltaDist(rSE,pSE,dD)

tRelativeTimeSectionHead = dD(:,1);
tRelativeTimeSectionTail = dD(:,2);
tRelativeDistance = dD(:,8);

n = size(tRelativeTimeSectionHead,1);
ddPE1 = zeros(n,1);
ddPE2 = zeros(n,1);
for i = 1:n
    pDeltaSE = pSE(:,:,tRelativeTimeSectionHead(i)) \ pSE(:,:,tRelativeTimeSectionTail(i));
    rDeltaSE = rSE(:,:,tRelativeTimeSectionHead(i)) \ rSE(:,:,tRelativeTimeSectionTail(i));
    dDeltaSE = pDeltaSE \ rDeltaSE;
    ddPE1(i) = norm(dDeltaSE(1:3,4,:));
    ddPE2(i) = norm(dDeltaSE(1:2,4,:));
end

dDeltaP1PerDistance = ddPE1 ./ tRelativeDistance * 100;
dDeltaP2PerDistance = ddPE2 ./ tRelativeDistance * 100;

MAE1 = mean(abs(dDeltaP1PerDistance));
RMSE1 = rms(dDeltaP1PerDistance);

MAE2 = mean(abs(ddPE1));
RMSE2 = rms(ddPE1);

MAE3 = mean(abs(dDeltaP2PerDistance));
RMSE3 = rms(dDeltaP2PerDistance);

MAE4 = mean(abs(ddPE2));
RMSE4 = rms(ddPE2);