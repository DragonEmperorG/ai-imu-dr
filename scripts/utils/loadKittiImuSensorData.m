function [rMeasurementGyrAcc] = loadKittiImuSensorData(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cINGyrAccFileName = 'INSensor.csv';

tINGyrAccFilePath = fullfile(folderPath,cINGyrAccFileName);
rMeasurementGyrAcc = readmatrix(tINGyrAccFilePath);

end