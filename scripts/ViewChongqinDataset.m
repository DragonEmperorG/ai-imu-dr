%%% 小论文图片生成脚本

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
cDayZeroOClockAlignFolderName = 'dayZeroOClockAlign';
cTrackGroundTruthNavFileName = 'TrackGroundTruthNav.csv';

% TODO: S2.1: 配置调试模式
% cDebug = true;
cDebug = false;

figureMapHandle = figure;
% https://ww2.mathworks.cn/help/matlab/ref/geobasemap.html
geographicAxesObject = geoaxes("Basemap","satellite");

bboxMaxLatitude = -90;
bboxMinLatitude = 90;
bboxMaxLongitude = -180;
bboxMinLongitude = 180;

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
                    
                    tTrackGroundTruthNavFilePath = fullfile(tDatasetLevel5FolderPhonePath,cDayZeroOClockAlignFolderName,cTrackGroundTruthNavFileName);
                    tTrackGroundTruthNavData = readmatrix(tTrackGroundTruthNavFilePath);
                    tTrackGroundTruthNavDataTime = tTrackGroundTruthNavData(:,1);
                    tTrackSynchronizedData = loadPreprocessRawFlat(tDatasetLevel5FolderPhonePath);
                    tTrackSynchronizedDataTime = getPreprocessTime(tTrackSynchronizedData);
                    tTrackGroundTruthNavData = tTrackGroundTruthNavData(tTrackGroundTruthNavDataTime>=tTrackSynchronizedDataTime(1)&tTrackGroundTruthNavDataTime<=tTrackSynchronizedDataTime(end),:);

                    tGroundTruthNavDataLatitude = tTrackGroundTruthNavData(:,2);
                    tGroundTruthNavDataLongitude = tTrackGroundTruthNavData(:,3);
                    % tOxtsRawDataAltitude = zeros(size(tOxtsRawData(:,3)));

                    bboxMaxLatitude = max(bboxMaxLatitude,max(tGroundTruthNavDataLatitude));
                    bboxMinLatitude = min(bboxMinLatitude,min(tGroundTruthNavDataLatitude));
                    bboxMaxLongitude = max(bboxMaxLongitude,max(tGroundTruthNavDataLongitude));
                    bboxMinLongitude = min(bboxMaxLongitude,min(tGroundTruthNavDataLongitude));

                    hold on;
                    lineObject = geoplot(geographicAxesObject,tGroundTruthNavDataLatitude,tGroundTruthNavDataLongitude);
                    set(lineObject,'LineWidth',1.2);
                    % tDisplayName = extractAfter(tDatasetLevel4TrackFolderName,2);
                    tDisplayName = sprintf("%02d",logTrackNumerator);
                    set(lineObject,'DisplayName',tDisplayName);
                    hold off;
                end
            end
            % Tail iterate phone_name
        end
    end
    % Tail iterate drive_id
end

legend();

% gx.LatitudeLimits  = [dms2degrees([29 27 11.4]) dms2degrees([29 27 14.6])];
% gx.LongitudeLimits = [dms2degrees([106 28 15.9]) dms2degrees([106 28 20])];

% 字体
% set(geographicAxesObject,'FontName','Times New Roman');
% set(geographicAxesObject,'FontSize',10.5);

set(geographicAxesObject,'FontName','Arial');
set(geographicAxesObject,'FontSize',8);

% 标尺
cLatitudeAxisTickInterval = 0.5/3600;
tMapCenter = geographicAxesObject.MapCenter;
tMapCenterDegreeFloor = floor(tMapCenter);
tMapCenterMimute = (tMapCenter-tMapCenterDegreeFloor) * 60;
tMapCenterMimuteFloor = floor(tMapCenterMimute);
tMapCenterSecond = (tMapCenterMimute-tMapCenterMimuteFloor) * 60;
tMapCenterSecondFloor = floor(tMapCenterSecond);
tGeographicAxesCenter = tMapCenterDegreeFloor + tMapCenterMimuteFloor / 60 + tMapCenterSecondFloor/3600;
cLatitudeHalfTickSize = 10;
tLatitudeAxisHead = tGeographicAxesCenter(1) - cLatitudeAxisTickInterval * cLatitudeHalfTickSize;
tLatitudeAxisTail = tGeographicAxesCenter(1) + cLatitudeAxisTickInterval * cLatitudeHalfTickSize;
tLatitudeAxisTickValues = tLatitudeAxisHead:cLatitudeAxisTickInterval:tLatitudeAxisTail;
set(get(geographicAxesObject,'LatitudeAxis'),'TickValues',tLatitudeAxisTickValues);
cLongitudeAxisTickInterval = 1/3600;
cLongitudeHalfTickSize = 10;
tLongitudeAxisHead = tGeographicAxesCenter(2) - cLongitudeAxisTickInterval * cLongitudeHalfTickSize;
tLongitudeAxisTail = tGeographicAxesCenter(2) + cLongitudeAxisTickInterval * cLongitudeHalfTickSize;
tLongitudeAxisTickValues = tLongitudeAxisHead:cLongitudeAxisTickInterval:tLongitudeAxisTail;
set(get(geographicAxesObject,'LongitudeAxis'),'TickValues',tLongitudeAxisTickValues);

