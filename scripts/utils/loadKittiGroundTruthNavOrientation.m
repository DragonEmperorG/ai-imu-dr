function [rGroundTruthNavOrientation] = loadKittiGroundTruthNavOrientation(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cGroundTruthNavOrientationFileName = 'GTOrientation.csv';

tGroundTruthNavOrientationFilePath = fullfile(folderPath,cGroundTruthNavOrientationFileName);
tGroundTruthOrientationRaw = readmatrix(tGroundTruthNavOrientationFilePath);
tGroundTruthOrientationFlat = tGroundTruthOrientationRaw(:,2:10);
rGroundTruthNavOrientation = convertOrientationFlatToRotationMatrix(tGroundTruthOrientationFlat);

end