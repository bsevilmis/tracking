function initialParticles = generateParticles(objectInitialState, N, generationVariances)
initialParticles = repmat(objectInitialState,1,N) + repmat(sqrt(generationVariances),1,N).*randn(size(objectInitialState,1),N);
end