function [] = plotComparedTrackImuData(trackFolderPath)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
cPhoneFolderNameList = ["GOOGLE_Pixel3" "HUAWEI_Mate30"];
cPhoneFolderNameListLength = length(cPhoneFolderNameList);

cDayZeroOClockAlignFolderName = 'dayZeroOClockAlign';
cTrackGroundTruthImuFileName = 'TrackGroundTruthImu.csv';
cMotionSensorGyroscopeUncalibratedFileName = 'MotionSensorGyroscopeUncalibrated.csv';
cMotionSensorAccelerometerUncalibratedFileName = 'MotionSensorAccelerometerUncalibrated.csv';

tTrackGooglePixel3FolderPath = fullfile(trackFolderPath,cPhoneFolderNameList(1),cDayZeroOClockAlignFolderName);
tTrackHuaweiMate30FolderPath = fullfile(trackFolderPath,cPhoneFolderNameList(2),cDayZeroOClockAlignFolderName);

tTrackGroundTruthImuFilePath = fullfile(tTrackGooglePixel3FolderPath,cTrackGroundTruthImuFileName);
tTrackGooglePixel3SensorGyroscopeUncalibratedFilePath = fullfile(tTrackGooglePixel3FolderPath,cMotionSensorGyroscopeUncalibratedFileName);
tTrackGooglePixel3SensorAccelerometerUncalibratedFilePath = fullfile(tTrackGooglePixel3FolderPath,cMotionSensorAccelerometerUncalibratedFileName);
tTrackHuaweiMate30SensorGyroscopeUncalibratedFilePath = fullfile(tTrackHuaweiMate30FolderPath,cMotionSensorGyroscopeUncalibratedFileName);
tTrackHuaweiMate30SensorAccelerometerUncalibratedFilePath = fullfile(tTrackHuaweiMate30FolderPath,cMotionSensorAccelerometerUncalibratedFileName);

tTrackGroundTruthImuRawData = readmatrix(tTrackGroundTruthImuFilePath);
tTrackGroundTruthImuRawData(:,5:7) = deg2rad(tTrackGroundTruthImuRawData(:,5:7));

tTrackGooglePixel3ImuGyroRawData = readmatrix(tTrackGooglePixel3SensorGyroscopeUncalibratedFilePath);
tTrackGooglePixel3ImuAcceRawData = readmatrix(tTrackGooglePixel3SensorAccelerometerUncalibratedFilePath);
tTrackHuaweiMate30ImuGyroRawData = readmatrix(tTrackHuaweiMate30SensorGyroscopeUncalibratedFilePath);
tTrackHuaweiMate30ImuAcceRawData = readmatrix(tTrackHuaweiMate30SensorAccelerometerUncalibratedFilePath);

tTrackGroundTruthImuGnssClockTime = tTrackGroundTruthImuRawData(:,1);
tTrackGooglePixel3GyroGnssClockTime = tTrackGooglePixel3ImuGyroRawData(:,2);
tTrackGooglePixel3AcceGnssClockTime = tTrackGooglePixel3ImuAcceRawData(:,2);
tTrackHuaweiMate30GyroGnssClockTime = tTrackHuaweiMate30ImuGyroRawData(:,2);
tTrackHuaweiMate30AcceGnssClockTime = tTrackHuaweiMate30ImuAcceRawData(:,2);
tTrackFineClipHeadTime = max(min(tTrackGooglePixel3GyroGnssClockTime),min(tTrackHuaweiMate30AcceGnssClockTime));
tTrackFineClipTailTime = min(max(tTrackGooglePixel3GyroGnssClockTime),max(tTrackHuaweiMate30AcceGnssClockTime));
pTrackFineClipHeadTime = ceil(tTrackFineClipHeadTime);
pTrackFineClipTailTime = floor(tTrackFineClipTailTime);
pTrackFineClipDuration = pTrackFineClipTailTime - pTrackFineClipHeadTime;
pTrackGTImu = tTrackGroundTruthImuRawData(tTrackGroundTruthImuGnssClockTime>=pTrackFineClipHeadTime&tTrackGroundTruthImuGnssClockTime<=pTrackFineClipTailTime,:);
pTrackGPGyr = tTrackGooglePixel3ImuGyroRawData(tTrackGooglePixel3GyroGnssClockTime>=pTrackFineClipHeadTime&tTrackGooglePixel3GyroGnssClockTime<=pTrackFineClipTailTime,:);
pTrackGPAcc = tTrackGooglePixel3ImuAcceRawData(tTrackGooglePixel3AcceGnssClockTime>=pTrackFineClipHeadTime&tTrackGooglePixel3AcceGnssClockTime<=pTrackFineClipTailTime,:);
pTrackHMGyr = tTrackHuaweiMate30ImuGyroRawData(tTrackHuaweiMate30GyroGnssClockTime>=pTrackFineClipHeadTime&tTrackHuaweiMate30GyroGnssClockTime<=pTrackFineClipTailTime,:);
pTrackHMAcc = tTrackHuaweiMate30ImuAcceRawData(tTrackHuaweiMate30AcceGnssClockTime>=pTrackFineClipHeadTime&tTrackHuaweiMate30AcceGnssClockTime<=pTrackFineClipTailTime,:);

