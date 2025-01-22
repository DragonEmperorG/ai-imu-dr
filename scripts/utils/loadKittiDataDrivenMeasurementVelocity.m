function [rDataDrivenMeasurementDrivenVelocity] = loadKittiDataDrivenMeasurementVelocity(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cGroundTruthVelocityFileName = "GTVelocity.csv";
cDataDrivenMeasurementVelocityFileName = "ModelDeepOdoInput6DInput100HzInputHSOutputNS.txt";

tGroundTruthVelocityFilePath = fullfile(folderPath,cGroundTruthVelocityFileName);
tGroundTruthVelocityRaw = readmatrix(tGroundTruthVelocityFilePath);
tGroundTruthVelocity = tGroundTruthVelocityRaw(:,2);
tDataDrivenMeasurementVelocityFilePath = fullfile(folderPath,cDataDrivenMeasurementVelocityFileName);
tDataDrivenMeasurementVelocityRaw = readmatrix(tDataDrivenMeasurementVelocityFilePath);

rDataDrivenMeasurementDrivenVelocity = zeros(size(tGroundTruthVelocity));
rDataDrivenMeasurementDrivenVelocity(1) = tGroundTruthVelocity(1);
rDataDrivenMeasurementDrivenVelocity(2:end) = tDataDrivenMeasurementVelocityRaw + rDataDrivenMeasurementDrivenVelocity(1);

end