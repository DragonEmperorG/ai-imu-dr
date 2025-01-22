function [] = plotDDOriLossValueComparation(trackFolderPath)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'plotDDOriLossValueComparation';

cModelDeepOriLossOrientationWindowInfLossMinus2FileName = "LossOrientationWindowInfLoss-2.txt";
cModelDeepOriLossOrientationWindowInfLossMinus3FileName = "LossOrientationWindowInfLoss-3.txt";
cModelDeepOriLossOrientationWindowInfLossMinus4FileName = "LossOrientationWindowInfLoss-4.txt";
cModelDeepOriLossOrientationWindowInfLossMinus5FileName = "LossOrientationWindowInfLoss-5.txt";
cModelDeepOriLossOrientationWindowInfLossMinus6FileName = "LossOrientationWindowInfLoss-6.txt";

cComparedResultList = [
    cModelDeepOriLossOrientationWindowInfLossMinus2FileName,...
    cModelDeepOriLossOrientationWindowInfLossMinus3FileName,...
    cModelDeepOriLossOrientationWindowInfLossMinus4FileName,...
    cModelDeepOriLossOrientationWindowInfLossMinus5FileName,...
    cModelDeepOriLossOrientationWindowInfLossMinus6FileName...
];
cComparedResultListLength = length(cComparedResultList);

tTrackGroundTruthOriRotm = loadDataDrivenAttitudeGroundTruth(trackFolderPath);
tTrackGroundTruthOriEuler = convertOrientationRotationMatrixToEulerAngle(tTrackGroundTruthOriRotm, true);
tTrackTestOriRotmCellList = cell([2 cComparedResultListLength]);
for k = 1:cComparedResultListLength
    tTrackTestOriRotmCellList{1,k} = loadCustomDataDrivenAttitudeMeasurement(trackFolderPath,1,cComparedResultList(k));
    tTrackTestOriRotmCellList{2,k} = convertOrientationRotationMatrixToEulerAngle(tTrackTestOriRotmCellList{1,k}, true);
end

tTrackTimeLength = size(tTrackGroundTruthOriRotm,3);
pT = 0:1:(tTrackTimeLength-1);

pTTickValues = 0:10:(tTrackTimeLength+10);

cPaletteViridisCategories11Color = ["#fde725" "#5ec962" "#21918c" "#3b528b" "#440154"];
cTrackTestDisplayName = ["e^{-2}" "e^{-3}" "e^{-4}" "e^{-5}" "e^{-6}"];

figureObject1 = figure;
axesObject1 = gca;
hold on;
for k = 1:cComparedResultListLength
    lineObject = plot(pT,tTrackTestOriRotmCellList{2,k}(:,1));
    set(lineObject,"Color",cPaletteViridisCategories11Color(k));
    set(lineObject,"DisplayName",cTrackTestDisplayName(k));
end
lineObject1 = plot(pT,tTrackGroundTruthOriEuler(:,1));
% legendObject1 = legend();
grid on;
hold off;

figureObject2 = figure;
axesObject2 = gca;
hold on;
for k = 1:cComparedResultListLength
    lineObject = plot(pT,tTrackTestOriRotmCellList{2,k}(:,2));
    set(lineObject,"Color",cPaletteViridisCategories11Color(k));
    set(lineObject,"DisplayName",cTrackTestDisplayName(k));
end
lineObject2 = plot(pT,tTrackGroundTruthOriEuler(:,2));
% legendObject2 = legend();
grid on;
hold off;

figureObject3 = figure;
axesObject3 = gca;
hold on;
for k = 1:cComparedResultListLength
    lineObject = plot(pT,tTrackTestOriRotmCellList{2,k}(:,3));
    set(lineObject,"Color",cPaletteViridisCategories11Color(k));
    set(lineObject,"DisplayName",cTrackTestDisplayName(k));
end
lineObject3 = plot(pT,tTrackGroundTruthOriEuler(:,3));
legendObject3 = legend();
grid on;
hold off;

figureObjectList = [figureObject1,figureObject2,figureObject3];

axesObjectList = [axesObject1,axesObject2,axesObject3];

% legendObjectList = [legendObject1,legendObject2,legendObject3];
legendObjectList = [legendObject3];

% http://gs.xjtu.edu.cn/info/1209/7605.htm
% 参考《西安交通大学博士、硕士学位论文模板（2021版）》中对图的要求
% 图尺寸的一般宽高比应为6.67 cm×5.00 cm。特殊情况下， 也可为
% 9.00 cm×6.75 cm， 或13.5 cm×9.00 cm。总之， 一篇论文中， 同类图片的
% 大小应该一致，编排美观、整齐；
figurePropertiesPositionLeft = 10;
figurePropertiesPositionBottom = 20;
figurePropertiesPositionWidth = 16;
figurePropertiesPositionHeight = 3;
figurePropertiesPosition = [ ...
    figurePropertiesPositionLeft ...
    figurePropertiesPositionBottom ...
    figurePropertiesPositionWidth ...
    figurePropertiesPositionHeight ...
    ];
figurePropertiesPaperSize = [figurePropertiesPositionWidth figurePropertiesPositionHeight];
% 位置和大小
set(figureObject1,'Units','centimeters');
set(figureObject1,'Position',figurePropertiesPosition);
% 打印和导出
set(figureObject1,'PaperUnits','centimeters');
set(figureObject1,'PaperPosition',figurePropertiesPosition);
set(figureObject1,'PaperSize',figurePropertiesPaperSize);

