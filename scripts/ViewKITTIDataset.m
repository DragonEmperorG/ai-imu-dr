clearvars;
close all;
dbstop error;

addpath('E:\GitHubRepositories\KITTI\downloads\raw_data\devkit\matlab');
addpath(genpath(pwd));

TAG = 'OdometryPosesViewer';

load 'OdometryMappingConfig.mat';

cRawDatasetFolderPath = 'E:\GitHubRepositories\KITTI\raw_data';
cOxtsFolderName = 'oxts';
cOxtsliteDataMatFileName = 'data.mat';
cOxtslitePoseMatFileName = 'pose.mat';

cRecomputeOxtslitePoseMatFile = 1;

figureMapHandle = figure;
% https://ww2.mathworks.cn/help/matlab/ref/geobasemap.html
geographicAxesObject = geoaxes("Basemap","satellite");

bboxMaxLatitude = -90;
bboxMinLatitude = 90;
bboxMaxLongitude = -180;
bboxMinLongitude = 180;

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
        cOxtsliteDataMatFilePath = fullfile(tRawDataFolderPath,cOxtsFolderName,cOxtsliteDataMatFileName);
        if ~isfile(cOxtsliteDataMatFilePath)
            tOxtsliteData = loadOxtsliteData(tRawDataFolderPath);
            save(cOxtsliteDataMatFilePath,'tOxtsliteData');
        else
            load(cOxtsliteDataMatFilePath);
        end
        tOxtsRawData = cell2mat(tOxtsliteData');
        tOxtsRawDataLatitude = tOxtsRawData(:,1);
        tOxtsRawDataLongitude = tOxtsRawData(:,2);
        % tOxtsRawDataAltitude = zeros(size(tOxtsRawData(:,3)));

        bboxMaxLatitude = max(bboxMaxLatitude,max(tOxtsRawDataLatitude));
        bboxMinLatitude = min(bboxMinLatitude,min(tOxtsRawDataLatitude));
        bboxMaxLongitude = max(bboxMaxLongitude,max(tOxtsRawDataLongitude));
        bboxMinLongitude = min(bboxMaxLongitude,min(tOxtsRawDataLongitude));
        
        hold on;
        lineObject = geoplot(geographicAxesObject,tOxtsRawDataLatitude,tOxtsRawDataLongitude);
        set(lineObject,'LineWidth',1.2);
        set(lineObject,'DisplayName',tSequenceNumberString);
        hold off;

        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end    
end

legend();

% 字体
set(geographicAxesObject,'FontName','Times New Roman');
set(geographicAxesObject,'FontSize',10.5);

% 标尺
cLatitudeAxisTickInterval = 1/60;
tMapCenter = geographicAxesObject.MapCenter;
tMapCenterDegree = floor(tMapCenter);
tMapCenterMimute = floor((tMapCenter-tMapCenterDegree) * 60);
tGeographicAxesCenter = tMapCenterDegree + tMapCenterMimute / 60;
cLatitudeHalfTickSize = 10;
tLatitudeAxisHead = tGeographicAxesCenter(1) - cLatitudeAxisTickInterval * cLatitudeHalfTickSize;
tLatitudeAxisTail = tGeographicAxesCenter(1) + cLatitudeAxisTickInterval * cLatitudeHalfTickSize;
tLatitudeAxisTickValues = tLatitudeAxisHead:cLatitudeAxisTickInterval:tLatitudeAxisTail;
set(get(geographicAxesObject,'LatitudeAxis'),'TickValues',tLatitudeAxisTickValues);
cLongitudeAxisTickInterval = 2/60;
cLongitudeHalfTickSize = 10;
tLongitudeAxisHead = tGeographicAxesCenter(2) - cLongitudeAxisTickInterval * cLongitudeHalfTickSize;
tLongitudeAxisTail = tGeographicAxesCenter(2) + cLongitudeAxisTickInterval * cLongitudeHalfTickSize;
tLongitudeAxisTickValues = tLongitudeAxisHead:cLongitudeAxisTickInterval:tLongitudeAxisTail;
set(get(geographicAxesObject,'LongitudeAxis'),'TickValues',tLongitudeAxisTickValues);

% 网格
set(geographicAxesObject,'GridLineStyle','--');
set(geographicAxesObject,'GridColor','w');
set(geographicAxesObject,'GridAlpha',0.5);

% 标签
set(get(geographicAxesObject,'LatitudeLabel'),'String','纬度');
set(get(geographicAxesObject,'LatitudeLabel'),'FontName','宋体');
set(get(geographicAxesObject,'LongitudeLabel'),'String','经度');
set(get(geographicAxesObject,'LongitudeLabel'),'FontName','宋体');

set(get(geographicAxesObject,'Legend'),'Location','northeastoutside');
% set(get(geographicAxesObject,'Legend'),'Orientation','horizontal');
% set(get(geographicAxesObject,'Legend'),'NumColumns',5);
set(get(geographicAxesObject,'Legend'),'FontName','Times New Roman');
set(get(geographicAxesObject,'Legend'),'FontSize',10.5);

% http://gs.xjtu.edu.cn/info/1209/7605.htm
% 参考《西安交通大学博士、硕士学位论文模板（2021版）》中对图的要求
% 图尺寸的一般宽高比应为6.67 cm×5.00 cm。特殊情况下， 也可为
% 9.00 cm×6.75 cm， 或13.5 cm×9.00 cm。总之， 一篇论文中， 同类图片的
% 大小应该一致，编排美观、整齐；
figurePropertiesPositionLeft = 0;
figurePropertiesPositionBottom = 0;
figurePropertiesPositionWidth = 16;
figurePropertiesPositionHeight = 9;
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

cKITTIOdometryPreviewFilePath = fullfile(cRawDatasetFolderPath,'KITTIOdometryPreview.png');
exportgraphics(gcf,cKITTIOdometryPreviewFilePath,'Resolution',600);

% close(figureMapHandle);
