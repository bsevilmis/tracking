function propagatedProbabilities = propagateLabelsv2(spImages, nbOfNeighbors, randomWalkMatrix, spFeatures, numberOfFrames)

% obtain sparse randomWalkMatrix    
reducedRandomWalkMatrix = zeros(size(randomWalkMatrix));
for i = 1:size(randomWalkMatrix,1)
    currentRow = randomWalkMatrix(i,:);
    [val,ind] = sort(currentRow,'descend');
    values = val(1:nbOfNeighbors);
    indices = ind(1:nbOfNeighbors);
    values = (values / sum(values));
    reducedRandomWalkMatrix(i,indices) = values;
end

fgVotes = extractfield(spFeatures,'fgProbability');
fgVotes = fgVotes';
frameIdentities = extractfield(spFeatures,'frameNumber');
frameIdentities = frameIdentities';
% obtain propagated probabilities
for T = 1:10
    updatedfgVotes = reducedRandomWalkMatrix*fgVotes;
    normalizedfgVotes = normalizeUpdatedVotes(updatedfgVotes, frameIdentities, numberOfFrames);
    fgVotes = normalizedfgVotes;
end
      
propagatedProbabilities = fgVotes;

end


function normalizedVotes = normalizeUpdatedVotes(votes, frameIdentities, numberOfFrames)
    normalizedVotes = zeros(size(votes));
    for frame = 2:numberOfFrames
        ind = (frameIdentities == frame);
        voteSum = sum(votes(ind));
        normalizedVotes(ind) = votes(ind)/voteSum;
    end
end