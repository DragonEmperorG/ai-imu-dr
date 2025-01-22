function [] = plotTrackGnssClockImuDataCrossCorrelation(trackFolderPath)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'plotTrackGnssClockImuDataCrossCorrelation';

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

resampleRate = 200;
resampleInterval = 1 / resampleRate;
resampleTime = (pTrackFineClipHeadTime:resampleInterval:pTrackFineClipTailTime)';
resampleTimeSize = size(resampleTime,1);
pTrackGTImu = interp1(tTrackGroundTruthImuGnssClockTime,tTrackGroundTruthImuRawData(:,2:7),resampleTime);
pTrackGPGyr = interp1(tTrackGooglePixel3GyroGnssClockTime,tTrackGooglePixel3ImuGyroRawData(:,4:6),resampleTime);
pTrackGPAcc = interp1(tTrackGooglePixel3AcceGnssClockTime,tTrackGooglePixel3ImuAcceRawData(:,4:6),resampleTime);
pTrackHMGyr = interp1(tTrackHuaweiMate30GyroGnssClockTime,tTrackHuaweiMate30ImuGyroRawData(:,4:6),resampleTime);
pTrackHMAcc = interp1(tTrackHuaweiMate30AcceGnssClockTime,tTrackHuaweiMate30ImuAcceRawData(:,4:6),resampleTime);

[pTrackGTGPGyrAxisXXCorr,pTimeLag] = xcorr(pTrackGTImu(:,4),pTrackGPGyr(:,1),'normalized');
pTrackGTGPGyrAxisYXCorr = xcorr(pTrackGTImu(:,5),pTrackGPGyr(:,2),'normalized');
pTrackGTGPGyrAxisZXCorr = xcorr(pTrackGTImu(:,6),pTrackGPGyr(:,3),'normalized');
pTrackGTGPAccAxisXXCorr = xcorr(pTrackGTImu(:,1),pTrackGPAcc(:,1),'normalized');
pTrackGTGPAccAxisYXCorr = xcorr(pTrackGTImu(:,2),pTrackGPAcc(:,2),'normalized');
pTrackGTGPAccAxisZXCorr = xcorr(pTrackGTImu(:,3),pTrackGPAcc(:,3),'normalized');
pTrackGTHMGyrAxisXXCorr = xcorr(pTrackGTImu(:,4),pTrackHMGyr(:,1),'normalized');
pTrackGTHMGyrAxisYXCorr = xcorr(pTrackGTImu(:,5),pTrackHMGyr(:,2),'normalized');
pTrackGTHMGyrAxisZXCorr = xcorr(pTrackGTImu(:,6),pTrackHMGyr(:,3),'normalized');
pTrackGTHMAccAxisXXCorr = xcorr(pTrackGTImu(:,1),pTrackHMAcc(:,1),'normalized');
pTrackGTHMAccAxisYXCorr = xcorr(pTrackGTImu(:,2),pTrackHMAcc(:,2),'normalized');
pTrackGTHMAccAxisZXCorr = xcorr(pTrackGTImu(:,3),pTrackHMAcc(:,3),'normalized');

[pTrackGTGPGyrAxisXXCorrM,pTrackGTGPGyrAxisXXCorrI] = max(pTrackGTGPGyrAxisXXCorr);
[pTrackGTGPGyrAxisYXCorrM,pTrackGTGPGyrAxisYXCorrI] = max(pTrackGTGPGyrAxisYXCorr);
[pTrackGTGPGyrAxisZXCorrM,pTrackGTGPGyrAxisZXCorrI] = max(pTrackGTGPGyrAxisZXCorr);
[pTrackGTGPAccAxisXXCorrM,pTrackGTGPAccAxisXXCorrI] = max(pTrackGTGPAccAxisXXCorr);
[pTrackGTGPAccAxisYXCorrM,pTrackGTGPAccAxisYXCorrI] = max(pTrackGTGPAccAxisYXCorr);
[pTrackGTGPAccAxisZXCorrM,pTrackGTGPAccAxisZXCorrI] = max(pTrackGTGPAccAxisZXCorr);
[pTrackGTHMGyrAxisXXCorrM,pTrackGTHMGyrAxisXXCorrI] = max(pTrackGTHMGyrAxisXXCorr);
[pTrackGTHMGyrAxisYXCorrM,pTrackGTHMGyrAxisYXCorrI] = max(pTrackGTHMGyrAxisYXCorr);
[pTrackGTHMGyrAxisZXCorrM,pTrackGTHMGyrAxisZXCorrI] = max(pTrackGTHMGyrAxisZXCorr);
[pTrackGTHMAccAxisXXCorrM,pTrackGTHMAccAxisXXCorrI] = max(pTrackGTHMAccAxisXXCorr);
[pTrackGTHMAccAxisYXCorrM,pTrackGTHMAccAxisYXCorrI] = max(pTrackGTHMAccAxisYXCorr);
[pTrackGTHMAccAxisZXCorrM,pTrackGTHMAccAxisZXCorrI] = max(pTrackGTHMAccAxisZXCorr);