pTrackGTImuTime = pTrackGTImu(:,1) - pTrackFineClipHeadTime;
pTrackGPGyrTime = pTrackGPGyr(:,2) - pTrackFineClipHeadTime;
pTrackGPAccTime = pTrackGPAcc(:,2) - pTrackFineClipHeadTime;
pTrackHMGyrTime = pTrackHMGyr(:,2) - pTrackFineClipHeadTime;
pTrackHMAccTime = pTrackHMAcc(:,2) - pTrackFineClipHeadTime;

pGyrAxisX = [pTrackGPGyr(:,4);pTrackHMGyr(:,4);pTrackGTImu(:,5)];
pGyrAxisY = [pTrackGPGyr(:,5);pTrackHMGyr(:,5);pTrackGTImu(:,6)];
pGyrAxisZ = [pTrackGPGyr(:,6);pTrackHMGyr(:,6);pTrackGTImu(:,7)];
pAccAxisX = [pTrackGPAcc(:,4);pTrackHMAcc(:,4);pTrackGTImu(:,2)];
pAccAxisY = [pTrackGPAcc(:,5);pTrackHMAcc(:,5);pTrackGTImu(:,3)];
pAccAxisZ = [pTrackGPAcc(:,6);pTrackHMAcc(:,6);pTrackGTImu(:,4)];

figureObject1 = figure;
hold on;
lineObjectGPGyrX = plot(pTrackGPGyrTime,pTrackGPGyr(:,4));
lineObjectHMGyrX = plot(pTrackHMGyrTime,pTrackHMGyr(:,4));
lineObjectGTGyrX = plot(pTrackGTImuTime,pTrackGTImu(:,5));
legendObject1 = legend();
hold off;

figureObject2 = figure;
hold on;
lineObjectGyrGPY = plot(pTrackGPGyrTime,pTrackGPGyr(:,5));
lineObjectGyrHMY = plot(pTrackHMGyrTime,pTrackHMGyr(:,5));
lineObjectGyrGTY = plot(pTrackGTImuTime,pTrackGTImu(:,6));
legendObject2 = legend();
hold off;

figureObject3 = figure;
hold on;
lineObjectGyrGPZ = plot(pTrackGPGyrTime,pTrackGPGyr(:,6));
lineObjectGyrHMZ = plot(pTrackHMGyrTime,pTrackHMGyr(:,6));
lineObjectGyrGTZ = plot(pTrackGTImuTime,pTrackGTImu(:,7));
legendObject3 = legend();
hold off;

figureObject4 = figure;
hold on;
lineObjectGPAccX = plot(pTrackGPAccTime,pTrackGPAcc(:,4));
lineObjectHMAccX = plot(pTrackHMAccTime,pTrackHMAcc(:,4));
lineObjectGTAccX = plot(pTrackGTImuTime,pTrackGTImu(:,2));
legendObject4 = legend();
hold off;

figureObject5 = figure;
hold on;
lineObjectAccGPY = plot(pTrackGPAccTime,pTrackGPAcc(:,5));
lineObjectAccHMY = plot(pTrackHMAccTime,pTrackHMAcc(:,5));
lineObjectAccGTY = plot(pTrackGTImuTime,pTrackGTImu(:,3));
legendObject5 = legend();
hold off;

