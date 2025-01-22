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
cDebug = true;
% cDebug = false;

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
        if ~strcmp(tSequenceNumberString,"05")
            continue;
        end
    end

    if isfolder(tRawDataFolderPath)

        processKittiDataModelDrivenMethod(tExpDataFolderPath);

        plotKITTIComparedTrackPositionCustomDataDriven(tExpDataFolderPath,'Integrated2DNHCDataDriven.mat');

        % plotKITTIFilterStateCombination(tExpDataFolderPath,'Integrated3DNHCATTDataDriven.mat')

        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end
end