pGyrAxisX = [pTrackGTGPGyrAxisXXCorr;pTrackGTHMGyrAxisXXCorr];
pGyrAxisY = [pTrackGTGPGyrAxisYXCorr;pTrackGTHMGyrAxisYXCorr];
pGyrAxisZ = [pTrackGTGPGyrAxisZXCorr;pTrackGTHMGyrAxisZXCorr];
pAccAxisX = [pTrackGTGPAccAxisXXCorr;pTrackGTHMAccAxisXXCorr];
pAccAxisY = [pTrackGTGPAccAxisYXCorr;pTrackGTHMAccAxisYXCorr];
pAccAxisZ = [pTrackGTGPAccAxisZXCorr;pTrackGTHMAccAxisZXCorr];

pTimeAxis = pTimeLag * resampleInterval;

pTrackGTGPGyrAxisXXCorrITime = pTimeAxis(pTrackGTGPGyrAxisXXCorrI);
pTrackGTGPGyrAxisYXCorrITime = pTimeAxis(pTrackGTGPGyrAxisYXCorrI);
pTrackGTGPGyrAxisZXCorrITime = pTimeAxis(pTrackGTGPGyrAxisZXCorrI);
pTrackGTGPAccAxisXXCorrITime = pTimeAxis(pTrackGTGPAccAxisXXCorrI);
pTrackGTGPAccAxisYXCorrITime = pTimeAxis(pTrackGTGPAccAxisYXCorrI);
pTrackGTGPAccAxisZXCorrITime = pTimeAxis(pTrackGTGPAccAxisZXCorrI);
pTrackGTHMGyrAxisXXCorrITime = pTimeAxis(pTrackGTHMGyrAxisXXCorrI);
pTrackGTHMGyrAxisYXCorrITime = pTimeAxis(pTrackGTHMGyrAxisYXCorrI);
pTrackGTHMGyrAxisZXCorrITime = pTimeAxis(pTrackGTHMGyrAxisZXCorrI);
pTrackGTHMAccAxisXXCorrITime = pTimeAxis(pTrackGTHMAccAxisXXCorrI);
pTrackGTHMAccAxisYXCorrITime = pTimeAxis(pTrackGTHMAccAxisYXCorrI);
pTrackGTHMAccAxisZXCorrITime = pTimeAxis(pTrackGTHMAccAxisZXCorrI);


logMsg = sprintf('Gyroscope Axis X | Google Pixel3 %.3f | Huawei Mate30 %.3f | %.3f', ...
    pTrackGTGPGyrAxisXXCorrITime,pTrackGTHMGyrAxisXXCorrITime,pTrackGTHMGyrAxisXXCorrITime-pTrackGTGPGyrAxisXXCorrITime);
log2terminal('I',TAG,logMsg);
logMsg = sprintf('Gyroscope Axis Y | Google Pixel3 %.3f | Huawei Mate30 %.3f | %.3f', ...
    pTrackGTGPGyrAxisYXCorrITime,pTrackGTHMGyrAxisYXCorrITime,pTrackGTHMGyrAxisYXCorrITime-pTrackGTGPGyrAxisYXCorrITime);
log2terminal('I',TAG,logMsg);
logMsg = sprintf('Gyroscope Axis Z | Google Pixel3 %.3f | Huawei Mate30 %.3f | %.3f', ...
    pTrackGTGPGyrAxisZXCorrITime,pTrackGTHMGyrAxisZXCorrITime,pTrackGTHMGyrAxisZXCorrITime-pTrackGTGPGyrAxisZXCorrITime);
log2terminal('I',TAG,logMsg);
logMsg = sprintf('Accelerometer Axis X | Google Pixel3 %.3f | Huawei Mate30 %.3f | %.3f', ...
    pTrackGTGPAccAxisXXCorrITime,pTrackGTHMAccAxisXXCorrITime,pTrackGTHMAccAxisXXCorrITime-pTrackGTGPAccAxisXXCorrITime);
log2terminal('I',TAG,logMsg);
logMsg = sprintf('Accelerometer Axis Y | Google Pixel3 %.3f | Huawei Mate30 %.3f | %.3f', ...
    pTrackGTGPAccAxisYXCorrITime,pTrackGTHMAccAxisYXCorrITime,pTrackGTHMAccAxisYXCorrITime-pTrackGTGPAccAxisYXCorrITime);
