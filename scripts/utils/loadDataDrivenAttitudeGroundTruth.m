function [outputArg1] = loadDataDrivenAttitudeGroundTruth(foderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cDeepOriFolderName = 'DATASET_DEEPORI';
cDeepOriTrainFileName = 'DeepOriTrainData.csv';
cDeepOriTrainFilePath = fullfile(foderPath,cDeepOriFolderName,cDeepOriTrainFileName);
cDeepOriTrainData = readmatrix(cDeepOriTrainFilePath);

cDeepOriTrainDataTime = cDeepOriTrainData(:,1);
cDeepOriTrainDataTimeHead = cDeepOriTrainDataTime(1);
cDeepOriTrainDataTimeTail = cDeepOriTrainDataTime(end);

cDeepOriTrainDataTimeIndex = (201:200:size(cDeepOriTrainDataTime,1))';
cDeepOriTrainDataFlat = cDeepOriTrainData(cDeepOriTrainDataTimeIndex,8:16);
cDeepOriTrainDataReshape = reshape(cDeepOriTrainDataFlat',3,3,[]);
cDeepOriTrainDataMatrix = permute(cDeepOriTrainDataReshape,[2 1 3]);

outputArg1 = cDeepOriTrainDataMatrix;

end
