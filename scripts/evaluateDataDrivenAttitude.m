function [outputArg1] = evaluateDataDrivenAttitude(folderPath)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
TAG = 'evaluateDataDrivenAttitude';

groundTruthAttitude = loadDataDrivenAttitudeGroundTruth(folderPath);

if contains(folderPath,'0008')
    dataDrivenAttitude = loadDataDrivenAttitudeMeasurement(folderPath,0);
else
    dataDrivenAttitude = loadDataDrivenAttitudeMeasurement(folderPath,0);
end


n = size(groundTruthAttitude,3);

deltaAttitude = zeros(n,1);
for i = 1:n
    deltaMatrix = (dataDrivenAttitude(:,:,i))' * groundTruthAttitude(:,:,i);
    deltaAttitude(i) = rad2deg(evaluateRotationError(deltaMatrix));
end

outputArg1 = deltaAttitude;


end