log2terminal('I',TAG,logMsg);
logMsg = sprintf('Accelerometer Axis Z | Google Pixel3 %.3f | Huawei Mate30 %.3f | %.3f', ...
    pTrackGTGPAccAxisZXCorrITime,pTrackGTHMAccAxisZXCorrITime,pTrackGTHMAccAxisZXCorrITime-pTrackGTGPAccAxisZXCorrITime);
log2terminal('I',TAG,logMsg);

figureObject1 = figure;
axesObject11 = gca;
hold on;
lineObjectGTGPGyrX = plot(pTimeAxis,pTrackGTGPGyrAxisXXCorr);
lineObjectGTHMGyrX = plot(pTimeAxis,pTrackGTHMGyrAxisXXCorr);
legendObject1 = legend();
hold off;
axesObject12 = axes(figureObject1);
hold on;
lineObjectGTGPGyrX1 = plot(axesObject12,pTimeAxis,pTrackGTGPGyrAxisXXCorr);
lineObjectGTHMGyrX1 = plot(axesObject12,pTimeAxis,pTrackGTHMGyrAxisXXCorr);
hold off;


figureObject2 = figure;
axesObject21 = gca;
hold on;
lineObjectGTGPGyrY = plot(pTimeAxis,pTrackGTGPGyrAxisYXCorr);
lineObjectGTHMGyrY = plot(pTimeAxis,pTrackGTHMGyrAxisYXCorr);
legendObject2 = legend();
hold off;
axesObject22 = axes(figureObject2);
hold on;
lineObjectGTGPGyrY1 = plot(pTimeAxis,pTrackGTGPGyrAxisYXCorr);
lineObjectGTHMGyrY1 = plot(pTimeAxis,pTrackGTHMGyrAxisYXCorr);
hold off;

figureObject3 = figure;
axesObject31 = gca;
hold on;
lineObjectGTGPGyrZ = plot(pTimeAxis,pTrackGTGPGyrAxisZXCorr);
lineObjectGTHMGyrZ = plot(pTimeAxis,pTrackGTHMGyrAxisZXCorr);
legendObject3 = legend();
hold off;
axesObject32 = axes(figureObject3);
hold on;
lineObjectGTGPGyrZ1 = plot(pTimeAxis,pTrackGTGPGyrAxisZXCorr);
lineObjectGTHMGyrZ1 = plot(pTimeAxis,pTrackGTHMGyrAxisZXCorr);
hold off;


figureObject4 = figure;
axesObject41 = gca;
hold on;
lineObjectGTGPAccX = plot(pTimeAxis,pTrackGTGPAccAxisXXCorr);
lineObjectGTHMAccX = plot(pTimeAxis,pTrackGTHMAccAxisXXCorr);
legendObject4 = legend();
hold off;
axesObject42 = axes(figureObject4);
hold on;
lineObjectGTGPAccX1 = plot(pTimeAxis,pTrackGTGPAccAxisXXCorr);
lineObjectGTHMAccX1 = plot(pTimeAxis,pTrackGTHMAccAxisXXCorr);
hold off;

figureObject5 = figure;
axesObject51 = gca;
hold on;
lineObjectGTGPAccY = plot(pTimeAxis,pTrackGTGPAccAxisYXCorr);
lineObjectGTHMAccY = plot(pTimeAxis,pTrackGTHMAccAxisYXCorr);
legendObject5 = legend();
hold off;
axesObject52 = axes(figureObject5);
hold on;
lineObjectGTGPAccY1 = plot(pTimeAxis,pTrackGTGPAccAxisYXCorr);
lineObjectGTHMAccY1 = plot(pTimeAxis,pTrackGTHMAccAxisYXCorr);
hold off;

figureObject6 = figure;
axesObject61 = gca;
hold on;
lineObjectGTGPAccZ = plot(pTimeAxis,pTrackGTGPAccAxisZXCorr);
lineObjectGTHMAccZ = plot(pTimeAxis,pTrackGTHMAccAxisZXCorr);
legendObject6 = legend();
hold off;
axesObject62 = axes(figureObject6);
hold on;
lineObjectGTGPAccZ1 = plot(pTimeAxis,pTrackGTGPAccAxisZXCorr);
lineObjectGTHMAccZ1 = plot(pTimeAxis,pTrackGTHMAccAxisZXCorr);
hold off;

figureObjectList = [figureObject1,figureObject2,figureObject3,figureObject4,figureObject5,figureObject6];

