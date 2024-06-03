close all;
clear;
addpath(genpath(pwd));

S2MS = 1e3;
MS2S = 1/S2MS;
S2NS = 1e9;
NS2S = 1/S2NS;
MS2NS = 1e6;
NS2MS = 1/MS2NS;

LEAPSECOND = 18;
LEAPNANOSECOND = LEAPSECOND * S2NS;

TAG = 'CustomViewerSensor';

% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_22\0010';
% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_22\Pixel\0010';

% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_23\MIAOMI\0002';
% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_23\HUAWEI\0001';

% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_24\0002';

% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_28\HUAWEI\0010';
% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_28\PIXEL\0010';
% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_02_28\SAMSUNG\0010';

% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_03_01\HUAWEI\0001';
% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_03_01\PIXEL\0001';

% cDatasetFolderPath = 'C:\Users\QIAN LONG\Downloads\2023_04_18\GOOGLE_Pixel3\0002';

% cDatasetFolderPath = 'C:\DoctorRelated\20230410重庆VDR数据采集\2023_04_10\HUAWEI\0003';

% cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_10\Reorganized\0008\HUAWEI_Mate30';

% cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_11\Reorganized\0002\HUAWEI_P20';

cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_13\Reorganized\0008\HUAWEI_Mate30';

% cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_13\Reorganized\0017\HUAWEI_Mate30';

% cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_15\Reorganized\0003\GOOGLE_Pixel3';
% cDatasetFolderPath = 'E:\DoctorRelated\20230410重庆VDR数据采集\2023_04_15\Reorganized\0001\HUAWEI_Mate30';



% 添加输入原始数据集存储文件夹
kRawFolderName = 'raw';
load 'SmartPhoneDataConfig.mat';

motionSensorAccelerometerUncalibratedFilePath = fullfile(cDatasetFolderPath,kRawFolderName,kMotionSensorAccelerometerUncalibratedFileNameString);
motionSensorAccelerometerUncalibratedRawData = readmatrix(motionSensorAccelerometerUncalibratedFilePath);
if mean(motionSensorAccelerometerUncalibratedRawData(:,3)) == 0
    motionSensorAccelerometerUncalibratedRawData(:,3) = motionSensorAccelerometerUncalibratedRawData(:,1) * MS2NS - motionSensorAccelerometerUncalibratedRawData(:,2);
    logMsg = sprintf('Missing GNSS clock reference');
    log2terminal('W',TAG,logMsg);
end
motionSensorAccelerometerUncalibratedData = motionSensorAccelerometerUncalibratedRawData(motionSensorAccelerometerUncalibratedRawData(:,3)~=0,:);
N = length(motionSensorAccelerometerUncalibratedData);

systemTime = motionSensorAccelerometerUncalibratedData(:,1);
systemClockTime = motionSensorAccelerometerUncalibratedData(:,2);
gpsSystemClockTimeOffset = motionSensorAccelerometerUncalibratedData(:,3);
sensorEventTime = motionSensorAccelerometerUncalibratedData(:,4);

[referenceZeroOClockDateTimeFromSystemClock, referenceZeroOClockFromSystemClockOffset] = getSystemCurrentTimeMillisMapZeroOClockTime(systemTime(1,1));
logMsg = sprintf('System clock based date: %s, time offset %f s', datestr(referenceZeroOClockDateTimeFromSystemClock,'yyyy-mm-dd HH:MM:ss.FFF'),referenceZeroOClockFromSystemClockOffset);
log2terminal('I',TAG,logMsg);
[referenceZeroOClockDateTimeFromGnssClock, referenceZeroOClockFromGnssClockOffset] = getGnssClockGpsTimeMapZeroOClockTime(gpsSystemClockTimeOffset(1,1));
referenceZeroOClockLeapseconds = getZeroOClockTimeGpsTimeLeapseconds(referenceZeroOClockDateTimeFromGnssClock);
logMsg = sprintf('GNSS clock based date: %s, time offset %f s, leapseconds %d s', datestr(referenceZeroOClockDateTimeFromGnssClock,'yyyy-mm-dd HH:MM:ss.FFF'),referenceZeroOClockFromGnssClockOffset,referenceZeroOClockLeapseconds);
log2terminal('I',TAG,logMsg);

