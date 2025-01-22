function [rDataDrivenMeasurementTime] = loadKittiDataDrivenMeasurementTime(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cGroundTruthVelocityFileName = "GTVelocity.csv";

tGroundTruthVelocityFilePath = fullfile(folderPath,cGroundTruthVelocityFileName);
tGroundTruthVelocityRaw = readmatrix(tGroundTruthVelocityFilePath);

rDataDrivenMeasurementTime = tGroundTruthVelocityRaw(:,1);

end