geolimits([dms2degrees([29 27 11.5]) dms2degrees([29 27 14.5])],[dms2degrees([106 28 16]) dms2degrees([106 28 20])]);

% 网格
% set(geographicAxesObject,'GridLineStyle','--');
% set(geographicAxesObject,'GridColor','w');
% set(geographicAxesObject,'GridAlpha',0.5);

% 标签
% set(get(geographicAxesObject,'LatitudeLabel'),'String','纬度');
% set(get(geographicAxesObject,'LatitudeLabel'),'FontName','宋体');
% set(get(geographicAxesObject,'LongitudeLabel'),'String','经度');
% set(get(geographicAxesObject,'LongitudeLabel'),'FontName','宋体');

set(get(geographicAxesObject,'LatitudeLabel'),'String','Latitude');
% set(get(geographicAxesObject,'LatitudeLabel'),'FontName','Times New Roman');
set(get(geographicAxesObject,'LatitudeLabel'),'FontName','Arial');
set(get(geographicAxesObject,'LongitudeLabel'),'String','Longitude');
% set(get(geographicAxesObject,'LongitudeLabel'),'FontName','Times New Roman');
set(get(geographicAxesObject,'LongitudeLabel'),'FontName','Arial');


set(get(geographicAxesObject,'Legend'),'Location','northeastoutside');
% set(get(geographicAxesObject,'Legend'),'Orientation','horizontal');
% set(get(geographicAxesObject,'Legend'),'NumColumns',5);
set(get(geographicAxesObject,'Legend'),'FontName','Times New Roman');
set(get(geographicAxesObject,'Legend'),'FontName','Arial');
% set(get(geographicAxesObject,'Legend'),'FontSize',10.5);
set(get(geographicAxesObject,'Legend'),'FontSize',8);

% http://gs.xjtu.edu.cn/info/1209/7605.htm
% 参考《西安交通大学博士、硕士学位论文模板（2021版）》中对图的要求
% 图尺寸的一般宽高比应为6.67 cm×5.00 cm。特殊情况下， 也可为
% 9.00 cm×6.75 cm， 或13.5 cm×9.00 cm。总之， 一篇论文中， 同类图片的
% 大小应该一致，编排美观、整齐；
figurePropertiesPositionLeft = 0;
figurePropertiesPositionBottom = 0;
figurePropertiesPositionWidth = 17;
figureAspectRatio = 4/3;
figurePropertiesPositionHeight = figurePropertiesPositionWidth/figureAspectRatio;
figurePropertiesPositionHeight = 12.3;
figurePropertiesPosition = [ ...
    figurePropertiesPositionLeft ...
    figurePropertiesPositionBottom ...
    figurePropertiesPositionWidth ...
    figurePropertiesPositionHeight ...
    ];
set(gcf,'Units','centimeters');
set(gcf,'Position',figurePropertiesPosition);
% 打印和导出
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','landscape');
figurePropertiesPaperSize = [figurePropertiesPositionWidth figurePropertiesPositionHeight];
set(gcf,'PaperSize',figurePropertiesPaperSize);
set(gcf,'PaperPosition',figurePropertiesPosition);

cChongqinDatasetOverviewFilePath = fullfile(ccDatasetLevel2CollectionDateFolderPath,'ChongqinDatasetOverview1.png');
exportgraphics(gcf,cChongqinDatasetOverviewFilePath,'Resolution',600);

% close(figureMapHandle);
