function [outputArg1] = loadCustomDataDrivenAttitudeMeasurement(folderPath, type, fileName)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cDeepOriFolderName = 'DATASET_DEEPORI';

tDeepOriDataFilePath = fullfile(folderPath,cDeepOriFolderName,fileName);
dataDrivenMeasurementAttitudeRaw = readmatrix(tDeepOriDataFilePath);

preprocessRawFlatData = loadPreprocessRawFlat(folderPath);
preprocessTime = getPreprocessTime(preprocessRawFlatData);
preprocessGroundTruthNavOrientation = getPreprocessGroundTruthNavOrientationRotationMatrix(preprocessRawFlatData);
[~, referenceOrientationTimeIndex] = getTrackBeginIntegerSecondTime(preprocessTime);
dataDrivenMeasurementAttitude = getDataDrivenMeasurementOrientationRotationMatrix(preprocessGroundTruthNavOrientation(:,:,referenceOrientationTimeIndex),dataDrivenMeasurementAttitudeRaw,type);

outputArg1 = dataDrivenMeasurementAttitude;

end
