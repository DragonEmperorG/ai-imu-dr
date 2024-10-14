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
cTrackSynchronizedFileName = 'TrackSynchronized.csv';
cTrackGroundTruthNavFileName = 'TrackGroundTruthNav.csv';
cSmartphoneGnssLocationFileName = 'GnssLocation.csv';
cResampledSynchronizationTimeOffsetFileName = 'ResampledSynchronizationTimeOffset.txt';
% 添加输出预处理时间同步文件
cDeepOriTrainDataFileName = 'SmartphoneGnssSynchronized.csv';

% DEBUG: 配置是否调试
cDebug = true;

for i = 1:cPreprocessTrackListLength
    tTrackFolderNameStr = cPreprocessTrackList(i);
    tTrackFolderPath = fullfile(cReorganizedFolderPath,tTrackFolderNameStr);
    if isfolder(tTrackFolderPath)
        % Head statistic of track

        if cDebug
            if ~strcmp(tTrackFolderNameStr,"0008")
                continue;
            end
        end

        tTrackFolderDir = dir(tTrackFolderPath);
        tTrackFolderDirLength = length(tTrackFolderDir);
        for j = 1:kPhoneMapNumberLength
            tTrackSmartPhoneFolderNameChar = cPhoneMapNumber(j);
            if ~strcmp(tTrackSmartPhoneFolderNameChar,'.') && ~strcmp(tTrackSmartPhoneFolderNameChar,'..')
                tTrackSmartPhoneFolderPath = fullfile(tTrackFolderPath,tTrackSmartPhoneFolderNameChar);
                if isfolder(tTrackSmartPhoneFolderPath)
                    
                    if ~strcmp(tTrackSmartPhoneFolderNameChar,'HUAWEI_Mate30')
                        continue;
                    end

                    tDayZeroOClockAlignFolderPath = fullfile(tTrackSmartPhoneFolderPath,cDayZeroOClockAlignFolderName);

                    iTrackSynchronizedData = fullfile(tDayZeroOClockAlignFolderPath,cTrackSynchronizedFileName);
                    trackSynchronizedRawData = readmatrix(iTrackSynchronizedData);

                    iTrackGroundTruthNavData = fullfile(tDayZeroOClockAlignFolderPath,cTrackGroundTruthNavFileName);
                    trackGroundTruthNavRawData = readmatrix(iTrackGroundTruthNavData);
                    trackGroundTruthNavDataTime = smartphoneGnssLocationRawData(:,1);
                    trackGroundTruthNavDataGeodeticCoordinate = smartphoneGnssLocationRawData(:,2:4);

                    iSmartphoneGnssLocationData = fullfile(tDayZeroOClockAlignFolderPath,cSmartphoneGnssLocationFileName);
                    smartphoneGnssLocationRawData = readmatrix(iSmartphoneGnssLocationData);
                    smartphoneGnssLocationRawDataSize = size(smartphoneGnssLocationRawData,1);
                    smartphoneGnssLocationDataTime = smartphoneGnssLocationRawData(:,2);
                    smartphoneGnssLocationDataGeodeticCoordinate = smartphoneGnssLocationRawData(:,6:8);
                    smartphoneGnssLocationDataMercatorCoordinate = zeros(size(smartphoneGnssLocationDataGeodeticCoordinate));

                    iResampledSynchronizationTimeOffsetFileData = fullfile(tDayZeroOClockAlignFolderPath,cResampledSynchronizationTimeOffsetFileName);
                    resampledSynchronizationTimeOffsetRawData = readmatrix(iResampledSynchronizationTimeOffsetFileData);

                    oHeadTime = ceil(trackSynchronizedRawData(1,1));
                    oTailTime = floor(trackSynchronizedRawData(1,end));
                    oTime = oHeadTime:1:oTailTime;
                    
                    tIndex = findTheNearestTimeIndexInVector(trackGroundTruthNavDataTime,oHeadTime);
                    rGeodeticCoordinate = trackGroundTruthNavDataGeodeticCoordinate(tIndex,:);
                    rScale = latToScale(spanRawData(1,2));
                    [referenceTransition(1,1),referenceTransition(1,2)] = latlonToMercator(rGeodeticCoordinate(1),rGeodeticCoordinate(2),rScale);
                    referenceTransition(1,3) = rGeodeticCoordinate(3);
                    for smartphoneGnssLocationRawDataTraversal = 1:smartphoneGnssLocationRawDataSize
                        [t(1,1),t(2,1)] = latlonToMercator(smartphoneGnssLocationDataGeodeticCoordinate(i,1),smartphoneGnssLocationDataGeodeticCoordinate(i,2),rScale);
                        t(3,1) = smartphoneGnssLocationDataGeodeticCoordinate(i,3);
                        smartphoneGnssLocationDataMercatorCoordinate(i,1:3) = t - referenceTransition;
                    end

                    iTime = smartphoneGnssLocationDataTime + resampledSynchronizationTimeOffsetRawData;
                    oTranslation = interp1(iTime,smartphoneGnssLocationDataMercatorCoordinate,oTime);
                    
                    
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

