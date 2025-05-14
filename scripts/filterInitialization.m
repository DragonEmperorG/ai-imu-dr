function [filterInitialState] = filterInitialization(folderPath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
% cTraceInfoFileName = 'info.json';
% tTraceInfoFilePath = fullfile(folderPath,cTraceInfoFileName);
% tTraceInfoFileFid = fopen(tTraceInfoFilePath); 
% tTraceInfoFileRaw = fread(tTraceInfoFileFid,inf); 
% tTraceInfoFileStr = char(tTraceInfoFileRaw'); 
% fclose(tTraceInfoFileFid); 
% tTraceInfo = jsondecode(tTraceInfoFileStr);
% 
% tCoordinateTransformImuToTangleQuaternion = (tTraceInfo.start_calibration)';
% tCoordinateTransformImuToTangleRotm = quat2rotm(tCoordinateTransformImuToTangleQuaternion);
% tCoordinateTransformImuToTangleEulerAngleRad = rotm2eul(tCoordinateTransformImuToTangleRotm,'XYZ');
% tCoordinateTransformImuToTangleEulerAngleDeg = rad2deg(tCoordinateTransformImuToTangleEulerAngleRad);
% 
% tCoordinateTransformTangleToBodyQuaternion = (tTraceInfo.align_tango_to_body)';
% tCoordinateTransformTangleToBodyRotm = quat2rotm(tCoordinateTransformTangleToBodyQuaternion);
% tCoordinateTransformTangleToBodyEulerAngleRad = rotm2eul(tCoordinateTransformTangleToBodyRotm,'XYZ');
% tCoordinateTransformTangleToBodyEulerAngleDeg = rad2deg(tCoordinateTransformTangleToBodyEulerAngleRad);

cGroundTruthImuOrientationFileName = 'gt_imu_ori.csv';
cGroundTruthBodyOrientationFileName = 'gt_body_ori.csv';
cGroundTruthTangleVelocityFileName = 'gt_tangle_vel.csv';

% 加载数据
tGroundTruthImuOrientationFilePath = fullfile(folderPath,cGroundTruthImuOrientationFileName);
tGroundTruthImuOrientationQuaternionData = readmatrix(tGroundTruthImuOrientationFilePath);

tGroundTruthBodyOrientationFilePath = fullfile(folderPath,cGroundTruthBodyOrientationFileName);
tGroundTruthBodyOrientationQuaternionData = readmatrix(tGroundTruthBodyOrientationFilePath);

tGroundTruthTangleVelocityFilePath = fullfile(folderPath,cGroundTruthTangleVelocityFileName);
tGroundTruthTangleVelocityData = readmatrix(tGroundTruthTangleVelocityFilePath);

% 解析数据
tGroundTruthImuOrientationRotm = quat2rotm(tGroundTruthImuOrientationQuaternionData);
tGroundTruthImuOrientationEulerAngleRad = rotm2eul(tGroundTruthImuOrientationRotm,'XYZ');
tGroundTruthImuOrientationEulerAngleDeg = rad2deg(tGroundTruthImuOrientationEulerAngleRad);

tGroundTruthBodyOrientationRotm = quat2rotm(tGroundTruthBodyOrientationQuaternionData);
tGroundTruthBodyOrientationEulerAngleRad = rotm2eul(tGroundTruthBodyOrientationRotm,'XYZ');
tGroundTruthBodyOrientationEulerAngleDeg = rad2deg(tGroundTruthBodyOrientationEulerAngleRad);

tCoordinateTransformImuToBodyRotm = pagemtimes(tGroundTruthBodyOrientationRotm,'transpose',tGroundTruthImuOrientationRotm,'none');
tCoordinateTransformImuToBodyEulerAngleRad = rotm2eul(tCoordinateTransformImuToBodyRotm,'XYZ');
tCoordinateTransformImuToBodyEulerAngleDeg = rad2deg(tCoordinateTransformImuToBodyEulerAngleRad);

filterInitialState = cell(1,9);
filterInitialRotationMatrixFromImuToNav = tGroundTruthImuOrientationRotm(:,:,1);
filterInitialState{1,1} = filterInitialRotationMatrixFromImuToNav;
filterInitialState{1,2} = [0 0 0];
filterInitialState{1,3} = [0 0 0];

filterInitialImuGyroscopeBiasX = 0;
filterInitialImuGyroscopeBiasY = 0;
filterInitialImuGyroscopeBiasZ = 0;
filterInitialState{1,4} = [filterInitialImuGyroscopeBiasX filterInitialImuGyroscopeBiasY filterInitialImuGyroscopeBiasZ];

filterInitialImuAccelerometerBiasX = 0;
filterInitialImuAccelerometerBiasY = 0;
filterInitialImuAccelerometerBiasZ = 0;
filterInitialState{1,5} = [filterInitialImuAccelerometerBiasX filterInitialImuAccelerometerBiasY filterInitialImuAccelerometerBiasZ];

% https://ww2.mathworks.0cn/matlabcentral/answers/436980-difference-between-angle2dcm-and-eul2rotm-same-angle-sequence-different-result
filterInitulRotationMatrixFromImuToBody = tCoordinateTransformImuToBodyRotm(:,:,1);
filterInitialState{1,6} = filterInitulRotationMatrixFromImuToBody;
filterInitialState{1,7} = [0 0 0];

filterInitPSOBracket3XFromImuToNav = 1e-2;
filterInitPSOBracket3YFromImuToNav = 1e-2;
filterInitPSOBracket3ZFromImuToNav = 1e-2;
filterInitPVelocityX = 0;
filterInitPVelocityY = 0;
filterInitPVelocityZ = 0;
filterInitPPosition = 0;
filterInitPAngularSpeedBiasX = 5.0e-6;
filterInitPAngularSpeedBiasY = 5.0e-6;
filterInitPAngularSpeedBiasZ = 5.0e-6;
filterInitPAccelerationBiasX = 1.6e-5;
filterInitPAccelerationBiasY = 1.6e-5;
filterInitPAccelerationBiasZ = 1.6e-5;
filterInitPSOBracket3FromImuToCar = 2e-4;
filterInitTranslationFromImuToCar = 2e-1;
filterInitP(1:3,1:3) = diag([filterInitPSOBracket3XFromImuToNav filterInitPSOBracket3YFromImuToNav filterInitPSOBracket3ZFromImuToNav]);
filterInitP(4:6,4:6) = diag([filterInitPVelocityX filterInitPVelocityY filterInitPVelocityZ]);
filterInitP(7:9,7:9) = eye(3) * filterInitPPosition;
filterInitP(10:12,10:12) = diag([filterInitPAngularSpeedBiasX filterInitPAngularSpeedBiasY filterInitPAngularSpeedBiasZ]);
filterInitP(13:15,13:15) = diag([filterInitPAccelerationBiasX filterInitPAccelerationBiasY filterInitPAccelerationBiasZ]);
filterInitP(16:18,16:18) = eye(3) * filterInitPSOBracket3FromImuToCar;
filterInitP(19:21,19:21) = eye(3) * filterInitTranslationFromImuToCar;
filterInitialState{1,8} = filterInitP;


filterInitQ = zeros(18);
cNoiseAngularSpeedCovariance = 1e-3;
cNoiseAccelerometerCovariance = 1e-3;
cNoiseAngularSpeedBiasCovariance = 1e-5;
cNoiseAccelerometerBiasCovariance = 1e-4;
cNoiseSOBracket3FromImuToCar = 1e-1;
cNoiseTransitionFromImuToCar = 1e-1;
filterInitQ(1:3,1:3) = eye(3) * cNoiseAngularSpeedCovariance;
filterInitQ(4:6,4:6) = eye(3) * cNoiseAccelerometerCovariance;
filterInitQ(7:9,7:9) = eye(3) * cNoiseAngularSpeedBiasCovariance;
filterInitQ(10:12,10:12) = eye(3) * cNoiseAccelerometerBiasCovariance;
filterInitQ(13:15,13:15) = eye(3) * cNoiseSOBracket3FromImuToCar;
filterInitQ(16:18,16:18) = eye(3) * cNoiseTransitionFromImuToCar;
filterInitialState{1,9} = filterInitQ;