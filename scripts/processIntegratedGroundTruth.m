function [] = processIntegratedGroundTruth(folderPath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

TAG = 'processIntegratedGroundTruth';

% 加载数据
preprocessRawFlatData = loadPreprocessRawFlat(folderPath);

filterTimeLength = size(preprocessRawFlatData,1);
preprocessTime = getPreprocessTime(preprocessRawFlatData);
preprocessPhoneImuGyroscope = getPreprocessPhoneImuGyroscope(preprocessRawFlatData);
preprocessPhoneImuAccelerometer = getPreprocessPhoneImuAccelerometer(preprocessRawFlatData);
preprocessGroundTruthNavOrientation = getPreprocessGroundTruthNavOrientationRotationMatrix(preprocessRawFlatData);
preprocessGroundTruthNavVelocity = getPreprocessGroundTruthNavVelocity(preprocessRawFlatData);
preprocessGroundTruthNavPosition = getPreprocessGroundTruthNavPosition(preprocessRawFlatData);

tFilterStateCell = filterInitialization(folderPath);
saveFilterStateCell = horzcat({preprocessTime(1)},tFilterStateCell);

saveFilterState = cell(filterTimeLength,10);
saveFilterState(1,:) = saveFilterStateCell;

preprocessGroundTruthNavOrientationCovarianceMatrix = diag([1e-3 1e-3 1e-3]).^2;
preprocessGroundTruthNavVelocityCovarianceMatrix = diag([1e-3 1e-3 1e-3]).^2;
preprocessGroundTruthNavPositionCovarianceMatrix = diag([1e-3 1e-3 1e-3]).^2;
% preprocessGroundTruthNavPositionCovarianceMatrix = diag([3 3 3]).^2;

globalHeadTime = preprocessTime(1);
globalTailTime = preprocessTime(end);
globalTimeInterval = globalTailTime - globalHeadTime;
cLogTriggerInterval = 3.000;
logPrevTriggerTimer = convertTo(datetime("now"),'posixtime') - cLogTriggerInterval;
for i = 2:filterTimeLength

    tFilterTime = preprocessTime(i-1);
    tMeasurementTime = preprocessTime(i);
    tDeltaTime = tMeasurementTime - tFilterTime;
    tMeasurementImuGyroscope = preprocessPhoneImuGyroscope(i-1,:);
    tMeasurementImuAccelerometer = preprocessPhoneImuAccelerometer(i-1,:);
    tMeasurementNavOrientation = preprocessGroundTruthNavOrientation(:,:,i);
    tMeasurementNavVelocity = preprocessGroundTruthNavVelocity(i,:);
    tMeasurementNavPosition = preprocessGroundTruthNavPosition(i,:);

    % if rem(i,200*10) == 0
    %     log2terminal('I',TAG,"");
    % end

    % logMsg = sprintf('filter index: %d',i);
    % log2terminal('D',TAG,logMsg);

    imuMeasurement = cell(1,3);
    imuMeasurement{1,1} = tDeltaTime;
    imuMeasurement{1,2} = tMeasurementImuGyroscope;
    imuMeasurement{1,3} = tMeasurementImuAccelerometer;
    imuMeasurement{1,4} = tMeasurementNavOrientation' * tMeasurementNavVelocity';
    tFilterStateCell = filterPropagateUpdate2DNHCImuMeasurement(tFilterStateCell,imuMeasurement);

    orientationMeasurement = cell(1,2);
    orientationMeasurement{1,1} = tMeasurementNavOrientation;
    orientationMeasurement{1,2} = preprocessGroundTruthNavOrientationCovarianceMatrix;
    % tFilterStateCell = filterUpdateOrientationMeasurement(tFilterStateCell,orientationMeasurement);
    if mod(i,200) == 0
        tFilterStateCell = filterUpdateOrientationMeasurement(tFilterStateCell,orientationMeasurement);
    end

    velocityMeasurement = cell(1,2);
    velocityMeasurement{1,1} = tMeasurementNavVelocity;
    velocityMeasurement{1,2} = preprocessGroundTruthNavVelocityCovarianceMatrix;
    % tFilterStateCell = filterUpdateVelocityMeasurement(tFilterStateCell,velocityMeasurement);
    % tFilterStateCell = filterUpdateVelocityZMeasurement(tFilterStateCell,velocityMeasurement);

    if mod(i,200) == 0
        tFilterStateCell = filterUpdateVelocityMeasurement(tFilterStateCell,velocityMeasurement);
    end

    % if mod(i,200*60) == 0
    %     positionMeasurement = cell(1,2);
    %     positionMeasurement{1,1} = tMeasurementNavPosition;
    %     positionMeasurement{1,2} = preprocessGroundTruthNavPositionCovarianceMatrix;
    %     tFilterStateCell = filterUpdatePositionMeasurement(tFilterStateCell,positionMeasurement);
    % end

    saveFilterStateCell = horzcat({tMeasurementTime},tFilterStateCell);
    saveFilterState(i,:) = saveFilterStateCell;

    logCheckTime = convertTo(datetime("now"),'posixtime');
    if (logCheckTime - logPrevTriggerTimer) > cLogTriggerInterval
        logMsg = sprintf('filter time: %.3f s (%.3f | %.2f %%)',tFilterTime,globalTailTime,(tFilterTime-globalHeadTime)/globalTimeInterval*100);
        log2terminal('I',TAG,logMsg);
        logPrevTriggerTimer = logCheckTime;
    end

end

saveFilterStateIntegratedCombinationDataDriven(folderPath,'IntegratedGTDataDriven1.mat',saveFilterState);
