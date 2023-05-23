% 重置工作区环境
close all;
clear;

% 添加自定义工具类函数
addpath(genpath(pwd));
TAG = 'PreprocessorCoarseClip';

% 添加时间换算常量
S2MS = 1e3;
MS2S = 1/S2MS;
S2NS = 1e9;
NS2S = 1/S2NS;
MS2NS = 1e6;
NS2MS = 1/MS2NS;
US2NS = 1e3;
NS2US = 1/US2NS;

% TODO: S1.1: 配置数据集存储文件夹 根目录
% cDatasetFolderPath = 'C:\DoctorRelated\20230410重庆VDR数据采集';
cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集';
% TODO: S1.2: 配置数据集存储文件夹 采集日期
cDatasetCollectionDate = '2023_04_10';
% 添加预处理粗分割文件夹路径
cReorganizedFolderName = 'Reorganized';
cReorganizedFolderPath = fullfile(cDatasetFolderPath,cDatasetCollectionDate,cReorganizedFolderName);
% TODO: S1.3: 配置数据集存储文件夹 采集轨迹编号
cPreprocessTrackList = ["0009"];
cPreprocessTrackListLength = length(cPreprocessTrackList);
% TODO: S1.4: 配置数据集存储文件夹 采集手机
cPhoneMapNumber = ["HUAWEI_Mate30"];
% cPhoneMapNumber = ["GOOGLE_Pixel3" "HUAWEI_Mate30"];
% cPhoneMapNumber = ["GOOGLE_Pixel3" "HUAWEI_Mate30" "HUAWEI_P20"];
kPhoneMapNumberLength = length(cPhoneMapNumber);

% TODO: S2.1: 配置导航坐标系参考真值文件路径
% Load Novatel SPAN data
cGpsWeek = 2257;
cReferenceNovatelSpanDataFilePath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_10\重大数据\SPAN\IMU位置车体姿态\3-车体坐标系-IMU位置-gps.csv';
novatelSpanData = loadSpanPostDataWithZeroOClockTime(cReferenceNovatelSpanDataFilePath,cGpsWeek,cDatasetCollectionDate);
% TODO: S2.2: 配置时间同步参考IMU文件路径
% Load JZ-MINS200 data
cReferenceJZMINS200DataFilePath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_10\重大数据\九州数据\九洲设备-COM4-2023_4_10_14-17-17-imu.csv';
jZMINS200Data = loadJzMins200DataWithZeroOClockTime(cReferenceJZMINS200DataFilePath,cGpsWeek,cDatasetCollectionDate);

% 添加输入原始数据集存储文件夹
kRawFolderName = 'raw';
load 'SmartPhoneDataConfig.mat';
% 添加输出预处理粗切割存储文件夹
cDayZeroOClockAlignFolderName = 'dayZeroOClockAlign';

% TODO: S3.1: 配置是否替换有问题的GNSS时间基准
isReplaceGpsTimeBase = false;

% DEBUG: 配置是否重新计算
isRecomputeGroundTruthFile = true;
cTrackSmartPhoneStatisticColumn = 6;
cTrackPhoneCoarseClipStatisticFileName = 'TrackPhoneCoarseClipStatistic.csv';
cTrackCoarseClipStatisticFileName = 'TrackSensorCoarseClipStatistic.csv';
cTrackGroundTruthNavFileName = 'TrackGroundTruthNav.csv';
cTrackGroundTruthImuFileName = 'TrackGroundTruthImu.csv';

