clearvars;
close all;
dbstop error;

addpath('E:\GitHubRepositories\KITTI\downloads\raw_data\devkit\matlab');
addpath(genpath(pwd));

TAG = 'OdometryPosesViewer';

load 'OdometryMappingConfig.mat';

cRawDatasetFolderPath = 'E:\GitHubRepositories\KITTI\raw_data';
cExpDatasetFolderPath = 'E:\GitHubRepositories\KITTI\odometry\export';
cOxtsFolderName = 'oxts';
cOxtsliteDataMatFileName = 'data.mat';
cExportINGyrAccFileName = 'INSensor.csv';
cExportGTOrientationFileName = 'GTOrientation.csv';
cExportGTVelocityFileName = 'GTVelocity.csv';

cExportGTGeodeticCoordinateFileName = 'GTGeodeticCoordinate.csv';
cExportGTNavVelocityFileName = 'GTNavVelocity.csv';

cRecomputeOxtslitePoseMatFile = 1;

odometryMappingSize = size(ODOMETRY_MAPPING,1);
for i = 1 : odometryMappingSize
    tSequenceNumberString = ODOMETRY_MAPPING{i,1};
    tSequenceNumber = str2double(tSequenceNumberString);
    tSequenceName = ODOMETRY_MAPPING{i,2};
    tSequenceNameSplit = strsplit(tSequenceName,'_');
    tRawDateFolderName = strjoin(tSequenceNameSplit(1:3),'_');
    tRawDataFolderName = strcat(tSequenceName,'_extract');
    tRawDataFolderPath = fullfile(cRawDatasetFolderPath,tRawDateFolderName,tRawDataFolderName);

    if isfolder(tRawDataFolderPath)
        % tOxtsRawInterpGTOrientation = loadOxtsRawInterpOrientation(tRawDataFolderPath);
        % tOxtsRawInterpGTVelocity = loadOxtsRawInterpVelocity(tRawDataFolderPath);
        % tOxtsRawInterpSensor = loadOxtsRawInterpSensor(tRawDataFolderPath);

        tOxtsRawInterpNavVelocity = loadOxtsRawInterpNavVelocity(tRawDataFolderPath);
        tOxtsRawInterpGeodeticCoordinate = loadOxtsRawInterpGeodeticCoordinate(tRawDataFolderPath);
        
        cExportTrackFolderPath = fullfile(cExpDatasetFolderPath,tSequenceNumberString);
        if ~isfolder(cExportTrackFolderPath)
            mkdir(cExportTrackFolderPath);
        end
        
        % tExportGTOrientationFilePath = fullfile(cExportTrackFolderPath,cExportGTOrientationFileName);
        % writematrix(tOxtsRawInterpGTOrientation,tExportGTOrientationFilePath);

        % tExportGTVelocityFilePath = fullfile(cExportTrackFolderPath,cExportGTVelocityFileName);
        % writematrix(tOxtsRawInterpGTVelocity,tExportGTVelocityFilePath);

        % tExportINGyrAccFilePath = fullfile(cExportTrackFolderPath,cExportINGyrAccFileName);
        % writematrix(tOxtsRawInterpSensor,tExportINGyrAccFilePath);

        % tExportGTGeodeticCoordinateFilePath = fullfile(cExportTrackFolderPath,cExportGTGeodeticCoordinateFileName);
        % writematrix(tOxtsRawInterpGeodeticCoordinate,tExportGTGeodeticCoordinateFilePath);

        tExportGTNavVelocityFilePath = fullfile(cExportTrackFolderPath,cExportGTNavVelocityFileName);
        writematrix(tOxtsRawInterpNavVelocity,tExportGTNavVelocityFilePath);
        
        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end    
end
