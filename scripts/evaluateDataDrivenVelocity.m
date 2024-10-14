function [outputArg1] = evaluateDataDrivenVelocity(folderPath)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
TAG = 'evaluateDataDrivenVelocity';

dataDrivenVelocity = loadDataDrivenVelocityGroundTruth(folderPath);
groundTruthVelocity = loadDataDrivenVelocityMeasurement(folderPath);

deltaVelocity = dataDrivenVelocity - groundTruthVelocity;

outputArg1 = deltaVelocity;

end