figureObject6 = figure;
hold on;
lineObjectAccGPZ = plot(pTrackGPAccTime,pTrackGPAcc(:,6));
lineObjectAccHMZ = plot(pTrackHMAccTime,pTrackHMAcc(:,6));
lineObjectAccGTZ = plot(pTrackGTImuTime,pTrackGTImu(:,4));
legendObject6 = legend();
hold off;

% Line 属性 https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.chart.primitive.line-properties.html
% 线条
% https://waldyrious.net/viridis-palette-generator/
% cPaletteViridisCategories11Color = ["#fde725" "#21918c" "#440154"];
cPaletteViridisCategories11Color = ["#ff0000" "#00ff00" "#0000ff"];
set(lineObjectGTGyrX,"Color",cPaletteViridisCategories11Color(1));
set(lineObjectGyrGTY,"Color",cPaletteViridisCategories11Color(1));
set(lineObjectGyrGTZ,"Color",cPaletteViridisCategories11Color(1));
set(lineObjectGPGyrX,"Color",cPaletteViridisCategories11Color(2));
set(lineObjectGyrGPY,"Color",cPaletteViridisCategories11Color(2));
set(lineObjectGyrGPZ,"Color",cPaletteViridisCategories11Color(2));
set(lineObjectHMGyrX,"Color",cPaletteViridisCategories11Color(3));
set(lineObjectGyrHMY,"Color",cPaletteViridisCategories11Color(3));
set(lineObjectGyrHMZ,"Color",cPaletteViridisCategories11Color(3));
set(lineObjectGTAccX,"Color",cPaletteViridisCategories11Color(1));
set(lineObjectAccGTY,"Color",cPaletteViridisCategories11Color(1));
set(lineObjectAccGTZ,"Color",cPaletteViridisCategories11Color(1));
set(lineObjectGPAccX,"Color",cPaletteViridisCategories11Color(2));
set(lineObjectAccGPY,"Color",cPaletteViridisCategories11Color(2));
set(lineObjectAccGPZ,"Color",cPaletteViridisCategories11Color(2));
set(lineObjectHMAccX,"Color",cPaletteViridisCategories11Color(3));
set(lineObjectAccHMY,"Color",cPaletteViridisCategories11Color(3));
set(lineObjectAccHMZ,"Color",cPaletteViridisCategories11Color(3));
% set(lineObjectGTX,"LineStyle","--");
% set(lineObjectGTY,"LineStyle","--");
% set(lineObjectGTZ,"LineStyle","--");
% set(lineObjectGPX,"LineStyle","--");
% set(lineObjectGPY,"LineStyle","--");
% set(lineObjectGPZ,"LineStyle","--");
% set(lineObjectHMX,"LineStyle",":");
% set(lineObjectHMY,"LineStyle",":");
% set(lineObjectHMZ,"LineStyle",":");
% set(lineObjectGTX,"LineWidth",1);
% set(lineObjectGTY,"LineWidth",1);
% set(lineObjectGTZ,"LineWidth",1);
% set(lineObjectGPX,"LineWidth","--");
% set(lineObjectGPY,"LineWidth","--");
% set(lineObjectGPZ,"LineWidth","--");
% set(lineObjectHMX,"LineWidth",":");
% set(lineObjectHMY,"LineWidth",":");
% set(lineObjectHMZ,"LineWidth",":");
% 标记
% set(lineObject,"Marker",".");
% 图例
kNovAtelSPANString = 'NovAtel SPAN';
kGooglePixel3String = 'Google Pixel3';
kHuaweiMate30String = 'Huawei Mate30';
set(lineObjectGTGyrX,"DisplayName",kNovAtelSPANString);
set(lineObjectGyrGTY,"DisplayName",kNovAtelSPANString);
set(lineObjectGyrGTZ,"DisplayName",kNovAtelSPANString);
set(lineObjectGPGyrX,"DisplayName",kGooglePixel3String);
set(lineObjectGyrGPY,"DisplayName",kGooglePixel3String);
set(lineObjectGyrGPZ,"DisplayName",kGooglePixel3String);
set(lineObjectHMGyrX,"DisplayName",kHuaweiMate30String);
set(lineObjectGyrHMY,"DisplayName",kHuaweiMate30String);
set(lineObjectGyrHMZ,"DisplayName",kHuaweiMate30String);
set(lineObjectGTAccX,"DisplayName",kNovAtelSPANString);
set(lineObjectAccGTY,"DisplayName",kNovAtelSPANString);
set(lineObjectAccGTZ,"DisplayName",kNovAtelSPANString);
set(lineObjectGPAccX,"DisplayName",kGooglePixel3String);
set(lineObjectAccGPY,"DisplayName",kGooglePixel3String);
set(lineObjectAccGPZ,"DisplayName",kGooglePixel3String);
set(lineObjectHMAccX,"DisplayName",kHuaweiMate30String);
set(lineObjectAccHMY,"DisplayName",kHuaweiMate30String);
set(lineObjectAccHMZ,"DisplayName",kHuaweiMate30String);

