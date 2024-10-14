function [] = plotDeepOdoTestData(plotFlag,folderPath)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'plotDeepOdoTrainData';

if plotFlag ~= 0
    dataDrivenProposedVelocity = loadDataDrivenVelocityMeasurement(folderPath);

    dataDrivenGroundTruthVelocity = loadDataDrivenVelocityGroundTruth(folderPath);

    figureHandle = figure;
    pX = 0:1:(size(dataDrivenProposedVelocity,1)-1);
    pY1 = dataDrivenGroundTruthVelocity;
    pY2 = dataDrivenProposedVelocity;
    hold on;
    lineObject1 = plot(pX,pY1);
    lineObject2 = plot(pX,pY2);
    xlabel('Time (s)');
    ylabel('Vecolity (m/s)');
    legendObject = legend;
    hold off;

    % Line 属性
    % 线条
    set(lineObject1,'Color',"r");
    set(lineObject2,'Color',"b");

    set(lineObject2,'LineStyle',"--");

    % 图例
    set(lineObject1,'DisplayName',"Ground Truth");
    set(lineObject2,'DisplayName',"Proposed");

    % Legend 属性
    % Position and Layout 位置和布局
    set(legendObject,'Location','northeast');
    set(legendObject,'FontName','Times New Roman');
    set(legendObject,'FontSize',10);

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

    % 标尺
    % 平移坐标轴
    axesObjectXlimProperty = xlim;
    axesObjectXlimProperty = axesObjectXlimProperty + [0 -30];
    set(gca,'XLim',axesObjectXlimProperty);
    axesObjectYlimProperty = ylim;
    axesObjectYlimProperty = axesObjectYlimProperty + [0.5 0.5];
    set(gca,'YLim',axesObjectYlimProperty);

    % 网格
    set(gca,'XGrid','on');
    set(gca,'YGrid','on');
    set(gca,'ZGrid','on');

    set(gca,'XMinorGrid','on');
    set(gca,'YMinorGrid','on');
    set(gca,'ZMinorGrid','on');
    set(gca,'MinorGridLineStyle','--');

    printFolderPath = fullfile(folderPath,'DATASET_DEEPODO');
    saveFigFileName = "DeepOdoTestData";
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