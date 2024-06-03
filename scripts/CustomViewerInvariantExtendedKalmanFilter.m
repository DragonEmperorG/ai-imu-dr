% 重置工作区环境
clearvars;
close all;
dbstop error;
% clc;

% 添加自定义工具类函数
addpath(genpath(pwd));
TAG = 'CustomViewerInvariantExtendedKalmanFilter';

SCRIPT_MODE = 0;

% TODO: S1.1: 模型输入预处理文件夹 根目录
% cDatasetFolderPath = 'C:\DoctorRelated\20230410重庆VDR数据采集';
cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集';
% TODO: S1.2: 模型输入预处理文件夹 采集日期
cDatasetCollectionDateFolderName = '2023_04_10';
% cDatasetCollectionDateFolderName = '2023_04_11';
% cDatasetCollectionDateFolderName = '2023_04_13';
% cDatasetCollectionDateFolderName = '2023_04_15';
ccDatasetCollectionDateFolderPath = fullfile(cDatasetFolderPath,cDatasetCollectionDateFolderName);
% 配置预处理根文件夹路径
cReorganizedFolderName = 'Reorganized';
cReorganizedFolderPath = fullfile(ccDatasetCollectionDateFolderPath,cReorganizedFolderName);
% TODO: S1.3: 模型输入预处理文件夹 采集轨迹编号
% cPreprocessTrackFolderName = '0002';
% cPreprocessTrackFolderName = '0003';
% cPreprocessTrackFolderName = '0004';
% cPreprocessTrackFolderName = '0005';
% cPreprocessTrackFolderName = '0006';
% cPreprocessTrackFolderName = '0007';
cPreprocessTrackFolderName = '0008';
% cPreprocessTrackFolderName = '0009';
% cPreprocessTrackFolderName = '0010';
% cPreprocessTrackFolderName = '0011';
% cPreprocessTrackFolderName = '0012';
% cPreprocessTrackFolderName = '0013';
% cPreprocessTrackFolderName = '0014';
% cPreprocessTrackFolderName = '0015';
% cPreprocessTrackFolderName = '0016';
% cPreprocessTrackFolderName = '0017';
% cPreprocessTrackFolderName = '0018';
% cPreprocessTrackFolderName = '0019';
% cPreprocessTrackFolderName = '0020';
% cPreprocessTrackFolderName = '0021';
% cPreprocessTrackFolderName = '0022';
% cPreprocessTrackFolderName = '0023';
cPreprocessTrackFolderPath = fullfile(cReorganizedFolderPath,cPreprocessTrackFolderName);
% TODO: S1.4: 模型输入预处理文件夹 采集手机
% cPreprocessPhoneFolderName = 'GOOGLE_Pixel3';
cPreprocessPhoneFolderName = 'HUAWEI_Mate30';
% cPreprocessPhoneFolderName = 'HUAWEI_P20';
cPreprocessPhoneFolderPath = fullfile(cPreprocessTrackFolderPath,cPreprocessPhoneFolderName);
% 配置预处理模型输入文件夹路径
cDayZeroOClockAlignFolderName = 'dayZeroOClockAlign';
cDayZeroOClockAlignFolderPath = fullfile(cPreprocessPhoneFolderPath,cDayZeroOClockAlignFolderName);

% 配置预处理模型输入内部文件名
cTrainDatasetFolderPath = cDayZeroOClockAlignFolderPath;
cTrainFileName = 'TrackSynchronized.mat';
cTrainFilePath = fullfile(cTrainDatasetFolderPath,cTrainFileName);
if ~isfile(cTrainFilePath)
    cTrainFileNameSplit = strsplit(cTrainFileName,'.');
    cTrainCsvFileName = strcat(cTrainFileNameSplit{1},'.csv');
    cTrainCsvFilePath = fullfile(cTrainDatasetFolderPath,cTrainCsvFileName);
    trainRawData = readmatrix(cTrainCsvFilePath);
    trainRawDataSize = size(trainRawData,1);
    trackSynchronizedData = cell(trainRawDataSize,5);
    for i = 1:trainRawDataSize
        trackSynchronizedData{i,1} = trainRawData(i,1);
        groundTruthPoseRotationMatrixArray = trainRawData(i,14:22);
        groundTruthPoseRotationMatrix = zeros(3,3);
        groundTruthPoseRotationMatrix(1,1:3) = groundTruthPoseRotationMatrixArray(1:3);
        groundTruthPoseRotationMatrix(2,1:3) = groundTruthPoseRotationMatrixArray(4:6);
        groundTruthPoseRotationMatrix(3,1:3) = groundTruthPoseRotationMatrixArray(7:9);
        groundTruthPosePosition = trainRawData(i,23:25)';
        trackSynchronizedData{i,2} = SE3(groundTruthPoseRotationMatrix,groundTruthPosePosition).double;
        trackSynchronizedData{i,3} = trainRawData(i,26:28);
        trackSynchronizedData{i,4} = trainRawData(i,2:4);
        trackSynchronizedData{i,5} = trainRawData(i,5:7);
%         trackSynchronizedData{i,4} = trainRawData(i,8:10);
%         trackSynchronizedData{i,5} = trainRawData(i,11:13);
    end

    save(cTrainFilePath,"trackSynchronizedData");
else
    load(cTrainFilePath);
end

trackSynchronizedDataTime = cell2mat(trackSynchronizedData(:,1));

spanResampledRawData = trackSynchronizedData;
cCarCoordinateType = 'RFU';

% TODO: S2.1: 自动加载基于深度学习的自适应参数
cDeepLearnedCovarianceAvailable = false;
cDeepLearnedCovarianceUse = true;
cDeepLearnedCovarianceTxtFileName = 'DeepLearnedCovariance.txt';
cDeepLearnedCovarianceFilePath = fullfile(cTrainDatasetFolderPath,cDeepLearnedCovarianceTxtFileName);
if isfile(cDeepLearnedCovarianceFilePath)
    cDeepLearnedCovarianceAvailable = true;

    cDeepLearnedCovarianceFileNameSplit = strsplit(cDeepLearnedCovarianceTxtFileName,'.');
    cDeepLearnedCovarianceMatFileName = strcat(cDeepLearnedCovarianceFileNameSplit{1},'.mat');
    cDeepLearnedCovarianceMatFilePath = fullfile(cTrainDatasetFolderPath,cDeepLearnedCovarianceMatFileName);
    if ~isfile(cDeepLearnedCovarianceMatFilePath)
        cDeepLearnedCovariance = readmatrix(cDeepLearnedCovarianceFilePath);
        save(cDeepLearnedCovarianceMatFilePath,"cDeepLearnedCovariance");
    else
        load(cDeepLearnedCovarianceMatFilePath);
    end

    cDeepLearnedCovarianceCell = num2cell(cDeepLearnedCovariance);
    spanResampledRawData = [trackSynchronizedData cDeepLearnedCovarianceCell];
end


% cOxtslitePoseMatFilePath = 'E:\GitHubRepositories\KITTI\raw_data\2011_09_30\2011_09_30_drive_0027_extract\oxts\pose.mat';
% load(cOxtslitePoseMatFilePath);
% spanResampledData = tOxtslitePose;
% cCarCoordinateType = 'FRU';

spanResampledRawDataSize = size(spanResampledRawData,1);