zSystemTime = systemTime - referenceZeroOClockFromSystemClockOffset * S2MS;
zBootTimeGpsClock = gpsSystemClockTimeOffset - referenceZeroOClockFromGnssClockOffset * S2NS - referenceZeroOClockLeapseconds * S2NS;



%%% Time reference analysis
systemDuration = zSystemTime(N,1) - zSystemTime(1,1);
logMsg = sprintf('System.currentTimeMillis() delta time: %.9f s', systemDuration*MS2S);
log2terminal('I',TAG,logMsg);
systemClockDuration = systemClockTime(N,1) - systemClockTime(1,1);
logMsg = sprintf('SystemClock.elapsedRealtimeNanos() delta time: %.9f s', systemClockDuration*NS2S);
log2terminal('I',TAG,logMsg);

bootTimeNanosSystemClock = zSystemTime * MS2NS - systemClockTime;
minBootTimeNanosSystemClock = min(bootTimeNanosSystemClock);
pReferenceBootTimeNanosSystemClock = floor(minBootTimeNanosSystemClock * NS2MS) * MS2NS;
figure();
timeReferenceSubPlotRows = 3;
timeReferenceSubPlotColumns = 1;
subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,1);
pBootTimeNanosSystemClock = bootTimeNanosSystemClock - pReferenceBootTimeNanosSystemClock;
plot(pBootTimeNanosSystemClock);
ax = gca;
ax.YAxis.Exponent = 6;
xlabel('Sample');
ylabel('Nanosecond');
title('System clock based boot time');
pBootTimeNanosSystemBaseMean = mean(pBootTimeNanosSystemClock);
pBootTimeNanosSystemBaseStd = std(pBootTimeNanosSystemClock);
logMsg = sprintf('System clock based boot time value offset: %d ms, mean %.3f ms, std %.3f ms',pReferenceBootTimeNanosSystemClock*NS2MS,pBootTimeNanosSystemBaseMean*NS2MS,pBootTimeNanosSystemBaseStd*NS2MS);
log2terminal('I',TAG,logMsg);

minBootTimeNanosGnssClock = min(zBootTimeGpsClock);
pMinBootTimeNanosGnssClock = floor(minBootTimeNanosGnssClock * NS2MS) * MS2NS;
subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,2);
pBootTimeNanosGnssClock = zBootTimeGpsClock - pMinBootTimeNanosGnssClock;
plot(pBootTimeNanosGnssClock);
ax = gca;
ax.YAxis.Exponent = 6;
xlabel('Sample');
ylabel('Nanosecond');
title('GNSS clock based boot time');
pGpsSystemClockTimeOffsetMean = mean(pBootTimeNanosGnssClock);
pGpsSystemClockTimeOffsetStd = std(pBootTimeNanosGnssClock);
logMsg = sprintf('GNSS clock based boot time value offset: %d ms, mean %.3f ms, std %.3f ms',pMinBootTimeNanosGnssClock*NS2MS,pGpsSystemClockTimeOffsetMean*NS2MS,pGpsSystemClockTimeOffsetStd*NS2MS);
log2terminal('I',TAG,logMsg);

subplot(timeReferenceSubPlotRows,timeReferenceSubPlotColumns,3);
dSystemMinusGnssClockTimeOffset = bootTimeNanosSystemClock - zBootTimeGpsClock;
plot(dSystemMinusGnssClockTimeOffset);
ax = gca;
ax.YAxis.Exponent = 6;
xlabel('Sample') ;
ylabel('Nanosecond');
title('System minus GNSS clock offset');

%%% Time series analysis
figure;
timeSeriesSubPlotRows = 2;
timeSeriesSubPlotColumns = 3;
subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,1);
plot(zSystemTime);
xlabel('Sample') ;
ylabel('Millisecond');
title('System based sample time');
subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,4);
dSystemTime = zSystemTime(2:N,1) - zSystemTime(1:(N-1),1);
plot(dSystemTime);
xlabel('Sample') ;
ylabel('Millisecond');
title('System based sample interval');

dSystemTimeMin = min(dSystemTime);
dSystemTimeMax = max(dSystemTime);
dSystemTimeMean = mean(dSystemTime);
dSystemTimeStd = std(dSystemTime);
dSystemTimeSampleRate = 1 / (dSystemTimeMean*MS2S);
logMsg = sprintf('System based sample sample rate: %.0f Hz, sample interval: min %d ms, max %d ms, mean %.3f ms, std %.3f ms',dSystemTimeSampleRate,dSystemTimeMin,dSystemTimeMax,dSystemTimeMean,dSystemTimeStd);
log2terminal('I',TAG,logMsg);

subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,2);
sensorEventTimeStampMinusElapsedRealtimeNanos = sensorEventTime - systemClockTime;
actualEventTimeNanosUnixReferenceSystemBase = zSystemTime * MS2NS + sensorEventTimeStampMinusElapsedRealtimeNanos;
plot(actualEventTimeNanosUnixReferenceSystemBase);
xlabel('Sample');
ylabel('Nanosecond');
title('System clock based sample time');
subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,5);
dActualEventTimeNanosSystemBase = actualEventTimeNanosUnixReferenceSystemBase(2:N,1) - actualEventTimeNanosUnixReferenceSystemBase(1:(N-1),1);
plot(dActualEventTimeNanosSystemBase);
xlabel('Sample') ;
ylabel('Nanosecond');
title('System clock based sample interval');

dActualEventTimeNanosSystemBaseMin = min(dActualEventTimeNanosSystemBase);
dActualEventTimeNanosSystemBaseMax = max(dActualEventTimeNanosSystemBase);
dActualEventTimeNanosSystemBaseMean = mean(dActualEventTimeNanosSystemBase);
dActualEventTimeNanosSystemBaseStd = std(dActualEventTimeNanosSystemBase);
dActualEventTimeNanosSystemBaseSampleRate = 1 / (dActualEventTimeNanosSystemBaseMean*NS2S);
logMsg = sprintf('System clock based sample rate: %.0f Hz, sample interval: min %.1f ms, max %.1f ms, mean %.3f ms, std %.3f ms',dActualEventTimeNanosSystemBaseSampleRate,dActualEventTimeNanosSystemBaseMin*NS2MS,dActualEventTimeNanosSystemBaseMax*NS2MS,dActualEventTimeNanosSystemBaseMean*NS2MS,dActualEventTimeNanosSystemBaseStd*NS2MS);
log2terminal('I',TAG,logMsg);


subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,3);
actualEventTimeNanosGpsReferenceGnssClockBase = zBootTimeGpsClock + sensorEventTime;
plot(actualEventTimeNanosGpsReferenceGnssClockBase);
xlabel('Sample');
ylabel('Nanosecond');
title('GNSS clock based sample time');
subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,6);
dActualEventTimeNanosGpsBase = actualEventTimeNanosGpsReferenceGnssClockBase(2:N,1) - actualEventTimeNanosGpsReferenceGnssClockBase(1:(N-1),1);
plot(dActualEventTimeNanosGpsBase);
xlabel('Sample') ;
ylabel('Nanosecond');
title('GNSS clock based sample interval');

dActualEventTimeNanosGpsBaseMin = min(dActualEventTimeNanosGpsBase);
dActualEventTimeNanosGpsBaseMax = max(dActualEventTimeNanosGpsBase);
dActualEventTimeNanosGpsBaseMean = mean(dActualEventTimeNanosGpsBase);
dActualEventTimeNanosGpsBaseStd = std(dActualEventTimeNanosGpsBase);
dActualEventTimeNanosGpsBaseSampleRate = 1 / (dActualEventTimeNanosGpsBaseMean*NS2S);
logMsg = sprintf('GNSS clock based sample rate: %.0f Hz, sample interval: min %.1f ms, max %.1f ms, mean %.3f ms, std %.3f ms',dActualEventTimeNanosGpsBaseSampleRate,dActualEventTimeNanosGpsBaseMin*NS2MS,dActualEventTimeNanosGpsBaseMax*NS2MS,dActualEventTimeNanosGpsBaseMean*NS2MS,dActualEventTimeNanosGpsBaseStd*NS2MS);
log2terminal('I',TAG,logMsg);


figure;
timeSeriesSubPlotRows = 2;
timeSeriesSubPlotColumns =1;
subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,1);
plot(sensorEventTime);
xlabel('Sample') ;
ylabel('Nanosecond');
title('System based sample time');
subplot(timeSeriesSubPlotRows,timeSeriesSubPlotColumns,2);
dSensorEventTime = sensorEventTime(2:N,1) - sensorEventTime(1:(N-1),1);
plot(dSensorEventTime);
ax = gca;
ax.YAxis.Exponent = 6;
xlabel('Sample') ;
ylabel('Nanosecond');
title('System based sample interval');