for i = 1:cPreprocessTrackListLength
    tTrackFolderNameStr = cPreprocessTrackList(i);
    tTrackFolderPath = fullfile(cReorganizedFolderPath,tTrackFolderNameStr);
    if isfolder(tTrackFolderPath)
        % Head statistic of track
        tTrackFolderDir = dir(tTrackFolderPath);
        tTrackFolderDirLength = length(tTrackFolderDir);
        tTrackStatisticMatrix = [];
        for j = 1:kPhoneMapNumberLength
            tTrackSmartPhoneFolderNameChar = cPhoneMapNumber(j);
            if ~strcmp(tTrackSmartPhoneFolderNameChar,'.') && ~strcmp(tTrackSmartPhoneFolderNameChar,'..')
                tTrackSmartPhoneFolderPath = fullfile(tTrackFolderPath,tTrackSmartPhoneFolderNameChar);
                if isfolder(tTrackSmartPhoneFolderPath)
                    tDayZeroOClockAlignFolderPath = fullfile(tTrackSmartPhoneFolderPath,cDayZeroOClockAlignFolderName);
                    if ~isfolder(tDayZeroOClockAlignFolderPath)
                        mkdir(tDayZeroOClockAlignFolderPath);
                    end
                    % Head statistic of track smart phone
                    tTrackGroundTruthNavFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackGroundTruthNavFileName);
                    tTrackGroundTruthImuFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackGroundTruthImuFileName);
                    if ~isfile(tTrackGroundTruthNavFilePath) || isRecomputeGroundTruthFile
                        tTrackPhoneCoarseClipStatisticFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackPhoneCoarseClipStatisticFileName);
                        if isfile(tTrackPhoneCoarseClipStatisticFilePath) && ~isRecomputeGroundTruthFile
                            tTrackPhoneStatisticMatrix = readmatrix(tTrackPhoneCoarseClipStatisticFilePath);
                        else
                            tTrackPhoneStatisticMatrix = [];
                            for k = 1:kValidateSensorFileListLength
                                tSensorFileName = kValidateSensorFileList(k);
                                tDayAlignedSensorFilePath = fullfile(tDayZeroOClockAlignFolderPath,tSensorFileName);
                                if isfile(tDayAlignedSensorFilePath) && ~isRecomputeGroundTruthFile
                                    tDayAlignedSensorData = readmatrix(tDayAlignedSensorFilePath);
                                else
                                    tSensorFilePath = fullfile(tTrackSmartPhoneFolderPath,kRawFolderName,tSensorFileName);

                                    if isfile(tSensorFilePath)
                                        tSensorRawData = readmatrix(tSensorFilePath);
                                        tSensorRawDataRows = size(tSensorRawData,2);
                                        tSensorRawDataColumns = size(tSensorRawData,2);
                                        % GNSS sensor data need to be handled separately
                                        if strcmp(tSensorFileName,kGnssLocationFileNameString)
                                            tSensorRawDataSysClockSensorEventTime = tSensorRawData(:,1) * MS2S + (tSensorRawData(:,5) - tSensorRawData(:,2)) * NS2S;

                                            if isReplaceGpsTimeBase
                                                tSensorGnssMeasurementFilePath = fullfile(tTrackSmartPhoneFolderPath,kRawFolderName,kGnssMeasurementFileNameString);
                                                tSensorGnssMeasurementRawData = readmatrix(tSensorGnssMeasurementFilePath);
                                                tSensorRawDataSysClockSensorEventTime = tSensorGnssMeasurementRawData(:,1) * MS2S;
                                                tSensorGnssMeasurementRawDataGpsClockBaseSensorEventTime = tSensorGnssMeasurementRawData(:,4) - (tSensorGnssMeasurementRawData(:,6) + tSensorGnssMeasurementRawData(:,7)) - tSensorGnssMeasurementRawData(:,2);
                                                tEstimatedGpsClockBaseSensorEventTime = interp1(tSensorGnssMeasurementRawDataSysClockSensorEventTime,tSensorGnssMeasurementRawDataGpsClockBaseSensorEventTime,tSensorRawData(:,1),'linear','extrap');
                                                tSensorRawDataGpsClockSensorEventTime = (tEstimatedGpsClockBaseSensorEventTime + tSensorRawData(:,5)) * NS2S;
                                            else
                                                tSensorRawDataGpsClockSensorEventTime = (tSensorRawData(:,3) + tSensorRawData(:,5)) * NS2S;
                                            end
                                            
                                        elseif strcmp(tSensorFileName,kGnssMeasurementFileNameString)
                                            tSensorRawDataSysClockSensorEventTime = tSensorRawData(:,1) * MS2S;
                                            tSensorRawDataGpsClockSensorEventTime = (tSensorRawData(:,4) - (tSensorRawData(:,6) + tSensorRawData(:,7))) * NS2S;
                                        else
                                            tSensorRawDataSysClockSensorEventTime = tSensorRawData(:,1) * MS2S + (tSensorRawData(:,4) - tSensorRawData(:,2)) * NS2S;
                                            
                                            if isReplaceGpsTimeBase
                                                tSensorGnssMeasurementFilePath = fullfile(tTrackSmartPhoneFolderPath,kRawFolderName,kGnssMeasurementFileNameString);
                                                tSensorGnssMeasurementRawData = readmatrix(tSensorGnssMeasurementFilePath);
                                                tSensorGnssMeasurementRawDataSysClockSensorEventTime = tSensorGnssMeasurementRawData(:,1);
                                                tSensorGnssMeasurementRawDataGpsClockBaseSensorEventTime = tSensorGnssMeasurementRawData(:,4) - (tSensorGnssMeasurementRawData(:,6) + tSensorGnssMeasurementRawData(:,7)) - tSensorGnssMeasurementRawData(:,2);
                                                tEstimatedGpsClockBaseSensorEventTime = interp1(tSensorGnssMeasurementRawDataSysClockSensorEventTime,tSensorGnssMeasurementRawDataGpsClockBaseSensorEventTime,tSensorRawData(:,1),'linear','extrap');
                                                tSensorRawDataGpsClockSensorEventTime = (tEstimatedGpsClockBaseSensorEventTime + tSensorRawData(:,4)) * NS2S;
                                            else
                                                tSensorRawDataGpsClockSensorEventTime = (tSensorRawData(:,3) + tSensorRawData(:,4)) * NS2S;
                                            end
                                            
                                        end
                                        % Convert UTC or GPS time to the zero O'clock on day
                                        [referenceZeroOClockDateTimeFromSystemClock, referenceZeroOClockFromSystemClockOffset] = getSystemCurrentTimeMillisMapZeroOClockTime(tSensorRawDataSysClockSensorEventTime(1,1)*S2MS);
                                        zSensorRawDataSysClockSensorEventTime = tSensorRawDataSysClockSensorEventTime - referenceZeroOClockFromSystemClockOffset;

                                        [referenceZeroOClockDateTimeFromGnssClock, referenceZeroOClockFromGnssClockOffset] = getGnssClockGpsTimeMapZeroOClockTime(tSensorRawDataGpsClockSensorEventTime(1,1)*S2NS);
                                        referenceZeroOClockLeapseconds = getZeroOClockTimeGpsTimeLeapseconds(referenceZeroOClockDateTimeFromGnssClock);
                                        zSensorRawDataGpsClockSensorEventTime = tSensorRawDataGpsClockSensorEventTime - referenceZeroOClockFromGnssClockOffset - referenceZeroOClockLeapseconds;

                                        tSensorDataValue = tSensorRawData(:,4:tSensorRawDataColumns);
                                        tDayAlignedSensorData = [zSensorRawDataSysClockSensorEventTime,zSensorRawDataGpsClockSensorEventTime,tSensorDataValue];
                                        writematrix(tDayAlignedSensorData,tDayAlignedSensorFilePath);
                                    else
                                        logMsg = sprintf('Missing data track %s smart phone %s file %s',tTrackFolderNameStr,tTrackSmartPhoneFolderNameChar,tSensorFileName);
                                        log2terminal('W',TAG,logMsg);
                                    end
                                end

                                tTrackSmartPhoneSensorStatisticMatrix = zeros(1,cTrackSmartPhoneStatisticColumn);
                                tTrackSmartPhoneSensorStatisticMatrix(1,1) = min(tDayAlignedSensorData(:,1));
                                tTrackSmartPhoneSensorStatisticMatrix(1,2) = max(tDayAlignedSensorData(:,1));
                                tTrackSmartPhoneSensorStatisticMatrix(1,3) = min(tDayAlignedSensorData(:,2));
                                tTrackSmartPhoneSensorStatisticMatrix(1,4) = max(tDayAlignedSensorData(:,2));
                                tTrackSmartPhoneSensorStatisticMatrix(1,5) = min(tTrackSmartPhoneSensorStatisticMatrix(1,1),tTrackSmartPhoneSensorStatisticMatrix(1,3));
                                tTrackSmartPhoneSensorStatisticMatrix(1,6) = max(tTrackSmartPhoneSensorStatisticMatrix(1,2),tTrackSmartPhoneSensorStatisticMatrix(1,4));
                                tTrackPhoneStatisticMatrix = vertcat(tTrackPhoneStatisticMatrix,[k,tTrackSmartPhoneSensorStatisticMatrix]);
                            end
                            writematrix(tTrackPhoneStatisticMatrix,tTrackPhoneCoarseClipStatisticFilePath);
                        end
                        % Tail statistic of track smart phone
                        tTrackPhoneStatisticMatrixColumns = size(tTrackPhoneStatisticMatrix,2);
                        zClipReferenceHeadTime = min(tTrackPhoneStatisticMatrix(:,tTrackPhoneStatisticMatrixColumns-1));
                        zClipReferenceTailTime = max(tTrackPhoneStatisticMatrix(:,tTrackPhoneStatisticMatrixColumns));

                        zClipHeadTime = floor(zClipReferenceHeadTime/60) * 60;
                        zClipTailTime = ceil(zClipReferenceTailTime/60) * 60;
                        zGroundTruthNavData = novatelSpanData(novatelSpanData(:,1) >= zClipHeadTime & novatelSpanData(:,1) <= zClipTailTime,:);
                        zGroundTruthImuData = jZMINS200Data(jZMINS200Data(:,1) >= zClipHeadTime & jZMINS200Data(:,1) <= zClipTailTime,:);
                        writematrix(zGroundTruthNavData,tTrackGroundTruthNavFilePath);
                        writematrix(zGroundTruthImuData,tTrackGroundTruthImuFilePath);
                    end
                end
            end
        end
        % Tail statistic of track
        logMsg = sprintf('Statistic track %s', tTrackFolderNameStr);
        log2terminal('I',TAG,logMsg);

    else
        logMsg = sprintf('Not have track %s on %s',tTrackFolderNameSt,cDatasetCollectionDater);
        log2terminal('W',TAG,logMsg);
    end
end

