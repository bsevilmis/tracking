function updatedDistribution = updateNBDistribution(distribution, observedImage, proposalMask)
pixelIndices = find(proposalMask);

separatedRChannel = observedImage(:,:,1);
separatedGChannel = observedImage(:,:,2);
separatedBChannel = observedImage(:,:,3);

for i = 1:length(pixelIndices)
    rValue = separatedRChannel(pixelIndices(i));
    gValue = separatedGChannel(pixelIndices(i));
    bValue = separatedBChannel(pixelIndices(i));
        
    distribution(1,rValue+1,1) = distribution(1,rValue+1,1) + 1;
    distribution(1,gValue+1,2) = distribution(1,gValue+1,2) + 1;
    distribution(1,bValue+1,3) = distribution(1,bValue+1,3) + 1;
end
updatedDistribution = distribution;
end