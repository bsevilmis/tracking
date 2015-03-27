function negativeLogLikelihood = getNegativeLogLikelihood(pixelIndices, observedImage, distribution)

separatedRChannel = observedImage(:,:,1);
separatedGChannel = observedImage(:,:,2);
separatedBChannel = observedImage(:,:,3);

rVector = separatedRChannel(pixelIndices);
gVector = separatedGChannel(pixelIndices);
bVector = separatedBChannel(pixelIndices);

negativeLogLikelihood = sum(log(distribution(1,rVector+1,1))) + ...
    sum(log(distribution(1,gVector+1,2))) + sum(log(distribution(1,bVector+1,3)));
negativeLogLikelihood = -negativeLogLikelihood;
negativeLogLikelihood = negativeLogLikelihood / length(pixelIndices);
end