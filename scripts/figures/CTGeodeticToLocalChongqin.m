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
addpath(genpath(pwd));

% 设置log标识
fullpath = mfilename('fullpath');
[folderPath,fileName]=fileparts(fullpath);
TAG = fileName;

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


% TODO: S2.1: 配置调试模式
% cDebug = true;
cDebug = false;

tSequenceVelocityTable = [];
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
            if ~strcmp(tDatasetLevel4TrackFolderName,"0009")
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

                    cDayZeroOClockAlignFolderName = "dayZeroOClockAlign";
                    tDayZeroOClockAlignFolderPath = fullfile(tDatasetLevel5FolderPhonePath,cDayZeroOClockAlignFolderName);
                    cTrackSynchronizedFileName = "TrackSynchronized.csv";
                    tTrackSynchronizedFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackSynchronizedFileName);
                    tTrackSynchronizedData = readmatrix(tTrackSynchronizedFilePath);
                    cTrackGroundTruthNavFileName = "TrackGroundTruthNav.csv";
                    tTrackGroundTruthNavFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackGroundTruthNavFileName);
                    tTrackGroundTruthNavData = readmatrix(tTrackGroundTruthNavFilePath);

                    tClipHeadTime = ceil(tTrackSynchronizedData(1,1));
                    tClipTailTime = floor(tTrackSynchronizedData(end,1));

                    tClipTrackGroundTruthNavData = tTrackGroundTruthNavData(tTrackGroundTruthNavData(:,1)>=tClipHeadTime&tTrackGroundTruthNavData(:,1)<=tClipTailTime,:);
                    plotTrackGeodeticCoordinateTransformComparation(tDayZeroOClockAlignFolderPath,tClipTrackGroundTruthNavData(:,1:4));

                end
            end
            % Tail iterate phone_name
        end
    end
    % Tail iterate drive_id
end
