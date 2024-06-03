function [rDeepOriTrainData] = loadDeepOriTrainData(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'loadDeepOriTrainData';

% 添加输出预处理时间同步文件
cDatasetDeepOriModelFolderName = 'DATASET_DEEPORI';
cDeepOriTrainDataFileName = 'DeepOriTrainData.csv';

tDeepOriTrainDataFilePath = fullfile(folderPath,cDatasetDeepOriModelFolderName,cDeepOriTrainDataFileName);
rDeepOriTrainData = readmatrix(tDeepOriTrainDataFilePath);

end