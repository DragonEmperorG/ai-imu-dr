function [] = plotFilterStateNavSE2(folderPath)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明

preprocessRawFlatData = loadPreprocessRawFlat(folderPath);
preprocessTime = getPreprocessTime(preprocessRawFlatData);
preprocessGroundTruthNavOrientationEulerAngleDeg = getPreprocessGroundTruthNavOrientationEulerAngleDeg(preprocessRawFlatData);
preprocessGroundTruthNavVelocity = getPreprocessGroundTruthNavVelocity(preprocessRawFlatData);
preprocessGroundTruthNavPosition = getPreprocessGroundTruthNavPosition(preprocessRawFlatData);

filterState = loadFilterStateIntegratedGroundTruth(folderPath);

printFolderPath = fullfile(folderPath,'dayZeroOClockAlign');

filterStateTime = getFilterStateTime(filterState);
filterStateNavOrientationEulerAngleDeg = getFilterStateNavOrientationEulerAngleDeg(filterState);
filterStateNavVelocity = getFilterStateNavVelocity(filterState);
filterStateNavPosition = getFilterStateNavPosition(filterState);

filterStateTimeMin = min(filterStateTime);
filterStateTimeFloor = floor(filterStateTimeMin);

figureHandle = figure;
timeReferenceSubPlotRows = 3;
timeReferenceSubPlotColumns = 1;
pX = filterStateTime - filterStateTimeFloor;

axesObject1 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,1);
pY1 = filterStateNavOrientationEulerAngleDeg;
pY1g = preprocessGroundTruthNavOrientationEulerAngleDeg;
hold on;
lineObject11 = plot(pX,pY1(:,1));
lineObject12 = plot(pX,pY1(:,2));
lineObject13 = plot(pX,pY1(:,3));
xlabel('Sample (s)');
ylabel('Value (rad/s)');
title('Smart Phone raw IMU gyroscope data');
legend1 = legend();
grid on;
hold off;

axesObject2 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,2);
pY2 = filterStateNavVelocity;
pY2g = preprocessGroundTruthNavVelocity;
hold on;
lineObject21 = plot(pX,pY2(:,1));
lineObject22 = plot(pX,pY2(:,2));
lineObject23 = plot(pX,pY2(:,3));
title('World Velocity');
xlabel("Time (s)");
ylabel("Value (m/s)");
legend2 = legend();
grid on;
hold off;

axesObject3 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,3);
pY3 = filterStateNavPosition;
pY3g = preprocessGroundTruthNavPosition;
hold on;
lineObject31 = plot(pX,pY3(:,1));
lineObject32 = plot(pX,pY3(:,2));
lineObject33 = plot(pX,pY3(:,3));
lineObject31g = plot(pX,pY3g(:,1));
lineObject32g = plot(pX,pY3g(:,2));
lineObject33g = plot(pX,pY3g(:,3));
title('World Position');
xlabel("Time (s)");
ylabel("Value (m)");
legend3 = legend();
grid on;
hold off;

% Line 属性
% 线条
set(lineObject11,'Color',"r");
set(lineObject12,'Color',"g");
set(lineObject13,'Color',"b");
set(lineObject21,'Color',"r");
set(lineObject22,'Color',"g");
set(lineObject23,'Color',"b");
set(lineObject31,'Color',"r");
set(lineObject32,'Color',"g");
set(lineObject33,'Color',"b");
set(lineObject31g,'Color',"r");
set(lineObject32g,'Color',"g");
set(lineObject33g,'Color',"b");

set(lineObject31g,'LineStyle',"--");
set(lineObject32g,'LineStyle',"--");
set(lineObject33g,'LineStyle',"--");

% 图例
set(lineObject11,'DisplayName',"Pitch");
set(lineObject12,'DisplayName',"Roll");
set(lineObject13,'DisplayName',"Yaw");
set(lineObject21,'DisplayName',"East");
set(lineObject22,'DisplayName',"North");
set(lineObject23,'DisplayName',"Up");
set(lineObject31,'DisplayName',"East");
set(lineObject32,'DisplayName',"North");
set(lineObject33,'DisplayName',"Up");
set(lineObject31g,'DisplayName',"GT East");
set(lineObject32g,'DisplayName',"GT North");
set(lineObject33g,'DisplayName',"GT Up");

% Legend 属性
% 字体
set(legend1,'FontName','Times New Roman');
set(legend2,'FontName','Times New Roman');
set(legend3,'FontName','Times New Roman');
set(legend1,'FontSize',10);
set(legend2,'FontSize',10);
set(legend3,'FontSize',10);
set(legend1,'Location','bestoutside');
set(legend2,'Location','bestoutside');
set(legend3,'Location','bestoutside');

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
set(axesObject1,'FontName','Times New Roman');
set(axesObject2,'FontName','Times New Roman');
set(axesObject3,'FontName','Times New Roman');

% I. Using Labels Within Figures
% Figure labels should be legible, approximately 8- to 10-point type.
% 字体大小
set(axesObject1,'FontSize',10);
set(axesObject2,'FontSize',10);
set(axesObject3,'FontSize',10);

saveFigFileName = "StateNavSE2";
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
% set(gca,'Units','centimeters');
% set(gca,'OuterPosition',gcf().Position);

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

close(figureHandle);

end