function [outputArg1] = loadCustomDataDrivenVelocityMeasurement(foderPath,fileName)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cDeepOdoFolderName = 'DATASET_DEEPODO';
cDeepOdoPredictFileName = fileName;
cDeepOdoPredictFilePath = fullfile(foderPath,cDeepOdoFolderName,cDeepOdoPredictFileName);
cDeepOdoPredictData = readmatrix(cDeepOdoPredictFilePath);

outputArg1 = cDeepOdoPredictData;

end