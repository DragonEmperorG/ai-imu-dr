function [] = plotGroundTruthOdometry(plotFlag,folderPath)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'plotGroundTruthOdometry';

plotFlag = 0;
preprocessTime = loadPreprocessTime(folderPath);
preprocessGroundTruthNavPosition = loadPreprocessGroundTruthNavPosition(folderPath);
preprocessGroundTruthNavDeltaPosition = diff(preprocessGroundTruthNavPosition);
preprocessGroundTruthNavDeltaDistance = sqrt(sum(preprocessGroundTruthNavDeltaPosition.*preprocessGroundTruthNavDeltaPosition,2));
preprocessGroundTruthNavCumsum = cumsum(preprocessGroundTruthNavDeltaDistance);
length = preprocessGroundTruthNavCumsum(end);
duration = preprocessTime(end) - preprocessTime(1);
logMsg = sprintf('length: %.3f, duration: %.3f', length, duration);
log2terminal('I',TAG,logMsg);


if plotFlag ~= 0
    preprocessTime = loadPreprocessTime(folderPath);
    preprocessGroundTruthNavPosition = loadPreprocessGroundTruthNavPosition(folderPath);
    preprocessGroundTruthNavDeltaPosition = diff(preprocessGroundTruthNavPosition);
    preprocessGroundTruthNavDeltaDistance = sqrt(sum(preprocessGroundTruthNavDeltaPosition.*preprocessGroundTruthNavDeltaPosition,2));
    preprocessGroundTruthNavCumsum = cumsum(preprocessGroundTruthNavDeltaDistance);

    figureHandle = figure;
    pSubPlotRows = 2;
    pSubPlotColumns = 1;
    pTime = preprocessTime(2:end);

    axesObject1 = subplot(pSubPlotRows,pSubPlotColumns,1);
    pX1 = pTime;
    pY1 = preprocessGroundTruthNavCumsum;
    hold on;
    lineObject1 = plot(pX1,pY1);
    title('Odometry');
    xlabel("Time (s)");
    ylabel("Odometry (m)");
    grid on;
    hold off;

    axesObject2 = subplot(pSubPlotRows,pSubPlotColumns,2);
    pX2 = 1:size(pTime,1);
    pY2 = preprocessGroundTruthNavCumsum;
    hold on;
    lineObject2 = plot(pX2,pY2);
    title('Odometry');
    xlabel("Index");
    ylabel("Odometry (m)");
    grid on;
    hold off;

    set(axesObject1,'FontName','Times New Roman');
    set(axesObject2,'FontName','Times New Roman');

    set(axesObject1,'FontSize',10);
    set(axesObject2,'FontSize',10);

    integerTimeIndex = [];
    for i = 1:size(pTime,1)
        if rem(pTime(i),1) == 0
            integerTimeIndex = [integerTimeIndex; i];
        end
    end
    set(lineObject1,'Marker','o');
    set(lineObject1,'MarkerIndices',integerTimeIndex);
    set(lineObject2,'Marker','o');
    set(lineObject2,'MarkerIndices',integerTimeIndex);

    saveFolderPath = fullfile(folderPath,"dayZeroOClockAlign");
    saveFigFileName = "GroundTruthOdometry";
    saveFigFilePath = fullfile(saveFolderPath,saveFigFileName);
    saveas(gcf,saveFigFilePath,'fig')

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

    hold off;

    printFileName = strcat(saveFigFileName,".png");
    printFilePath = fullfile(saveFolderPath,printFileName);
    exportgraphics(gcf,printFilePath,'Resolution',600)

    close(figureHandle);
end


end