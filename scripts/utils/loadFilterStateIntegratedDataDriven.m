function [filterState] = loadFilterStateIntegratedDataDriven(folderPath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

cFilterResultFileName = 'IntegratedDataDriven.mat';
tFilterResultFilePath = fullfile(folderPath,'DATASET_QAIIMUDEADRECKONING',cFilterResultFileName);
load(tFilterResultFilePath,'sIntegratedDataDrivenFilterState');
filterState = sIntegratedDataDrivenFilterState;

end