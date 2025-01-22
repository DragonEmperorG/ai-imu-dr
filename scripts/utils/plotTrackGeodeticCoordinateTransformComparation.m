function [] = plotTrackGeodeticCoordinateTransformComparation(sFolderPath,trackGeodeticCoordinateData)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

TAG = 'plotTrackGeodeticCoordinateTransformComparation';

SPHEROID = wgs84Ellipsoid;
ER = 6378137;

tTime = trackGeodeticCoordinateData(:,1);
tGeodeticCoordinate = trackGeodeticCoordinateData(:,2:4);
rGeodeticCoordinate = tGeodeticCoordinate(1,:);

tMercatorPScale = cos(deg2rad(rGeodeticCoordinate(1)));
tMercatorPX = tMercatorPScale * ER * deg2rad(tGeodeticCoordinate(:,2));
tMercatorPX = tMercatorPX - tMercatorPX(1);
tMercatorPY = tMercatorPScale * ER * log( tan( deg2rad((90+tGeodeticCoordinate(:,1))/2) ) );
tMercatorPY = tMercatorPY - tMercatorPY(1);
tMercatorPZ = tGeodeticCoordinate(:,3);
tMercatorPZ = tMercatorPZ - tMercatorPZ(1);

[tLocalE,tLocalN,tLocalU] = geodetic2enu( ...
    tGeodeticCoordinate(:,1), ...
    tGeodeticCoordinate(:,2), ...
    tGeodeticCoordinate(:,3), ...
    rGeodeticCoordinate(1), ...
    rGeodeticCoordinate(2), ...
    rGeodeticCoordinate(3), ...
    SPHEROID ...
);

pX = [tMercatorPX;tLocalE];
pY = [tMercatorPY;tLocalN];

figureObject1 = figure;
axesObject1 = gca;
hold on;
lineObjectMercatorPXY = plot(tMercatorPX,tMercatorPY);
lineObjectLocalEN = plot(tLocalE,tLocalN);
legendObject1 = legend();
grid on;
hold off;
axesObject12 = axes(figureObject1);
hold on;
lineObjectMercatorPXY1 = plot(tMercatorPX,tMercatorPY);
lineObjectLocalEN1 = plot(tLocalE,tLocalN);
grid on;
hold off;
axis equal;

pTime = tTime - tTime(1);
figureObject2 = figure;
axesObject2 = gca;
hold on;
lineObjectDeltaX = plot(pTime,tMercatorPX-tLocalE);
lineObjectDeltaY = plot(pTime,tMercatorPY-tLocalN);
legendObject2 = legend();
hold off;
grid on;

figureObject3 = figure;
axesObject3 = gca;
hold on;
lineObjectDeltaZ = plot(pTime,tMercatorPZ-tLocalU);
hold off;
grid on;

figureObjectList = [figureObject1,figureObject2,figureObject3];

axesObjectC2List = [axesObject2,axesObject3];
axesObjectList = [axesObject1,axesObjectC2List,axesObject12];

legendObjectList = [legendObject1,legendObject2];

% http://gs.xjtu.edu.cn/info/1209/7605.htm
% 参考《西安交通大学博士、硕士学位论文模板（2021版）》中对图的要求
% 图尺寸的一般宽高比应为6.67 cm×5.00 cm。特殊情况下， 也可为
% 9.00 cm×6.75 cm， 或13.5 cm×9.00 cm。总之， 一篇论文中， 同类图片的
% 大小应该一致，编排美观、整齐；
figurePropertiesPositionLeft = 10;
figurePropertiesPositionBottom = 10;
figurePropertiesPositionWidth = 9;
figurePropertiesPositionHeight = 9;
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

figurePropertiesPositionLeft = 20;
figurePropertiesPositionBottom = 15;
figurePropertiesPositionWidth = 7;
figurePropertiesPositionHeight = 3.8;
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

figurePropertiesPositionLeft = 20;
figurePropertiesPositionBottom = 10;
figurePropertiesPositionWidth = 7;
figurePropertiesPositionHeight = 2.9;
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

% 网格
axesPropertyYLim = [floor(min(pY)) ceil(max(pY))];
set(axesObject1,'YLim',axesPropertyYLim);

% set(axesObject12,'XLim',[281.5 283.5]);
% set(axesObject12,'YLim',[361.5 363.5]);
set(axesObject12,'XLim',[32.5 34.5]);
set(axesObject12,'YLim',[-81.5 -79.5]);

