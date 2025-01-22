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

% 
cMethod1FileName = "Integrated2DNHCDataDriven.mat";
cMethod2FileName = "Integrated3DNHCDataDriven.mat";
cMethod3FileName = "Integrated2DNHCATTDataDriven.mat";
cMethod4FileName = "IntegratedDataDriven.mat";
cComparedResultList = [
    cMethod1FileName, ...
    cMethod2FileName, ...
    cMethod3FileName, ...
    cMethod4FileName, ...
];

% TODO: S2.1: 配置调试模式
% cDebug = true;
cDebug = false;

cExportFileName = "DDMDPositionEvaluationTable.txt";
tExportFilePath = fullfile(cDatasetLevel3ReorganizedFolderPath,cExportFileName);
exportLatexTable(tExportFilePath,datasetPE);

datasetPE = [];
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

                    tGroundTruthNavSE = loadPreprocessGroundTruthNavSE(tDatasetLevel5FolderPhonePath);
                    tGroundTruthNavSEDownSampled = tGroundTruthNavSE(:,:,1:200:size(tGroundTruthNavSE,3));

                    tRelativeErrorSet = loadChongqinRelativeErrorOdometry(tDatasetLevel5FolderPhonePath);
                    trackVE = [];
                    for k = 1:length(cComparedResultList)
                        tDDMDFilterResultRaw = loadFilterStateIntegratedCustomDataDriven(tDatasetLevel5FolderPhonePath,cComparedResultList(k));
                        tDDMDFilterNavSE = getFilterStateNavSE(tDDMDFilterResultRaw);
                        tDDMDFilterNavSEDownSampled = tDDMDFilterNavSE(:,:,1:200:size(tDDMDFilterNavSE,3));

                        [APE1,APE2] = evaluateAPE(tGroundTruthNavSEDownSampled,tDDMDFilterNavSEDownSampled);
                        [RPE1,RPE2,RPE3,RPE4,RPE5,RPE6,RPE7,RPE8] = evaluateRPEDeltaDist(tGroundTruthNavSEDownSampled,tDDMDFilterNavSEDownSampled,tRelativeErrorSet);
                        trackVE = [trackVE,APE1,APE2,RPE3,RPE4,RPE1,RPE2,RPE7,RPE8,RPE5,RPE6];
                        logMsg = sprintf('%s, APE MAE: %.3f, APE RMSE: %.3f; RPE MAE: %.3f, RPE RMSE: %.3f', ...
                            cComparedResultList(k),APE1,APE2,RPE1,RPE2);
                        log2terminal('I',TAG,logMsg);
                    end
                    datasetPE = [datasetPE;trackVE];

                    % velocityLabel = repmat({seqString},size(velocityError,1),1);
                    % boxplotg = [boxplotg;velocityLabel];

                end
            end
            % Tail iterate phone_name
        end
    end
    % Tail iterate drive_id
end