figurePropertiesPositionLeft = 10;
figurePropertiesPositionBottom = 15;
figurePropertiesPositionWidth = 16;
figurePropertiesPositionHeight = 3;
figurePropertiesPosition = [ ...
    figurePropertiesPositionLeft ...
    figurePropertiesPositionBottom ...
    figurePropertiesPositionWidth ...
    figurePropertiesPositionHeight ...
    ];
figurePropertiesPaperSize = [figurePropertiesPositionWidth figurePropertiesPositionHeight];
% 位置和大小
set(figureObject2,'Units','centimeters');
set(figureObject2,'Position',figurePropertiesPosition);
% 打印和导出
set(figureObject2,'PaperUnits','centimeters');
set(figureObject2,'PaperPosition',figurePropertiesPosition);
set(figureObject2,'PaperSize',figurePropertiesPaperSize);

figurePropertiesPositionLeft = 10;
figurePropertiesPositionBottom = 5;
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
set(figureObject3,'Units','centimeters');
set(figureObject3,'Position',figurePropertiesPosition);
% 打印和导出
set(figureObject3,'PaperUnits','centimeters');
set(figureObject3,'PaperPosition',figurePropertiesPosition);
set(figureObject3,'PaperSize',figurePropertiesPaperSize);


% Axes 属性 https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.axis.axes-properties.html
% 字体
for i = 1:length(axesObjectList)
    set(axesObjectList(i),'FontName','Times New Roman');
    set(axesObjectList(i),'FontSize',10.5);
end

% 刻度
for i = 1:length(axesObjectList)
    set(axesObjectList(i),'XTick',pTTickValues);
end

set(axesObject3,'YTick',-180:30:180);

% 标尺
axesPropertyXLim = [pT(1) pT(end)];
for i = 1:length(axesObjectList)
    set(axesObjectList(i),'XLim',axesPropertyXLim);
end

set(axesObject1,'YLim',[-10 10]);
set(axesObject2,'YLim',[-10 10]);
set(axesObject3,'YLim',[-180 180]);

% 网格
for i = 1:length(axesObjectList)
    set(axesObjectList(i),'Layer','top');
    set(axesObjectList(i),'GridLineStyle','--');
end

% 标签
for i = 1:length(axesObjectList)
    set(get(axesObjectList(i),'XLabel'),'String','\fontname{宋体}时间\fontname{Times new roman}(s)');
end
set(get(axesObjectList(1),'YLabel'),'String','\fontname{宋体}欧拉角\theta\fontname{Times new roman}(°)');
set(get(axesObjectList(2),'YLabel'),'String','\fontname{宋体}欧拉角\phi\fontname{Times new roman}(°)');
set(get(axesObjectList(3),'YLabel'),'String','\fontname{宋体}欧拉角\psi\fontname{Times new roman}(°)');

% for i = 1:length(axesObjectList)
%     set(axesObjectList(i),'XAxisLocation','origin');
%     set(axesObjectList(i),'YAxisLocation','origin');
% end

% Line 属性 https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.chart.primitive.line-properties.html
% 线条
set(lineObject1,"Color",'r');
set(lineObject2,"Color",'r');
set(lineObject3,"Color",'r');
pLineWidth = 0.9;
set(lineObject1,"LineWidth",pLineWidth);
set(lineObject2,"LineWidth",pLineWidth);
set(lineObject3,"LineWidth",pLineWidth);

% % 图例
set(lineObject1,"DisplayName",'\fontname{宋体}真值');
set(lineObject2,"DisplayName",'\fontname{宋体}真值');
set(lineObject3,"DisplayName",'\fontname{宋体}真值');

% Legend 属性
% 位置和布局
for i = 1:length(legendObjectList)
    set(legendObjectList(i),'Location','northoutside');
    set(legendObjectList(i),'Orientation','horizontal');
    set(legendObjectList(i),'NumColumns',6);
    % set(legendObjectList(i),'Direction','reverse');
end
% 字体
for i = 1:length(legendObjectList)
    set(legendObjectList(i),'FontName','Times New Roman');
    set(legendObjectList(i),'FontSize',10.5);
end

cAndroidSystemClockSeqGyrXFileName = sprintf('DataDrivenOrientationTest08QuaternionLossValueTrackPitch.png');
cAndroidSystemClockSeqGyrYFileName = sprintf('DataDrivenOrientationTest08QuaternionLossValueTrackRoll.png');
cAndroidSystemClockSeqGyrZFileName = sprintf('DataDrivenOrientationTest08QuaternionLossValueTrackHeading.png');
cAndroidSystemClockSeqGyrXFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqGyrXFileName);
cAndroidSystemClockSeqGyrYFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqGyrYFileName);
cAndroidSystemClockSeqGyrZFileFilePath = fullfile(trackFolderPath,cAndroidSystemClockSeqGyrZFileName);
exportgraphics(figureObject1,cAndroidSystemClockSeqGyrXFileFilePath,'Resolution',600);
exportgraphics(figureObject2,cAndroidSystemClockSeqGyrYFileFilePath,'Resolution',600);
exportgraphics(figureObject3,cAndroidSystemClockSeqGyrZFileFilePath,'Resolution',600);

for i = 1:length(figureObjectList)
    close(figureObjectList(i));
end

end