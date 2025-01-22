% 重置工作区环境
clearvars;
close all;
dbstop error;
% clc;

% 添加自定义工具类函数
addpath(genpath(pwd));
fullpath = mfilename('fullpath');
[folderPath,fileName]=fileparts(fullpath);
TAG = fileName;

S2MS = 1e3;
MS2S = 1/S2MS;
S2NS = 1e9;
NS2S = 1/S2NS;
MS2NS = 1e6;
NS2MS = 1/MS2NS;
US2NS = 1e3;
NS2US = 1/US2NS;

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
cPaletteViridisCategories11Color = [
    "#fde725",...
    "#bddf26",...
    "#7ad151",...
    "#44bf70",...
    "#22a884",...
    "#21918c",...
    "#2a788e",...
    "#355f8d",...
    "#414487",...
    "#482475",...
    "#440154"
];

% cPhone = 'GOOGLE_Pixel3';
cPhone = 'HUAWEI_Mate30';

% TODO: S2.1: 配置调试模式
% cDebug = true;
cDebug = false;

tSequenceGnssMeasurementEventTable = [];
if ~isfolder(cDatasetLevel3ReorganizedFolderPath)
    logMsg = sprintf('Not folder path %s',cDatasetLevel3ReorganizedFolderPath);
    log2terminal('E',TAG,logMsg);
else
    logTrackDenominator = cDatasetLevel4TrackFolderNameListLength;
    % Headjianzhi iterate drive_id
    for i = 1:cDatasetLevel4TrackFolderNameListLength
        logTrackNumerator = i;
        tDatasetLevel4TrackFolderName = cDatasetLevel4TrackFolderNameList(i);
        tTrackNumber = str2double(tDatasetLevel4TrackFolderName);

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
                    if ~strcmp(tDatasetLevel5FolderPhoneName,cPhone)
                        continue;
                    end

                    tDatasetLevel5FolderPhonePath = fullfile(tDatasetLevel4TrackFolderPath,tDatasetLevel5FolderPhoneName);
                    logMsg = sprintf('drive id: %s (%d/%d), phone name: %s', ...
                        tDatasetLevel4TrackFolderName, logTrackNumerator, logTrackDenominator, ...
                        tDatasetLevel5FolderPhoneName ...
                        );
                    log2terminal('I',TAG,logMsg);

                    tSensorGnssMeasurementFilePath = fullfile(tDatasetLevel5FolderPhonePath,"raw","GnssMeasurement.csv");
                    tSensorGnssMeasurementRawData = readmatrix(tSensorGnssMeasurementFilePath);

                    tSystClockGnssMeasurementEventTime = tSensorGnssMeasurementRawData(:,1);
                    tGnssClockGnssMeasurementEventTime = tSensorGnssMeasurementRawData(:,4) - (tSensorGnssMeasurementRawData(:,6) + tSensorGnssMeasurementRawData(:,7));

                    tSmartphoneRawSystemClockSize = size(tGnssClockGnssMeasurementEventTime,1);
                    tSequenceMarker = ones(tSmartphoneRawSystemClockSize,1) * tTrackNumber;
                    tSequenceGnssMeasurementEventTable = [tSequenceGnssMeasurementEventTable;[tSequenceMarker,tSystClockGnssMeasurementEventTime,tGnssClockGnssMeasurementEventTime]];

                end
            end
            % Tail iterate phone_name
        end
    end
    % Tail iterate drive_id
end

pSequenceGnssMeasurementEventTable = tSequenceGnssMeasurementEventTable;
systClockGnssMeasurementEventTime = pSequenceGnssMeasurementEventTable(:,2);
[utcTimeZeroOClockTimeDateTime,dUtcTimeZeroOClockTimeOffset] = getUtcTimeMapZeroOClockTime(systClockGnssMeasurementEventTime(1) * MS2S);
systClockGnssMeasurementEventTime = systClockGnssMeasurementEventTime - dUtcTimeZeroOClockTimeOffset * S2MS;

