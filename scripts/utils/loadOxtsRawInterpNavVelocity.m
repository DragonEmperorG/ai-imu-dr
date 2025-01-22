function oxtsRawInterpNavVelocity = loadOxtsRawInterpNavVelocity(extractFolderPath)

cOxtsFolderName = 'oxts';
cOxtsRawDataInterpNavVelocityMatFileName = 'OxtsRawDataInterpNavVelocity.mat';

cOxtsRowDataInterpNavVelocityMatFilePath = fullfile(extractFolderPath,cOxtsFolderName,cOxtsRawDataInterpNavVelocityMatFileName);
% if isfile(cOxtsRowDataInterpNavVelocityMatFilePath)
%     oxtsRawInterpNavVelocity = load(cOxtsRowDataInterpNavVelocityMatFilePath,'-mat').oxtsRawInterpNavVelocity;
%     return;
% end

oxtsRawData = loadOxtsRawData(extractFolderPath);
tOxtsRawDataTime = oxtsRawData(:,1);
tOxtsRawDataNavVelocityNorth = oxtsRawData(:,8);
tOxtsRawDataNavVelocityEast = oxtsRawData(:,9);

tOxtsRawDataForwardVelocity = oxtsRawData(:,10);
tOxtsRawDataLeftwardVelocity = oxtsRawData(:,11);
tOxtsRawDataUpwardVelocity = oxtsRawData(:,12);
tOxtsRawDataOdometryVelocity = ((tOxtsRawDataForwardVelocity.^2) + (tOxtsRawDataLeftwardVelocity.^2) + (tOxtsRawDataUpwardVelocity.^2)).^(0.5);

tOxtsRawDataNavVelocityUpPower = (tOxtsRawDataOdometryVelocity.^2) - (tOxtsRawDataNavVelocityEast.^2) - (tOxtsRawDataNavVelocityNorth.^2);
tOxtsRawDataNavVelocityUp = zeros(size(tOxtsRawDataTime));
tOxtsRawDataNavVelocityUp(tOxtsRawDataNavVelocityUpPower>=0) = tOxtsRawDataNavVelocityUpPower(tOxtsRawDataNavVelocityUpPower>=0).^(0.5);
tOxtsRawDataNavVelocityUp(tOxtsRawDataNavVelocityUpPower<0) = 0;
tOxtsRawDataNavVelocity = [tOxtsRawDataNavVelocityEast,tOxtsRawDataNavVelocityNorth,tOxtsRawDataNavVelocityUp];

tTimeHead = ceil(tOxtsRawDataTime(1));
tTimeTail = floor(tOxtsRawDataTime(end));
tInterpTime = (tTimeHead:0.01:tTimeTail)';

[~,ia,~] = unique(tOxtsRawDataTime);
resampledNavVelocity = interp1(tOxtsRawDataTime(ia),tOxtsRawDataNavVelocity(ia,:),tInterpTime);
oxtsRawInterpNavVelocity = [tInterpTime,resampledNavVelocity];

save(cOxtsRowDataInterpNavVelocityMatFilePath,'oxtsRawInterpNavVelocity');
