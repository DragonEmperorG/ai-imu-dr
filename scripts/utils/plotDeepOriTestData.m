function [] = plotDeepOriTestData(plotFlag,folderPath)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'plotDeepOdoTrainData';

if plotFlag ~= 0
    dataDrivenMeasurementOrientationRaw = loadDataDrivenMeasurementOrientationRaw(folderPath);
    dataDrivenTime = dataDrivenMeasurementOrientationRaw(:,1);
    dataDrivenAttitudeMeasurement = loadDataDrivenAttitudeMeasurement(folderPath,0);
    proposedEulerAngleDeg = convertOrientationRotationMatrixToEulerAngle(dataDrivenAttitudeMeasurement, true);

    rHeadTime = dataDrivenTime(1);
    rTailTime = dataDrivenTime(end);

    preprocessRawFlatData = loadPreprocessRawFlat(folderPath);
    preprocessTime = getPreprocessTime(preprocessRawFlatData);
    preprocessRawFlatDataClipped = preprocessRawFlatData(preprocessTime>=rHeadTime&preprocessTime<=rTailTime,:);
    preprocessTimeClipped = getPreprocessTime(preprocessRawFlatDataClipped);
    preprocessGroundTruthNavOrientationClipped = getPreprocessGroundTruthNavOrientationRotationMatrix(preprocessRawFlatDataClipped);
    groundTruthEulerAngleDeg = convertOrientationRotationMatrixToEulerAngle(preprocessGroundTruthNavOrientationClipped, true);


    figureHandle = figure;
    pX1 = preprocessTimeClipped - rHeadTime;
    pX2 = dataDrivenTime - rHeadTime;

    pY1 = groundTruthEulerAngleDeg;
    pY2 = proposedEulerAngleDeg;
    hold on;
    lineObject11 = plot(pX1,pY1(:,1));
    lineObject12 = plot(pX1,pY1(:,2));
    lineObject13 = plot(pX1,pY1(:,3));
    lineObject21 = plot(pX2,pY2(:,1));
    lineObject22 = plot(pX2,pY2(:,2));
    lineObject23 = plot(pX2,pY2(:,3));
    % title('Output Nav orientation euler angle');
    xlabel("Time (s)");
    ylabel("Euler angle (°)");
    legend1 = legend();
    hold off;

    box on;

    % Line 属性
    % 线条
    set(lineObject11,'Color',"r");
    set(lineObject12,'Color',"g");
    set(lineObject13,'Color',"b");
    set(lineObject21,'Color',"r");
    set(lineObject22,'Color',"g");
    set(lineObject23,'Color',"b");

    set(lineObject11,'LineStyle',"--");
    set(lineObject12,'LineStyle',"--");
    set(lineObject13,'LineStyle',"--");

    % 图例
    set(lineObject11,'DisplayName',"Ground truth euler angle pitch");
    set(lineObject12,'DisplayName',"Ground truth euler angle roll");
    set(lineObject13,'DisplayName',"Ground truth euler angle yaw");
    set(lineObject21,'DisplayName',"Proposed euler angle pitch");
    set(lineObject22,'DisplayName',"Proposed euler angle roll");
    set(lineObject23,'DisplayName',"Proposed euler angle yaw");

    % Legend 属性
    % Position and Layout 位置和布局
    set(legend1,'Location','northoutside');
    set(legend1,'NumColumns',2);
    set(legend1,'FontName','Arial');
    set(legend1,'FontSize',8);

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

    set(gca,'YTick',-180:30:180);

    % 标尺
    % 平移坐标轴
    axesObjectXlimProperty = xlim;
    axesObjectXlimProperty = axesObjectXlimProperty + [0 -30];
    set(gca,'XLim',axesObjectXlimProperty);
    % axesObjectYlimProperty = ylim;
    % axesObjectYlimProperty = axesObjectYlimProperty + [0 60];
    % set(gca,'YLim',axesObjectYlimProperty);
    set(gca,'YLim',[-180 180]);

    % % 网格
    % set(gca,'XGrid','on');
    % set(gca,'YGrid','on');
    % set(gca,'ZGrid','on');
    % 
    % set(gca,'XMinorGrid','on');
    % set(gca,'YMinorGrid','on');
    % set(gca,'ZMinorGrid','on');
    % set(gca,'MinorGridLineStyle','--');

    printFolderPath = fullfile(folderPath,'DATASET_DEEPORI');
    saveFigFileName = "DeepOriTestData";
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

    % close(figureHandle);

end


end