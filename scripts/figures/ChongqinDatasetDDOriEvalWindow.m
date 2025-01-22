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

SCRIPT_MODE = 0;

% TODO: S1.1: 模型输入预处理文件夹 根目录
% cDatasetFolderPath = 'C:\DoctorRelated\20230410重庆VDR数据采集';
cDatasetLevel1FolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集';
% TODO: S1.2: 模型输入预处理文件夹 采集日期
cDatasetLevel2CollectionDateFolderName = '2023_04_10';
% cDatasetCollectionDateFolderName = '2023_04_11';
% cDatasetCollectionDateFolderName = '2023_04_13';
% cDatasetCollectionDateFolderName = '2023_04_15';
ccDatasetLevel2CollectionDateFolderPath = fullfile(cDatasetLevel1FolderPath,cDatasetLevel2CollectionDateFolderName);
% 配置预处理根文件夹路径
cDatasetLevel3ReorganizedFolderName = 'Reorganized';
cDatasetLevel3ReorganizedFolderPath = fullfile(ccDatasetLevel2CollectionDateFolderPath,cDatasetLevel3ReorganizedFolderName);
% TODO: S1.3: 模型输入预处理文件夹 采集轨迹编号
cDatasetLevel4TrackFolderNameList = [...
    "0008" ...
    "0009" ...
    "0010" ...
    "0011" ...
    "0012" ...
    "0013" ...
    "0014" ...
    "0015" ...
    "0016" ...
    "0017" ...
    "0018" ...
    ];
cDatasetLevel4TrackFolderNameListLength = length(cDatasetLevel4TrackFolderNameList);

% 基于DeepOdo模型对比输入标准化和输出归一化的效果
cModelDeepOdoLossDeltaOrientationWindow1FileName = "DeepOriPredictedData.txt";
cModelDeepOdoLossDeltaOrientationWindow2FileName = "LossDeltaOrientationWindow2.txt";

cComparedResultList = [
    cModelDeepOdoLossDeltaOrientationWindow1FileName,
    cModelDeepOdoLossDeltaOrientationWindow2FileName
];

% TODO: S2.1: 配置调试模式
% cDebug = true;
cDebug = false;

% cExportFileName = "DataDrivenOrientationMeasurementWindowSizeFactorTable.txt";
% tExportFilePath = fullfile(cDatasetLevel3ReorganizedFolderPath,cExportFileName);
% exportLatexTable(tExportFilePath,datasetOE);

datasetOE = [];
if ~isfolder(cDatasetLevel3ReorganizedFolderPath)
    logMsg = sprintf('Not folder path %s',cDatasetLevel3ReorganizedFolderPath);
    log2terminal('E',TAG,logMsg);
else
    logTrackDenominator = cDatasetLevel4TrackFolderNameListLength;
    % Headjianzhi iterate drive_id
    for i = 1:cDatasetLevel4TrackFolderNameListLength
        logTrackNumerator = i;
        tDatasetLevel4TrackFolderName = cDatasetLevel4TrackFolderNameList(i);

        if cDebug
            if ~strcmp(tDatasetLevel4TrackFolderName,"0008")
                continue;
            end
        end

        tDatasetLevel4TrackFolderPath = fullfile(cDatasetLevel3ReorganizedFolderPath,tDatasetLevel4TrackFolderName);
        if isfolder(tDatasetLevel4TrackFolderPath)
            tDatasetLevel4TrackFolderDir = dir(tDatasetLevel4TrackFolderPath);
            tDatasetLevel4TrackFolderDirLength = length(tDatasetLevel4TrackFolderDir);
            % Head iterate phone_name
            for j = 1:tDatasetLevel4TrackFolderDirLength
                tDatasetLevel5FolderPhoneName = tDatasetLevel4TrackFolderDir(j).name;
                if ~strcmp(tDatasetLevel5FolderPhoneName,'.') && ~strcmp(tDatasetLevel5FolderPhoneName,'..') && tDatasetLevel4TrackFolderDir(j).isdir

                    if ~strcmp(tDatasetLevel5FolderPhoneName,'HUAWEI_Mate30')
                        continue;
                    end

                    tDatasetLevel5FolderPhonePath = fullfile(tDatasetLevel4TrackFolderPath,tDatasetLevel5FolderPhoneName);
                    logMsg = sprintf('drive id: %s (%d/%d), phone name: %s', ...
                        tDatasetLevel4TrackFolderName, logTrackNumerator, logTrackDenominator, ...
                        tDatasetLevel5FolderPhoneName ...
                        );
                    log2terminal('I',TAG,logMsg);

                    groundTruthOrientation = loadDataDrivenAttitudeGroundTruth(tDatasetLevel5FolderPhonePath);
                    trackVE = [];
                    for k = 1:length(cComparedResultList)
                        tDataDrivenOrientationFilePath = fullfile(tDatasetLevel5FolderPhonePath,'DATASET_DEEPORI',cComparedResultList(k));
                        tDataDrivenOrientationRaw = readmatrix(tDataDrivenOrientationFilePath);
                        tDataDrivenOrientation = [];
                        if size(tDataDrivenOrientationRaw,2) == 4
                            tDataDrivenOrientation = loadDataDrivenAttitudeMeasurement(tDatasetLevel5FolderPhonePath, 0);
                        else
                            tDataDrivenOrientation = convertOrientationFlatToRotationMatrix(tDataDrivenOrientationRaw(:,2:end));
                        end

                        [AOE1,AOE2] = evaluateAOE(groundTruthOrientation,tDataDrivenOrientation);
                        [ROE1,ROE2] = evaluateROE(groundTruthOrientation,tDataDrivenOrientation);
                        trackVE = [trackVE,AOE1,AOE2,ROE1,ROE2];
                        logMsg = sprintf('%s, AOE MAE: %.3f, AOE RMSE: %.3f; ROE MAE: %.3f, ROE RMSE: %.3f', ...
                            cComparedResultList(k),AOE1,AOE2,ROE1,ROE2);
                        log2terminal('I',TAG,logMsg);
                    end
                    datasetOE = [datasetOE;trackVE];

                    % velocityLabel = repmat({seqString},size(velocityError,1),1);
                    % boxplotg = [boxplotg;velocityLabel];

                end
            end
            % Tail iterate phone_name
        end
    end
    % Tail iterate drive_id
end
