%%% 重置工作区环境
% 清除内存中的变量 
% https://ww2.mathworks.cn/help/matlab/ref/clearvars.html
clearvars; 
% 关闭一个或多个图窗 
% https://ww2.mathworks.cn/help/matlab/ref/close.html?s_tid=doc_ta
close all;
% 设置断点用于调试 
% https://ww2.mathworks.cn/help/matlab/ref/dbstop.html?s_tid=doc_ta
dbstop error;

% 添加自定义工具类函数
addpath('..');
addpath('E:\GitHubRepositories\ai-imu-dr\scripts\utils');
addpath('E:\GitHubRepositories\KITTI\downloads\raw_data\devkit\matlab');

% 设置log标识
fullpath = mfilename('fullpath');
[folderPath,fileName]=fileparts(fullpath);
TAG = fileName;

load 'OdometryMappingConfig.mat';

cRawDatasetFolderPath = 'E:\GitHubRepositories\KITTI\raw_data';

tSequenceVelocityTable = [];

odometryMappingSize = size(ODOMETRY_MAPPING,1);
for i = 1 : odometryMappingSize
    tSequenceNumberString = ODOMETRY_MAPPING{i,1};
    tSequenceNumber = str2double(tSequenceNumberString);
    tSequenceName = ODOMETRY_MAPPING{i,2};
    tSequenceNameSplit = strsplit(tSequenceName,'_');
    tRawDateFolderName = strjoin(tSequenceNameSplit(1:3),'_');
    tRawDataFolderName = strcat(tSequenceName,'_extract');
    tRawDataFolderPath = fullfile(cRawDatasetFolderPath,tRawDateFolderName,tRawDataFolderName);
    if isfolder(tRawDataFolderPath)
        tOxtsRawData = loadOxtsRawData(tRawDataFolderPath);
        plotTrackGeodeticCoordinateTransformComparation(tRawDataFolderPath,tOxtsRawData(:,1:4));

        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end
end
