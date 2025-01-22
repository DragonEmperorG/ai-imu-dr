function oxtsRawInterpVelocity = loadOxtsRawInterpVelocity(extractFolderPath)

cOxtsFolderName = 'oxts';
cOxtsRawDataInterpVelocityMatFileName = 'OxtsRawDataInterpVelocity.mat';

cOxtsRowDataInterpVelocityMatFilePath = fullfile(extractFolderPath,cOxtsFolderName,cOxtsRawDataInterpVelocityMatFileName);
if isfile(cOxtsRowDataInterpVelocityMatFilePath)
    oxtsRawInterpVelocity = load(cOxtsRowDataInterpVelocityMatFilePath,'-mat').oxtsRawInterpVelocity;
    return;
end

oxtsRawData = loadOxtsRawData(extractFolderPath);
tOxtsRawDataTime = oxtsRawData(:,1);
tOxtsRawDataForwardVelocity = oxtsRawData(:,10);
tOxtsRawDataLeftwardVelocity = oxtsRawData(:,11);
tOxtsRawDataUpwardVelocity = oxtsRawData(:,12);
tOxtsRawDataOdometryVelocity = ((tOxtsRawDataForwardVelocity.^2) + (tOxtsRawDataLeftwardVelocity.^2) + (tOxtsRawDataUpwardVelocity.^2)).^(0.5);

tTimeHead = ceil(tOxtsRawDataTime(1));
tTimeTail = floor(tOxtsRawDataTime(end));
tInterpTime = (tTimeHead:1:tTimeTail)';

[~,ia,~] = unique(tOxtsRawDataTime);
resampledVelocity = interp1(tOxtsRawDataTime(ia),tOxtsRawDataOdometryVelocity(ia),tInterpTime);
oxtsRawInterpVelocity = [tInterpTime,resampledVelocity];

save(cOxtsRowDataInterpVelocityMatFilePath,'oxtsRawInterpVelocity');
