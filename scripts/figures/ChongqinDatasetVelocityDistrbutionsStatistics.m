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

                    tGroundTruthVelocity = loadDataDrivenVelocityGroundTruth(tDatasetLevel5FolderPhonePath);
                    tGroundTruthVelocitySize = size(tGroundTruthVelocity,1);
                    tSequenceMarker = ones(tGroundTruthVelocitySize,1) * logTrackNumerator;

                    tSequenceVelocityTable = [tSequenceVelocityTable;[tSequenceMarker,tGroundTruthVelocity]];

                end
            end
            % Tail iterate phone_name
        end
    end
    % Tail iterate drive_id
end

tDatasetVelocity = tSequenceVelocityTable(:,2);
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

cKITTIOdometryPreviewFilePath = fullfile(cDatasetLevel3ReorganizedFolderPath,'ChongqinDatasetVelocityDistribution.png');
exportgraphics(gcf,cKITTIOdometryPreviewFilePath,'Resolution',600);

close(figureMapHandle);


tDatasetVelocity = tSequenceVelocityTable(:,2) * 3.6;
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
    tLabel = sprintf('%2d~%2d km/h',tPieVelocityTable(i,1),tPieVelocityTable(i,2));
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

cKITTIOdometryPreviewFilePath = fullfile(cDatasetLevel3ReorganizedFolderPath,'ChongqinDatasetVelocityDistributionKilometerPerHour.png');
exportgraphics(gcf,cKITTIOdometryPreviewFilePath,'Resolution',600);

% close(figureMapHandle);
