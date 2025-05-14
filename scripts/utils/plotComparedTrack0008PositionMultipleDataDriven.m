function [] = plotComparedTrack0008PositionMultipleDataDriven(folderPath)
%UNTITLED2 此处显示有关此函数的摘要、
%   此处显示详细说明

preprocessGroundTruthNavPosition = loadPreprocessGroundTruthNavPosition(folderPath);

filterStateIntegrated2DNHCDataDriven = loadFilterStateIntegratedCustomDataDriven(folderPath,'Integrated2DNHCDataDriven.mat');
filterStateIntegrated3DNHCDataDriven = loadFilterStateIntegratedCustomDataDriven(folderPath,'Integrated3DNHCDataDriven.mat');
filterStateIntegrated2DNHCATTDataDriven = loadFilterStateIntegratedCustomDataDriven(folderPath,'Integrated2DNHCATTDataDriven.mat');
filterStateIntegratedDataDriven = loadFilterStateIntegratedCustomDataDriven(folderPath,'IntegratedDataDriven.mat');

filterStateIntegrated2DNHCDataDrivenClipped = loadFilterStateIntegratedCustomDataDriven(folderPath,'Integrated2DNHCDataDrivenClipped.mat');
filterStateIntegrated3DNHCDataDrivenClipped = loadFilterStateIntegratedCustomDataDriven(folderPath,'Integrated3DNHCDataDrivenClipped.mat');
filterStateIntegrated2DNHCATTDataDrivenClipped = loadFilterStateIntegratedCustomDataDriven(folderPath,'Integrated2DNHCATTDataDrivenClipped.mat');
filterStateIntegratedDataDrivenClipped = loadFilterStateIntegratedCustomDataDriven(folderPath,'Integrated3DNHCATTDataDrivenClipped.mat');

printFolderPath = fullfile(folderPath,'DATASET_QAIIMUDEADRECKONING');
% TODO: 指定保存图片名称
saveFigFileName = "ComparedMultipleTrackPositionClippedFactor";

filterState1NavPosition = getFilterStateNavPosition(filterStateIntegrated2DNHCDataDriven);
filterState2NavPosition = getFilterStateNavPosition(filterStateIntegrated3DNHCDataDriven);
filterState3NavPosition = getFilterStateNavPosition(filterStateIntegrated2DNHCATTDataDriven);
filterState4NavPosition = getFilterStateNavPosition(filterStateIntegratedDataDriven);

filterState11NavPosition = getFilterStateNavPosition(filterStateIntegrated2DNHCDataDrivenClipped);
filterState22NavPosition = getFilterStateNavPosition(filterStateIntegrated3DNHCDataDrivenClipped);
filterState33NavPosition = getFilterStateNavPosition(filterStateIntegrated2DNHCATTDataDrivenClipped);
filterState44NavPosition = getFilterStateNavPosition(filterStateIntegratedDataDrivenClipped);

figureHandle = figure;
referencePosition = preprocessGroundTruthNavPosition;
proposedPosition = filterState4NavPosition;
filterPosition1 = filterState1NavPosition;
filterPosition2 = filterState2NavPosition;
filterPosition3 = filterState3NavPosition;
filterPosition5 = filterState11NavPosition;
filterPosition6 = filterState22NavPosition;
filterPosition7 = filterState33NavPosition;
filterPosition8 = filterState44NavPosition;
hold on;
referenceLineHandle = plot3(referencePosition(:,1),referencePosition(:,2),referencePosition(:,3));

filterLineHandle1 = plot3(filterPosition1(:,1),filterPosition1(:,2),filterPosition1(:,3));
filterLineHandle5 = plot3(filterPosition5(:,1),filterPosition5(:,2),filterPosition5(:,3));

filterLineHandle2 = plot3(filterPosition2(:,1),filterPosition2(:,2),filterPosition2(:,3));
filterLineHandle6 = plot3(filterPosition6(:,1),filterPosition6(:,2),filterPosition6(:,3));

filterLineHandle3 = plot3(filterPosition3(:,1),filterPosition3(:,2),filterPosition3(:,3));
filterLineHandle7 = plot3(filterPosition7(:,1),filterPosition7(:,2),filterPosition7(:,3));

proposedHandle = plot3(proposedPosition(:,1),proposedPosition(:,2),proposedPosition(:,3));
filterLineHandle8 = plot3(filterPosition8(:,1),filterPosition8(:,2),filterPosition8(:,3));

% xlim([-50 55]);
% ylim([-85 5]);

% Line 属性
% 线条
set(referenceLineHandle,'Color',"r");
set(proposedHandle,'Color',"b");
set(filterLineHandle1,'Color',"c");
set(filterLineHandle2,'Color',"m");
set(filterLineHandle3,'Color',"g");

set(filterLineHandle5,'Color',"c");
set(filterLineHandle6,'Color',"m");
set(filterLineHandle7,'Color',"g");
set(filterLineHandle8,'Color',"b");

set(referenceLineHandle,'LineStyle',"--");
set(filterLineHandle1,'LineStyle',"--");
set(filterLineHandle2,'LineStyle',"--");
set(filterLineHandle3,'LineStyle',"--");
set(proposedHandle,'LineStyle',"--");

% 图例
set(referenceLineHandle,'DisplayName',"Ground truth trajectory");
set(proposedHandle,'DisplayName',"Proposed method trajectory");
set(filterLineHandle1,'DisplayName',"AI-IMU method trajectory");
set(filterLineHandle2,'DisplayName',"DeepOdo method trajectory");
set(filterLineHandle3,'DisplayName',"DeepOri method trajectory");
set(filterLineHandle5,'DisplayName',"AI-IMU delayed method trajectory");
set(filterLineHandle6,'DisplayName',"DeepOdo delayed method trajectory");
set(filterLineHandle7,'DisplayName',"DeepOri delayed method trajectory");
set(filterLineHandle8,'DisplayName',"Proposed delayed method trajectory");

legendHandle = legend();
% Legend 属性
% 字体
set(legendHandle,'FontName','Arial');
set(legendHandle,'FontSize',8);
% set(legendHandle,'NumColumn',2);
set(legendHandle,'Location','northeastoutside');

% Axes 属性
view([0 0 1]);
axis equal;

xlabel("East distance (m)");
ylabel("North distance (m)");
zlabel("Up (m)");

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
set(gca,'FontName','Arial');

% I. Using Labels Within Figures
% Figure labels should be legible, approximately 8- to 10-point type.
% 字体大小
set(gca,'FontSize',8);

% 网格
% grid on;
% 
% grid minor;
% set(gca,'MinorGridLineStyle','--');

set(gca,'Box','on');

% 平移坐标轴 
% axesObjectXlimProperty = xlim;
% axesObjectXlimProperty = axesObjectXlimProperty + 10;
% set(gca,'XLim',axesObjectXlimProperty);

% set(gca,'XLim',[-38, 66]);
% set(gca,'YLim',[-84, 2]);

set(gca,'XLim',[-50, 50]);
set(gca,'YLim',[-90, 10]);

set(gca,'XTick',-60:10:60);

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
figurePropertiesPositionWidth = 17;
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

% close(figureHandle);

end