function [] = evaluateTrajetory(folderPath)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明

TAG = 'evaluateTrajetory';

filterState = loadFilterStateIntegratedDataDriven(folderPath);
preprocessRawFlatData = loadPreprocessRawFlat(folderPath);

preprocessGroundTruthNavOrientationRotationMatrix = getPreprocessGroundTruthNavOrientationRotationMatrix(preprocessRawFlatData);
preprocessGroundTruthNavPosition = getPreprocessGroundTruthNavPosition(preprocessRawFlatData);
preprocessGroundTruthNavSE = se3(preprocessGroundTruthNavOrientationRotationMatrix,preprocessGroundTruthNavPosition);
filterStateNavOrientationRotationMatrix = getFilterStateNavOrientation(filterState);
filterStateNavPosition = getFilterStateNavPosition(filterState);
filterStateNavSE = se3(filterStateNavOrientationRotationMatrix,filterStateNavPosition);

preprocessGroundTruthNavDeltaPosition = diff(preprocessGroundTruthNavPosition);
preprocessGroundTruthNavDeltaDistance = sqrt(sum(preprocessGroundTruthNavDeltaPosition.*preprocessGroundTruthNavDeltaPosition,2));
preprocessGroundTruthNavCumsum = cumsum(preprocessGroundTruthNavDeltaDistance);
preprocessGroundTruthNavCumsum = [0; preprocessGroundTruthNavCumsum];

evaluationSection = []; 
evaluationSampleSize = size(preprocessGroundTruthNavCumsum,1);
evaluationHopLength = 200;
% evaluationSubtrajetoryLength = [100, 200];
% evaluationSubtrajetoryLength = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200];
evaluationSubtrajetoryLength = [100, 200, 300, 400, 500, 600, 700, 800, 900];
for i = 1:evaluationHopLength:evaluationSampleSize
    for j = evaluationSubtrajetoryLength
        tHeadOdometry = preprocessGroundTruthNavCumsum(i);
        tTailOdometry = tHeadOdometry + j;
        tTailOdometryIndexList = find(preprocessGroundTruthNavCumsum >= tTailOdometry);
        if ~isempty(tTailOdometryIndexList)
            tTailOdometryIndex = tTailOdometryIndexList(1);
            evaluationSection = [evaluationSection; [i tTailOdometryIndex j (preprocessGroundTruthNavCumsum(tTailOdometryIndex) - preprocessGroundTruthNavCumsum(i))]];
        end
    end
end

evaluationSectionSize = size(evaluationSection,1);
for i = 1:evaluationSectionSize
    iH = evaluationSection(i,1);
    iT = evaluationSection(i,2);
    distance =  evaluationSection(i,4);
    pHFilter = tform(filterStateNavSE(iH));
    pTFilter = tform(filterStateNavSE(iT));
    pHGT = tform(preprocessGroundTruthNavSE(iH));
    pTGT = tform(preprocessGroundTruthNavSE(iT));
    dFliter = inv(pHFilter) * pTFilter;
    dGT = inv(pHGT) * pTGT;
    dError = inv(dFliter) * dGT;
    dRotationError = evaluateRotationError(dError);
    dTranslationError = evaluateTranslationError(dError);
    dTranslationHorizantalError = evaluateHorizantalTranslationError(dError);

    evaluationSection(i,5) = dRotationError;
    evaluationSection(i,6) = dTranslationError;
    evaluationSection(i,7) = dTranslationHorizantalError;
    evaluationSection(i,8) = dRotationError / distance;
    evaluationSection(i,9) = dTranslationError / distance;
    evaluationSection(i,10) = dTranslationHorizantalError / distance;

end

meanRotationError = mean(evaluationSection(:,5));
meanTranslationError = mean(evaluationSection(:,6));
meanTranslationHorizantalError = mean(evaluationSection(:,7));
meanRelativeRotationError = mean(evaluationSection(:,8));
meanRelativeTranslationError = mean(evaluationSection(:,9));
meanRelativeTranslationHorizantalError = mean(evaluationSection(:,10));

evaluationSection(evaluationSectionSize+1,1) = evaluationSectionSize;
evaluationSection(evaluationSectionSize+1,5) = meanRotationError;
evaluationSection(evaluationSectionSize+1,6) = meanTranslationError;
evaluationSection(evaluationSectionSize+1,7) = meanTranslationHorizantalError;
evaluationSection(evaluationSectionSize+1,8) = meanRelativeRotationError;
evaluationSection(evaluationSectionSize+1,9) = meanRelativeTranslationError;
evaluationSection(evaluationSectionSize+1,10) = meanRelativeTranslationHorizantalError;

evaluationResultFolderName = 'EVALUATION';
evaluationResultFolderPath = fullfile(folderPath,evaluationResultFolderName);
if ~isfolder(evaluationResultFolderPath)
    mkdir(evaluationResultFolderPath);
end

evaluationResultFileName = 'DDAttitude_FUncertainty_DDVelocity_FUncertainty.txt';
evaluationResultFilePath = fullfile(evaluationResultFolderPath,evaluationResultFileName);
% writematrix(evaluationSection, evaluationResultFilePath);

logMsg = sprintf('%.2f, %.2f, %.2f', ...
    rad2deg(meanRelativeRotationError*1e3), ...
    meanRelativeTranslationError * 1e2, ...
    meanRelativeTranslationHorizantalError * 1e2 ...
    );
log2terminal('I',TAG,logMsg);

end