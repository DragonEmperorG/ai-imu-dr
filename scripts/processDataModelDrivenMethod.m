function [] = processDataModelDrivenMethod(folderPath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

TAG = 'processIntegratedGroundTruth';

% 加载数据
preprocessRawFlatData = loadPreprocessRawFlat(folderPath);
dataDrivenMeasurementOrientationRaw = loadDataDrivenMeasurementOrientationRaw(folderPath);

% 解析数据
filterTimeLength = size(preprocessRawFlatData,1);
preprocessTime = getPreprocessTime(preprocessRawFlatData);
preprocessPhoneImuGyroscope = getPreprocessPhoneImuGyroscope(preprocessRawFlatData);
preprocessPhoneImuAccelerometer = getPreprocessPhoneImuAccelerometer(preprocessRawFlatData);
preprocessGroundTruthNavOrientation = getPreprocessGroundTruthNavOrientationRotationMatrix(preprocessRawFlatData);
preprocessGroundTruthNavVelocity = getPreprocessGroundTruthNavVelocity(preprocessRawFlatData);
preprocessGroundTruthNavPosition = getPreprocessGroundTruthNavPosition(preprocessRawFlatData);

dataDrivenTime = dataDrivenMeasurementOrientationRaw(:,1);
[~, referenceOrientationTimeIndex] = getTrackBeginIntegerSecondTime(preprocessTime);
dataDrivenNavOrientation = getDataDrivenMeasurementOrientationRotationMatrix(preprocessGroundTruthNavOrientation(:,:,referenceOrientationTimeIndex),dataDrivenMeasurementOrientationRaw);


[PreprocessGroundTruthNavOrientationEulerAnglePitch,PreprocessGroundTruthNavOrientationEulerAngleRoll,PreprocessGroundTruthNavOrientationEulerAngleYaw] = dcm2angle(dataDrivenNavOrientation,'XYZ');
preprocessGroundTruthNavOrientationEulerAngleDeg = rad2deg(horzcat(PreprocessGroundTruthNavOrientationEulerAnglePitch,PreprocessGroundTruthNavOrientationEulerAngleRoll,PreprocessGroundTruthNavOrientationEulerAngleYaw));
figure;
plot(preprocessGroundTruthNavOrientationEulerAngleDeg);
% 
% 
trackEndIntegerSecondTime = floor(preprocessTime(end));
trackBeginIntegerSecondTimeIndex = find(preprocessTime == trackEndIntegerSecondTime);
trackIntegerSecondTimeIndex = referenceOrientationTimeIndex:200:trackBeginIntegerSecondTimeIndex;
[PreprocessGroundTruthNavOrientationEulerAnglePitch,PreprocessGroundTruthNavOrientationEulerAngleRoll,PreprocessGroundTruthNavOrientationEulerAngleYaw] = dcm2angle(preprocessGroundTruthNavOrientation(:,:,trackIntegerSecondTimeIndex),'XYZ');
preprocessGroundTruthNavOrientationEulerAngleDeg1 = rad2deg(horzcat(PreprocessGroundTruthNavOrientationEulerAnglePitch,PreprocessGroundTruthNavOrientationEulerAngleRoll,PreprocessGroundTruthNavOrientationEulerAngleYaw));
hold on;
plot(preprocessGroundTruthNavOrientationEulerAngleDeg1);

% preprocessGroundTruthNavOrientationEulerAngleDeg(:,1:2) = preprocessGroundTruthNavOrientationEulerAngleDeg1(:,1:2);
preprocessGroundTruthNavOrientationEulerAngleRad = deg2rad(preprocessGroundTruthNavOrientationEulerAngleDeg1);
dataDrivenNavOrientation = angle2dcm( ...
    preprocessGroundTruthNavOrientationEulerAngleRad(:,1), ...
    preprocessGroundTruthNavOrientationEulerAngleRad(:,2), ...
    preprocessGroundTruthNavOrientationEulerAngleRad(:,3), ...
    'XYZ');


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
    tFilterStateCell = filterPropagateImuMeasurement(tFilterStateCell,imuMeasurement);

    if find(dataDrivenTime == tFilterTime)
        orientationMeasurement = cell(1,2);
        
        % orientationMeasurement{1,1} = preprocessGroundTruthNavOrientation(:,:,preprocessTime == tFilterTime);
        % orientationMeasurement{1,2} = diag([1e-3 1e-3 1e-3]).^2;

        orientationMeasurement{1,1} = dataDrivenNavOrientation(:,:,dataDrivenTime == tFilterTime);
        orientationMeasurement{1,2} = diag([1e-2 1e-2 1e-2]).^2;
        tFilterStateCell = filterUpdateOrientationMeasurement(tFilterStateCell,orientationMeasurement);
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

saveFilterStateIntegratedDataDriven(folderPath,saveFilterState);
