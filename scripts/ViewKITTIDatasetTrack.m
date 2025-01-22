clearvars;
close all;
dbstop error;

addpath('E:\GitHubRepositories\KITTI\downloads\raw_data\devkit\matlab');
addpath(genpath(pwd));

TAG = 'OdometryPosesViewer';

load 'OdometryMappingConfig.mat';

cRawDatasetFolderPath = 'E:\GitHubRepositories\KITTI\raw_data';
cExpDatasetFolderPath = 'E:\GitHubRepositories\KITTI\odometry\export';

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
        tExportTrackFolderPath = fullfile(cExpDatasetFolderPath,tSequenceNumberString);

        plotKITTIGroundTruthGeodeticCoordinate(tRawDataFolderPath, tExportTrackFolderPath);

        logMsg = sprintf('Sequence: %s',tSequenceNumberString);
        log2terminal('D',TAG,logMsg);
    end    
end
