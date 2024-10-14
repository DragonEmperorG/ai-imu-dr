function [] = plotFilterStateCombination(folderPath)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明

filterState = loadFilterStateIntegratedGroundTruth(folderPath);

printFolderPath = fullfile(folderPath,'dayZeroOClockAlign');

filterStateTime = getFilterStateTime(filterState);
filterStateTimeSize = size(filterStateTime,1);
filterStateNavOrientationEulerAngleDeg = getFilterStateNavOrientationEulerAngleDeg(filterState);
filterStateNavVelocity = getFilterStateNavVelocity(filterState);
filterStateNavPosition = getFilterStateNavPosition(filterState);
filterStateImuGyroscopeBias = getFilterStateImuGyroscopeBias(filterState);
filterStateImuAccelerometerBias = getFilterStateImuAccelerometerBias(filterState);
filterStateCarOrientationEulerAngleDeg = getFilterStateCarOrientationEulerAngleDeg(filterState);
filterStateCarPosition = getFilterStateCarPosition(filterState);

filterStateCovariance = getFilterStateCovariance(filterState);
filterStateNavOrientationCovarianceX = reshape(filterStateCovariance(1,1,:),filterStateTimeSize,1);
filterStateNavOrientationCovarianceY = reshape(filterStateCovariance(2,2,:),filterStateTimeSize,1);
filterStateNavOrientationCovarianceZ = reshape(filterStateCovariance(3,3,:),filterStateTimeSize,1);
filterStateNavVelocityCovarianceX = reshape(filterStateCovariance(4,4,:),filterStateTimeSize,1);
filterStateNavVelocityCovarianceY = reshape(filterStateCovariance(5,5,:),filterStateTimeSize,1);
filterStateNavVelocityCovarianceZ = reshape(filterStateCovariance(6,6,:),filterStateTimeSize,1);
filterStateNavPositionCovarianceX = reshape(filterStateCovariance(7,7,:),filterStateTimeSize,1);
filterStateNavPositionCovarianceY = reshape(filterStateCovariance(8,8,:),filterStateTimeSize,1);
filterStateNavPositionCovarianceZ = reshape(filterStateCovariance(9,9,:),filterStateTimeSize,1);
filterStateImuGyroscopeBiasCovarianceX = reshape(filterStateCovariance(10,10,:),filterStateTimeSize,1);
filterStateImuGyroscopeBiasCovarianceY = reshape(filterStateCovariance(11,11,:),filterStateTimeSize,1);
filterStateImuGyroscopeBiasCovarianceZ = reshape(filterStateCovariance(12,12,:),filterStateTimeSize,1);
filterStateImuAccelerometerBiasCovarianceX = reshape(filterStateCovariance(13,13,:),filterStateTimeSize,1);
filterStateImuAccelerometerBiasCovarianceY = reshape(filterStateCovariance(14,14,:),filterStateTimeSize,1);
filterStateImuAccelerometerBiasCovarianceZ = reshape(filterStateCovariance(15,15,:),filterStateTimeSize,1);
filterStateCarOrientationCovarianceX = reshape(filterStateCovariance(16,16,:),filterStateTimeSize,1);
filterStateCarOrientationCovarianceY = reshape(filterStateCovariance(17,17,:),filterStateTimeSize,1);
filterStateCarOrientationCovarianceZ = reshape(filterStateCovariance(18,18,:),filterStateTimeSize,1);
filterStateCarPositionCovarianceX = reshape(filterStateCovariance(19,19,:),filterStateTimeSize,1);
filterStateCarPositionCovarianceY = reshape(filterStateCovariance(20,20,:),filterStateTimeSize,1);
filterStateCarPositionCovarianceZ = reshape(filterStateCovariance(21,21,:),filterStateTimeSize,1);

filterStateTimeMin = min(filterStateTime);
filterStateTimeFloor = floor(filterStateTimeMin);

figureHandle = figure;
timeReferenceSubPlotRows = 2;
timeReferenceSubPlotColumns = 7;
pX = filterStateTime - filterStateTimeFloor;

