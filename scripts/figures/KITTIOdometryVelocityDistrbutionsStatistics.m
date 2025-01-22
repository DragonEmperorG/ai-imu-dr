clearvars;
close all;
dbstop error;

addpath('..');
addpath('E:\GitHubRepositories\KITTI\downloads\raw_data\devkit\matlab');

TAG = 'VelocityDistrbutions';

load 'OdometryMappingConfig.mat';

cRawDatasetFolderPath = 'E:\GitHubRepositories\KITTI\raw_data';

tSequenceVelocityTable = [];

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
        tOxtsRawInterpVelocity = loadOxtsRawInterpVelocity(tRawDataFolderPath);
        tOxtsRawInterpVelocitySize = size(tOxtsRawInterpVelocity,1);
        tSequenceMarker = ones(tOxtsRawInterpVelocitySize,1) * tSequenceNumber;

        tSequenceVelocityTable = [tSequenceVelocityTable;[tSequenceMarker,tOxtsRawInterpVelocity]];

        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end
end

tDatasetVelocity = tSequenceVelocityTable(:,3);
cVelocityMaxValue = max(tDatasetVelocity);
cVelocityInterval = 5;
cVelocityLength = ceil(cVelocityMaxValue/cVelocityInterval);
tPieVelocityTable = zeros(cVelocityLength,3);
tVelocityIntervalHead = 0;
tVelocityIntervalTail = tVelocityIntervalHead + cVelocityInterval;
pieChartLabels = [];
for i = 1:cVelocityLength
    tPieVelocityTable(i,1) = tVelocityIntervalHead;
    tPieVelocityTable(i,2) = tVelocityIntervalTail;
    tLabel = sprintf('%2d~%2d m/s',tPieVelocityTable(i,1),tPieVelocityTable(i,2));
    pieChartLabels = [pieChartLabels,string(tLabel)];
    indices = find(tDatasetVelocity >= tPieVelocityTable(i,1) & tDatasetVelocity < tPieVelocityTable(i,2));
    tPieVelocityTable(i,3) = numel(indices);

    tVelocityIntervalHead = tVelocityIntervalTail;
    tVelocityIntervalTail = tVelocityIntervalHead + cVelocityInterval;
end


figureMapHandle = figure;
pieChartObject = piechart(tPieVelocityTable(:,3),pieChartLabels);

% 标签
set(pieChartObject,'LabelStyle','percent');
set(pieChartObject,'LegendVisible','on');

% 字体
set(pieChartObject,'FontName','Times New Roman');
set(pieChartObject,'FontSize',10.5); % Word 五号

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

cKITTIOdometryPreviewFilePath = fullfile(cRawDatasetFolderPath,'KITTIOdometryVelocityDistribution.png');
exportgraphics(gcf,cKITTIOdometryPreviewFilePath,'Resolution',600);

% close(figureMapHandle);