% for i = 1:length(axesObjectPipList)
%     set(axesObjectPipList(i),'XLim',[-1 1]);
% end
% 

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
set(get(axesObject1,'XLabel'),'String','\fontname{Times new roman}X\fontname{宋体}方向\fontname{Times new roman}(m)');
set(get(axesObject1,'YLabel'),'String','\fontname{Times new roman}Y\fontname{宋体}方向\fontname{Times new roman}(m)');
set(get(axesObject2,'XLabel'),'String','\fontname{宋体}时间\fontname{Times new roman}(s)');
set(get(axesObject2,'YLabel'),'String','\fontname{宋体}坐标差\fontname{Times new roman}(m)');
set(get(axesObject3,'XLabel'),'String','\fontname{宋体}时间\fontname{Times new roman}(s)');
set(get(axesObject3,'YLabel'),'String','\fontname{宋体}坐标差\fontname{Times new roman}(m)');

% 框样式
% 框轮廓
set(axesObject12,'Box','on');

% 位置
% set(axesObject12,'Position',[0.67,0.67,0.3,0.16]);
set(axesObject12,'Position',[0.6,0.2,0.3,0.16]);

% Line 属性 https://ww2.mathworks.cn/help/matlab/ref/matlab.graphics.chart.primitive.line-properties.html
% 线条
% https://waldyrious.net/viridis-palette-generator/
cPaletteViridisCategories2Color = ["#fde725" "#440154"];
set(lineObjectMercatorPXY,"Color",cPaletteViridisCategories2Color(1));
set(lineObjectLocalEN,"Color",cPaletteViridisCategories2Color(2));
set(lineObjectMercatorPXY1,"Color",cPaletteViridisCategories2Color(1));
set(lineObjectLocalEN1,"Color",cPaletteViridisCategories2Color(2));
set(lineObjectDeltaX,"Color",'r');
set(lineObjectDeltaY,"Color",'g');
set(lineObjectDeltaZ,"Color",'b');

% 图例
set(lineObjectMercatorPXY,"DisplayName","\fontname{宋体}墨卡托投影");
set(lineObjectLocalEN,"DisplayName","\fontname{宋体}东北天转换");
set(lineObjectDeltaX,"DisplayName","\fontname{Times new roman}X\fontname{宋体}方向");
set(lineObjectDeltaY,"DisplayName","\fontname{Times new roman}Y\fontname{宋体}方向");


% Legend 属性
% 位置和布局
for i = 1:length(legendObjectList)
    set(legendObjectList(i),'Location','northoutside');
    set(legendObjectList(i),'Orientation','horizontal');
    set(legendObjectList(i),'NumColumns',2);
end
set(legendObject1,'Direction','reverse');
% 字体
for i = 1:length(legendObjectList)
    set(legendObjectList(i),'FontName','Times New Roman');
    set(legendObjectList(i),'FontSize',10.5);
end

cTrackGeodeticCoordinateTransformComparationXYFileName = sprintf('TrackGeodeticCoordinateTransformComparationXY.png');
cTrackGeodeticCoordinateTransformComparationDeltaXYFileName = sprintf('TrackGeodeticCoordinateTransformComparationDeltaXY.png');
cTrackGeodeticCoordinateTransformComparationDeltaZFileName = sprintf('TrackGeodeticCoordinateTransformComparationDeltaZ.png');
cTrackGeodeticCoordinateTransformComparationXYFilePath = fullfile(sFolderPath,cTrackGeodeticCoordinateTransformComparationXYFileName);
cTrackGeodeticCoordinateTransformComparationDeltaXYFilePath = fullfile(sFolderPath,cTrackGeodeticCoordinateTransformComparationDeltaXYFileName);
cTrackGeodeticCoordinateTransformComparationDeltaZFilePath = fullfile(sFolderPath,cTrackGeodeticCoordinateTransformComparationDeltaZFileName);
exportgraphics(figureObject1,cTrackGeodeticCoordinateTransformComparationXYFilePath,'Resolution',600);
exportgraphics(figureObject2,cTrackGeodeticCoordinateTransformComparationDeltaXYFilePath,'Resolution',600);
exportgraphics(figureObject3,cTrackGeodeticCoordinateTransformComparationDeltaZFilePath,'Resolution',600);

for i = 1:length(figureObjectList)
    close(figureObjectList(i));
end

end