% 给定参数
N = timeReferenceSubPlotRows; % 子图行数
M = timeReferenceSubPlotColumns; % 子图列数
subplot_height = 4; % 子图长度
subplot_width = 3; % 子图宽度
top_margin = 0.5; % 上边界间距
bottom_margin = 0.5; % 下边界间距
left_margin = 0.5; % 左边界间距
right_margin = 0.5; % 右边界间距
gap = 0.5; % 子图间隙

% 计算合适的figure大小
figure_width = M * subplot_width + (M -1) * gap+left_margin+right_margin;
figure_height = N * subplot_height + (N -1) * gap + top_margin + bottom_margin;

% 计算每个子图的position数据
subplot_position = zeros(N * M, 4); % 初始化位置参数数组

for i = 1:N
    for j = 1:M
        x_left =( (j - 1) * (subplot_width+gap) + left_margin )/ figure_width;
        y_bottom = 1-(i*subplot_height+top_margin+(i-1)*gap)/ figure_height ;
        subplot_position((i - 1) * M + j, :) = [x_left, y_bottom, subplot_width / figure_width, subplot_height / figure_height];
    end
end


% axesObject11 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,1);
axesObject11 = subplot("Position", subplot_position(1,:));
pY11 = filterStateNavOrientationEulerAngleDeg;
hold on;
lineObject111 = plot(pX,pY11(:,1));
lineObject112 = plot(pX,pY11(:,2));
lineObject113 = plot(pX,pY11(:,3));
xlabel('Sample (s)');
ylabel('Value (rad/s)');
title('Smart Phone raw IMU gyroscope data');
legend11 = legend();
grid on;
hold off;

% axesObject12 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,2);
axesObject12 = subplot("Position", subplot_position(2,:));
pY12 = filterStateNavVelocity;
hold on;
lineObject121 = plot(pX,pY12(:,1));
lineObject122 = plot(pX,pY12(:,2));
lineObject123 = plot(pX,pY12(:,3));
title('World Velocity');
xlabel("Time (s)");
ylabel("Value (m/s)");
legend12 = legend();
grid on;
hold off;

% axesObject13 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,3);
axesObject13 = subplot("Position", subplot_position(3,:));
pY13 = filterStateNavPosition;
hold on;
lineObject131 = plot(pX,pY13(:,1));
lineObject132 = plot(pX,pY13(:,2));
lineObject133 = plot(pX,pY13(:,3));
title('World Position');
xlabel("Time (s)");
ylabel("Value (m)");
legend13 = legend();
grid on;
hold off;

% axesObject14 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,4);
axesObject14 = subplot("Position", subplot_position(4,:));
pY14 = filterStateImuGyroscopeBias;
hold on;
lineObject141 = plot(pX,pY14(:,1));
lineObject142 = plot(pX,pY14(:,2));
lineObject143 = plot(pX,pY14(:,3));
title('IMU Gyroscope Bias');
xlabel("Time (s)");
ylabel("Bias (rad/s)");
legend14 = legend();
grid on;
hold off;

% axesObject15 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,5);
axesObject15 = subplot("Position", subplot_position(5,:));
pY15 = filterStateImuAccelerometerBias;
hold on;
lineObject151 = plot(pX,pY15(:,1));
lineObject152 = plot(pX,pY15(:,2));
lineObject153 = plot(pX,pY15(:,3));
title('IMU Accelerometer Bias');
xlabel("Time (s)");
ylabel("Bias (m/s^2)");
legend15 = legend();
grid on;
hold off;

% axesObject16 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,6);
axesObject16 = subplot("Position", subplot_position(6,:));
pY16 = filterStateCarOrientationEulerAngleDeg;
hold on;
lineObject161 = plot(pX,pY16(:,1));
lineObject162 = plot(pX,pY16(:,2));
lineObject163 = plot(pX,pY16(:,3));
title('Car Orientation');
xlabel("Time (s)");
ylabel("Value (deg)");
legend16 = legend();
grid on;
hold off;

% axesObject17 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,7);
axesObject17 = subplot("Position", subplot_position(7,:));
pY17 = filterStateCarPosition;
hold on;
lineObject171 = plot(pX,pY17(:,1));
lineObject172 = plot(pX,pY17(:,2));
lineObject173 = plot(pX,pY17(:,3));
title('Car Position');
xlabel("Time (s)");
ylabel("Value (m)");
legend17 = legend();
grid on;
hold off;

