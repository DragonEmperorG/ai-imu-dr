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
cExportGTVelocityFileName = 'GTVelocity.csv';
% TODO: S1.2: 加载KITTI Odometry轨迹映射
load 'OdometryMappingConfig.mat';

% 基于DeepOdo模型对比输入标准化和输出归一化的效果
cModelDeepOdoInput6DInput100HzInputHSOutputNSFileName = "ModelDeepOdoInput6DInput100HzInputHSOutputNS.txt";
cComparedResultList = [cModelDeepOdoInput6DInput100HzInputHSOutputNSFileName];

% TODO: S2.1: 配置调试模式
% cDebug = true;
cDebug = false;

% cExportFileName = "DataDrivenVelocityMeasurementTable.txt";
% tExportFilePath = fullfile(cExpDatasetFolderPath,cExportFileName);
% exportLatexTable(tExportFilePath,datasetVE);

datasetVE = [];
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
        groundTruthVelocityRaw = loadOxtsRawInterpVelocity(tRawDataFolderPath);
        groundTruthVelocity = groundTruthVelocityRaw(:,2);

        relativeErrorSet = loadOxtsRelativeErrorOdometry(tRawDataFolderPath);
        trackVE = [];
        for k = 1:length(cComparedResultList)
            % dataDrivenVelocityRaw = readmatrix(fullfile(tExpDataFolderPath,cComparedResultList(i)));
            dataDrivenVelocityRaw = readmatrix(fullfile(tExpDataFolderPath,cComparedResultList));
            dataDrivenVelocity = zeros(size(groundTruthVelocity));
            dataDrivenVelocity(1) = groundTruthVelocity(1);
            dataDrivenVelocity(2:end) = dataDrivenVelocityRaw + dataDrivenVelocity(1);

            [AVE1,AVE2] = evaluateAVE(groundTruthVelocity,dataDrivenVelocity);
            [RVE1,RVE2] = evaluateRVEDeltaDist(groundTruthVelocity,dataDrivenVelocity,relativeErrorSet);
            trackVE = [trackVE,AVE1,AVE2,RVE1,RVE2];
            logMsg = sprintf('%s, AVE MAE: %.3f, AVE RMSE: %.3f; RVE MAE: %.3f, RVE RMSE: %.3f', ...
                cComparedResultList(k),AVE1,AVE2,RVE1,RVE2);
            log2terminal('I',TAG,logMsg);
        end
        datasetVE = [datasetVE;trackVE];

        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end
end

