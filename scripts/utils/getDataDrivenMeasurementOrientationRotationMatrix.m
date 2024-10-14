function [dataDrivenMeasurementOrientationRotationMatrix] = getDataDrivenMeasurementOrientationRotationMatrix(referenceOrientation,rawData,type)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

orientationQuaternionXYZ = rawData(:,2:4);

% orientationQuaternionXYZ(90:107,3) = -orientationQuaternionXYZ(90:107,3);

orientationQuaternionXYZQuadraticSum = sum(orientationQuaternionXYZ .^ 2, 2);
orientationQuaternionXYZFilter = orientationQuaternionXYZQuadraticSum > 1;
if orientationQuaternionXYZFilter > 1
    orientationQuaternionXYZQuadraticSumSqrt = orientationQuaternionXYZQuadraticSum .^ 0.5;
    orientationQuaternionXYZ(orientationQuaternionXYZFilter,:) = orientationQuaternionXYZ(orientationQuaternionXYZFilter,:) ./ orientationQuaternionXYZQuadraticSumSqrt(orientationQuaternionXYZFilter,:);
end
orientationQuaternionW = (1 - orientationQuaternionXYZQuadraticSum) .^ 0.5;

% orientationQuaternionW(90:107,:) = -orientationQuaternionW(90:107,:);

orientationQuaternionWXYZ = horzcat(orientationQuaternionW,orientationQuaternionXYZ);
orientationQuaternion = quaternion(orientationQuaternionWXYZ);


orientationRotationMatrix = quat2rotm(orientationQuaternion);

% orientationRotationMatrix = quat2dcm(orientationQuaternion);

dataDrivenMeasurementOrientationRotationMatrix = zeros(size(orientationRotationMatrix));
dataDrivenMeasurementOrientationRotationMatrix(:,:,1) = referenceOrientation * orientationRotationMatrix(:,:,1);
for i = 2:size(dataDrivenMeasurementOrientationRotationMatrix,3)
    if type == 0
        dataDrivenMeasurementOrientationRotationMatrix(:,:,i) = dataDrivenMeasurementOrientationRotationMatrix(:,:,i-1) * orientationRotationMatrix(:,:,i);
    else
        dataDrivenMeasurementOrientationRotationMatrix(:,:,i) = referenceOrientation * orientationRotationMatrix(:,:,i);
        % dataDrivenMeasurementOrientationRotationMatrix(:,:,i) = orientationRotationMatrix(:,:,i) * referenceOrientation;
    end
end

end