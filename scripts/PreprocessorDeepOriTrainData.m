% 重置工作区环境
close all;
clear;

% 添加自定义工具类函数
addpath(genpath(pwd));
TAG = 'PreprocessorDeepOriTrainData';

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
% cPreprocessTrackList = ["0008"];
cPreprocessTrackList = ["0008" "0009" "0010" "0011" "0012" "0013" "0014" "0015" "0016" "0017" "0018"];
cPreprocessTrackListLength = length(cPreprocessTrackList);
% TODO: S1.4: 配置数据集存储文件夹 采集手机
% cPhoneMapNumber = ["GOOGLE_Pixel3"];
cPhoneMapNumber = ["HUAWEI_Mate30"];
% cPhoneMapNumber = ["HUAWEI_P20"];
% cPhoneMapNumber = ["GOOGLE_Pixel3" "HUAWEI_Mate30"];
% cPhoneMapNumber = ["GOOGLE_Pixel3" "HUAWEI_Mate30" "HUAWEI_P20"];
kPhoneMapNumberLength = length(cPhoneMapNumber);

% TODO: S2.1: 2023年04月 11|13|15日 这三天的数据由于SPAN输出的频率为200Hz, 需要处理真值的时间戳精度不足的问题
isRecomputeTrackGroundTruthNavTime = false;
cTrackGroundTruthNavFileName = 'TrackGroundTruthNav.csv';


% 添加输入预处理粗切割存储文件夹
load 'SmartPhoneDataConfig.mat';
cDayZeroOClockAlignFolderName = 'dayZeroOClockAlign';
cTrackGroundTruthImuFileName = 'TrackGroundTruthImu.csv';
cResampledSynchronizationTimeOffsetFileName = 'ResampledSynchronizationTimeOffset.txt';
% 添加输出预处理时间同步文件
cDatasetDeepOriModelFolderName = 'DATASET_DEEPORI';
cDeepOriTrainDataFileName = 'DeepOriTrainData.csv';

% DEBUG: 配置是否重新计算
isRecomputeDeepOriTrainDataFile = true;

