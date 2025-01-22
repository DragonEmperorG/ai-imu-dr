function oxtsRawData = loadOxtsRawData(extractFolderPath)

cOxtsFolderName = 'oxts';
cOxtsRawDataFileName = 'OxtsRawData.mat';

cOxtsRowDataMatFilePath = fullfile(extractFolderPath,cOxtsFolderName,cOxtsRawDataFileName);
if isfile(cOxtsRowDataMatFilePath)
    oxtsRawData = load(cOxtsRowDataMatFilePath,'-mat').oxtsRawData;
    return;
end

cOxtsliteDataMatFilePath = fullfile(extractFolderPath,cOxtsFolderName,'data.mat');
if ~isfile(cOxtsliteDataMatFilePath)
    tOxtsliteData = loadOxtsliteData(tRawDataFolderPath);
    save(cOxtsliteDataMatFilePath,'tOxtsliteData');
else
    load(cOxtsliteDataMatFilePath);
end
oxtsRawData = cell2mat(tOxtsliteData');

cOxtsSensorTimestampsFilePath = fullfile(extractFolderPath,cOxtsFolderName,'timestamps.txt');
if isfile(cOxtsSensorTimestampsFilePath)
    oxtsSensorTimestampsTable = readtable(cOxtsSensorTimestampsFilePath);
    oxtsSensorTimestampsTableHeight = height(oxtsSensorTimestampsTable);
    oxtsSensorTimeData = zeros(oxtsSensorTimestampsTableHeight, 1);
    for i = 1:oxtsSensorTimestampsTableHeight
        oxtsSensorIteratorDateTime = oxtsSensorTimestampsTable.Var1(i);
        oxtsSensorTimeData(i, 1) = oxtsSensorIteratorDateTime.Hour * 3600 + oxtsSensorIteratorDateTime.Minute * 60 + oxtsSensorIteratorDateTime.Second;
    end
    oxtsRawData = horzcat(oxtsSensorTimeData,oxtsRawData) ;
end

save(cOxtsRowDataMatFilePath,'oxtsRawData');
