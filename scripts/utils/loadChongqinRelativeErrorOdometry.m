function rRelativeErrorOdometrySet = loadChongqinRelativeErrorOdometry(iFolderPath)

TAG = "loadChongqinRelativeErrorOdometry";

cRelativeHopSamples = 200;

cSaveFolderName = 'dayZeroOClockAlign';
cSaveMatFileName = 'RelativeErrorOdometrySet.mat';

cSaveMatFilePath = fullfile(iFolderPath,cSaveFolderName,cSaveMatFileName);
% if isfile(cSaveMatFilePath)
%     rRelativeErrorOdometrySet = load(cSaveMatFilePath,'-mat').rRelativeErrorOdometrySet;
%     return;
% end

tGroundTruthTime = loadPreprocessTime(iFolderPath);
tGroundTruthNavPosition = loadPreprocessGroundTruthNavPosition(iFolderPath);

tSamples = size(tGroundTruthTime,1);
tDownSampledIndex = 1:cRelativeHopSamples:tSamples;
tGroundTruthTime = tGroundTruthTime(tDownSampledIndex,1);
tGroundTruthNavPosition = tGroundTruthNavPosition(tDownSampledIndex,:);

tGroundTruthNavPosition0 = tGroundTruthNavPosition(1:end-1,:);
tGroundTruthNavPosition1 = tGroundTruthNavPosition(2:end,:);
dGroundTruthNavPosition = tGroundTruthNavPosition1 - tGroundTruthNavPosition0;

dOdometry = sqrt(sum(dGroundTruthNavPosition.^2,2));
tOdometry = cumsum(dOdometry);
tOdometry = [0;tOdometry];

cOdometrySet = (100:100:800)';
rRelativeErrorOdometrySet = [];
tOdometrySize = size(tOdometry,1);
for i = 1:tOdometrySize
    t0 = i;
    for j = 1:size(cOdometrySet,1)
        tOdometry1 = tOdometry(t0) + cOdometrySet(j);
        if tOdometry1 > tOdometry(end)
            continue;
        end
        tSearch = find(tOdometry >= tOdometry1);
        t1 = tSearch(1);
        tRelativeErrorOdometry = [
            t0, ...
            t1, ...
            tGroundTruthTime(t0), ...
            tGroundTruthTime(t1), ...
            tOdometry(t0), ...
            tOdometry(t1), ...
            cOdometrySet(j), ...
            tOdometry(t1)-tOdometry(t0) ...
        ];
        rRelativeErrorOdometrySet = [rRelativeErrorOdometrySet;tRelativeErrorOdometry];
    end
end

save(cSaveMatFilePath,'rRelativeErrorOdometrySet');
