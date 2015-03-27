function foregroundNegativeLogLikelihood = getNegativeLogLikelihoodLocation(pixelIndices, foregroundProbability)

foregroundNegativeLogLikelihood = -sum(log(foregroundProbability(pixelIndices)));
foregroundNegativeLogLikelihood = foregroundNegativeLogLikelihood / length(pixelIndices);
end