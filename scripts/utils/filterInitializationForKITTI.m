function [filterInitialState] = filterInitializationForKITTI(folderPath)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

cGTOrientationFileName = 'GTOrientation.csv';
cGTNavVelocityFileName = 'GTNavVelocity.csv';

tGTOrientationFilePath = fullfile(folderPath,cGTOrientationFileName);
tGroundTruthOrientationRaw = readmatrix(tGTOrientationFilePath);
tGroundTruthOrientationFlat = tGroundTruthOrientationRaw(:,2:10);
tGroundTruthOrientation = convertOrientationFlatToRotationMatrix(tGroundTruthOrientationFlat);

tGroundTruthNavVelocityFilePath = fullfile(folderPath,cGTNavVelocityFileName);
tGroundTruthNavVelocityRaw = readmatrix(tGroundTruthNavVelocityFilePath);
tGroundTruthNavVelocity = tGroundTruthNavVelocityRaw(:,2:4);

filterInitialState = cell(1,9);
filterInitialRotationMatrixFromImuToNav = tGroundTruthOrientation(:,:,1);
filterInitialState{1,1} = filterInitialRotationMatrixFromImuToNav;
filterInitialState{1,2} = tGroundTruthNavVelocity(1,:);
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
filterInitulFromCarToImuDeg = [0 0 0];
filterInitulFromCarToImuRad = deg2rad(filterInitulFromCarToImuDeg);
filterInitulRotationMatrixFromCarToImu = eul2rotm(filterInitulFromCarToImuRad,'XYZ');
filterInitialState{1,6} = filterInitulRotationMatrixFromCarToImu;
filterInitialState{1,7} = [0 0 0];

filterInitPSOBracket3XFromImuToNav = 1e-3;
filterInitPSOBracket3YFromImuToNav = 1e-3;
filterInitPSOBracket3ZFromImuToNav = 1e-3;
filterInitPVelocityX = 0.3;
filterInitPVelocityY = 0.3;
filterInitPVelocityZ = 0.3;
filterInitPPosition = 0;
filterInitPAngularSpeedBiasX = 1.0e-4;
filterInitPAngularSpeedBiasY = 1.0e-4;
filterInitPAngularSpeedBiasZ = 1.0e-4;
filterInitPAccelerationBiasX = 3.0e-2;
filterInitPAccelerationBiasY = 3.0e-2;
filterInitPAccelerationBiasZ = 3.0e-2;
filterInitPSOBracket3FromImuToCar = 3.0e-3;
filterInitTranslationFromImuToCar = 1.0e-1;
filterInitP(1:3,1:3) = diag([filterInitPSOBracket3XFromImuToNav filterInitPSOBracket3YFromImuToNav filterInitPSOBracket3ZFromImuToNav]);
filterInitP(4:6,4:6) = diag([filterInitPVelocityX filterInitPVelocityY filterInitPVelocityZ]);
filterInitP(7:9,7:9) = eye(3) * filterInitPPosition;
filterInitP(10:12,10:12) = diag([filterInitPAngularSpeedBiasX filterInitPAngularSpeedBiasY filterInitPAngularSpeedBiasZ]);
filterInitP(13:15,13:15) = diag([filterInitPAccelerationBiasX filterInitPAccelerationBiasY filterInitPAccelerationBiasZ]);
filterInitP(16:18,16:18) = eye(3) * filterInitPSOBracket3FromImuToCar;
filterInitP(19:21,19:21) = eye(3) * filterInitTranslationFromImuToCar;
filterInitialState{1,8} = filterInitP;


filterInitQ = zeros(18);
cNoiseAngularSpeedCovariance = 1.4e-2;
cNoiseAccelerometerCovariance = 3e-2;
cNoiseAngularSpeedBiasCovariance = 1e-4;
cNoiseAccelerometerBiasCovariance = 1e-3;
cNoiseSOBracket3FromImuToCar = 1e-4;
cNoiseTransitionFromImuToCar = 1e-4;
filterInitQ(1:3,1:3) = eye(3) * cNoiseAngularSpeedCovariance;
filterInitQ(4:6,4:6) = eye(3) * cNoiseAccelerometerCovariance;
filterInitQ(7:9,7:9) = eye(3) * cNoiseAngularSpeedBiasCovariance;
filterInitQ(10:12,10:12) = eye(3) * cNoiseAccelerometerBiasCovariance;
filterInitQ(13:15,13:15) = eye(3) * cNoiseSOBracket3FromImuToCar;
filterInitQ(16:18,16:18) = eye(3) * cNoiseTransitionFromImuToCar;
filterInitialState{1,9} = filterInitQ;