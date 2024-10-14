function [outputArg1] = loadDataDrivenVelocityMeasurement(foderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cDeepOdoFolderName = 'DATASET_DEEPODO';
cDeepOdoPredictFileName = 'DeepOdoPredictData.txt';
cDeepOdoPredictFilePath = fullfile(foderPath,cDeepOdoFolderName,cDeepOdoPredictFileName);
cDeepOdoPredictData = readmatrix(cDeepOdoPredictFilePath);

outputArg1 = cDeepOdoPredictData;

end