% axesObject21 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,8);
axesObject21 = subplot("Position", subplot_position(8,:));
pY21 = horzcat(filterStateNavOrientationCovarianceX,filterStateNavOrientationCovarianceY,filterStateNavOrientationCovarianceZ);
hold on;
lineObject211 = plot(pX,pY21(:,1));
lineObject212 = plot(pX,pY21(:,2));
lineObject213 = plot(pX,pY21(:,3));
title('World Position Covariance');
xlabel("Time (s)");
ylabel("Covariance (rad^2)");
legend21 = legend();
grid on;
hold off;

% axesObject22 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,9);
axesObject22 = subplot("Position", subplot_position(9,:));
pY22 = horzcat(filterStateNavVelocityCovarianceX,filterStateNavVelocityCovarianceY,filterStateNavVelocityCovarianceZ);
hold on;
lineObject221 = plot(pX,pY22(:,1));
lineObject222 = plot(pX,pY22(:,2));
lineObject223 = plot(pX,pY22(:,3));
title('World Velocity Covariance');
xlabel("Time (s)");
ylabel("Covariance ((m/s)^2)");
legend22 = legend();
grid on;
hold off;

% axesObject23 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,10);
axesObject23 = subplot("Position", subplot_position(10,:));
pY23 = horzcat(filterStateNavPositionCovarianceX,filterStateNavPositionCovarianceY,filterStateNavPositionCovarianceZ);
hold on;
lineObject231 = plot(pX,pY23(:,1));
lineObject232 = plot(pX,pY23(:,2));
lineObject233 = plot(pX,pY23(:,3));
title('World Position Covariance');
xlabel("Time (s)");
ylabel("Covariance (m^2)");
legend23 = legend();
grid on;
hold off;

% axesObject24 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,11,'');
axesObject24 = subplot("Position", subplot_position(11,:));
pY24 = horzcat(filterStateImuGyroscopeBiasCovarianceX,filterStateImuGyroscopeBiasCovarianceY,filterStateImuGyroscopeBiasCovarianceZ);
hold on;
lineObject241 = plot(pX,pY24(:,1));
lineObject242 = plot(pX,pY24(:,2));
lineObject243 = plot(pX,pY24(:,3));
title('IMU Gyroscope Bias Covariance');
xlabel("Time (s)");
ylabel("Covariance ((rad/s)^2)");
legend24 = legend();
grid on;
hold off;

% axesObject25 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,12);
axesObject25 = subplot("Position", subplot_position(12,:));
pY25 = horzcat(filterStateImuAccelerometerBiasCovarianceX,filterStateImuAccelerometerBiasCovarianceY,filterStateImuAccelerometerBiasCovarianceZ);
hold on;
lineObject251 = plot(pX,pY25(:,1));
lineObject252 = plot(pX,pY25(:,2));
lineObject253 = plot(pX,pY25(:,3));
title('IMU Accelerometer Bias Covariance');
xlabel("Time (s)");
ylabel("Covariance ((m/s^2)^2)");
legend25 = legend();
grid on;
hold off;

% axesObject26 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,13);
axesObject26 = subplot("Position", subplot_position(13,:));
pY26 = horzcat(filterStateCarOrientationCovarianceX,filterStateCarOrientationCovarianceY,filterStateCarOrientationCovarianceZ);
hold on;
lineObject261 = plot(pX,pY26(:,1));
lineObject262 = plot(pX,pY26(:,2));
lineObject263 = plot(pX,pY26(:,3));
title('Car Orientation Covariance');
xlabel("Time (s)");
ylabel("Covariance ((rad/s)^2)");
legend26 = legend();
grid on;
hold off;