for i = 1:cPreprocessTrackListLength
    tTrackFolderNameStr = cPreprocessTrackList(i);
    tTrackFolderPath = fullfile(cReorganizedFolderPath,tTrackFolderNameStr);
    if isfolder(tTrackFolderPath)
        % Head statistic of track
        tTrackFolderDir = dir(tTrackFolderPath);
        tTrackFolderDirLength = length(tTrackFolderDir);
        for j = 1:kPhoneMapNumberLength
            tTrackSmartPhoneFolderNameChar = cPhoneMapNumber(j);
            if ~strcmp(tTrackSmartPhoneFolderNameChar,'.') && ~strcmp(tTrackSmartPhoneFolderNameChar,'..')
                tTrackSmartPhoneFolderPath = fullfile(tTrackFolderPath,tTrackSmartPhoneFolderNameChar);
                if isfolder(tTrackSmartPhoneFolderPath)
                    tDayZeroOClockAlignFolderPath = fullfile(tTrackSmartPhoneFolderPath,cDayZeroOClockAlignFolderName);

                    cDatasetDeepOdoModelFolderPath = fullfile(tTrackSmartPhoneFolderPath,cDatasetDeepOriModelFolderName);
                    if ~isfolder(cDatasetDeepOdoModelFolderPath)
                        mkdir(cDatasetDeepOdoModelFolderPath);
                    end

                    cDeepOdoTrainDataFilePath = fullfile(cDatasetDeepOdoModelFolderPath,cDeepOriTrainDataFileName);

                    if ~isfile(cDeepOdoTrainDataFilePath) || isRecomputeDeepOriTrainDataFile
                        tTrackSmartPhoneSensorGyroscopeUncalibratedFilePath = fullfile(tDayZeroOClockAlignFolderPath,kMotionSensorGyroscopeUncalibratedFileNameString);
                        tTrackSmartPhoneSensorAccelerometerUncalibratedFilePath = fullfile(tDayZeroOClockAlignFolderPath,kMotionSensorAccelerometerUncalibratedFileNameString);
                        tTrackSmartPhoneSensorPressureFilePath = fullfile(tDayZeroOClockAlignFolderPath,kEnvironmentSensorPressureFileNameString);

                        % 去除原始数据中的重复数据
                        smartPhoneImuGyroscopeRawData = readmatrix(tTrackSmartPhoneSensorGyroscopeUncalibratedFilePath);
                        smartPhoneImuGyroscopeData = smartPhoneImuGyroscopeRawData;
                        smartPhoneImuGyroscopeRawDataTabulate = tabulate(smartPhoneImuGyroscopeRawData(:,2));
                        smartPhoneImuGyroscopeRawDataTabulateSorted = sortrows(smartPhoneImuGyroscopeRawDataTabulate,2,'descend');
                        if smartPhoneImuGyroscopeRawDataTabulateSorted(1,2) >= 2
                            duplicateData = smartPhoneImuGyroscopeRawDataTabulate(smartPhoneImuGyroscopeRawDataTabulate(:,2)>=2,:);
                            duplicateDataSize = size(duplicateData,1);

                            logMsg = sprintf('Duplicate smart phone gyroscope data count %d',duplicateDataSize);
                            log2terminal('E',TAG,logMsg);

                            for duplicateDataCounter = 1:duplicateDataSize
                                tDuplicateData = duplicateData(duplicateDataCounter,:);
                                logMsg = sprintf('Duplicate smart phone gyroscope data timestamp %.3f s, count %d',tDuplicateData(1),tDuplicateData(2));
                                log2terminal('E',TAG,logMsg);

                                if duplicateDataCounter > 3
                                    break;
                                end

                            end
                            [~,ia,~] = unique(smartPhoneImuGyroscopeRawData(:,2),'rows');
                            smartPhoneImuGyroscopeData = smartPhoneImuGyroscopeRawData(ia,:);
                        end
                        smartPhoneImuGyroscopeDataSize = size(smartPhoneImuGyroscopeData,1);
                        smartPhoneImuGyroscopeDataTimeHead = smartPhoneImuGyroscopeData(1,2);
                        smartPhoneImuGyroscopeDataTimeTail = smartPhoneImuGyroscopeData(smartPhoneImuGyroscopeDataSize,2);

                        smartPhoneImuAccelerometerRawData = readmatrix(tTrackSmartPhoneSensorAccelerometerUncalibratedFilePath);
                        smartPhoneImuAccelerometerData = smartPhoneImuAccelerometerRawData;
                        smartPhoneImuAccelerometerRawDataTabulate = tabulate(smartPhoneImuAccelerometerRawData(:,2));
                        smartPhoneImuAccelerometerRawDataTabulateSorted = sortrows(smartPhoneImuAccelerometerRawDataTabulate,2,'descend');
                        if smartPhoneImuAccelerometerRawDataTabulateSorted(1,2) >= 2
                            duplicateData = smartPhoneImuAccelerometerRawDataTabulate(smartPhoneImuAccelerometerRawDataTabulate(:,2)>=2,:);
                            duplicateDataSize = size(duplicateData,1);

                            logMsg = sprintf('Duplicate smart phone accelerometer data count %d',duplicateDataSize);
                            log2terminal('E',TAG,logMsg);

                            for duplicateDataCounter = 1:duplicateDataSize
                                tDuplicateData = duplicateData(duplicateDataCounter,:);
                                logMsg = sprintf('Duplicate smart phone accelerometer data timestamp %.3f s, count %d',tDuplicateData(1),tDuplicateData(2));
                                log2terminal('E',TAG,logMsg);

                                if duplicateDataCounter > 3
                                    break;
                                end

                            end
                            [~,ia,~] = unique(smartPhoneImuAccelerometerRawData(:,2),'rows');
                            smartPhoneImuAccelerometerData = smartPhoneImuAccelerometerRawData(ia,:);
                        end
                        smartPhoneImuAccelerometerDataSize = size(smartPhoneImuAccelerometerData,1);
                        smartPhoneImuAccelerometerDataTimeHead = smartPhoneImuAccelerometerData(1,2);
                        smartPhoneImuAccelerometerDataTimeTail = smartPhoneImuAccelerometerData(smartPhoneImuAccelerometerDataSize,2);

                        smartPhonePressureRawData = readmatrix(tTrackSmartPhoneSensorPressureFilePath);
                        smartPhonePressureData = smartPhonePressureRawData;
                        smartPhonePressureDataSize = size(smartPhonePressureData,1);
                        smartPhonePressureDataTimeHead = smartPhonePressureData(1,2);
                        smartPhonePressureDataTimeTail = smartPhonePressureData(smartPhonePressureDataSize,2);

                        % 修复200Hz输出频率下SPAN时间戳精度不足的问题
                        tTrackGroundTruthNavFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackGroundTruthNavFileName);
                        tTrackGroundTruthNavDataRaw = readmatrix(tTrackGroundTruthNavFilePath);
                        tTrackGroundTruthNavData = tTrackGroundTruthNavDataRaw;
                        tTrackGroundTruthNavDataSize = size(tTrackGroundTruthNavData,1);
                        if isRecomputeTrackGroundTruthNavTime
                            if tTrackGroundTruthNavData(1,1) == tTrackGroundTruthNavData(2,1)
                                headTime = tTrackGroundTruthNavData(1,1);
                            else
                                headTime = tTrackGroundTruthNavData(1,1) + 0.005;
                            end

                            if tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize-1,1) == tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1)
                                tailTime = tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1) + 0.005;
                            else
                                tailTime = tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1);
                            end

                            fixedTime = (headTime:0.005:tailTime)';
                            tTrackGroundTruthNavData(:,1) = fixedTime;
                        end
                        groundTruthNavDataTimeHead = tTrackGroundTruthNavData(1,1);
                        groundTruthNavDataTimeTail = tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1);
                        

                        cResampledSynchronizationTimeOffsetFilePath = fullfile(tDayZeroOClockAlignFolderPath,cResampledSynchronizationTimeOffsetFileName);
                        if isfile(cResampledSynchronizationTimeOffsetFilePath)
                            cResampledSynchronizationTimeOffsetData = readmatrix(cResampledSynchronizationTimeOffsetFilePath);
                        else
                            logMsg = sprintf('Not have file %s',cResampledSynchronizationTimeOffsetFileName);
                            log2terminal('E',TAG,logMsg);
                        end


                        sensorHeadTimeList = [smartPhoneImuGyroscopeDataTimeHead smartPhoneImuAccelerometerDataTimeHead smartPhonePressureDataTimeHead];
                        sensorTailTimeList = [smartPhoneImuGyroscopeDataTimeTail smartPhoneImuAccelerometerDataTimeTail smartPhonePressureDataTimeTail];
                        resamplePhoneHeadTime = max(sensorHeadTimeList);
                        resamplePhoneTailTime = min(sensorTailTimeList);

                        % Interpolate train data
                        synchronizeTimeOffset = cResampledSynchronizationTimeOffsetData;
                        resampleGroundTruthHeadTime = resamplePhoneHeadTime + synchronizeTimeOffset;
                        resampleGroundTruthTailTime = resamplePhoneTailTime + synchronizeTimeOffset;

                        % 修复时间同步后SPAN尾部数据缺失的问题
                        if resampleGroundTruthHeadTime < groundTruthNavDataTimeHead
                            logMsg = sprintf('Synchronization resample head time issue, %.3f < %.3f',resampleGroundTruthHeadTime,tTrackGroundTruthNavData(1,1));
                            log2terminal('E',TAG,logMsg);
                            resampleGroundTruthHeadTime = groundTruthNavDataTimeHead;
                        end

                        if resampleGroundTruthTailTime > groundTruthNavDataTimeTail
                            logMsg = sprintf('Synchronization resample tail time issue, %.3f < %.3f',resampleGroundTruthTailTime,groundTruthNavDataTimeTail);
                            log2terminal('E',TAG,logMsg);
                            resampleGroundTruthTailTime = groundTruthNavDataTimeTail;
                        end

                        resampleGroundTruthHeadTimeCeil = ceil(resampleGroundTruthHeadTime);
                        resampleGroundTruthTailTimeFloor = floor(resampleGroundTruthTailTime);
                        resampleRate = 200;
                        resampleInterval = 1 / resampleRate;
                        resampleGroundTruthTime = (resampleGroundTruthHeadTimeCeil:resampleInterval:resampleGroundTruthTailTimeFloor)';
                        resampleGroundTruthTimeSize = size(resampleGroundTruthTime,1);

                        resamplePhoneTime = resampleGroundTruthTime - synchronizeTimeOffset;

                        deepOriTrainData = zeros(resampleGroundTruthTimeSize,1+6+9);
                        deepOriTrainData(:,1) = resampleGroundTruthTime;
                        deepOriTrainData(:,2:4) = interp1(smartPhoneImuGyroscopeData(:,2),smartPhoneImuGyroscopeData(:,4:6),resamplePhoneTime);
                        deepOriTrainData(:,5:7) = interp1(smartPhoneImuAccelerometerData(:,2),smartPhoneImuAccelerometerData(:,4:6),resamplePhoneTime);
                        
                        interpGroundTruthData = interpolateSpanRawData(tTrackGroundTruthNavData,deepOriTrainData(:,1));
                        deepOriTrainData(:,8:16) = interpGroundTruthData(:,1:9);

                        writematrix(deepOriTrainData,cDeepOdoTrainDataFilePath);
                    end

                    % logMsg = sprintf('D');
                    % log2terminal('D',TAG,logMsg);
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