gnssClockGnssMeasurementEventTime = pSequenceGnssMeasurementEventTable(:,3);
[gnssTimeZeroOClockTimeDateTime,dGnssTimeZeroOClockTimeOffset] = getGnssClockGpsTimeMapZeroOClockTime(gnssClockGnssMeasurementEventTime(1));
referenceZeroOClockLeapseconds = getZeroOClockTimeGpsTimeLeapseconds(gnssTimeZeroOClockTimeDateTime);
gnssClockGnssMeasurementEventTime = gnssClockGnssMeasurementEventTime - dGnssTimeZeroOClockTimeOffset * S2NS - referenceZeroOClockLeapseconds * S2NS;

minSystClockGnssMeasurementEventTime = min(systClockGnssMeasurementEventTime);
pReferenceSystClockGnssMeasurementEventTime = floor(minSystClockGnssMeasurementEventTime * MS2S) * S2MS;
minGnssClockGnssMeasurementEventTime = min(gnssClockGnssMeasurementEventTime);
pReferenceGnssClockGnssMeasurementEventTime = floor(minGnssClockGnssMeasurementEventTime * NS2S) * S2NS;

pDeltaTime = (systClockGnssMeasurementEventTime * MS2NS - gnssClockGnssMeasurementEventTime) * NS2MS;
pReferenceDeltaTime = floor(mean(pDeltaTime));

% [utcTimeZeroOClockTimeDateTime,dUtcTimeZeroOClockTimeOffset] = getUtcTimeMapZeroOClockTime(pReferenceBootTimeNanosSystemBase * NS2S);
% pReferenceBootTimeSystemBaseDZRT = pReferenceBootTimeNanosSystemBase * NS2S - dUtcTimeZeroOClockTimeOffset;
% pReferenceBootTimeSystemBaseDZRTHour = floor(pReferenceBootTimeSystemBaseDZRT/3600);
% pReferenceBootTimeSystemBaseDZRTMinusHour = pReferenceBootTimeSystemBaseDZRT - pReferenceBootTimeSystemBaseDZRTHour * 3600;
% pReferenceBootTimeSystemBaseDZRTMinute = floor(pReferenceBootTimeSystemBaseDZRTMinusHour/60);
% pReferenceBootTimeSystemBaseDZRTMinusMinute = pReferenceBootTimeSystemBaseDZRTMinusHour - pReferenceBootTimeSystemBaseDZRTMinute * 60;
% pReferenceBootTimeSystemBaseDZRTSecond = floor(pReferenceBootTimeSystemBaseDZRTMinusMinute);
% pReferenceBootTimeSystemBaseDZRTMinusSecond = pReferenceBootTimeSystemBaseDZRTMinusMinute - pReferenceBootTimeSystemBaseDZRTSecond;

rGpsReferenceDateTime = datetime(1980,1,6);
rGpsReferencePosixTime = convertTo(rGpsReferenceDateTime,'posixtime');

pReferenceSystClockGnssMeasurementEventTimeSecond = rGpsReferencePosixTime + dGnssTimeZeroOClockTimeOffset + pReferenceSystClockGnssMeasurementEventTime * MS2S;
pReferenceSystClockGnssMeasurementEventTimeDatetime = datetime(pReferenceSystClockGnssMeasurementEventTimeSecond,'ConvertFrom','posixtime','TimeZone','Asia/Shanghai');
pReferenceGnssClockGnssMeasurementEventTimeSecond = rGpsReferencePosixTime + dGnssTimeZeroOClockTimeOffset + pReferenceGnssClockGnssMeasurementEventTime * NS2S;
pReferenceGnssClockGnssMeasurementEventTimeDatetime = datetime(pReferenceGnssClockGnssMeasurementEventTimeSecond,'ConvertFrom','posixtime','TimeZone','Asia/Shanghai');
format long;
logMsg = sprintf('绘图参考System Time: %s',string(pReferenceSystClockGnssMeasurementEventTimeDatetime,'yyyy-MM-dd''T''HH:mm:ss.SSSSSSSSSZZZZZ'));
log2terminal('I',TAG,logMsg);
logMsg = sprintf('绘图参考GNSS Time: %s',string(pReferenceGnssClockGnssMeasurementEventTimeDatetime,'yyyy-MM-dd''T''HH:mm:ss.SSSSSSSSSZZZZZ'));
log2terminal('I',TAG,logMsg);

