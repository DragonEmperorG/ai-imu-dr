function [systemClock] = loadSmartphoneRawSystemClock(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
cRawFolderName = "raw";
cRawFolderPath = fullfile(folderPath,cRawFolderName);
cSystemClockFileName = "SystemClock.mat";
cSystemClockMatFilePath = fullfile(cRawFolderPath,cSystemClockFileName);
if isfile(cSystemClockMatFilePath)
    systemClock = load(cSystemClockMatFilePath,'-mat').systemClock;
    return;
end

kMotionSensorAccelerometerFileNameString = "MotionSensorAccelerometer.csv";
kMotionSensorAccelerometerUncalibratedFileNameString = "MotionSensorAccelerometerUncalibrated.csv";
kMotionSensorGyroscopeFileNameString = "MotionSensorGyroscope.csv";
kMotionSensorGyroscopeUncalibratedFileNameString = "MotionSensorGyroscopeUncalibrated.csv";
kPositionSensorMagneticFieldFileNameString = "PositionSensorMagneticField.csv";
kPositionSensorMagneticFieldUncalibratedFileNameString = "PositionSensorMagneticFieldUncalibrated.csv";
kPositionSensorGameRotationVectorFileNameString = "PositionSensorGameRotationVector.csv";
kGnssLocationFileNameString = "GnssLocation.csv";
kGnssMeasurementFileNameString = "GnssMeasurement.csv";
kValidateSensorFileList = horzcat(kMotionSensorAccelerometerFileNameString,...
    kMotionSensorAccelerometerUncalibratedFileNameString,...
    kMotionSensorGyroscopeFileNameString,...
    kMotionSensorGyroscopeUncalibratedFileNameString,...
    kPositionSensorMagneticFieldFileNameString,...
    kPositionSensorMagneticFieldUncalibratedFileNameString,...
    kPositionSensorGameRotationVectorFileNameString,...
    kGnssLocationFileNameString,...
    kGnssMeasurementFileNameString);
kValidateSensorFileListLength = length(kValidateSensorFileList);

systemClock = [];
for i = 1:kValidateSensorFileListLength
    tSensorFileName = kValidateSensorFileList(i);
    tSensorFilePath = fullfile(cRawFolderPath,tSensorFileName);
    tSensorRawData = readmatrix(tSensorFilePath);
    tSensorRawDataSize = size(tSensorRawData,1);
    tSensorMarker = ones(tSensorRawDataSize,1) * i;
    systemClock = [systemClock;[tSensorMarker,tSensorRawData(:,1:3)]];
end

systemClock = sortrows(systemClock,[2 3 1]);
save(cSystemClockMatFilePath,'systemClock');

end