function [outputArg1] = loadDataDrivenAttitudeMeasurement(folderPath, type)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cDeepOriFolderName = 'DATASET_DEEPORI';

dataDrivenMeasurementAttitudeRaw = loadDataDrivenMeasurementOrientationRaw(folderPath);

preprocessRawFlatData = loadPreprocessRawFlat(folderPath);
preprocessTime = getPreprocessTime(preprocessRawFlatData);
preprocessGroundTruthNavOrientation = getPreprocessGroundTruthNavOrientationRotationMatrix(preprocessRawFlatData);
[~, referenceOrientationTimeIndex] = getTrackBeginIntegerSecondTime(preprocessTime);
dataDrivenMeasurementAttitude = getDataDrivenMeasurementOrientationRotationMatrix(preprocessGroundTruthNavOrientation(:,:,referenceOrientationTimeIndex),dataDrivenMeasurementAttitudeRaw,type);

outputArg1 = dataDrivenMeasurementAttitude;

end
