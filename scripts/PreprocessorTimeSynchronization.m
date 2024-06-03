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
cPreprocessTrackList = ["0008"];
% cPreprocessTrackList = ["0008" "0009" "0010" "0011" "0012" "0013" "0014" "0015" "0016"];
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
% 添加输出预处理时间同步文件
cResampledSynchronizationTimeOffsetFileName = 'ResampledSynchronizationTimeOffset.txt';
cTrackSynchronizedFileName = 'TrackSynchronized.csv';

% DEBUG: 配置是否重新计算
isRecomputeTrackSynchronizedFile = true;

% DEBUG: 配置可视化时间同步传感器测量值
cVisualizeCoarseClipData = 0;
cVisualizeFineClipData = 1;
cVisualizeResampledClipData = 1;
cVisualizeSynchronizedClipData = 1;

% TODO: S1.5: 配置初始时间同步
cInitTimeSynchronizationIndex = 15;
prevTimeSynchronizationIndex = 0;

% DEBUG: 配置可视化全局时间同步
cVisualizeGlobalSynchronization = true;

% DEBUG: 配置可视化局部时间同步
cVisualizeLocalSynchronization = false;


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
                    cTrackSynchronizedFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackSynchronizedFileName);
                   
                    if ~isfile(cTrackSynchronizedFilePath) || isRecomputeTrackSynchronizedFile
                        % DEBUG: Visualize coarse clip
                        tTrackGroundTruthImuFilePath = fullfile(tDayZeroOClockAlignFolderPath,cTrackGroundTruthImuFileName);
                        plotGroundTruthImuData(cVisualizeCoarseClipData,tTrackGroundTruthImuFilePath);

                        tTrackSmartPhoneSensorGyroscopeUncalibratedFilePath = fullfile(tDayZeroOClockAlignFolderPath,kMotionSensorGyroscopeUncalibratedFileNameString);
                        tTrackSmartPhoneSensorAccelerometerUncalibratedFilePath = fullfile(tDayZeroOClockAlignFolderPath,kMotionSensorAccelerometerUncalibratedFileNameString);
                        plotSmartPhoneImuData(cVisualizeCoarseClipData,tTrackSmartPhoneSensorGyroscopeUncalibratedFilePath,tTrackSmartPhoneSensorAccelerometerUncalibratedFilePath);

                        % 去除原始数据中的重复数据
                        groundTruthImuRawData = readmatrix(tTrackGroundTruthImuFilePath);
                        groundTruthImuData = groundTruthImuRawData;
                        groundTruthImuDataTabulate = tabulate(groundTruthImuRawData(:,1));
                        groundTruthImuDataTabulateSorted = sortrows(groundTruthImuDataTabulate,2,'descend');
                        if groundTruthImuDataTabulateSorted(1,2) >= 2
                            duplicateData = groundTruthImuDataTabulateSorted(groundTruthImuDataTabulateSorted(:,2)>=2,:);
                            duplicateDataSize = size(duplicateData,1);

                            logMsg = sprintf('Duplicate ground truth IMU data count %d',duplicateDataSize);
                            log2terminal('E',TAG,logMsg);

                            for duplicateDataCounter = 1:duplicateDataSize
                                tDuplicateData = duplicateData(duplicateDataCounter,:);
                                logMsg = sprintf('Duplicate ground truth IMU data timestamp %.3f s, count %d',tDuplicateData(1),tDuplicateData(2));
                                log2terminal('E',TAG,logMsg);
                                
                                if duplicateDataCounter > 3
                                    break;
                                end

                            end
                            groundTruthImuData = unique(groundTruthImuRawData,'rows');
                        end

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

                        % DEBUG: Visualize fine clip
                        fineClipReferenceHeadTime = max(min(smartPhoneImuGyroscopeData(:,2)),min(smartPhoneImuAccelerometerData(:,2)));
                        fineClipReferenceTailTime = min(max(smartPhoneImuGyroscopeData(:,2)),max(smartPhoneImuAccelerometerData(:,2)));
                        fineClipHeadTime = floor(fineClipReferenceHeadTime / 60) * 60;
                        fineClipTailTime = ceil(fineClipReferenceTailTime / 60) * 60;
                        fineClipGroundTruthImuData = groundTruthImuData(groundTruthImuData(:,1) >= fineClipHeadTime & groundTruthImuData(:,1) <= fineClipTailTime,:);
                        plotComparedImuData(cVisualizeFineClipData,fineClipGroundTruthImuData,smartPhoneImuGyroscopeData,smartPhoneImuAccelerometerData);
                        

                        % Step: Visualize resampled sensor data
                        groundTruthImuDataSize= size(groundTruthImuData,1);
                        resampleHeadTime = ceil(max([fineClipReferenceHeadTime,groundTruthImuData(1,1),tTrackGroundTruthNavData(1,1)]));
                        resampleTailTime = floor(min([fineClipReferenceTailTime,groundTruthImuData(groundTruthImuDataSize,1),tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1)]));
                        
                        resampleHeadTimeString = convertDaySecondsToString(resampleHeadTime,0);
                        resampleTailTimeString = convertDaySecondsToString(resampleTailTime,0);
                        logMsg = sprintf('Track %s, phone %s, resample time from %s to %s',tTrackFolderNameStr,tTrackSmartPhoneFolderNameChar,resampleHeadTimeString,resampleTailTimeString);
                        log2terminal('I',TAG,logMsg);
                        
                        resampleRate = 200;
                        resampleInterval = 1 / resampleRate;
                        resampleTime = (resampleHeadTime:resampleInterval:resampleTailTime)';
                        resampleTimeSize = size(resampleTime,1);

                        resampledGroundTruthAccelerometerData = interp1(fineClipGroundTruthImuData(:,1),fineClipGroundTruthImuData(:,2:4),resampleTime);
                        resampledSmartPhoneAccelerometerData = interp1(smartPhoneImuAccelerometerData(:,2),smartPhoneImuAccelerometerData(:,4:6),resampleTime);
                        plotComparedResampledData(cVisualizeResampledClipData,resampleTime,resampledGroundTruthAccelerometerData,resampledSmartPhoneAccelerometerData);

                        % 基于种子同步时间差计算全局时间同步
                        cSynchronizationAxis = 2;
                        if prevTimeSynchronizationIndex == 0
                            globalSynchronizeTimeIndex = -cInitTimeSynchronizationIndex;
                        else
                            globalSynchronizeTimeIndex = prevTimeSynchronizationIndex;
                        end
                        
                        analysisGlobalSynchronizeTimeIndexRadius = 100;
                        analysisGlobalSynchronizeTimeIndexListHead = globalSynchronizeTimeIndex - analysisGlobalSynchronizeTimeIndexRadius;
                        analysisGlobalSynchronizeTimeIndexListTail = globalSynchronizeTimeIndex + analysisGlobalSynchronizeTimeIndexRadius;
                        analysisGlobalSynchronizeTimeIndexList = (analysisGlobalSynchronizeTimeIndexListHead:analysisGlobalSynchronizeTimeIndexListTail)';
                        analysisGlobalSynchronizeTimeIndexListSize = size(analysisGlobalSynchronizeTimeIndexList,1);
                        globalSynchronizeTimeIndexStatistic = zeros(analysisGlobalSynchronizeTimeIndexListSize,5);
                        for k = 1:analysisGlobalSynchronizeTimeIndexListSize
                            tGlobalSynchronizeTimeIndex = analysisGlobalSynchronizeTimeIndexList(k);
                            if tGlobalSynchronizeTimeIndex < 0
                                xcorrDataX = resampledGroundTruthAccelerometerData(-tGlobalSynchronizeTimeIndex:resampleTimeSize,cSynchronizationAxis);
                                xcorrDataY = resampledSmartPhoneAccelerometerData(1:(resampleTimeSize+tGlobalSynchronizeTimeIndex+1),cSynchronizationAxis);
                            else
                                xcorrDataX = resampledGroundTruthAccelerometerData(1:(resampleTimeSize-tGlobalSynchronizeTimeIndex),cSynchronizationAxis);
                                xcorrDataY = resampledSmartPhoneAccelerometerData(tGlobalSynchronizeTimeIndex+1:resampleTimeSize,cSynchronizationAxis);
                            end
                            [xcorrDataR,xcorrDataLags] = xcorr(xcorrDataX,xcorrDataY,'normalized');
                            xcorrDataRMax = max(xcorrDataR);
                            xcorrDataRMaxIndex = find(xcorrDataR == xcorrDataRMax);
                            xcorrDataRMaxLag = xcorrDataLags(xcorrDataRMaxIndex);
                            % figure;
                            % stem(xcorrDataLags,xcorrDataR);
                            globalSynchronizeTimeIndexStatistic(k,1) = tGlobalSynchronizeTimeIndex;
                            globalSynchronizeTimeIndexStatistic(k,2) = xcorrDataRMaxLag;
                            globalSynchronizeTimeIndexStatistic(k,3) = tGlobalSynchronizeTimeIndex-xcorrDataRMaxLag;
                            globalSynchronizeTimeIndexStatistic(k,4) = xcorrDataRMax;
                        end

                        globalSynchronizeTimeIndexStatisticTabulate = tabulate(globalSynchronizeTimeIndexStatistic(:,3));
                        % 
                        globalSynchronizeTimeIndexStatisticTabulateValid = globalSynchronizeTimeIndexStatisticTabulate(globalSynchronizeTimeIndexStatisticTabulate(:,2)>0,:);
                        globalSynchronizeTimeIndexStatisticTabulateSorted = sortrows(globalSynchronizeTimeIndexStatisticTabulateValid,2,'descend');
                        globalSynchronizeTimeIndexStatisticTabulateSortedSize = size(globalSynchronizeTimeIndexStatisticTabulateSorted,1);
                        
                        if globalSynchronizeTimeIndexStatisticTabulateSortedSize >= 3
                            logMsg = sprintf('No convergence for global synchronize time, size %d',globalSynchronizeTimeIndexStatisticTabulateSortedSize);
                            log2terminal('E',TAG,logMsg);
                        end

                        for globalSynchronizeTimeIndexTraversal = 1:globalSynchronizeTimeIndexStatisticTabulateSortedSize
                            tGlobalSynchronizeTimeIndex = globalSynchronizeTimeIndexStatisticTabulateSorted(globalSynchronizeTimeIndexTraversal,1);
                            tGlobalSynchronizeTimeIndexStatistic = globalSynchronizeTimeIndexStatistic(globalSynchronizeTimeIndexStatistic(:,3)==tGlobalSynchronizeTimeIndex,:);
                            tGlobalSynchronizeTimeIndexStatisticMaxXcorrDataRMax = max(tGlobalSynchronizeTimeIndexStatistic(:,4));
                            globalSynchronizeTimeIndexStatisticTabulateSorted(globalSynchronizeTimeIndexTraversal,4) = tGlobalSynchronizeTimeIndexStatisticMaxXcorrDataRMax;
                            logMsg = sprintf('Statistic Index: %d SyncIndex: %d StatisticNum: %d SyncXcorrMax: %.6f',globalSynchronizeTimeIndexTraversal,tGlobalSynchronizeTimeIndex,globalSynchronizeTimeIndexStatisticTabulateSorted(globalSynchronizeTimeIndexTraversal,2),tGlobalSynchronizeTimeIndexStatisticMaxXcorrDataRMax);
                            log2terminal('I',TAG,logMsg);
                        end

                        globalSynchronizeTimeIndexStatisticTabulateSortedSorted = sortrows(globalSynchronizeTimeIndexStatisticTabulateSorted,4,'descend');
                        globalSynchronizeTimeIndexSelected = globalSynchronizeTimeIndexStatisticTabulateSortedSorted(1,1);
                        globalSynchronizeTimeOffsetSelected = -globalSynchronizeTimeIndexSelected * resampleInterval;

                        cResampledSynchronizationTimeOffsetFilePath = fullfile(tDayZeroOClockAlignFolderPath,cResampledSynchronizationTimeOffsetFileName);
                        if isfile(cResampledSynchronizationTimeOffsetFilePath)
                            cResampledSynchronizationTimeOffsetData = readmatrix(cResampledSynchronizationTimeOffsetFilePath);
                            if abs(cResampledSynchronizationTimeOffsetData - globalSynchronizeTimeOffsetSelected) > 1e-6
                                logMsg = sprintf('Recompute synchronization time offset not equal, file %.3f compared with recomputed %.3f',cResampledSynchronizationTimeOffsetData,globalSynchronizeTimeOffsetSelected);
                                log2terminal('E',TAG,logMsg);
                            end
                        else
                            writematrix(globalSynchronizeTimeOffsetSelected,cResampledSynchronizationTimeOffsetFilePath);
                        end

                        if cVisualizeGlobalSynchronization
                            figure;
                            subPlotRows = 2;
                            subPlotColumns = 1;
                            subplot(subPlotRows,subPlotColumns,1);
                            plot(globalSynchronizeTimeIndexStatistic(:,1),globalSynchronizeTimeIndexStatistic(:,3));
                            subplot(subPlotRows,subPlotColumns,2);
                            plot(globalSynchronizeTimeIndexStatistic(:,1),globalSynchronizeTimeIndexStatistic(:,4));

                            logMsg = sprintf('Global synchronization');
                            log2terminal('D',TAG,logMsg);
                        end

                        if cVisualizeLocalSynchronization
                            analysisCorrelationTimeLength = 3;
                            analysisCorrelationSampleLength = analysisCorrelationTimeLength * resampleRate;
                            analysisSampleHeadTime = 14427;
                            analysisSampleHeadIndex = find(resampleTime == analysisSampleHeadTime);
                            analysisSampleTailIndex = analysisSampleHeadIndex + analysisCorrelationSampleLength - 1;
                            analysisSampleIndex = analysisSampleHeadIndex:analysisSampleTailIndex;
                            analysisResampleTime = resampleTime(analysisSampleIndex,:);
                            analysisResampledGroundTruthAccelerometerData = resampledGroundTruthAccelerometerData(analysisSampleIndex,:);

                            % Analyze the xcorr value around the synchronization offset
                            synchronizeTimeIndex = globalSynchronizeTimeIndex;
                            analysisSynchronizeTimeIndexRadius = 50;
                            analysisSynchronizeTimeIndexListHead = synchronizeTimeIndex - analysisSynchronizeTimeIndexRadius;
                            analysisSynchronizeTimeIndexListTail = synchronizeTimeIndex + analysisSynchronizeTimeIndexRadius;
                            analysisSynchronizeTimeIndexList = (analysisSynchronizeTimeIndexListHead:analysisSynchronizeTimeIndexListTail)';
                            analysisSynchronizeTimeIndexListSize = size(analysisSynchronizeTimeIndexList,1);
                            synchronizeTimeIndexStatistic = zeros(analysisSynchronizeTimeIndexListSize,5);
                            for k = 1:analysisSynchronizeTimeIndexListSize
                                tSynchronizeTimeIndex = analysisSynchronizeTimeIndexList(k);
                                analysisResampledSmartPhoneAccelerometerData = resampledSmartPhoneAccelerometerData(analysisSampleIndex+tSynchronizeTimeIndex,:);

                                analysisXCorrDataX = analysisResampledGroundTruthAccelerometerData(:,cSynchronizationAxis);
                                analysisXCorrDataY = analysisResampledSmartPhoneAccelerometerData(:,cSynchronizationAxis);
                                % [analysisXCorrDataR,analysisXCorrDataLags] = xcorr(analysisXCorrDataX,analysisXCorrDataY,'normalized');

                                if tSynchronizeTimeIndex == synchronizeTimeIndex
                                    plotComparedResampledData(1,analysisResampleTime,analysisResampledGroundTruthAccelerometerData,analysisResampledSmartPhoneAccelerometerData);
                                    figure;
                                    stem(analysisXCorrDataLags,analysisXCorrDataR);
                                    titleText = sprintf('%d',tSynchronizeTimeIndex);
                                    title(titleText);
                                end

                                analysisXCorrDataRMax = max(analysisXCorrDataR);
                                analysisXCorrDataRMaxIndex = find(analysisXCorrDataR == analysisXCorrDataRMax);
                                analysisXCorrDataRMaxLag = analysisXCorrDataLags(analysisXCorrDataRMaxIndex);

                                synchronizeTimeIndexStatistic(k,1) = tSynchronizeTimeIndex;
                                synchronizeTimeIndexStatistic(k,2) = analysisXCorrDataRMaxLag;
                                synchronizeTimeIndexStatistic(k,3) = tSynchronizeTimeIndex-analysisXCorrDataRMaxLag;
                                synchronizeTimeIndexStatistic(k,4) = analysisXCorrDataRMax;

                                logMsg = sprintf('Local synchronization');
                                log2terminal('D',TAG,logMsg);
                            end

                            figure;
                            subPlotRows = 2;
                            subPlotColumns = 1;
                            subplot(subPlotRows,subPlotColumns,1);
                            plot(synchronizeTimeIndexStatistic(:,1),synchronizeTimeIndexStatistic(:,3));
                            subplot(subPlotRows,subPlotColumns,2);
                            plot(synchronizeTimeIndexStatistic(:,1),synchronizeTimeIndexStatistic(:,4));
                        end


                        % Interpolate train data
                        synchronizeTimeBias = -globalSynchronizeTimeIndexSelected;
                        % synchronizeTimeBias = 15;
                        % prevTimeSynchronizationIndex = globalSynchronizeTimeIndexSelected;

                        logMsg = sprintf('Date %s, track %s, phone %s, synchronize time bias %.3f s',cDatasetCollectionDate,tTrackFolderNameStr,tTrackSmartPhoneFolderNameChar,synchronizeTimeBias * resampleInterval);
                        log2terminal('I',TAG,logMsg);

                       synchronizedMapTime = resampleTime + synchronizeTimeBias * resampleInterval;
                        
                        % 修复时间同步后SPAN尾部数据缺失的问题
                        if synchronizedMapTime(1,1) < tTrackGroundTruthNavData(1,1)
                            logMsg = sprintf('Synchronization resample head time issue, %.3f < %.3f',synchronizedMapTime(1,1),tTrackGroundTruthNavData(1,1));
                            log2terminal('E',TAG,logMsg);
                            synchronizedMapTime = synchronizedMapTime(synchronizedMapTime>=tTrackGroundTruthNavData(1,1));
                        end

                        if synchronizedMapTime(resampleTimeSize,1) > tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1)
                            logMsg = sprintf('Synchronization resample tail time issue, %.3f < %.3f',synchronizedMapTime(resampleTimeSize,1),tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1));
                            log2terminal('E',TAG,logMsg);
                            synchronizedMapTime = synchronizedMapTime(synchronizedMapTime<=tTrackGroundTruthNavData(tTrackGroundTruthNavDataSize,1));
                        end

                        resampledMapTime = synchronizedMapTime - synchronizeTimeBias * resampleInterval;
                        synchronizedDataSize = size(synchronizedMapTime,1);
                        synchronizedData = zeros(synchronizedDataSize,1+6+6+9+3+3);
                        synchronizedData(:,1) = synchronizedMapTime;
                        synchronizedData(:,2:4) = interp1(smartPhoneImuGyroscopeData(:,2),smartPhoneImuGyroscopeData(:,4:6),resampledMapTime);
                        synchronizedData(:,5:7) = interp1(smartPhoneImuAccelerometerData(:,2),smartPhoneImuAccelerometerData(:,4:6),resampledMapTime);
                        synchronizedData(:,8:10) = interp1(fineClipGroundTruthImuData(:,1),fineClipGroundTruthImuData(:,5:7),synchronizedData(:,1));
                        synchronizedData(:,11:13) = interp1(fineClipGroundTruthImuData(:,1),fineClipGroundTruthImuData(:,2:4),synchronizedData(:,1));
                        interpGroundTruthData = interpolateSpanRawData(tTrackGroundTruthNavData,synchronizedData(:,1));
                        synchronizedData(:,14:28) = interpGroundTruthData;

                        plotComparedResampledData(cVisualizeSynchronizedClipData,synchronizedData(:,1),synchronizedData(:,11:13),synchronizedData(:,5:7));

                        writematrix(synchronizedData,cTrackSynchronizedFilePath);
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

