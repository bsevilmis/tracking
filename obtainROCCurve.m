function [] = obtainROCCurve(propagatedProbabilities, spFeatures,spLabels,groundTruthPath, numberOfFrames)

groundTruthSet = cell(1,numberOfFrames);
% obtain groundtruth set
groundTruthFolder = dir(groundTruthPath);
for frameNumber = 1:numberOfFrames
    groundTruthImage = imread([groundTruthPath '/' groundTruthFolder(2+frameNumber).name]);
    if (nnz(size(groundTruthImage)) == 3)
        groundTruthImage = rgb2gray(groundTruthImage);
    end
    groundTruthImage = (groundTruthImage >= 128);
    groundTruthSet{frameNumber} = groundTruthImage;
end

imageRows = size(spLabels{2},1);
imageCols = size(spLabels{2},2);

% obtain threshold values
[thresholds, indices] = sort(propagatedProbabilities);
averagePrecisionValues = zeros(1,length(thresholds));
for i = 1:length(thresholds)
    
    %create empty result array
    thresholdedSet = cell(1,numberOfFrames);
    for k = 1:numberOfFrames
        thresholdedSet{k} = uint8(zeros(imageRows,imageCols));
    end
    %obtain figure segmentation
    for t = i:length(thresholds)
        currentFrameNumber = spFeatures(indices(t)).frameNumber;
        currentSpNumber = spFeatures(indices(t)).spNumber;
        linearIndices = find(spLabels{1,currentFrameNumber} == currentSpNumber);
        thresholdedSet{currentFrameNumber}(linearIndices) = 255;
    end
    %obtain current performance
    currentThresholdPrecisionValues = zeros(1,numberOfFrames);
    for j = 2:numberOfFrames
        groundTruthImage = groundTruthSet{j};
        resultImage = logical(thresholdedSet{j});
        precision = nnz(groundTruthImage & resultImage) / nnz(groundTruthImage | resultImage);
        currentThresholdPrecisionValues(1,j) = precision;
    end
    averagePrecisionValues(1,i) = mean(currentThresholdPrecisionValues(1,2:end));
    disp(['threshold: ' num2str(i) '..done' ' averagePrecisionValue: ' num2str(averagePrecisionValues(1,i))]);
end

figure,plot(averagePrecisionValues);