axesObject1 = get(figureObject1,'CurrentAxes');
axesObject2 = get(figureObject2,'CurrentAxes');
axesObject3 = get(figureObject3,'CurrentAxes');
axesObject4 = get(figureObject4,'CurrentAxes');
axesObject5 = get(figureObject5,'CurrentAxes');
axesObject6 = get(figureObject6,'CurrentAxes');
% Axes 属性 https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.axis.axes-properties.html
% 字体
set(axesObject1,'FontName','Times New Roman');
set(axesObject2,'FontName','Times New Roman');
set(axesObject3,'FontName','Times New Roman');
set(axesObject4,'FontName','Times New Roman');
set(axesObject5,'FontName','Times New Roman');
set(axesObject6,'FontName','Times New Roman');
set(axesObject1,'FontSize',10.5);
set(axesObject2,'FontSize',10.5);
set(axesObject3,'FontSize',10.5);
set(axesObject4,'FontSize',10.5);
set(axesObject5,'FontSize',10.5);
set(axesObject6,'FontSize',10.5);

% 网格
axesPropertyXLim = [0 pTrackFineClipDuration];
set(axesObject1,'XLim',axesPropertyXLim);
set(axesObject2,'XLim',axesPropertyXLim);
set(axesObject3,'XLim',axesPropertyXLim);
set(axesObject4,'XLim',axesPropertyXLim);
set(axesObject5,'XLim',axesPropertyXLim);
set(axesObject6,'XLim',axesPropertyXLim);

pGyrMinAxisX = min(pGyrAxisX);
pGyrMaxAxisX = max(pGyrAxisX);
axesObject1PropertyXLimMin = floor(pGyrMinAxisX*10)/10;
axesObject1PropertyXLimMax = ceil(pGyrMaxAxisX*10)/10;
pGyrMinAxisY = min(pGyrAxisY);
pGyrMaxAxisY = max(pGyrAxisY);
axesObject2PropertyXLimMin = floor(pGyrMinAxisY*10)/10;
axesObject2PropertyXLimMax = ceil(pGyrMaxAxisY*10)/10;
pGyrMinAxisZ = min(pGyrAxisZ);
pGyrMaxAxisZ = max(pGyrAxisZ);
axesObject3PropertyXLimMin = floor(pGyrMinAxisZ*10)/10;
axesObject3PropertyXLimMax = ceil(pGyrMaxAxisZ*10)/10;
pAccMinAxisX = min(pAccAxisX);
pAccMaxAxisX = max(pAccAxisX);
axesObject4PropertyXLimMin = floor(pAccMinAxisX*10)/10;
axesObject4PropertyXLimMax = ceil(pAccMaxAxisX*10)/10;
pAccMinAxisY = min(pAccAxisY);
pAccMaxAxisY = max(pAccAxisY);
axesObject5PropertyXLimMin = floor(pAccMinAxisY*10)/10;
axesObject5PropertyXLimMax = ceil(pAccMaxAxisY*10)/10;
pAccMinAxisZ = min(pAccAxisZ);
pAccMaxAxisZ = max(pAccAxisZ);
axesObject6PropertyXLimMin = floor(pAccMinAxisZ*10)/10;
axesObject6PropertyXLimMax = ceil(pAccMaxAxisZ*10)/10;
set(axesObject1,'YLim',[axesObject1PropertyXLimMin axesObject1PropertyXLimMax]);
set(axesObject2,'YLim',[axesObject2PropertyXLimMin axesObject2PropertyXLimMax]);
set(axesObject3,'YLim',[axesObject3PropertyXLimMin axesObject3PropertyXLimMax]);
set(axesObject4,'YLim',[axesObject4PropertyXLimMin axesObject4PropertyXLimMax]);
set(axesObject5,'YLim',[axesObject5PropertyXLimMin axesObject5PropertyXLimMax]);
set(axesObject6,'YLim',[axesObject6PropertyXLimMin axesObject6PropertyXLimMax]);

