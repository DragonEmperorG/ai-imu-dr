% 重置工作区环境
% clearvars;
close all;
dbstop error;
% clc;

% 添加自定义工具类函数
addpath(genpath(pwd));
fullpath = mfilename('fullpath');
[folderPath,fileName]=fileparts(fullpath);
TAG = fileName;

% TODO: S1.1: 模型输入预处理文件夹 根目录
cRawDatasetFolderPath = 'E:\GitHubRepositories\KITTI\raw_data';
cExpDatasetFolderPath = 'E:\GitHubRepositories\KITTI\odometry\export';
cOxtsFolderName = 'oxts';
cOxtsliteDataMatFileName = 'data.mat';
cExportGTOrientationFileName = 'GTOrientation.csv';
% TODO: S1.2: 加载KITTI Odometry轨迹映射
load 'OdometryMappingConfig.mat';

% 基于DeepOdo模型对比输入标准化和输出归一化的效果
cModelDeepOriInput6DInput100HzInputHSOutputNSFileName = "ModelDeepOriInput6DInput100HzInputHSOutputNS.txt";
cComparedResultList = [cModelDeepOriInput6DInput100HzInputHSOutputNSFileName];

% TODO: S2.1: 配置调试模式
% cDebug = true;
cDebug = false;

cExportFileName = "DataDrivenOrientationMeasurementTable.txt";
tExportFilePath = fullfile(cExpDatasetFolderPath,cExportFileName);
exportLatexTable(tExportFilePath,datasetOE);

datasetOE = [];
odometryMappingSize = size(ODOMETRY_MAPPING,1);
for i = 1 : odometryMappingSize
    tSequenceNumberString = ODOMETRY_MAPPING{i,1};
    tSequenceNumber = str2double(tSequenceNumberString);
    tSequenceName = ODOMETRY_MAPPING{i,2};
    tSequenceNameSplit = strsplit(tSequenceName,'_');
    tRawDateFolderName = strjoin(tSequenceNameSplit(1:3),'_');
    tRawDataFolderName = strcat(tSequenceName,'_extract');
    tRawDataFolderPath = fullfile(cRawDatasetFolderPath,tRawDateFolderName,tRawDataFolderName);
    tExpDataFolderPath = fullfile(cExpDatasetFolderPath,tSequenceNumberString);

    if cDebug
        if ~strcmp(tSequenceNumberString,"00")
            continue;
        end
    end

    if isfolder(tRawDataFolderPath)

        groundTruthOrientationRaw = loadOxtsRawInterpOrientation(tRawDataFolderPath);
        groundTruthOrientationFlat = groundTruthOrientationRaw(:,2:end);
        groundTruthOrientation = convertOrientationFlatToRotationMatrix(groundTruthOrientationFlat);
        groundTruthOrientationEulerAngle = convertOrientationRotationMatrixToEulerAngle(groundTruthOrientation,true);

        relativeErrorSet = loadOxtsRelativeErrorOdometry(tRawDataFolderPath);
        trackOE = [];
        for k = 1:length(cComparedResultList)
            % dataDrivenOrientationRaw = readmatrix(fullfile(tExpDataFolderPath,cComparedResultList(i)));
            dataDrivenOrientationRaw = readmatrix(fullfile(tExpDataFolderPath,cComparedResultList));
            dataDrivenOrientationFlat = dataDrivenOrientationRaw(:,2:end);
            dataDrivenOrientation = convertOrientationFlatToRotationMatrix(dataDrivenOrientationFlat);

            dataDrivenOrientationEulerAngle = convertOrientationRotationMatrixToEulerAngle(dataDrivenOrientation,true);

            [AOE1,AOE2] = evaluateAOE(groundTruthOrientation,dataDrivenOrientation);
            [ROE1,ROE2,ROE3,ROE4] = evaluateROEDeltaDist(groundTruthOrientation,dataDrivenOrientation,relativeErrorSet);
            trackOE = [trackOE,AOE1,AOE2,ROE3,ROE4,ROE1,ROE2];
            logMsg = sprintf('%s, AOE MAE: %.3f, AOE RMSE: %.3f; ROE MAE: %.3f, ROE RMSE: %.3f', ...
                cComparedResultList(k),AOE1,AOE2,ROE1,ROE2);
            log2terminal('I',TAG,logMsg);
        end
        datasetOE = [datasetOE;trackOE];

        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end
end

