function [filterState] = loadKittiFilterStateIntegratedCustomDataDriven(folderPath,fileName)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

tFilterResultFilePath = fullfile(folderPath,fileName);
load(tFilterResultFilePath,'sIntegratedDataDrivenFilterState');
filterState = sIntegratedDataDrivenFilterState;

end