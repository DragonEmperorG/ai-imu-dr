% close all;
clear;
addpath(genpath(pwd));

TAG = 'CompareTrainFile';

COM_NUM = 2;


cTrainFile1Path = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_10\Reorganized\0008\GOOGLE_Pixel3\DATASET_AIIMUDR\2023_04_10_drive_0008_phone_google_pixel3_extract.csv';
cTrainFile2Path = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_10\Reorganized\0008\GOOGLE_Pixel3\DATASET_AIIMUDR\2023_04_10_drive_0008_phone_google_pixel3_extract_test.csv';

cTrainFile1RawData = readmatrix(cTrainFile1Path);
cTrainFile2RawData = readmatrix(cTrainFile2Path);

cTrainFile1DataTime = cTrainFile1RawData(:,1);
cTrainFile2DataTime = cTrainFile2RawData(:,1);
xLimMin = min(min(cTrainFile1DataTime),min(cTrainFile2DataTime));
xLimMax = max(max(cTrainFile1DataTime),max(cTrainFile2DataTime));
xLimValue = [xLimMin xLimMax];

figure;
timeReferenceSubPlotRows = 2;
timeReferenceSubPlotColumns = 1;
subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,1);
plot(cTrainFile1DataTime, cTrainFile1RawData(:,5:7));
xlim(xLimValue);
subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,2);
plot(cTrainFile2DataTime, cTrainFile2RawData(:,5:7));
xlim(xLimValue);