% plotIndex = 1:spanResampledDataSize;
% plotIndex = 1:10000;
% measurementGyroscope = cell2mat(spanResampledData(plotIndex,4));
% measurementAccelerometer = cell2mat(spanResampledData(plotIndex,5));
% measurement = horzcat(measurementGyroscope,measurementAccelerometer);

% headBiasEstimationIndex = 1:7000;
% headBiasEstimation = mean(measurement(headBiasEstimationIndex,:),1);
% tailBiasEstimationIndex = 24200:spanResampledDataSize;
% tailBiasEstimation = mean(measurement(tailBiasEstimationIndex,:),1);
% headtailBiasEstimation = vertcat(headBiasEstimation,tailBiasEstimation);

spanResampledData = spanResampledRawData(1:spanResampledRawDataSize,:);
% spanResampledData = spanResampledRawData(1:12000,:);
% spanResampledData = spanResampledRawData(10000:12000,:);

% spanResampledData = spanResampledRawData(11187:15187,:);
% spanResampledData = spanResampledRawData(12187:15187,:);

% spanResampledData = spanResampledRawData(2385:spanResampledRawDataSize,:);
% spanResampledData = spanResampledRawData(1186:spanResampledRawDataSize,:);
% spanResampledData = spanResampledRawData(9000:10000,:);
spanResampledDataSize = size(spanResampledData,1);

% plotSEPose(spanResampledData(:,2),100);
% plotSEPose(spanResampledData(3000:6000,2));

plotIndex = 1:spanResampledDataSize;
plotSEPose(spanResampledData(plotIndex,2),100);
plotSESubscript4Bracket3Pose(spanResampledData(plotIndex,1),spanResampledData(plotIndex,2),spanResampledData(plotIndex,3),spanResampledData(plotIndex,4),spanResampledData(plotIndex,5));


GRAVITY = [0 0 -9.80655]';
SKEW_GRAVITY = skew(GRAVITY);

ROTATION_FROM_IMU_TO_CAR = [ 1 0  0;
    0 1 0;
    0  0 1];
% plotImuCarPoseRelation(ROTATION_FROM_IMU_TO_CAR);

ViridisColerPalette06 = ["#fde725" "#7ad151" "#22a884" "#2a788e" "#414487" "#440154"];

% FILTER INTERMEDIATE STATE
FIS_TIME_SAVE_INDEX = 1;
FIS_SEBRACKET3_SAVE_INDEX = 2;
FIS_SOBRACKET3_FROM_IMU_TO_NAV_SAVE_INDEX = 3;
FIS_VELOCITY_IN_NAV_SAVE_INDEX = 4;
FIS_POSITION_INDEX = 5;
FIS_ANGULAR_SPEED_SAVE_INDEX = 6;
FIS_ANGULAR_SPEED_BIAS_SAVE_INDEX = 7;
FIS_ACCELERATION_SAVE_INDEX = 8;
FIS_ACCELERATION_BIAS_SAVE_INDEX = 9;
FIS_SOBRACKET3_FROM_IMU_TO_CAR_SAVE_INDEX = 10;
FIS_TRANSLATION_FROM_IMU_TO_CAR_SAVE_INDEX = 11;
FIS_P_SAVE_INDEX = 12;
FIS_Q_SAVE_INDEX = 13;
FIS_F_SAVE_INDEX = 14;
FIS_G_SAVE_INDEX = 15;

