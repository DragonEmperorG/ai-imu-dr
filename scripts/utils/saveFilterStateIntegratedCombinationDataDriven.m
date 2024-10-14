function [] = saveFilterStateIntegratedCombinationDataDriven(folderPath,fileName,filterState)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

% 定义输出
cFilterResultFileName = 'IntegratedDataDriven.mat';
cFilterResultFilePath = fullfile(folderPath,'DATASET_QAIIMUDEADRECKONING',fileName);

sIntegratedDataDrivenFilterState = filterState;
save(cFilterResultFilePath,"sIntegratedDataDrivenFilterState");
end