% 网格
set(axesObject1,'Layer','top');
set(axesObject2,'Layer','top');
set(axesObject3,'Layer','top');
set(axesObject4,'Layer','top');
set(axesObject5,'Layer','top');
set(axesObject6,'Layer','top');

% 标签
set(get(axesObject1,'XLabel'),'String','\fontname{宋体}采样时间\fontname{Times new roman}(s)');
set(get(axesObject1,'YLabel'),'String','\fontname{宋体}角速度\fontname{Times new roman}(rad/s)');
set(get(axesObject2,'XLabel'),'String','\fontname{宋体}采样时间\fontname{Times new roman}(s)');
set(get(axesObject2,'YLabel'),'String','\fontname{宋体}角速度\fontname{Times new roman}(rad/s)');
set(get(axesObject3,'XLabel'),'String','\fontname{宋体}采样时间\fontname{Times new roman}(s)');
set(get(axesObject3,'YLabel'),'String','\fontname{宋体}角速度\fontname{Times new roman}(rad/s)');
set(get(axesObject4,'XLabel'),'String','\fontname{宋体}采样时间\fontname{Times new roman}(s)');
set(get(axesObject4,'YLabel'),'String','\fontname{宋体}加速度\fontname{Times new roman}(m/s^{2})');
set(get(axesObject5,'XLabel'),'String','\fontname{宋体}采样时间\fontname{Times new roman}(s)');
set(get(axesObject5,'YLabel'),'String','\fontname{宋体}加速度\fontname{Times new roman}(m/s^{2})');
set(get(axesObject6,'XLabel'),'String','\fontname{宋体}采样时间\fontname{Times new roman}(s)');
set(get(axesObject6,'YLabel'),'String','\fontname{宋体}加速度\fontname{Times new roman}(m/s^{2})');

% Legend 属性
% 位置和布局
set(legendObject1,'Location','northoutside');
set(legendObject2,'Location','northoutside');
set(legendObject3,'Location','northoutside');
set(legendObject4,'Location','northoutside');
set(legendObject5,'Location','northoutside');
set(legendObject6,'Location','northoutside');
set(legendObject1,'Orientation','horizontal');
set(legendObject2,'Orientation','horizontal');
set(legendObject3,'Orientation','horizontal');
set(legendObject4,'Orientation','horizontal');
set(legendObject5,'Orientation','horizontal');
set(legendObject6,'Orientation','horizontal');
set(legendObject1,'NumColumns',3);
set(legendObject2,'NumColumns',3);
set(legendObject3,'NumColumns',3);
set(legendObject4,'NumColumns',3);
set(legendObject5,'NumColumns',3);
set(legendObject6,'NumColumns',3);
set(legendObject1,'Direction','reverse');
set(legendObject2,'Direction','reverse');
set(legendObject3,'Direction','reverse');
set(legendObject4,'Direction','reverse');
set(legendObject5,'Direction','reverse');
set(legendObject6,'Direction','reverse');
% 字体
set(legendObject1,'FontName','Times New Roman');
set(legendObject2,'FontName','Times New Roman');
set(legendObject3,'FontName','Times New Roman');
set(legendObject4,'FontName','Times New Roman');
set(legendObject5,'FontName','Times New Roman');
set(legendObject6,'FontName','Times New Roman');
set(legendObject1,'FontSize',10.5);
set(legendObject2,'FontSize',10.5);
set(legendObject3,'FontSize',10.5);
set(legendObject4,'FontSize',10.5);
set(legendObject5,'FontSize',10.5);
set(legendObject6,'FontSize',10.5);