% axesObject27 = subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,14);
axesObject27 = subplot("Position", subplot_position(14,:));
pY27 = horzcat(filterStateCarPositionCovarianceX,filterStateCarPositionCovarianceY,filterStateCarPositionCovarianceZ);
hold on;
lineObject271 = plot(pX,pY27(:,1));
lineObject272 = plot(pX,pY27(:,2));
lineObject273 = plot(pX,pY27(:,3));
title('Car Position Covariance');
xlabel("Time (s)");
ylabel("Covariance (m^2)");
legend27 = legend();
grid on;
hold off;

% Line 属性
% 线条
set(lineObject111,'Color',"r");
set(lineObject112,'Color',"g");
set(lineObject113,'Color',"b");
set(lineObject121,'Color',"r");
set(lineObject122,'Color',"g");
set(lineObject123,'Color',"b");
set(lineObject131,'Color',"r");
set(lineObject132,'Color',"g");
set(lineObject133,'Color',"b");
set(lineObject141,'Color',"r");
set(lineObject142,'Color',"g");
set(lineObject143,'Color',"b");
set(lineObject151,'Color',"r");
set(lineObject152,'Color',"g");
set(lineObject153,'Color',"b");
set(lineObject161,'Color',"r");
set(lineObject162,'Color',"g");
set(lineObject163,'Color',"b");
set(lineObject171,'Color',"r");
set(lineObject172,'Color',"g");
set(lineObject173,'Color',"b");
set(lineObject211,'Color',"r");
set(lineObject212,'Color',"g");
set(lineObject213,'Color',"b");
set(lineObject221,'Color',"r");
set(lineObject222,'Color',"g");
set(lineObject223,'Color',"b");
set(lineObject231,'Color',"r");
set(lineObject232,'Color',"g");
set(lineObject233,'Color',"b");
set(lineObject241,'Color',"r");
set(lineObject242,'Color',"g");
set(lineObject243,'Color',"b");
set(lineObject251,'Color',"r");
set(lineObject252,'Color',"g");
set(lineObject253,'Color',"b");
set(lineObject261,'Color',"r");
set(lineObject262,'Color',"g");
set(lineObject263,'Color',"b");
set(lineObject271,'Color',"r");
set(lineObject272,'Color',"g");
set(lineObject273,'Color',"b");



% 图例
set(lineObject111,'DisplayName',"Pitch");
set(lineObject112,'DisplayName',"Roll");
set(lineObject113,'DisplayName',"Yaw");
set(lineObject121,'DisplayName',"East");
set(lineObject122,'DisplayName',"North");
set(lineObject123,'DisplayName',"Up");
set(lineObject131,'DisplayName',"East");
set(lineObject132,'DisplayName',"North");
set(lineObject133,'DisplayName',"Up");
set(lineObject141,'DisplayName',"X");
set(lineObject142,'DisplayName',"Y");
set(lineObject143,'DisplayName',"Z");
set(lineObject151,'DisplayName',"X");
set(lineObject152,'DisplayName',"Y");
set(lineObject153,'DisplayName',"Z");
set(lineObject161,'DisplayName',"Pitch");
set(lineObject162,'DisplayName',"Roll");
set(lineObject163,'DisplayName',"Yaw");
set(lineObject171,'DisplayName',"X");
set(lineObject172,'DisplayName',"Y");
set(lineObject173,'DisplayName',"Z");
set(lineObject211,'DisplayName',"Pitch");
set(lineObject212,'DisplayName',"Roll");
set(lineObject213,'DisplayName',"Yaw");
set(lineObject221,'DisplayName',"East");
set(lineObject222,'DisplayName',"North");
set(lineObject223,'DisplayName',"Up");
set(lineObject231,'DisplayName',"East");
set(lineObject232,'DisplayName',"North");
set(lineObject233,'DisplayName',"Up");
set(lineObject241,'DisplayName',"X");
set(lineObject242,'DisplayName',"Y");
set(lineObject243,'DisplayName',"Z");
set(lineObject251,'DisplayName',"X");
set(lineObject252,'DisplayName',"Y");
set(lineObject253,'DisplayName',"Z");
set(lineObject261,'DisplayName',"Pitch");
set(lineObject262,'DisplayName',"Roll");
set(lineObject263,'DisplayName',"Yaw");
set(lineObject271,'DisplayName',"X");
set(lineObject272,'DisplayName',"Y");
set(lineObject273,'DisplayName',"Z");


