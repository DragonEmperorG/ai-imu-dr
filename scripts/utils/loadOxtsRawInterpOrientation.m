function oxtsRawInterpOrientation = loadOxtsRawInterpOrientation(extractFolderPath)

cOxtsFolderName = 'oxts';
cOxtsRawDataInterpOrientationMatFileName = 'OxtsRawDataInterpOrientation.mat';

cOxtsRowDataInterpOrientationMatFilePath = fullfile(extractFolderPath,cOxtsFolderName,cOxtsRawDataInterpOrientationMatFileName);
if isfile(cOxtsRowDataInterpOrientationMatFilePath)
    oxtsRawInterpOrientation = load(cOxtsRowDataInterpOrientationMatFilePath,'-mat').oxtsRawInterpOrientation;
    return;
end

oxtsRawData = loadOxtsRawData(extractFolderPath);
tOxtsRawDataTime = oxtsRawData(:,1);
tOxtsRawDataOrientationRoll = oxtsRawData(:,5);
tOxtsRawDataOrientationPitch = oxtsRawData(:,6);
tOxtsRawDataOrientationYaw = oxtsRawData(:,7);

sampledTime = tOxtsRawDataTime;
sampledTimeSize = size(sampledTime,1);
sampledTimeSection = zeros(sampledTimeSize-1,2);
sampledTimeSection(:,1) = sampledTime(1:(sampledTimeSize-1),1);
sampledTimeSection(:,2) = sampledTime(2:sampledTimeSize,1);

sampledRotation = zeros(3,3,sampledTimeSize);
for i = 1:sampledTimeSize
    rx = tOxtsRawDataOrientationPitch(i); % pitch
    ry = tOxtsRawDataOrientationRoll(i); % roll
    rz = tOxtsRawDataOrientationYaw(i); % heading
    Rx = [1        0       0;
        0  cos(rx) sin(rx);
        0 -sin(rx) cos(rx)];
    Ry = [cos(ry) 0 -sin(ry);
        0 1 0;
        sin(ry) 0 cos(ry)];
    Rz = [cos(rz) sin(rz) 0;
        -sin(rz) cos(rz) 0;
        0 0 1];
    R = Ry*Rx*Rz;
    sampledRotation(1:3,1:3,i) = R';
end

sampledQuaternion = quaternion(sampledRotation,'rotmat','frame');

tTimeHead = ceil(tOxtsRawDataTime(1));
tTimeTail = floor(tOxtsRawDataTime(end));
resampledTime = (tTimeHead:1:tTimeTail)';
resampledTimeSize = size(resampledTime,1);
resampledTimeMapInterpolationSection = zeros(resampledTimeSize,7);
resampledTimeMapInterpolationSection(:,1) = resampledTime;
for i = 1:resampledTimeSize
    resampledTimeMapSectionLowerBound = resampledTime(i,1)>sampledTimeSection(:,1);
    resampledTimeMapSectionUpperBound = resampledTime(i,1)<=sampledTimeSection(:,2);
    resampledTimeMapSectionBoundIndex = resampledTimeMapSectionLowerBound == resampledTimeMapSectionUpperBound;
    resampledTimeMapInterpolationSection(i,2) = find(resampledTimeMapSectionBoundIndex == 1);
    resampledTimeMapInterpolationSection(i,3:4) = sampledTimeSection(resampledTimeMapSectionBoundIndex,1:2);
end
resampledTimeMapInterpolationSection(:,5) = resampledTimeMapInterpolationSection(:,1) - resampledTimeMapInterpolationSection(:,3);
resampledTimeMapInterpolationSection(:,6) = resampledTimeMapInterpolationSection(:,4) - resampledTimeMapInterpolationSection(:,3);
resampledTimeMapInterpolationSection(:,7) = resampledTimeMapInterpolationSection(:,5) ./ resampledTimeMapInterpolationSection(:,6);

interpolationSectionLowerBoundIndex = resampledTimeMapInterpolationSection(:,2);
interpolationSectionUpperBoundIndex = interpolationSectionLowerBoundIndex + 1;
interpolationQuaternion1 = sampledQuaternion(interpolationSectionLowerBoundIndex,1);
interpolationQuaternion2 = sampledQuaternion(interpolationSectionUpperBoundIndex,1);
interpolationCoefficient = resampledTimeMapInterpolationSection(i,7);
interpolationQuaternion = slerp(interpolationQuaternion1,interpolationQuaternion2,interpolationCoefficient);
interpolationRotationMatrix = rotmat(interpolationQuaternion,'frame');

interpolationRotationMatrixFlat = convertOrientationRotationMatrixToFlat(interpolationRotationMatrix);
oxtsRawInterpOrientation = [resampledTime,interpolationRotationMatrixFlat];

save(cOxtsRowDataInterpOrientationMatFilePath,'oxtsRawInterpOrientation');