% http://gs.xjtu.edu.cn/info/1209/7605.htm
% 参考《西安交通大学博士、硕士学位论文模板（2021版）》中对图的要求
% 图尺寸的一般宽高比应为6.67 cm×5.00 cm。特殊情况下， 也可为
% 9.00 cm×6.75 cm， 或13.5 cm×9.00 cm。总之， 一篇论文中， 同类图片的
% 大小应该一致，编排美观、整齐；
figurePropertiesPositionLeft = 10;
figurePropertiesPositionBottom = 10;
figurePropertiesPositionWidth = 16;
figurePropertiesPositionHeight = 7;
figurePropertiesPosition = [ ...
    figurePropertiesPositionLeft ...
    figurePropertiesPositionBottom ...
    figurePropertiesPositionWidth ...
    figurePropertiesPositionHeight ...
    ];
figurePropertiesPaperSize = [figurePropertiesPositionWidth figurePropertiesPositionHeight];
% 位置和大小
set(figureObject1,'Units','centimeters');
set(figureObject2,'Units','centimeters');
set(figureObject3,'Units','centimeters');
set(figureObject4,'Units','centimeters');
set(figureObject5,'Units','centimeters');
set(figureObject6,'Units','centimeters');
set(figureObject1,'Position',figurePropertiesPosition);
set(figureObject2,'Position',figurePropertiesPosition);
set(figureObject3,'Position',figurePropertiesPosition);
set(figureObject4,'Position',figurePropertiesPosition);
set(figureObject5,'Position',figurePropertiesPosition);
set(figureObject6,'Position',figurePropertiesPosition);
% 打印和导出
set(figureObject1,'PaperUnits','centimeters');
set(figureObject2,'PaperUnits','centimeters');
set(figureObject3,'PaperUnits','centimeters');
set(figureObject4,'PaperUnits','centimeters');
set(figureObject5,'PaperUnits','centimeters');
set(figureObject6,'PaperUnits','centimeters');
set(figureObject1,'PaperPosition',figurePropertiesPosition);
set(figureObject2,'PaperPosition',figurePropertiesPosition);
set(figureObject3,'PaperPosition',figurePropertiesPosition);
set(figureObject4,'PaperPosition',figurePropertiesPosition);
set(figureObject5,'PaperPosition',figurePropertiesPosition);
set(figureObject6,'PaperPosition',figurePropertiesPosition);
set(figureObject1,'PaperSize',figurePropertiesPaperSize);
set(figureObject2,'PaperSize',figurePropertiesPaperSize);
set(figureObject3,'PaperSize',figurePropertiesPaperSize);
set(figureObject4,'PaperSize',figurePropertiesPaperSize);
set(figureObject5,'PaperSize',figurePropertiesPaperSize);
set(figureObject6,'PaperSize',figurePropertiesPaperSize);

cAndroidSystemClockSeqGyrXFileName = sprintf('GnssClockGyroscopeUncalibratedXAxis.png');
cAndroidSystemClockSeqGyrYFileName = sprintf('GnssClockGyroscopeUncalibratedYAxis.png');
cAndroidSystemClockSeqGyrZFileName = sprintf('GnssClockGyroscopeUncalibratedZAxis.png');
cAndroidSystemClockSeqAccXFileName = sprintf('GnssClockAccelerometerUncalibratedXAxis.png');
cAndroidSystemClockSeqAccYFileName = sprintf('GnssClockAccelerometerUncalibratedYAxis.png');
cAndroidSystemClockSeqAccZFileName = sprintf('GnssClockAccelerometerUncalibratedZAxis.png');
cAndroidSystemClockSeqGyrXFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqGyrXFileName);
cAndroidSystemClockSeqGyrYFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqGyrYFileName);
cAndroidSystemClockSeqGyrZFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqGyrZFileName);
cAndroidSystemClockSeqAccXFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqAccXFileName);
cAndroidSystemClockSeqAccYFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqAccYFileName);
cAndroidSystemClockSeqAccZFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqAccZFileName);
exportgraphics(figureObject1,cAndroidSystemClockSeqGyrXFileFilePath,'Resolution',600);
exportgraphics(figureObject2,cAndroidSystemClockSeqGyrYFileFilePath,'Resolution',600);
exportgraphics(figureObject3,cAndroidSystemClockSeqGyrZFileFilePath,'Resolution',600);
exportgraphics(figureObject4,cAndroidSystemClockSeqAccXFileFilePath,'Resolution',600);
exportgraphics(figureObject5,cAndroidSystemClockSeqAccYFileFilePath,'Resolution',600);
exportgraphics(figureObject6,cAndroidSystemClockSeqAccZFileFilePath,'Resolution',600);

% close(figureMapHandle);



end