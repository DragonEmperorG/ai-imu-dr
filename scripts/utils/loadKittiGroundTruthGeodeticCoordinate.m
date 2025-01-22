function [rGroundTruthGeodeticCoordinate] = loadKittiGroundTruthGeodeticCoordinate(folderPath)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明

cGroundTruthGeodeticCoordinateFileName = 'GTGeodeticCoordinate.csv';

tGroundTruthGeodeticCoordinateFilePath = fullfile(folderPath,cGroundTruthGeodeticCoordinateFileName);
rGroundTruthGeodeticCoordinate = readmatrix(tGroundTruthGeodeticCoordinateFilePath);

end