pX = (gnssClockGnssMeasurementEventTime - pReferenceGnssClockGnssMeasurementEventTime) * NS2S;
pY = pDeltaTime - pReferenceDeltaTime;
figureObject = figure();
for i = 1:cDatasetLevel4TrackFolderNameListLength
    logTrackNumerator = i;
    tDatasetLevel4TrackFolderName = cDatasetLevel4TrackFolderNameList(i);
    tTrackNumber = str2double(tDatasetLevel4TrackFolderName);
    indices = find(pSequenceGnssMeasurementEventTable(:,1) == tTrackNumber);
    pTrackX = pX(indices);
    pTrackY = pY(indices);

    hold on;
    lineObject = plot(pTrackX,pTrackY);
    % 线条
    set(lineObject,"Color",cPaletteViridisCategories11Color(i));
    set(lineObject,"LineStyle","none");
    % 标记
    set(lineObject,"Marker",".");
    % 图例
    set(lineObject,'DisplayName',extractAfter(tDatasetLevel4TrackFolderName,2));
    hold off;
end

legend();

axesObject = gca;
% 字体
set(axesObject,'FontName','Times New Roman');
set(axesObject,'FontSize',10.5);

% 网格
% axesPropertyYLim = get(axesObject,'YLim');
axesPropertyYLim = [floor(min(pY)) ceil(max(pY))];
set(axesObject,'YLim',axesPropertyYLim);

% 网格
set(axesObject,'Layer','top');

% 标签
set(get(axesObject,'XLabel'),'String','\fontname{宋体}采样时间\fontname{Times new roman}(s)');
% set(get(axesObject,'XLabel'),'FontName','宋体');
set(get(axesObject,'YLabel'),'String','\fontname{宋体}系统时钟和GNSS时钟采样时间差\fontname{Times new roman}(ms)');
% set(get(axesObject,'YLabel'),'FontName','宋体');

set(get(axesObject,'Legend'),'Location','northoutside');
set(get(axesObject,'Legend'),'Orientation','horizontal');
set(get(axesObject,'Legend'),'NumColumns',cDatasetLevel4TrackFolderNameListLength);
set(get(axesObject,'Legend'),'FontName','Times New Roman');
set(get(axesObject,'Legend'),'FontSize',10.5);

% http://gs.xjtu.edu.cn/info/1209/7605.htm
% 参考《西安交通大学博士、硕士学位论文模板（2021版）》中对图的要求
% 图尺寸的一般宽高比应为6.67 cm×5.00 cm。特殊情况下， 也可为
% 9.00 cm×6.75 cm， 或13.5 cm×9.00 cm。总之， 一篇论文中， 同类图片的
% 大小应该一致，编排美观、整齐；
figurePropertiesPositionLeft = 10;
figurePropertiesPositionBottom = 10;
figurePropertiesPositionWidth = 16;
figurePropertiesPositionHeight = 9;
figurePropertiesPosition = [ ...
    figurePropertiesPositionLeft ...
    figurePropertiesPositionBottom ...
    figurePropertiesPositionWidth ...
    figurePropertiesPositionHeight ...
    ];
figurePropertiesPaperSize = [figurePropertiesPositionWidth figurePropertiesPositionHeight];
% 位置和大小
set(gcf,'Units','centimeters');
set(gcf,'Position',figurePropertiesPosition);
% 打印和导出
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',figurePropertiesPosition);
set(gcf,'PaperSize',figurePropertiesPaperSize);

set(gcf,'PaperOrientation','landscape');

cPhoneSplit = strsplit(cPhone,'_');
cAndroidSystemClockBootTimeStabilityFileName = strcat('AndroidSystemMinusGnssClockGnssMeasurementEventTime',cPhoneSplit{1},cPhoneSplit{2},'.png');
cAndroidSystemClockBootTimeStabilityFilePath = fullfile(cDatasetLevel3ReorganizedFolderPath,cAndroidSystemClockBootTimeStabilityFileName);
exportgraphics(gcf,cAndroidSystemClockBootTimeStabilityFilePath,'Resolution',600);

% close(figureMapHandle);


