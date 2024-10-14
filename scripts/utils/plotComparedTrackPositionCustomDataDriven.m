function [] = plotComparedTrackPositionCustomDataDriven(folderPath,fileName)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
[~,name,~] = fileparts(fileName);
filterState = loadFilterStateIntegratedCustomDataDriven(folderPath,fileName);
preprocessGroundTruthNavPosition = loadPreprocessGroundTruthNavPosition(folderPath);

printFolderPath = fullfile(folderPath,'DATASET_QAIIMUDEADRECKONING');
saveFigFileName = name + "ComparedTrackPosition";

filterStateNavPosition = getFilterStateNavPosition(filterState);

figureHandle = figure;
referencePosition = preprocessGroundTruthNavPosition;
filterPosition = filterStateNavPosition;
hold on;
referenceLineHandle = plot3(referencePosition(:,1),referencePosition(:,2),referencePosition(:,3));
filterLineHandle = plot3(filterPosition(:,1),filterPosition(:,2),filterPosition(:,3));

% xlim([-50 55]);
% ylim([-85 5]);

% Line 属性
% 线条
set(referenceLineHandle,'Color',"r");
set(filterLineHandle,'Color',"b");

set(referenceLineHandle,'LineStyle',"--");

% 图例
set(referenceLineHandle,'DisplayName',"Ground Truth");
set(filterLineHandle,'DisplayName',"Proposed");

legendHandle = legend();
% Legend 属性
% 字体
set(legendHandle,'FontName','Times New Roman');
set(legendHandle,'FontSize',10);
% set(legendHandle,'NumColumn',2);
% set(legendHandle,'Location','north');

% Axes 属性
view([0 0 1]);
axis equal;

xlabel("East (m)");
ylabel("North (m)");
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
set(gca,'FontName','Times New Roman');

% I. Using Labels Within Figures
% Figure labels should be legible, approximately 8- to 10-point type.
% 字体大小
set(gca,'FontSize',10);

% 网格
grid on;

grid minor;
set(gca,'MinorGridLineStyle','--');

% 平移坐标轴 
axesObjectXlimProperty = xlim;
axesObjectXlimProperty = axesObjectXlimProperty + 10;
set(gca,'XLim',axesObjectXlimProperty);

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

close(figureHandle);

end