function [] = plotDeepOriTrainData(plotFlag,folderPath)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'plotDeepOdoTrainData';

if plotFlag ~= 0

    deepOriTrainRawData = loadDeepOriTrainData(folderPath);

    deepOriTrainRawTimeData = deepOriTrainRawData(:,1);
    deepOriTrainInputImuGyroscopeData = deepOriTrainRawData(:,2:4);
    deepOriTrainInputImuAccelerometerData = deepOriTrainRawData(:,5:7);
    deepOriTrainOutputNavOrientationRotationMatrixFlatData = deepOriTrainRawData(:,8:16);
    deepOriTrainOutputNavOrientationEulerAngleDegData = convertOrientationFlatToEulerAngle(deepOriTrainOutputNavOrientationRotationMatrixFlatData, true);

    figureHandle = figure;
    subPlotRows = 3;
    subPlotColumns = 1;
    pX = deepOriTrainRawTimeData - deepOriTrainRawTimeData(1);

    axesObject1 = subplot(subPlotRows,subPlotColumns,1);
    pA1S1 = deepOriTrainInputImuGyroscopeData;
    hold on;
    lineObject11 = plot(pX,pA1S1(:,1));
    lineObject12 = plot(pX,pA1S1(:,2));
    lineObject13 = plot(pX,pA1S1(:,3));
    xlabel('Sample (s)');
    ylabel('Value (rad/s)');
    title('Input IMU gyroscope data');
    legend1 = legend();
    grid on;
    hold off;

    axesObject2 = subplot(subPlotRows,subPlotColumns,2);
    pA2S1 = deepOriTrainInputImuAccelerometerData;
    hold on;
    lineObject21 = plot(pX,pA2S1(:,1));
    lineObject22 = plot(pX,pA2S1(:,2));
    lineObject23 = plot(pX,pA2S1(:,3));
    xlabel('Sample (s)');
    ylabel('Value (m/s^{2})');
    title('Input IMU accelerometer data');
    legend2 = legend();
    grid on;
    hold off;

    axesObject3 = subplot(subPlotRows,subPlotColumns,3);
    pA3S1 = deepOriTrainOutputNavOrientationEulerAngleDegData;
    hold on;
    lineObject31 = plot(pX,pA3S1(:,1));
    lineObject32 = plot(pX,pA3S1(:,2));
    lineObject33 = plot(pX,pA3S1(:,3));
    title('Output Nav orientation euler angle');
    xlabel("Sample (s)");
    ylabel("Value (deg)");
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

    % 图例
    set(lineObject11,'DisplayName',"X");
    set(lineObject12,'DisplayName',"Y");
    set(lineObject13,'DisplayName',"Z");
    set(lineObject21,'DisplayName',"X");
    set(lineObject22,'DisplayName',"Y");
    set(lineObject23,'DisplayName',"Z");
    set(lineObject31,'DisplayName',"Pitch");
    set(lineObject32,'DisplayName',"Roll");
    set(lineObject33,'DisplayName',"Yaw");;

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

    printFolderPath = fullfile(folderPath,'DATASET_DEEPORI');
    saveFigFileName = "DeepOriTrainData";
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


end