function [outputArg1] = loadDataDrivenVelocityGroundTruth(foderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cDeepOdoFolderName = 'DATASET_DEEPODO';
cDeepOdoTrainFileName = 'DeepOdoTrainData.csv';
cDeepOdoTrainFilePath = fullfile(foderPath,cDeepOdoFolderName,cDeepOdoTrainFileName);
cDeepOdoTrainData = readmatrix(cDeepOdoTrainFilePath);

cDeepOdoTrainDataTime = cDeepOdoTrainData(:,1);
cDeepOdoTrainDataTimeHead = cDeepOdoTrainDataTime(1);
cDeepOdoTrainDataTimeTail = cDeepOdoTrainDataTime(end);

cDeepOdoTrainDataTimeIndex = (201:200:size(cDeepOdoTrainDataTime,1))';

outputArg1 = cDeepOdoTrainData(cDeepOdoTrainDataTimeIndex,end);

end
