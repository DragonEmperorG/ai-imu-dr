function [] = processKittiDataModelDrivenMethod(folderPath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

TAG = 'processKittiDataModelDrivenMethod';

cFilterMethodTag = 1;
cSaveMatFileName = 'Integrated2DNHCDataDriven.mat';
% cFilterMethodTag = 2;
% cSaveMatFileName = 'Integrated3DNHCDataDriven.mat';
% cSaveMatFileName = 'Integrated2DNHCATTDataDriven.mat';
% cFilterMethodTag = 4;
% cSaveMatFileName = 'Integrated3DNHCATTDataDriven.mat';

% 加载数据
tMeasurementImu = loadKittiImuSensorData(folderPath);
% tMeasurementImu = tMeasurementImu(1:1+100*120,:);

% plotImuData(tMeasurementImu);

filterTimeLength = size(tMeasurementImu,1);

tDataDrivenMeasurementTime = loadKittiDataDrivenMeasurementTime(folderPath);
tDataDrivenMeasurementOrientation = loadKittiDataDrivenMeasurementOrientation(folderPath);
tDataDrivenMeasurementVelocity = loadKittiDataDrivenMeasurementVelocity(folderPath);

tGroundTruthNavOrientation = loadKittiGroundTruthNavOrientation(folderPath);
tGroundTruthNavVelocity = loadKittiGroundTruthNavVelocity(folderPath);

%
filterTime = tMeasurementImu(:,1);
filterMeasurementGyroscope = tMeasurementImu(:,2:4);
filterMeasurementAccelerometer = tMeasurementImu(:,5:7);

filterDDMeasuremenTime = tDataDrivenMeasurementTime;
filterDDMeasurementOrientation = tGroundTruthNavOrientation;
filterDDMeasurementVelocity = tGroundTruthNavVelocity;

tFilterStateCell = filterInitializationForKITTI(folderPath);
saveFilterStateCell = horzcat({filterTime(1)},tFilterStateCell);

saveFilterState = cell(filterTimeLength,10);
saveFilterState(1,:) = saveFilterStateCell;

preprocessGroundTruthNavOrientationCovarianceMatrix = diag([1e-3 1e-3 1e-3]).^2;
preprocessGroundTruthNavVelocityCovarianceMatrix = diag([1e-3 1e-3 1e-3]).^2;
preprocessGroundTruthNavPositionCovarianceMatrix = diag([1e-3 1e-3 1e-3]).^2;
% preprocessGroundTruthNavPositionCovarianceMatrix = diag([3 3 3]).^2;

globalHeadTime = filterTime(1);
globalTailTime = filterTime(end);
globalTimeInterval = globalTailTime - globalHeadTime;
cLogTriggerInterval = 3.000;
logPrevTriggerTimer = convertTo(datetime("now"),'posixtime') - cLogTriggerInterval;
for i = 2:filterTimeLength

    tFilterTime = filterTime(i-1);
    tMeasurementTime = filterTime(i);
    tDeltaTime = tMeasurementTime - tFilterTime;
    tMeasurementImuGyroscope = filterMeasurementGyroscope(i-1,:);
    tMeasurementImuAccelerometer = filterMeasurementAccelerometer(i-1,:);

    % tMeasurementNavPosition = preprocessGroundTruthNavPosition(i,:);

    if rem(i,100*100) == 0
        log2terminal('I',TAG,"");
    end

    % logMsg = sprintf('filter index: %d',i);
    % log2terminal('D',TAG,logMsg);

    if find(filterDDMeasuremenTime == tMeasurementTime)

        tMeasurementNavOrientation = filterDDMeasurementOrientation(:,:,filterDDMeasuremenTime == tMeasurementTime);
        tMeasurementNavVelocity = filterDDMeasurementVelocity(filterDDMeasuremenTime == tMeasurementTime,:);

        if cFilterMethodTag == 1        
            imuMeasurement = cell(1,3);
            imuMeasurement{1,1} = tDeltaTime;
            imuMeasurement{1,2} = tMeasurementImuGyroscope;
            imuMeasurement{1,3} = tMeasurementImuAccelerometer;
            tFilterStateCell = filterPropagateUpdateKITTI2DNHCImuMeasurement(tFilterStateCell,imuMeasurement);
        end

        if cFilterMethodTag == 2        
            imuMeasurement = cell(1,3);
            imuMeasurement{1,1} = tDeltaTime;
            imuMeasurement{1,2} = tMeasurementImuGyroscope;
            imuMeasurement{1,3} = tMeasurementImuAccelerometer;
            imuMeasurement{1,4} = tMeasurementNavOrientation' * tMeasurementNavVelocity';
            % imuMeasurement{1,4} = [0 dataDrivenCarVelocity(i) 0];
            tFilterStateCell = filterKITTIPropagateUpdate3DNHCImuMeasurement(tFilterStateCell,imuMeasurement);
        end

        if cFilterMethodTag == 3
            if find(filterDDMeasuremenTime == tFilterTime)
                orientationMeasurement = cell(1,2);
                orientationMeasurement{1,1} = tMeasurementNavOrientation;
                orientationMeasurement{1,2} = diag([1e-3 1e-3 1e-3]).^2;
                % orientationMeasurement{1,2} = diag([1e-1 1e-1 1e-1]).^2;
                tFilterStateCell = filterUpdateOrientationMeasurement(tFilterStateCell,orientationMeasurement);
            end
        end

        if cFilterMethodTag == 4
            imuMeasurement = cell(1,3);
            imuMeasurement{1,1} = tDeltaTime;
            imuMeasurement{1,2} = tMeasurementImuGyroscope;
            imuMeasurement{1,3} = tMeasurementImuAccelerometer;
            tMeasurementCarVelocity = tMeasurementNavOrientation' * tMeasurementNavVelocity';
            imuMeasurement{1,4} = [tMeasurementCarVelocity(1) 0 0];
            % imuMeasurement{1,4} = [0 dataDrivenCarVelocity(i) 0];
            tFilterStateCell = filterKITTIPropagateUpdate3DNHCImuMeasurement(tFilterStateCell,imuMeasurement);

            orientationMeasurement = cell(1,2);
            orientationMeasurement{1,1} = tMeasurementNavOrientation;
            % orientationMeasurement{1,2} = diag([1e-3 1e-3 1e-3]).^2;
            orientationMeasurement{1,2} = diag([1e-1 1e-1 1e-1]).^2;
            tFilterStateCell = filterUpdateOrientationMeasurement(tFilterStateCell,orientationMeasurement);
        end
    else
        imuMeasurement = cell(1,3);
        imuMeasurement{1,1} = tDeltaTime;
        imuMeasurement{1,2} = tMeasurementImuGyroscope;
        imuMeasurement{1,3} = tMeasurementImuAccelerometer;
        % imuMeasurement{1,4} = tMeasurementNavOrientation' * tMeasurementNavVelocity';
        % imuMeasurement{1,4} = [0 dataDrivenCarVelocity(i) 0];
        tFilterStateCell = filterPropagateUpdateKITTI2DNHCImuMeasurement(tFilterStateCell,imuMeasurement);
    end

    saveFilterStateCell = horzcat({tMeasurementTime},tFilterStateCell);
    saveFilterState(i,:) = saveFilterStateCell;

    logCheckTime = convertTo(datetime("now"),'posixtime');
    if (logCheckTime - logPrevTriggerTimer) > cLogTriggerInterval
        logMsg = sprintf('filter time: %.3f s (%.3f | %.2f %%)',tFilterTime,globalTailTime,(tFilterTime-globalHeadTime)/globalTimeInterval*100);
        log2terminal('I',TAG,logMsg);
        logPrevTriggerTimer = logCheckTime;
    end

end

cSaveMatFilePath = fullfile(folderPath,cSaveMatFileName);
sIntegratedDataDrivenFilterState = saveFilterState;
save(cSaveMatFilePath,"sIntegratedDataDrivenFilterState");
