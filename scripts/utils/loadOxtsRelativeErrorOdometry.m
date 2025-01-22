function oxtsRelativeErrorOdometrySet = loadOxtsRelativeErrorOdometry(extractFolderPath)

TAG = "loadOxtsRelativeErrorOdometry";

cOxtsFolderName = 'oxts';
cOxtsRelativeErrorOdometrySetMatFileName = 'OxtsRelativeErrorOdometrySet.mat';

cOxtsRelativeErrorOdometrySetMatFilePath = fullfile(extractFolderPath,cOxtsFolderName,cOxtsRelativeErrorOdometrySetMatFileName);
% if isfile(cOxtsRelativeErrorOdometrySetMatFilePath)
%     oxtsRelativeErrorOdometrySet = load(cOxtsRelativeErrorOdometrySetMatFilePath,'-mat').oxtsRelativeErrorOdometrySet;
%     return;
% end

oxtsRawData = loadOxtsRawData(extractFolderPath);
tOxtsRawDataTime = oxtsRawData(:,1);
tOxtsRawDataGeodeticCoordinate = oxtsRawData(:,2:4);

tOxtsRawDataGeodeticCoordinate0 = tOxtsRawDataGeodeticCoordinate(1:end-1,:);
tOxtsRawDataGeodeticCoordinate1 = tOxtsRawDataGeodeticCoordinate(2:end,:);
[tLocalE,tLocalN,tLocalU] = geodetic2enu( ...
    tOxtsRawDataGeodeticCoordinate1(:,1), ...
    tOxtsRawDataGeodeticCoordinate1(:,2), ...
    tOxtsRawDataGeodeticCoordinate1(:,3), ...
    tOxtsRawDataGeodeticCoordinate0(:,1), ...
    tOxtsRawDataGeodeticCoordinate0(:,2), ...
    tOxtsRawDataGeodeticCoordinate0(:,3), ...
    wgs84Ellipsoid ...
);
tLocalENU = [tLocalE,tLocalN,tLocalU];

dOdometry = sqrt(sum(tLocalENU.^2,2));
cOdometry = cumsum(dOdometry);

tTimeHead = ceil(tOxtsRawDataTime(1));
tTimeTail = floor(tOxtsRawDataTime(end));
tInterpTime = (tTimeHead:1:tTimeTail)';

logMsg = sprintf('%.3f s',tTimeTail-tTimeHead);
log2terminal('I',TAG,logMsg);
logMsg = sprintf('%.3f m',cOdometry(end));
log2terminal('I',TAG,logMsg);

[~,ia,~] = unique(tOxtsRawDataTime);
iOdometry = [0;cOdometry];
resampledOdometryRaw = interp1(tOxtsRawDataTime(ia),iOdometry(ia),tInterpTime);
resampledOdometry = resampledOdometryRaw - resampledOdometryRaw(1);

cOdometrySet = (100:100:800)';
oxtsRelativeErrorOdometrySet = [];
for i = 1:size(tInterpTime,1)
    t0 = i;
    for j = 1:size(cOdometrySet,1)
        tOdometry1 = resampledOdometry(t0) + cOdometrySet(j);
        if resampledOdometry(t0) + cOdometrySet(j) > resampledOdometry(end)
            continue;
        end
        tSearch = find(resampledOdometry >= tOdometry1);
        t1 = tSearch(1);
        tRelativeErrorOdometry = [
            t0,t1,tInterpTime(t0),...
            tInterpTime(t1),resampledOdometry(t0),...
            resampledOdometry(t1),cOdometrySet(j),...
            resampledOdometry(t1)-resampledOdometry(t0)
        ];
        oxtsRelativeErrorOdometrySet = [oxtsRelativeErrorOdometrySet;tRelativeErrorOdometry];
    end
end

save(cOxtsRelativeErrorOdometrySetMatFilePath,'oxtsRelativeErrorOdometrySet');