kSampleRateList = [1 50 100 200 250 500];
dataSampleInterval = mean(diff(cell2mat(spanResampledData(:,1))));
dataSampleRate = 1 / dataSampleInterval;
dsearchnK = dsearchn(kSampleRateList',dataSampleRate);
cSampleRate = kSampleRateList(dsearchnK);
cLogSampleCountInterval = 5 * cSampleRate;

filterIntermediateState = cell(spanResampledDataSize,4);
filterIntermediateState{1,FIS_TIME_SAVE_INDEX} = spanResampledData{1,1};
filterIntermediateState{1,FIS_SEBRACKET3_SAVE_INDEX} = spanResampledData{1,2};
filterIntermediateState{1,FIS_SOBRACKET3_FROM_IMU_TO_NAV_SAVE_INDEX} = spanResampledData{1,2}(1:3,1:3) * ROTATION_FROM_IMU_TO_CAR;
filterIntermediateState{1,FIS_VELOCITY_IN_NAV_SAVE_INDEX} = spanResampledData{1,3};
filterIntermediateState{1,FIS_POSITION_INDEX} = (spanResampledData{1,2}(1:3,4))';
filterIntermediateState{1,FIS_ANGULAR_SPEED_SAVE_INDEX} = spanResampledData{1,4};

filterIntermediateState{1,FIS_ANGULAR_SPEED_BIAS_SAVE_INDEX} = zeros(1,3);
% filterIntermediateState{1,FIS_ANGULAR_SPEED_BIAS_SAVE_INDEX} = (headBiasEstimation(1:3));

filterIntermediateState{1,FIS_ACCELERATION_SAVE_INDEX} = spanResampledData{1,5};

filterIntermediateState{1,FIS_ACCELERATION_BIAS_SAVE_INDEX} = zeros(1,3);
% filterIntermediateState{1,FIS_ACCELERATION_BIAS_SAVE_INDEX} = (headBiasEstimation(4:6) + GRAVITY');

filterIntermediateState{1,FIS_SOBRACKET3_FROM_IMU_TO_CAR_SAVE_INDEX} = ROTATION_FROM_IMU_TO_CAR;
filterIntermediateState{1,FIS_TRANSLATION_FROM_IMU_TO_CAR_SAVE_INDEX} = [0 0 0];


filterInitP = zeros(21);
filterPSize = size(filterInitP,1);

% TODO: S2.2: 自动加载基于深度学习的自适应参数
filterInitPSOBracket3XFromCarToNav = 1e-6;
filterInitPSOBracket3YFromCarToNav = 1e-6;
filterInitPSOBracket3ZFromCarToNav = 0;
filterInitPVelocityX = 1e-1;
filterInitPVelocityY = 1e-1;
filterInitPVelocityZ = 0;
filterInitPPosition = 0;
filterInitPAngularSpeedBias = 1e-8;
filterInitPAccelerationBias = 1e-3;
filterInitPSOBracket3FromImuToCar = 1e-5;
filterInitTranslationFromImuToCar = 1e-2;
cDeepLearnedInitStateCovarianceFactorTxtFileName = 'DeepLearnedInitStateCovarianceFactor.txt';
cDeepLearnedInitStateCovarianceFactorTxtFilePath = fullfile(cTrainDatasetFolderPath,cDeepLearnedInitStateCovarianceFactorTxtFileName);
if isfile(cDeepLearnedInitStateCovarianceFactorTxtFilePath)
    deepLearnedInitStateCovarianceFactor = readmatrix(cDeepLearnedInitStateCovarianceFactorTxtFilePath);
    filterInitPSOBracket3XFromCarToNav = filterInitPSOBracket3XFromCarToNav * deepLearnedInitStateCovarianceFactor(1);
    filterInitPSOBracket3YFromCarToNav = filterInitPSOBracket3YFromCarToNav * deepLearnedInitStateCovarianceFactor(1);
    filterInitPVelocityX = filterInitPVelocityX * deepLearnedInitStateCovarianceFactor(2);
    filterInitPVelocityY = filterInitPVelocityY * deepLearnedInitStateCovarianceFactor(2);
    filterInitPAngularSpeedBias = filterInitPAngularSpeedBias * deepLearnedInitStateCovarianceFactor(3);
    filterInitPAccelerationBias = filterInitPAccelerationBias * deepLearnedInitStateCovarianceFactor(4);
    filterInitPSOBracket3FromImuToCar = filterInitPSOBracket3FromImuToCar * deepLearnedInitStateCovarianceFactor(5);
    filterInitTranslationFromImuToCar = filterInitTranslationFromImuToCar * deepLearnedInitStateCovarianceFactor(6);
end
filterInitP(1:3,1:3) = diag([filterInitPSOBracket3XFromCarToNav filterInitPSOBracket3YFromCarToNav filterInitPSOBracket3ZFromCarToNav]);
filterInitP(4:6,4:6) = diag([filterInitPVelocityX filterInitPVelocityY filterInitPVelocityZ]);
filterInitP(7:9,7:9) = eye(3) * filterInitPPosition;
filterInitP(10:12,10:12) = eye(3) * filterInitPAngularSpeedBias;
filterInitP(13:15,13:15) = eye(3) * filterInitPAccelerationBias;
filterInitP(16:18,16:18) = eye(3) * filterInitPSOBracket3FromImuToCar;
filterInitP(19:21,19:21) = eye(3) * filterInitTranslationFromImuToCar;
filterIntermediateState{1,FIS_P_SAVE_INDEX} = filterInitP;

filterInitQ = zeros(18);
filterQSize = size(filterInitQ,1);

% TODO: S2.3: 自动加载基于深度学习的自适应参数
cNoiseAngularSpeedCovariance = 2e-4;
cNoiseAccelerometerCovariance = 1e-3;
cNoiseAngularSpeedBiasCovariance = 1e-8;
cNoiseAccelerometerBiasCovariance = 1e-6;
cNoiseSOBracket3FromImuToCar = 1e-8;
cNoiseTransitionFromImuToCar = 1e-8;
cDeepLearnedQCovarianceFactorTxtFileName = 'DeepLearnedQCovarianceFactor.txt';
cDeepLearnedQCovarianceFactorTxtFilePath = fullfile(cTrainDatasetFolderPath,cDeepLearnedQCovarianceFactorTxtFileName);
if isfile(cDeepLearnedQCovarianceFactorTxtFilePath)
    deepLearnedQCovarianceFactor = readmatrix(cDeepLearnedQCovarianceFactorTxtFilePath);
    cNoiseAngularSpeedCovariance = cNoiseAngularSpeedCovariance * deepLearnedQCovarianceFactor(1);
    cNoiseAccelerometerCovariance = cNoiseAccelerometerCovariance * deepLearnedQCovarianceFactor(2);
    cNoiseAngularSpeedBiasCovariance = cNoiseAngularSpeedBiasCovariance * deepLearnedQCovarianceFactor(3);
    cNoiseAccelerometerBiasCovariance = cNoiseAccelerometerBiasCovariance * deepLearnedQCovarianceFactor(4);
    cNoiseSOBracket3FromImuToCar = cNoiseSOBracket3FromImuToCar * deepLearnedQCovarianceFactor(5);
    cNoiseTransitionFromImuToCar = cNoiseTransitionFromImuToCar * deepLearnedQCovarianceFactor(6);
end
filterInitQ(1:3,1:3) = eye(3) * cNoiseAngularSpeedCovariance;
filterInitQ(4:6,4:6) = eye(3) * cNoiseAccelerometerCovariance;
filterInitQ(7:9,7:9) = eye(3) * cNoiseAngularSpeedBiasCovariance;
filterInitQ(10:12,10:12) = eye(3) * cNoiseAccelerometerBiasCovariance;
filterInitQ(13:15,13:15) = eye(3) * cNoiseSOBracket3FromImuToCar;
filterInitQ(16:18,16:18) = eye(3) * cNoiseTransitionFromImuToCar;
filterIntermediateState{1,FIS_Q_SAVE_INDEX} = filterInitQ;

% TODO: S2.4: 
cDeepOdoFolderName = 'DATASET_DEEPODO';
cDeepOdoPredictFileName = 'DeepOdoPredictData.txt';
cDeepOdoPredictFilePath = fullfile(cPreprocessPhoneFolderPath,cDeepOdoFolderName,cDeepOdoPredictFileName);
if isfile(cDeepOdoPredictFilePath)
    dataDeepOdoPredictForwardVelocity = readmatrix(cDeepOdoPredictFilePath);
    trackSynchronizedDataTimeStartCeil = ceil(trackSynchronizedDataTime(1));
    trackSynchronizedDataTimeEndFloor = floor(trackSynchronizedDataTime(end));
    dataDeepOdoPredictTime = (trackSynchronizedDataTimeStartCeil:trackSynchronizedDataTimeEndFloor)';
    dataDeepOdoPredict = horzcat(dataDeepOdoPredictTime,dataDeepOdoPredictForwardVelocity);
end

if SCRIPT_MODE == 0

    figure;
    hold on;
    grid on;
    transitionStatistic = zeros(spanResampledDataSize,3);
    for i =1:spanResampledDataSize
        transitionStatistic(i,1:3) = (spanResampledData{i,2}(1:3,4))';
    end
    axisXLimMin = min(transitionStatistic(:,1));
    axisXLimMax = max(transitionStatistic(:,1));
    axisXLimDelta = axisXLimMax - axisXLimMin;
    axisYLimMin = min(transitionStatistic(:,2));
    axisYLimMax = max(transitionStatistic(:,2));
    axisYLimDelta = axisYLimMax - axisYLimMin;
    axisZLimMin = min(transitionStatistic(:,3));
    axisZLimMax = max(transitionStatistic(:,3));
    axisZLimDelta = axisZLimMax - axisZLimMin;
    if axisXLimDelta >= axisYLimDelta
        compensationH = axisXLimDelta - axisYLimDelta;
        compensationHHalf = compensationH * 0.5;
        compensationV = axisXLimDelta - axisZLimDelta;
        compensationVHalf = compensationV * 0.5;
        axis([axisXLimMin axisXLimMax axisYLimMin-compensationHHalf axisYLimMax+compensationHHalf axisZLimMin-compensationVHalf axisZLimMax+compensationVHalf]);
    else
        compensationH = axisYLimDelta - axisXLimDelta;
        compensationHHalf = compensationH * 0.5;
        compensationV = axisYLimDelta - axisZLimDelta;
        compensationVHalf = compensationV * 0.5;
        axis([axisXLimMin-compensationHHalf axisXLimMax+compensationHHalf axisYLimMin axisYLimMax axisZLimMin-compensationVHalf axisZLimMax+compensationVHalf]);
    end
    daspect([1 1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    pAxisLineWidth = 1;

    % 吉利 新豪越 
    % 轴距 2.815 m
    cCarCoordinateAxisDisplayTimeInterval = 1;
    cCarCoordinateAxisSampleCountInterval = cCarCoordinateAxisDisplayTimeInterval * cSampleRate;
    pCarXLength = 1.900;
    pCarYLength = 4.835;
    pCarZLength = 1.780;
    pCarCoordinateAxisScale = 0.5;
    pCarCoordinateAxisXLineLength = pCarXLength * pCarCoordinateAxisScale;
    pCarCoordinateAxisYLineLength = pCarYLength * pCarCoordinateAxisScale;
    pCarCoordinateAxisZLineLength = pCarZLength * pCarCoordinateAxisScale;
    pCarCoordinateAxisArrowWidth = min([pCarCoordinateAxisXLineLength pCarCoordinateAxisYLineLength pCarCoordinateAxisZLineLength]) * 1e-1;

    % KITTI
%     cCarCoordinateAxisDisplayTimeInterval = 1;
%     cCarCoordinateAxisSampleCountInterval = cCarCoordinateAxisDisplayTimeInterval * cSampleRate;
%     pCarCoordinateAxisXLineLength = 4.835;
%     pCarCoordinateAxisYLineLength = 1.900;
%     pCarCoordinateAxisZLineLength = 1.780;
%     pCarCoordinateAxisArrowWidth = 0.05;

    % Config for car coordinate
    cCarStateVelocityDisplayTimeInterval = 0.5;
    cCarStateVelocitySampleCountInterval = cCarStateVelocityDisplayTimeInterval * cSampleRate;
    pCarStateVelocityLineLengthRatio = 0.5;
    pCarStateVelocityLineWidth = 1;

    pImuCoordinateAxisLineLength = 0.5;
    pImuCoordinateAxisArrowWidth = 0.1;

    pImuStateAccelerometerLineLength = 2;
    pImuStateAccelerometerLineWidth = 3;



end


for i =2:spanResampledDataSize

    filterTimestamp = spanResampledData{i,1};

    filterIntermediateState{i,FIS_TIME_SAVE_INDEX} = spanResampledData{i,1};
    dt = filterIntermediateState{i,FIS_TIME_SAVE_INDEX} - filterIntermediateState{i-1,FIS_TIME_SAVE_INDEX};
    dtdt = dt * dt;

    filterIntermediateState{i,FIS_ANGULAR_SPEED_SAVE_INDEX} = spanResampledData{i,4};
    filterIntermediateState{i,FIS_ACCELERATION_SAVE_INDEX} = spanResampledData{i,5};

    %     cAcceleration = ROTATION_FROM_IMU_TO_CAR * (spanResampledData{i-1,5})';
    %     cGyroscope = ROTATION_FROM_IMU_TO_CAR * (spanResampledData{i-1,4})';

    observationAngulerSpeed = (filterIntermediateState{i-1,FIS_ANGULAR_SPEED_SAVE_INDEX})';
    observationAcceleration = (filterIntermediateState{i-1,FIS_ACCELERATION_SAVE_INDEX})';
    % observationAngulerSpeed = (filterIntermediateState{i,FIS_ANGULAR_SPEED_SAVE_INDEX})';
    % observationAcceleration = (filterIntermediateState{i,FIS_ACCELERATION_SAVE_INDEX})';


    filterState1Rotation = filterIntermediateState{i-1,FIS_SOBRACKET3_FROM_IMU_TO_NAV_SAVE_INDEX};
    filterState2Velocity = (filterIntermediateState{i-1,FIS_VELOCITY_IN_NAV_SAVE_INDEX})';
    filterState3Translation = (filterIntermediateState{i-1,FIS_POSITION_INDEX})';
    filterState4AngulerSpeedBias = (filterIntermediateState{i-1,FIS_ANGULAR_SPEED_BIAS_SAVE_INDEX})';
    filterState5AccelerationBias = (filterIntermediateState{i-1,FIS_ACCELERATION_BIAS_SAVE_INDEX})';
    filterState6Rotation = filterIntermediateState{i-1,FIS_SOBRACKET3_FROM_IMU_TO_CAR_SAVE_INDEX};
    filterState7Transition = filterIntermediateState{i-1,FIS_TRANSLATION_FROM_IMU_TO_CAR_SAVE_INDEX};
    filterState8StateCovariance = filterIntermediateState{i-1,FIS_P_SAVE_INDEX};
    filterState9NoiseCovariance = filterIntermediateState{i-1,FIS_Q_SAVE_INDEX};

    %%% Propagate
    % State X1
    propagateState1AngulerSpeed = observationAngulerSpeed - filterState4AngulerSpeedBias;
    propagateState1Phi = propagateState1AngulerSpeed * dt;
    propagateState1Gamma0Phi = uppercaseGreekLetterGammaSubscript0(propagateState1Phi);
    propagateState1RotationEstimation1 = filterState1Rotation * propagateState1Gamma0Phi;
    propagateState1RotationEstimation2 = filterState1Rotation * SO3.exp(propagateState1Phi).double;
    
    propagateState1RotationEstimation = propagateState1RotationEstimation1;
    % propagateState1RotationEstimation = propagateState1RotationEstimation2;

    [nPropagateRotationAng1, nPropagateRotationAng2, nPropagateRotationAng3] = dcm2angle(propagateState1RotationEstimation1,'ZXY');
    nPropagateRotationAng = rad2deg([nPropagateRotationAng1, nPropagateRotationAng2, nPropagateRotationAng3]);
    % State X2
    propagateState1Gamma1Phi = uppercaseGreekLetterGammaSubscript1(propagateState1Phi);
    propagateState2AccelerationEstimation = observationAcceleration - filterState5AccelerationBias;
    propagateState2VelocityEstimation1 = filterState2Velocity + filterState1Rotation * propagateState1Gamma1Phi * propagateState2AccelerationEstimation * dt + GRAVITY * dt;
    propagateState2VelocityEstimation2 = filterState2Velocity + (filterState1Rotation * propagateState2AccelerationEstimation + GRAVITY) * dt;
    
    propagateState2VelocityEstimation = propagateState2VelocityEstimation1;
    % propagateState2VelocityEstimation = propagateState2VelocityEstimation2;

    % State X3
    propagateState1Gamma2Phi = uppercaseGreekLetterGammaSubscript2(propagateState1Phi);
    propagateState3TranslationEstimation1 = filterState3Translation + filterState2Velocity * dt + filterState1Rotation * propagateState1Gamma2Phi * propagateState2AccelerationEstimation * dt * dt + 0.5 * GRAVITY * dt * dt;
    propagateState3TranslationEstimation2 = filterState3Translation + (filterState2Velocity + propagateState2VelocityEstimation2) * dt * 0.5;
    propagateState3TranslationEstimation = propagateState3TranslationEstimation1;
    % State X4
    propagateState4AngularSpeedBias = filterState4AngulerSpeedBias;
    % State X5
    propagateState5AccelerationBias = filterState5AccelerationBias;
    % State X6
    propagateState6Rotation = filterState6Rotation;
    % State X7
    propagateState7Transition = filterState7Transition';
    % State Covariance
    % propagateStateCovarianceTransitionPhi = eye(size(filterState8StateCovariance));
    % propagateStateCovarianceTransitionPhi(4:6,1:3) = SKEW_GRAVITY * dt;
    % propagateStateCovarianceTransitionPhi(7:9,1:3) = 0.5 * SKEW_GRAVITY * dtdt;
    % propagateStateCovarianceTransitionPhi(7:9,4:6) = eye(3) * dt;
    % propagateStateCovarianceTransitionPhi(1:3,10:12) = - filterState1Rotation * propagateState1Gamma1Phi * dt;
    % propagateStateCovarianceTransitionPhi(4:6,10:12) = skew(propagateState2VelocityEstimation) * propagateStateCovarianceTransitionPhi(1:3,10:12) + filterState1Rotation * uppercaseGreekLetterPsiSubscript1(propagateState1AngulerSpeed,propagateState2AccelerationEstimation,dt);
    % propagateStateCovarianceTransitionPhi(7:9,10:12) = skew(propagateState3TranslationEstimation) * propagateStateCovarianceTransitionPhi(1:3,10:12) + filterState1Rotation * uppercaseGreekLetterPsiSubscript2(propagateState1AngulerSpeed,propagateState2AccelerationEstimation,dt);
    % propagateStateCovarianceTransitionPhi(4:6,13:15) = propagateStateCovarianceTransitionPhi(1:3,10:12);
    % propagateStateCovarianceTransitionPhi(7:9,13:15) = - filterState1Rotation * propagateState1Gamma2Phi * dt;
    % propagateStateCovarianceTransitionAdjoint = zeros(filterPSize,filterQSize);
    % propagateStateCovarianceTransitionAdjoint(1:3,1:3) = filterState1Rotation;
    % propagateStateCovarianceTransitionAdjoint(4:6,1:3) = skew(propagateState2VelocityEstimation) * propagateStateCovarianceTransitionAdjoint(1:3,1:3);
    % propagateStateCovarianceTransitionAdjoint(7:9,1:3) = skew(propagateState3TranslationEstimation) * propagateStateCovarianceTransitionAdjoint(1:3,1:3);
    % propagateStateCovarianceTransitionAdjoint(4:6,4:6) = propagateStateCovarianceTransitionAdjoint(1:3,1:3);
    % propagateStateCovarianceTransitionAdjoint(10:21,7:18) = eye(12);
    % propagateNoiseCovariance = propagateStateCovarianceTransitionAdjoint * filterState9NoiseCovariance * propagateStateCovarianceTransitionAdjoint';
    % propagateStateCovariance = propagateStateCovarianceTransitionPhi * filterState8StateCovariance * propagateStateCovarianceTransitionPhi' ...
    %     + propagateNoiseCovariance;


    propagateStateCovarianceTransitionF = zeros(size(filterState8StateCovariance));
    propagateStateCovarianceTransitionF(4:6,1:3) = SKEW_GRAVITY;
    propagateStateCovarianceTransitionF(7:9,4:6) = eye(3);
    propagateStateCovarianceTransitionF(1:3,10:12) = - filterState1Rotation;
    propagateStateCovarianceTransitionF(4:6,10:12) = - skew(propagateState2VelocityEstimation) * filterState1Rotation;
    propagateStateCovarianceTransitionF(7:9,10:12) = - skew(propagateState3TranslationEstimation) * filterState1Rotation;
    propagateStateCovarianceTransitionF(4:6,13:15) = - filterState1Rotation;
    propagateStateCovarianceTransitionFdt = propagateStateCovarianceTransitionF .* dt;
    propagateStateCovarianceTransitionFdtFdt = propagateStateCovarianceTransitionFdt * propagateStateCovarianceTransitionFdt;
    propagateStateCovarianceTransitionFdtFdtFdt = propagateStateCovarianceTransitionFdtFdt * propagateStateCovarianceTransitionFdt;

    propagateStateCovarianceTransitionAdjoint = zeros(filterPSize,filterQSize);
    propagateStateCovarianceTransitionAdjoint(1:3,1:3) = filterState1Rotation;
    propagateStateCovarianceTransitionAdjoint(4:6,1:3) = skew(propagateState2VelocityEstimation) * filterState1Rotation;
    propagateStateCovarianceTransitionAdjoint(7:9,1:3) = skew(propagateState3TranslationEstimation) * filterState1Rotation;
    propagateStateCovarianceTransitionAdjoint(4:6,4:6) = filterState1Rotation;
    propagateStateCovarianceTransitionAdjoint(10:21,7:18) = eye(12);
    propagateStateCovarianceTransitionAdjointdt = propagateStateCovarianceTransitionAdjoint * dt;
    propagateNoiseCovariance = propagateStateCovarianceTransitionAdjointdt * filterState9NoiseCovariance * propagateStateCovarianceTransitionAdjointdt';

    propagateStateCovarianceTransitionPhi = eye(size(filterState8StateCovariance)) + propagateStateCovarianceTransitionFdt + (1/2) .* propagateStateCovarianceTransitionFdtFdt + (1/6) .* propagateStateCovarianceTransitionFdtFdtFdt;
    propagateStateCovariance = propagateStateCovarianceTransitionPhi * (filterState8StateCovariance + propagateNoiseCovariance) * propagateStateCovarianceTransitionPhi';


    
%     filterIntermediateState{i,FIS_SEBRACKET3_SAVE_INDEX} = SE3(propagateState1RotationEstimation,propagateState3TranslationEstimation).double;
%     filterIntermediateState{i,FIS_SOBRACKET3_FROM_IMU_TO_NAV_SAVE_INDEX} = propagateState1RotationEstimation;
%     filterIntermediateState{i,FIS_VELOCITY_IN_NAV_SAVE_INDEX} = (propagateState2VelocityEstimation)';
%     filterIntermediateState{i,FIS_POSITION_INDEX} = (propagateState3TranslationEstimation)';
%     filterIntermediateState{i,FIS_ANGULAR_SPEED_BIAS_SAVE_INDEX} = (propagateState4AngularSpeedBias)';
%     filterIntermediateState{i,FIS_ACCELERATION_BIAS_SAVE_INDEX} = (propagateState5AccelerationBias)';
%     filterIntermediateState{i,FIS_SOBRACKET3_FROM_IMU_TO_CAR_SAVE_INDEX} = propagateState6Rotation;
%     filterIntermediateState{i,FIS_TRANSLATION_FROM_IMU_TO_CAR_SAVE_INDEX} = (propagateState7Transition)';
% 
%     filterIntermediateState{i,FIS_ANGULAR_SPEED_SAVE_INDEX} = spanResampledData{i,4};
%     filterIntermediateState{i,FIS_ACCELERATION_SAVE_INDEX} = spanResampledData{i,5};
% 
%     filterIntermediateState{i,FIS_P_SAVE_INDEX} = propagateStateCovariance;
%     filterIntermediateState{i,FIS_Q_SAVE_INDEX} = filterInitQ;

    %%% Update
    updateStateSOBracket3FromCarToNav = propagateState1RotationEstimation * propagateState6Rotation;
    updateStateSOBracket3FromNavToCar = updateStateSOBracket3FromCarToNav';
    updateStateImuVelocityInImu = propagateState1RotationEstimation' * propagateState2VelocityEstimation;
    updateStateImuVelocityInCar = updateStateSOBracket3FromNavToCar * propagateState2VelocityEstimation;
    updateStateCarVelocityInCar = updateStateImuVelocityInCar + propagateState6Rotation' * skew(propagateState1AngulerSpeed') * propagateState7Transition;
    updateStateSkewAngularSpeedInImu = skew(propagateState1AngulerSpeed);
    updateStateJacobianA = propagateState6Rotation' * skew(propagateState7Transition');
    updateStateJacobianB = -skew(updateStateCarVelocityInCar);
    updateStateJacobianC = propagateState6Rotation' * updateStateSkewAngularSpeedInImu;    

    updateStateMeasurementTransitionHRaw = zeros(3,filterPSize);
    updateStateMeasurementTransitionHRaw(:,4:6) = updateStateSOBracket3FromNavToCar;
    updateStateMeasurementTransitionHRaw(:,10:12) = updateStateJacobianB;
    updateStateMeasurementTransitionHRaw(:,16:18) = updateStateJacobianC;
    updateStateMeasurementTransitionHRaw(:,19:21) = - updateStateSkewAngularSpeedInImu;

    updateStateMeasurementVelocity = dataDeepOdoPredict(filterTimestamp==dataDeepOdoPredict(:,1),:);
    if isempty(updateStateMeasurementVelocity)
        measurementCovarianceR = zeros(2);
        measurementCovarianceR(1,1) = 15;
        measurementCovarianceR(2,2) = 8;
        if cDeepLearnedCovarianceAvailable && cDeepLearnedCovarianceUse
            measurementCovarianceR(1,1) = spanResampledData{i,6};
            measurementCovarianceR(2,2) = spanResampledData{i,7};
        end

        if strcmp(cCarCoordinateType,'RFU')
            measurementIndex = [1 3];
        else
            measurementIndex = [2 3];
        end

        updateStateMeasurementTransitionH = updateStateMeasurementTransitionHRaw(measurementIndex, :);
        updateStateMeasurementError = - updateStateCarVelocityInCar(measurementIndex,:);
    else
        measurementCovarianceR = zeros(3);

        if strcmp(cCarCoordinateType,'RFU')
            measurementIndex = [1 3];
        else
            measurementIndex = [2 3];
        end

        measurementCovarianceR(measurementIndex(1),measurementIndex(1)) = 15;
        measurementCovarianceR(measurementIndex(2),measurementIndex(2)) = 8;
        if cDeepLearnedCovarianceAvailable && cDeepLearnedCovarianceUse
            measurementCovarianceR(measurementIndex(1),measurementIndex(1)) = spanResampledData{i,6};
            measurementCovarianceR(measurementIndex(2),measurementIndex(2)) = spanResampledData{i,7};
        end

        measurementCovarianceR(2,2) = 2;

        updateStateMeasurementTransitionH = updateStateMeasurementTransitionHRaw;
        measurementCarVelocityInCar = zeros(3,1);
        measurementCarVelocityInCar(2) = updateStateMeasurementVelocity(2);
        updateStateMeasurementError = measurementCarVelocityInCar - updateStateCarVelocityInCar;
    end



    updateStateMeasurementTransitionS = updateStateMeasurementTransitionH * propagateStateCovariance * updateStateMeasurementTransitionH' + measurementCovarianceR;
    updateStateMeasurementTransitionK = (linsolve(updateStateMeasurementTransitionS,(propagateStateCovariance * updateStateMeasurementTransitionH')'))';

    updateStateMeasurementTransitionDeltaX = updateStateMeasurementTransitionK * updateStateMeasurementError;
    updateStateSESubscript4Bracket3RotationElement = updateStateMeasurementTransitionDeltaX(1:3);
    updateStateSESubscript4Bracket3RotationElementNorm = norm(updateStateSESubscript4Bracket3RotationElement);
    updateStateSESubscript4Bracket3RotationElementAxis = updateStateSESubscript4Bracket3RotationElement / updateStateSESubscript4Bracket3RotationElementNorm;
    updateStateSESubscript4Bracket3RotationElementSkewAxis = skew(updateStateSESubscript4Bracket3RotationElementAxis);
    updateStateSESubscript4Bracket3RotationElementJacobian = (sin(updateStateSESubscript4Bracket3RotationElementNorm) / updateStateSESubscript4Bracket3RotationElementNorm) * eye(3) ...
        + (1 - sin(updateStateSESubscript4Bracket3RotationElementNorm) / updateStateSESubscript4Bracket3RotationElementNorm) * (updateStateSESubscript4Bracket3RotationElementAxis * updateStateSESubscript4Bracket3RotationElementAxis') ...
        + ((1 - cos(updateStateSESubscript4Bracket3RotationElementNorm)) / updateStateSESubscript4Bracket3RotationElementNorm) * updateStateSESubscript4Bracket3RotationElementSkewAxis;
    
    updateStateSESubscript4Bracket3DeltaRotation = cos(updateStateSESubscript4Bracket3RotationElementNorm) * eye(3) ...
        + (1 - cos(updateStateSESubscript4Bracket3RotationElementNorm)) * (updateStateSESubscript4Bracket3RotationElementAxis * updateStateSESubscript4Bracket3RotationElementAxis') ...
        + sin(updateStateSESubscript4Bracket3RotationElementNorm) * updateStateSESubscript4Bracket3RotationElementSkewAxis;
    updateStateSESubscript4Bracket3OtherElement = zeros(3,2);
    updateStateSESubscript4Bracket3OtherElement(1:3,1) = updateStateMeasurementTransitionDeltaX(4:6);
    updateStateSESubscript4Bracket3OtherElement(1:3,2) = updateStateMeasurementTransitionDeltaX(7:9);
    updateStateSESubscript4Bracket3DeltaOther = updateStateSESubscript4Bracket3RotationElementJacobian * updateStateSESubscript4Bracket3OtherElement;
    updateStateSESubscript4Bracket3DeltaVelocityInNav = updateStateSESubscript4Bracket3DeltaOther(1:3,1);
    updateStateSESubscript4Bracket3DeltaTransitionInNav = updateStateSESubscript4Bracket3DeltaOther(1:3,2);

    updateState1Rotation = updateStateSESubscript4Bracket3DeltaRotation * propagateState1RotationEstimation;
    updateState2Velocity = updateStateSESubscript4Bracket3DeltaRotation * propagateState2VelocityEstimation + updateStateSESubscript4Bracket3DeltaVelocityInNav;
    
    % updateState2VelocityNorm = norm(updateState2Velocity);
    % limitSpeed = 4.17;
    % limitVerticalSpeed = 0.5;
    % if updateState2VelocityNorm > limitSpeed
    %     updateState2Velocity = updateState2Velocity * limitSpeed / updateState2VelocityNorm;
    % 
    %     if abs(updateState2Velocity(3)) > limitVerticalSpeed
    %         updateState2Velocity(3) = sign(updateState2Velocity(3)) * limitVerticalSpeed;
    %     end
    % end
    
    updateState3Translation = updateStateSESubscript4Bracket3DeltaRotation * propagateState3TranslationEstimation + updateStateSESubscript4Bracket3DeltaTransitionInNav;
    updateState4AngulerSpeedBias = propagateState4AngularSpeedBias + updateStateMeasurementTransitionDeltaX(10:12);
    updateState5AccelerationBias = propagateState5AccelerationBias + updateStateMeasurementTransitionDeltaX(13:15);

    updateStateDeltaRotationFromImuToCar = SO3.exp(updateStateMeasurementTransitionDeltaX(16:18));
    updateState6Rotation = updateStateDeltaRotationFromImuToCar * propagateState6Rotation;
    updateState7Transition = propagateState7Transition + updateStateMeasurementTransitionDeltaX(19:21);

    updateStateMeasurementTransitionIKH = eye(filterPSize) - updateStateMeasurementTransitionK * updateStateMeasurementTransitionH;
    updateStateCovariance = updateStateMeasurementTransitionIKH * propagateStateCovariance * updateStateMeasurementTransitionIKH' ...
        + updateStateMeasurementTransitionK * measurementCovarianceR * updateStateMeasurementTransitionK';
    updateState8StateCovariance = (updateStateCovariance + updateStateCovariance') * 0.5;

    if strcmp(cCarCoordinateType,'LFU')
        dcm2angleScalar = 'ZXY';
        nGroundTruthSESubscript2Bracket3 = spanResampledData{i,2};
        [nGroundTruthRotationAng1, nGroundTruthRotationAng2, nGroundTruthRotationAng3] = dcm2angle(nGroundTruthSESubscript2Bracket3(1:3,1:3)',dcm2angleScalar);
        nGroundTruthRotationAng = rad2deg([nGroundTruthRotationAng1, nGroundTruthRotationAng2, nGroundTruthRotationAng3]);
        [updateState1RotationAng1, updateState1RotationAng2, updateState1RotationAng3] = dcm2angle(updateState1Rotation',dcm2angleScalar);
        updateState1RotationAng = rad2deg([updateState1RotationAng1, updateState1RotationAng2, updateState1RotationAng3]);
    else
        measurementIndex = [2 3];
    end

    filterIntermediateState{i,FIS_SEBRACKET3_SAVE_INDEX} = SE3(updateState1Rotation,updateState3Translation).double;
    filterIntermediateState{i,FIS_SOBRACKET3_FROM_IMU_TO_NAV_SAVE_INDEX} = updateState1Rotation;
    filterIntermediateState{i,FIS_VELOCITY_IN_NAV_SAVE_INDEX} = (updateState2Velocity)';
    filterIntermediateState{i,FIS_POSITION_INDEX} = (updateState3Translation)';
    filterIntermediateState{i,FIS_ANGULAR_SPEED_BIAS_SAVE_INDEX} = (updateState4AngulerSpeedBias)';
    filterIntermediateState{i,FIS_ACCELERATION_BIAS_SAVE_INDEX} = (updateState5AccelerationBias)';
    filterIntermediateState{i,FIS_SOBRACKET3_FROM_IMU_TO_CAR_SAVE_INDEX} = updateState6Rotation;
    filterIntermediateState{i,FIS_TRANSLATION_FROM_IMU_TO_CAR_SAVE_INDEX} = (updateState7Transition)';

    filterIntermediateState{i,FIS_P_SAVE_INDEX} = updateState8StateCovariance;
    filterIntermediateState{i,FIS_Q_SAVE_INDEX} = filterInitQ;

    if SCRIPT_MODE == 0

        pSEBracket3FromS2N = SE3(propagateState1RotationEstimation,propagateState3TranslationEstimation).double;
        pSEBracket3FromC2N = pSEBracket3FromS2N;
        pSEBracket3FromC2N(1:3,1:3) = pSEBracket3FromS2N(1:3,1:3) * propagateState6Rotation';


        if i == 2 || mod(i,cCarCoordinateAxisSampleCountInterval) == 0
            carCoordinateAxisInCarCoordinateSystem = [0 0 0 1; pCarCoordinateAxisXLineLength 0 0 1; 0 0 0 1; 0 pCarCoordinateAxisYLineLength 0 1; 0 0 0 1; 0 0 pCarCoordinateAxisZLineLength 1]';
            carCoordinateAxisInNavCoordinateSystem = pSEBracket3FromC2N * carCoordinateAxisInCarCoordinateSystem;
            pCarCoordinateAxisInNavCoordinateSystem = carCoordinateAxisInNavCoordinateSystem';
            arrow3(pCarCoordinateAxisInNavCoordinateSystem(1,1:3),pCarCoordinateAxisInNavCoordinateSystem(2,1:3),'r-0.1',pCarCoordinateAxisArrowWidth);
            arrow3(pCarCoordinateAxisInNavCoordinateSystem(3,1:3),pCarCoordinateAxisInNavCoordinateSystem(4,1:3),'g-0.1',pCarCoordinateAxisArrowWidth);
            arrow3(pCarCoordinateAxisInNavCoordinateSystem(5,1:3),pCarCoordinateAxisInNavCoordinateSystem(6,1:3),'b-0.1',pCarCoordinateAxisArrowWidth);
            logMsg = sprintf('Sample: %d, plot car coordinate axis',i);
            log2terminal('D',TAG,logMsg);
        end

        if i == 2 || mod(i,cCarStateVelocitySampleCountInterval) == 0
            pState2Velocity = filterState2Velocity;
            vc = pSEBracket3FromC2N(1:3,1:3)' * pState2Velocity;

            % if vc(2) < -0.2
            %     logMsg = sprintf('%f',vc(2));
            %     log2terminal('D',TAG,logMsg);
            % end

            % vc = vc ./ max(abs(vc));
            A = [0 0 0 1; pCarStateVelocityLineLengthRatio*vc(1) 0 0 1; 0 0 0 1; 0 pCarStateVelocityLineLengthRatio*vc(2) 0 1; 0 0 0 1; 0 0 pCarStateVelocityLineLengthRatio*vc(3) 1]';
            B = pSEBracket3FromC2N * A;
            plot3(B(1,1:2),B(2,1:2),B(3,1:2),'Color',ViridisColerPalette06(1),'LineStyle','-','LineWidth',pCarStateVelocityLineWidth);
            plot3(B(1,3:4),B(2,3:4),B(3,3:4),'Color',ViridisColerPalette06(3),'LineStyle','-','LineWidth',pCarStateVelocityLineWidth);
            plot3(B(1,5:6),B(2,5:6),B(3,5:6),'Color',ViridisColerPalette06(5),'LineStyle','-','LineWidth',pCarStateVelocityLineWidth);
            logMsg = sprintf('Sample: %d, plot car velocity',i);
            log2terminal('D',TAG,logMsg);

            % pMeasurementAccelerometer = spanResampledData{i,5};
            % A = [0 0 0 1; pImuStateAccelerometerLineLength*pMeasurementAccelerometer(1) 0 0 1; 0 0 0 1; 0 pImuStateAccelerometerLineLength*pMeasurementAccelerometer(2) 0 1; 0 0 0 1; 0 0 pImuStateAccelerometerLineLength*pMeasurementAccelerometer(3) 1]';
            % B = pSEBracket3FromS2N * A;
            % plot3(B(1,1:2),B(2,1:2),B(3,1:2),'Color',ViridisColerPalette06(1),'LineStyle','--','LineWidth',pImuStateAccelerometerLineWidth);
            % plot3(B(1,3:4),B(2,3:4),B(3,3:4),'Color',ViridisColerPalette06(3),'LineStyle','--','LineWidth',pImuStateAccelerometerLineWidth);
            % plot3(B(1,5:6),B(2,5:6),B(3,5:6),'Color',ViridisColerPalette06(5),'LineStyle','--','LineWidth',pImuStateAccelerometerLineWidth);
            % logMsg = sprintf('Sample: %d, plot car velocity',i);
            % log2terminal('D',TAG,logMsg);
        end

%         if i == 2 || mod(i,cCarCoordinateAxisSampleCountInterval) == 0
%             carCoordinateAxisInCarCoordinateSystem = [0 0 0 1; pCarCoordinateAxisXLineLength 0 0 1; 0 0 0 1; 0 pCarCoordinateAxisYLineLength 0 1; 0 0 0 1; 0 0 pCarCoordinateAxisZLineLength 1]';
%             carCoordinateAxisInNavCoordinateSystem = nGroundTruthSESubscript2Bracket3 * carCoordinateAxisInCarCoordinateSystem;
%             pCarCoordinateAxisInNavCoordinateSystem = carCoordinateAxisInNavCoordinateSystem';
%             arrow3(pCarCoordinateAxisInNavCoordinateSystem(1,1:3),pCarCoordinateAxisInNavCoordinateSystem(2,1:3),'r-0.1',pCarCoordinateAxisArrowWidth);
%             arrow3(pCarCoordinateAxisInNavCoordinateSystem(3,1:3),pCarCoordinateAxisInNavCoordinateSystem(4,1:3),'g-0.1',pCarCoordinateAxisArrowWidth);
%             arrow3(pCarCoordinateAxisInNavCoordinateSystem(5,1:3),pCarCoordinateAxisInNavCoordinateSystem(6,1:3),'b-0.1',pCarCoordinateAxisArrowWidth);
%             logMsg = sprintf('Sample: %d, plot car coordinate axis',i);
%             log2terminal('D',TAG,logMsg);
%         end
% 
%         if i == 2 || mod(i,cCarStateVelocitySampleCountInterval) == 0
%             pState2Velocity = spanResampledData{i,3}';
%             vc = nGroundTruthSESubscript2Bracket3(1:3,1:3)' * pState2Velocity;
%             % vc = vc ./ max(abs(vc));
%             A = [0 0 0 1; pCarStateVelocityLineLengthRatio*vc(1) 0 0 1; 0 0 0 1; 0 pCarStateVelocityLineLengthRatio*vc(2) 0 1; 0 0 0 1; 0 0 pCarStateVelocityLineLengthRatio*vc(3) 1]';
%             B = nGroundTruthSESubscript2Bracket3 * A;
%             plot3(B(1,1:2),B(2,1:2),B(3,1:2),'Color',ViridisColerPalette06(1),'LineStyle','-','LineWidth',pCarStateVelocityLineWidth);
%             plot3(B(1,3:4),B(2,3:4),B(3,3:4),'Color',ViridisColerPalette06(3),'LineStyle','-','LineWidth',pCarStateVelocityLineWidth);
%             plot3(B(1,5:6),B(2,5:6),B(3,5:6),'Color',ViridisColerPalette06(5),'LineStyle','-','LineWidth',pCarStateVelocityLineWidth);
%             logMsg = sprintf('Sample: %d, plot car velocity',i);
%             log2terminal('D',TAG,logMsg);
%         end

        %         as = observationAcceleration;
        %         pAccelerationInImuCoordinateSystem = as + GRAVITY;
        %         pAccelerationInImuCoordinateSystem = pAccelerationInImuCoordinateSystem ./ max(abs(pAccelerationInImuCoordinateSystem));
        %         A2 = [0 0 0 1; al*pAccelerationInImuCoordinateSystem(1) 0 0 1; 0 0 0 1; 0 al*pAccelerationInImuCoordinateSystem(2) 0 1; 0 0 0 1; 0 0 al*pAccelerationInImuCoordinateSystem(3) 1]';
        %         B2 = pSEBracket3FromS2N * A2;
        %         plot3(B2(1,1:2),B2(2,1:2),B2(3,1:2),'Color',ViridisColerPalette06(2),'LineStyle','--','LineWidth',pImuStateAccelerometerLineWidth); % x: red
        %         plot3(B2(1,3:4),B2(2,3:4),B2(3,3:4),'Color',ViridisColerPalette06(4),'LineStyle','--','LineWidth',pImuStateAccelerometerLineWidth); % y: green
        %         plot3(B2(1,5:6),B2(2,5:6),B2(3,5:6),'Color',ViridisColerPalette06(6),'LineStyle','--','LineWidth',pImuStateAccelerometerLineWidth); % z: blue

        %         imuCoordinateAxisInImuCoordinateSystem = [0 0 0 1; pImuCoordinateAxisLineLength 0 0 1; 0 0 0 1; 0 pImuCoordinateAxisLineLength 0 1; 0 0 0 1; 0 0 pImuCoordinateAxisLineLength 1]';
        %         imuCoordinateAxisInNavCoordinateSystem = pSEBracket3FromS2N * imuCoordinateAxisInImuCoordinateSystem;
        %         pImuCoordinateAxisInNavCoordinateSystem = imuCoordinateAxisInNavCoordinateSystem';
        %         arrow3(pImuCoordinateAxisInNavCoordinateSystem(1,1:3),pImuCoordinateAxisInNavCoordinateSystem(2,1:3),'c-0.2',pImuCoordinateAxisArrowWidth);
        %         arrow3(pImuCoordinateAxisInNavCoordinateSystem(3,1:3),pImuCoordinateAxisInNavCoordinateSystem(4,1:3),'m-0.2',pImuCoordinateAxisArrowWidth);
        %         arrow3(pImuCoordinateAxisInNavCoordinateSystem(5,1:3),pImuCoordinateAxisInNavCoordinateSystem(6,1:3),'y-0.2',pImuCoordinateAxisArrowWidth);

        nGroundTruthVelocity = spanResampledData{i,3};
        nGroundTruthTranslation = spanResampledData{i,2}(1:3,4);
        nGroundTruthRotation = spanResampledData{i,2}(1:3,1:3);

        if i == 8000
            fprintf('%d', i);
        end
    end

    if mod(i,cLogSampleCountInterval) == 2
        logMsg = sprintf('Progress %.2f (%d/%d)',i/spanResampledDataSize,i,spanResampledDataSize);
        log2terminal('D',TAG,logMsg);
    end

end


if SCRIPT_MODE == 0
    hold off;
end

% plotTime = cell2mat(spanResampledData(:,1));
% plotIndex = find(plotTime > 11542 & plotTime <= 11606);
plotIndex = 1:spanResampledDataSize;
% plotSESubscript4Bracket3Pose(filterIntermediateState(plotIndex,1),filterIntermediateState(plotIndex,2),filterIntermediateState(plotIndex,4),spanResampledData(plotIndex,4),spanResampledData(plotIndex,5));

zClipHeadTimeString = convertDaySecondsToString(filterIntermediateState{1,1},0);
zClipTailTimeString = convertDaySecondsToString(filterIntermediateState{spanResampledDataSize,1},0);
logMsg = sprintf('Date %s, Track %s, phone %s, clip coarse time from %s to %s',cDatasetCollectionDateFolderName,cPreprocessTrackFolderName,cPreprocessPhoneFolderName,zClipHeadTimeString,zClipTailTimeString);
log2terminal('I',TAG,logMsg);



% plotSEBracket3Comparison(spanResampledData(plotIndex,2),filterIntermediateState(plotIndex,2),50);
plotTransitionComparison(spanResampledData(plotIndex,2),filterIntermediateState(plotIndex,2),50);
% plotSEPose(spanResampledData(3000:6000,2));