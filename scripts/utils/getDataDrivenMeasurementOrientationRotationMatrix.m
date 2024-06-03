function [dataDrivenMeasurementOrientationRotationMatrix] = getDataDrivenMeasurementOrientationRotationMatrix(referenceOrientation,rawData)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

orientationQuaternionXYZ = rawData(:,2:4);
orientationQuaternionXYZQuadraticSum = sum(orientationQuaternionXYZ .^ 2, 2);
orientationQuaternionXYZFilter = orientationQuaternionXYZQuadraticSum > 1;
if orientationQuaternionXYZFilter > 1
    orientationQuaternionXYZQuadraticSumSqrt = orientationQuaternionXYZQuadraticSum .^ 0.5;
    orientationQuaternionXYZ(orientationQuaternionXYZFilter,:) = orientationQuaternionXYZ(orientationQuaternionXYZFilter,:) ./ orientationQuaternionXYZQuadraticSumSqrt(orientationQuaternionXYZFilter,:);
end
orientationQuaternionW = (1 - orientationQuaternionXYZQuadraticSum) .^ 0.5;
orientationQuaternionWXYZ = horzcat(orientationQuaternionW,orientationQuaternionXYZ);
orientationQuaternion = quaternion(orientationQuaternionWXYZ);

orientationRotationMatrix = quat2rotm(orientationQuaternion);
dataDrivenMeasurementOrientationRotationMatrix = zeros(size(orientationRotationMatrix));
dataDrivenMeasurementOrientationRotationMatrix(:,:,1) = referenceOrientation * orientationRotationMatrix(:,:,1);
for i = 2:size(dataDrivenMeasurementOrientationRotationMatrix,3)
    dataDrivenMeasurementOrientationRotationMatrix(:,:,i) = dataDrivenMeasurementOrientationRotationMatrix(:,:,i-1) * orientationRotationMatrix(:,:,i);
end

end