% Legend 属性
% 字体
set(legend11,'FontName','Times New Roman');
set(legend12,'FontName','Times New Roman');
set(legend13,'FontName','Times New Roman');
set(legend14,'FontName','Times New Roman');
set(legend15,'FontName','Times New Roman');
set(legend16,'FontName','Times New Roman');
set(legend17,'FontName','Times New Roman');
set(legend21,'FontName','Times New Roman');
set(legend22,'FontName','Times New Roman');
set(legend23,'FontName','Times New Roman');
set(legend24,'FontName','Times New Roman');
set(legend25,'FontName','Times New Roman');
set(legend26,'FontName','Times New Roman');
set(legend27,'FontName','Times New Roman');
% set(legend11,'FontSize',10);
% set(legend12,'FontSize',10);
% set(legend13,'FontSize',10);
% set(legend14,'FontSize',10);
% set(legend15,'FontSize',10);
% set(legend16,'FontSize',10);
% set(legend17,'FontSize',10);
% set(legend21,'FontSize',10);
% set(legend22,'FontSize',10);
% set(legend23,'FontSize',10);
% set(legend24,'FontSize',10);
% set(legend25,'FontSize',10);
% set(legend26,'FontSize',10);
% set(legend27,'FontSize',10);
% set(legend11,'Orientation','horizontal');
% set(legend12,'Orientation','horizontal');
% set(legend13,'Orientation','horizontal');
% set(legend14,'Orientation','horizontal');
% set(legend15,'Orientation','horizontal');
% set(legend16,'Orientation','horizontal');
% set(legend17,'Orientation','horizontal');
% set(legend21,'Orientation','horizontal');
% set(legend22,'Orientation','horizontal');
% set(legend23,'Orientation','horizontal');
% set(legend24,'Orientation','horizontal');
% set(legend25,'Orientation','horizontal');
% set(legend26,'Orientation','horizontal');
% set(legend27,'Orientation','horizontal');
set(legend11,'Location','best');
set(legend12,'Location','best');
set(legend13,'Location','best');
set(legend14,'Location','best');
set(legend15,'Location','best');
set(legend16,'Location','best');
set(legend17,'Location','best');
set(legend21,'Location','best');
set(legend22,'Location','best');
set(legend23,'Location','best');
set(legend24,'Location','best');
set(legend25,'Location','best');
set(legend26,'Location','best');
set(legend27,'Location','best');

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
set(axesObject11,'FontName','Times New Roman');
set(axesObject12,'FontName','Times New Roman');
set(axesObject13,'FontName','Times New Roman');
set(axesObject14,'FontName','Times New Roman');
set(axesObject15,'FontName','Times New Roman');
set(axesObject16,'FontName','Times New Roman');
set(axesObject17,'FontName','Times New Roman');
set(axesObject21,'FontName','Times New Roman');
set(axesObject22,'FontName','Times New Roman');
set(axesObject23,'FontName','Times New Roman');
set(axesObject24,'FontName','Times New Roman');
set(axesObject25,'FontName','Times New Roman');
set(axesObject26,'FontName','Times New Roman');
set(axesObject27,'FontName','Times New Roman');

% I. Using Labels Within Figures
% Figure labels should be legible, approximately 8- to 10-point type.
% 字体大小
% set(axesObject11,'FontSize',10);
% set(axesObject12,'FontSize',10);
% set(axesObject13,'FontSize',10);
% set(axesObject14,'FontSize',10);
% set(axesObject15,'FontSize',10);
% set(axesObject16,'FontSize',10);
% set(axesObject17,'FontSize',10);
% set(axesObject21,'FontSize',10);
% set(axesObject22,'FontSize',10);
% set(axesObject23,'FontSize',10);
% set(axesObject24,'FontSize',10);
% set(axesObject25,'FontSize',10);
% set(axesObject26,'FontSize',10);
% set(axesObject27,'FontSize',10);

saveFigFileName = "StateCambination";
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
figurePropertiesPositionWidth = 4;
% figureAspectRatio = 4/3;
figurePropertiesPositionHeight = 1;
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