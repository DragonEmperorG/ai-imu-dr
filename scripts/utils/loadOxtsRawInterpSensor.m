function oxtsRawInterpSensor = loadOxtsRawInterpSensor(extractFolderPath)

cOxtsFolderName = 'oxts';
cOxtsRawDataInterpSensorMatFileName = 'OxtsRawDataInterpSensor.mat';

cOxtsRowDataInterpSensorMatFilePath = fullfile(extractFolderPath,cOxtsFolderName,cOxtsRawDataInterpSensorMatFileName);
if isfile(cOxtsRowDataInterpSensorMatFilePath)
    oxtsRawInterpSensor = load(cOxtsRowDataInterpSensorMatFilePath,'-mat').oxtsRawInterpSensor;
    return;
end

tOxtsRawData = loadOxtsRawData(extractFolderPath);
tOxtsRawDataTime = tOxtsRawData(:,1);
tOxtsRawDataGyroscope = tOxtsRawData(:,19:21);
tOxtsRawDataAccelerometer = tOxtsRawData(:,13:15);
tOxtsRawDataOdometrySensor = [tOxtsRawDataGyroscope,tOxtsRawDataAccelerometer];

tTimeHead = ceil(tOxtsRawDataTime(1));
tTimeTail = floor(tOxtsRawDataTime(end));
cSampleInvertal = 1/100;
tInterpTime = (tTimeHead:cSampleInvertal:tTimeTail)';

[~,ia,~] = unique(tOxtsRawDataTime);
resampledSensor = interp1(tOxtsRawDataTime(ia),tOxtsRawDataOdometrySensor(ia,:),tInterpTime);
oxtsRawInterpSensor = [tInterpTime,resampledSensor];

save(cOxtsRowDataInterpSensorMatFilePath,'oxtsRawInterpSensor');