axesObjectMainList = [axesObject11,axesObject21,axesObject31,axesObject41,axesObject51,axesObject61];
axesObjectPipList = [axesObject12,axesObject22,axesObject32,axesObject42,axesObject52,axesObject62];
axesObjectList = [axesObjectMainList,axesObjectPipList];

legendObjectList = [legendObject1,legendObject2,legendObject3,legendObject4,legendObject5,legendObject6];

lineObjectGTGPGyrList = [lineObjectGTGPGyrX,lineObjectGTGPGyrY,lineObjectGTGPGyrZ];
lineObjectGTGPAccList = [lineObjectGTGPAccX,lineObjectGTGPAccY,lineObjectGTGPAccZ];
lineObjectGTHMGyrList = [lineObjectGTHMGyrX,lineObjectGTHMGyrY,lineObjectGTHMGyrZ];
lineObjectGTHMAccList = [lineObjectGTHMAccX,lineObjectGTHMAccY,lineObjectGTHMAccZ];
lineObjectGTGPList = [lineObjectGTGPGyrList,lineObjectGTGPAccList];
lineObjectGTHMList = [lineObjectGTHMGyrList,lineObjectGTHMAccList];
lineObjectMainList = [lineObjectGTGPList,lineObjectGTHMList];
lineObjectGTGP1GyrList = [lineObjectGTGPGyrX1,lineObjectGTGPGyrY1,lineObjectGTGPGyrZ1];
lineObjectGTGP1AccList = [lineObjectGTGPAccX1,lineObjectGTGPAccY1,lineObjectGTGPAccZ1];
lineObjectGTHM1GyrList = [lineObjectGTHMGyrX1,lineObjectGTHMGyrY1,lineObjectGTHMGyrZ1];
lineObjectGTHM1AccList = [lineObjectGTHMAccX1,lineObjectGTHMAccY1,lineObjectGTHMAccZ1];
lineObjectGTGP1List = [lineObjectGTGP1GyrList,lineObjectGTGP1AccList];
lineObjectGTHM1List = [lineObjectGTHM1GyrList,lineObjectGTHM1AccList];
lineObjectPipList = [lineObjectGTGP1List,lineObjectGTHM1List];
lineObjectList = [lineObjectMainList,lineObjectPipList];

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


% Axes 属性 https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.axis.axes-properties.html
% 字体
for i = 1:length(axesObjectList)
    set(axesObjectList(i),'FontName','Times New Roman');
    set(axesObjectList(i),'FontSize',10.5);
end

% 网格
axesPropertyXLim = [pTimeAxis(1) pTimeAxis(end)];
for i = 1:length(axesObjectMainList)
    set(axesObjectMainList(i),'XLim',axesPropertyXLim);
end
for i = 1:length(axesObjectPipList)
    set(axesObjectPipList(i),'XLim',[-1 1]);
end

for i = 1:length(axesObjectMainList)
    set(axesObjectMainList(i),'YLim',[-0.2 1]);
end

% pGyrMinAxisX = min(pGyrAxisX);
% pGyrMaxAxisX = max(pGyrAxisX);
% axesObject1PropertyXLimMin = floor(pGyrMinAxisX*10)/10;
% axesObject1PropertyXLimMax = ceil(pGyrMaxAxisX*10)/10;
% pGyrMinAxisY = min(pGyrAxisY);
% pGyrMaxAxisY = max(pGyrAxisY);
% axesObject2PropertyXLimMin = floor(pGyrMinAxisY*10)/10;
% axesObject2PropertyXLimMax = ceil(pGyrMaxAxisY*10)/10;
% pGyrMinAxisZ = min(pGyrAxisZ);
% pGyrMaxAxisZ = max(pGyrAxisZ);
% axesObject3PropertyXLimMin = floor(pGyrMinAxisZ*10)/10;
% axesObject3PropertyXLimMax = ceil(pGyrMaxAxisZ*10)/10;
% pAccMinAxisX = min(pAccAxisX);
% pAccMaxAxisX = max(pAccAxisX);
% axesObject4PropertyXLimMin = floor(pAccMinAxisX*10)/10;
% axesObject4PropertyXLimMax = ceil(pAccMaxAxisX*10)/10;
% pAccMinAxisY = min(pAccAxisY);
% pAccMaxAxisY = max(pAccAxisY);
% axesObject5PropertyXLimMin = floor(pAccMinAxisY*10)/10;
% axesObject5PropertyXLimMax = ceil(pAccMaxAxisY*10)/10;
% pAccMinAxisZ = min(pAccAxisZ);
% pAccMaxAxisZ = max(pAccAxisZ);
% axesObject6PropertyXLimMin = floor(pAccMinAxisZ*10)/10;
% axesObject6PropertyXLimMax = ceil(pAccMaxAxisZ*10)/10;
% set(axesObject11,'YLim',[axesObject1PropertyXLimMin axesObject1PropertyXLimMax]);
% set(axesObject21,'YLim',[axesObject2PropertyXLimMin axesObject2PropertyXLimMax]);
% set(axesObject31,'YLim',[axesObject3PropertyXLimMin axesObject3PropertyXLimMax]);
% set(axesObject41,'YLim',[axesObject4PropertyXLimMin axesObject4PropertyXLimMax]);
% set(axesObject51,'YLim',[axesObject5PropertyXLimMin axesObject5PropertyXLimMax]);
% set(axesObject61,'YLim',[axesObject6PropertyXLimMin axesObject6PropertyXLimMax]);

