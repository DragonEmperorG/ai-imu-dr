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

% 基于DeepOdo模型对比输入标准化和输出归一化的效果
cModelDeepOdoInput7DInputNSOutputNSFileName = "ModelDeepOdoInput7DInputNSOutputNS.txt";
cModelDeepOdoInput7DInputHSOutputNSFileName = "ModelDeepOdoInput7DInputHSOutputNS.txt";
cModelDeepOdoInput7DInputHSOutputHSFileName = "ModelDeepOdoInput7DInputHSOutputHS.txt";
cModelDeepOdoInput6DInputHSOutputNSFileName = "ModelDeepOdoInput6DInputHSOutputNS.txt";
cModelDeepOdoInput6DInput100HzInputHSOutputNSFileName = "ModelDeepOdoInput6DInput100HzInputHSOutputNS.txt";
cModelDeepOdoInput6DInput150HzInputHSOutputNSFileName = "ModelDeepOdoInput6DInput150HzInputHSOutputNS.txt";
cModelDeepOdoInput6DInput200HzInputHSOutputNSFileName = "ModelDeepOdoInput6DInput200HzInputHSOutputNS.txt";
cModelDeepOdoInput6DInput100HzInputHSOutputNSLoseDeltaVelocityFileName = "ModelDeepOdoInput6DInput100HzInputHSOutputNSLoseDeltaVelocity.txt";

% cComparedResultList = [cModelDeepOdoInput7DInputNSOutputNSFileName,cModelDeepOdoInput7DInputHSOutputNSFileName,cModelDeepOdoInput7DInputHSOutputHSFileName];
% cComparedResultList = [cModelDeepOdoInput6DInputHSOutputNSFileName];
% cComparedResultList = [cModelDeepOdoInput6DInput100HzInputHSOutputNSFileName,cModelDeepOdoInput6DInput150HzInputHSOutputNSFileName,cModelDeepOdoInput6DInput200HzInputHSOutputNSFileName];
cComparedResultList = [cModelDeepOdoInput6DInput100HzInputHSOutputNSLoseDeltaVelocityFileName];

% TODO: S2.1: 配置调试模式
cDebug = true;
% cDebug = false;

boxplotg = [];
boxplotx = [];

datasetVE = [];
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
            if ~strcmp(tDatasetLevel4TrackFolderName,"0012")
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

                    groundTruthVelocity = loadDataDrivenVelocityGroundTruth(tDatasetLevel5FolderPhonePath);
                    trackVE = [];
                    for k = 1:length(cComparedResultList)
                        dataDrivenVelocity = loadCustomDataDrivenVelocityMeasurement(tDatasetLevel5FolderPhonePath,cComparedResultList(k));
                        [AVE1,AVE2] = evaluateAVE(groundTruthVelocity,dataDrivenVelocity);
                        [RVE1,RVE2] = evaluateRVE(groundTruthVelocity,dataDrivenVelocity);
                        trackVE = [trackVE,AVE1,AVE2,RVE1,RVE2];
                        logMsg = sprintf('%s, AVE MAE: %.3f, AVE RMSE: %.3f; RVE MAE: %.3f, RVE RMSE: %.3f', ...
                            cComparedResultList(k),AVE1,AVE2,RVE1,RVE2);
                        log2terminal('I',TAG,logMsg);
                    end
                    datasetVE = [datasetVE;trackVE];

                    % velocityLabel = repmat({seqString},size(velocityError,1),1);
                    % boxplotg = [boxplotg;velocityLabel];

                end
            end
            % Tail iterate phone_name
        end
    end
    % Tail iterate drive_id
end

figureObject = boxplot(boxplotx,boxplotg);

printFolderPath = cDatasetLevel3ReorganizedFolderPath;
saveFigFileName = "VelocityErrorBoxPlot";

% Legend 属性
% 字体
% set(legendHandle,'FontName','Times New Roman');
% set(legendHandle,'FontSize',10);

xlabel("Seq");
ylabel("Velocity error (m/s)");

grid on;

% Preparation of Articles for IEEE TRANSACTIONS and JOURNALS (2022)
% IV. GUIDELINES FOR GRAPHICS PREPARATION AND SUBMISSION

% H. Accepted Fonts Within Figures
% Times New Roman,
% Helvetica, Arial
% Cambria
% Symbol
% Axes 属性
% https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.axis.axes-properties.html
% 字体
set(gca,'FontName','Times New Roman');

% I. Using Labels Within Figures
% Figure labels should be legible, approximately 8- to 10-point type.
% 字体大小
set(gca,'FontSize',10);

saveFigFilePath = fullfile(printFolderPath,saveFigFileName);
saveas(gcf,saveFigFilePath,'fig')

% D. Sizing of Graphics
% one column wide (3.5 inches / 88 mm / 21 picas)
% page wide (7.16 inches / 181 millimeters / 43 picas)
% maximum depth ( 8.5 inches / 216 millimeters / 54 picas)
% https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html
% Figure 属性
% 位置和大小
figurePropertiesPositionLeft = 0;
figurePropertiesPositionBottom = 0;
figurePropertiesPositionWidth = 18.1;
figureAspectRatio = 4/3;
figurePropertiesPositionHeight = figurePropertiesPositionWidth/figureAspectRatio;
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

% 位置
set(gca,'Units','centimeters');
set(gca,'OuterPosition',gcf().Position);

hold off;

printFileName = strcat(saveFigFileName,".png");
printFilePath = fullfile(printFolderPath,printFileName);
% C. File Formats for Graphics
% PostScript (PS)
% Encapsulated PostScript (.EPS)
% Tagged Image File Format (.TIFF)
% Portable Document Format (.PDF)
% JPEG
% Portable Network Graphics (.PNG)
% E. Resolution
% Author photographs, color, and grayscale figures should be at least 300dpi. 
% Line art, including tables should be a minimum of 600dpi.
% print(gcf,printFilePath,'-dpng','-r600');
exportgraphics(gcf,printFilePath,'Resolution',600)

% close(figureObject);





