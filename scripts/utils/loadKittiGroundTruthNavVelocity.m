function [rGroundTruthNavVelocity] = loadKittiGroundTruthNavVelocity(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cGroundTruthNavVelocityFileName = 'GTNavVelocity.csv';

tGroundTruthNavVelocityFilePath = fullfile(folderPath,cGroundTruthNavVelocityFileName);
tGroundTruthNavVelocityRaw = readmatrix(tGroundTruthNavVelocityFilePath);
tGroundTruthNavVelocityRawSize = size(tGroundTruthNavVelocityRaw,1);
rGroundTruthNavVelocity = tGroundTruthNavVelocityRaw(1:100:tGroundTruthNavVelocityRawSize,2:4);

end