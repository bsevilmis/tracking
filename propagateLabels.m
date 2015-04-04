function propagatedProbabilities = propagateLabels(spImages, nbOfNeighbors, randomWalkMatrix, spFeatures, numberOfFrames)

minForegroundProbabilities = ones(1,numberOfFrames);
%determine minimum fgProbabilities for each frame
for j = 1:length(spFeatures)
    currentFrameNumber = spFeatures(j).frameNumber;
    currentfgProbability = spFeatures(j).fgProbability;
    if(currentfgProbability < minForegroundProbabilities(1,currentFrameNumber))
        minForegroundProbabilities(1,currentFrameNumber) = currentfgProbability;
    end
end
    
%determine possibly foreground and possibly background superpixels
possiblyForegroundProbabilities = zeros(1,numberOfFrames);
possiblyForegroundSuperPixelIndices = zeros(1,numberOfFrames);
possiblyBackgroundIndices = cell(numberOfFrames,1);
for j = 1:length(spFeatures)
    currentFrameNumber = spFeatures(j).frameNumber;
    currentfgProbability = spFeatures(j).fgProbability;
    if(currentfgProbability > possiblyForegroundProbabilities(1,currentFrameNumber))
        possiblyForegroundProbabilities(1,currentFrameNumber) = currentfgProbability;
        possiblyForegroundSuperPixelIndices(1,currentFrameNumber) = j;
    end
    if(currentfgProbability == minForegroundProbabilities(1,currentFrameNumber))
        
        possiblyBackgroundIndices{currentFrameNumber} = ...
            [possiblyBackgroundIndices{currentFrameNumber} j];
    end
        
end

% pick random background from possibly background superpixels
possiblyBackgroundSuperPixelIndices = zeros(1,numberOfFrames);
for i = 2:numberOfFrames
    randomIndex = randi([1 size(possiblyBackgroundIndices{i},2)],1,1);
    possiblyBackgroundSuperPixelIndices(1,i) = possiblyBackgroundIndices{i}(1,randomIndex);
end
    
% obtain sparse randomWalkMatrix    
reducedRandomWalkMatrix = zeros(size(randomWalkMatrix));
b = zeros(size(randomWalkMatrix,1),1);
for i = 1:size(randomWalkMatrix,1)
    if(ismember(i,possiblyForegroundSuperPixelIndices))
        reducedRandomWalkMatrix(i,:) = 0;
        reducedRandomWalkMatrix(i,i) = 1;
        b(i) = 1;
    elseif(ismember(i,possiblyBackgroundSuperPixelIndices))
        reducedRandomWalkMatrix(i,:) = 0;
        reducedRandomWalkMatrix(i,i) = 1;
        b(i) = 0;
    else
    currentRow = randomWalkMatrix(i,:);
    [val,ind] = sort(currentRow,'descend');
    values = val(2:nbOfNeighbors);
    indices = ind(2:nbOfNeighbors);
    values = -(values / sum(values));
    reducedRandomWalkMatrix(i,i) = 1;
    reducedRandomWalkMatrix(i,indices) = values;
    end
end

% obtain propagated probabilities
propagatedProbabilities = reducedRandomWalkMatrix\b;

end