% 网格
for i = 1:length(axesObjectList)
    set(axesObjectList(i),'Layer','top');
end

% 标签
for i = 1:length(axesObjectMainList)
    set(get(axesObjectMainList(i),'XLabel'),'String','\fontname{宋体}互相关时间偏移\fontname{Times new roman}(s)');
    set(get(axesObjectMainList(i),'YLabel'),'String','\fontname{宋体}互相关结果\fontname{Times new roman}');
end

for i = 1:length(axesObjectPipList)
    set(axesObjectPipList(i),'XAxisLocation','origin');
    set(axesObjectPipList(i),'YAxisLocation','origin');
end

% 框样式
% 框轮廓
for i = 1:length(axesObjectPipList)
    set(axesObjectPipList(i),'Box','on');
end

% 位置
for i = 1:length(axesObjectPipList)
    set(axesObjectPipList(i),'Position',[0.55,0.35,0.35,0.45]);
end

% Line 属性 https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.chart.primitive.line-properties.html
% 线条
% https://waldyrious.net/viridis-palette-generator/
% cPaletteViridisCategories11Color = ["#fde725" "#21918c" "#440154"];
cPaletteViridisCategories2Color = ["#00ff00" "#0000ff"];
for i = 1:length(lineObjectGTGPList)
    set(lineObjectGTGPList(i),"Color",cPaletteViridisCategories2Color(1));
end
for i = 1:length(lineObjectGTGP1List)
    set(lineObjectGTGP1List(i),"Color",cPaletteViridisCategories2Color(1));
end

for i = 1:length(lineObjectGTHMList)
    set(lineObjectGTHMList(i),"Color",cPaletteViridisCategories2Color(2));
end
for i = 1:length(lineObjectGTHM1List)
    set(lineObjectGTHM1List(i),"Color",cPaletteViridisCategories2Color(2));
end

% 图例
kNovAtelSPANString = 'NovAtel SPAN';
kGooglePixel3String = 'Google Pixel3';
kHuaweiMate30String = 'Huawei Mate30';
for i = 1:length(lineObjectGTGPList)
    set(lineObjectGTGPList(i),"DisplayName",kGooglePixel3String);
end
for i = 1:length(lineObjectGTHMList)
    set(lineObjectGTHMList(i),"DisplayName",kHuaweiMate30String);
end


% Legend 属性
% 位置和布局
for i = 1:length(legendObjectList)
    set(legendObjectList(i),'Location','northoutside');
    set(legendObjectList(i),'Orientation','horizontal');
    set(legendObjectList(i),'NumColumns',3);
    set(legendObjectList(i),'Direction','reverse');
end
% 字体
for i = 1:length(legendObjectList)
    set(legendObjectList(i),'FontName','Times New Roman');
    set(legendObjectList(i),'FontSize',10.5);
end

cAndroidSystemClockSeqGyrXFileName = sprintf('GnssClockGyroscopeUncalibratedXAxisCrossCorrelation.png');
cAndroidSystemClockSeqGyrYFileName = sprintf('GnssClockGyroscopeUncalibratedYAxisCrossCorrelation.png');
cAndroidSystemClockSeqGyrZFileName = sprintf('GnssClockGyroscopeUncalibratedZAxisCrossCorrelation.png');
cAndroidSystemClockSeqAccXFileName = sprintf('GnssClockAccelerometerUncalibratedXAxisCrossCorrelation.png');
cAndroidSystemClockSeqAccYFileName = sprintf('GnssClockAccelerometerUncalibratedYAxisCrossCorrelation.png');
cAndroidSystemClockSeqAccZFileName = sprintf('GnssClockAccelerometerUncalibratedZAxisCrossCorrelation.png');
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

for i = 1:length(figureObjectList)
    close(figureObjectList(i));
end

end