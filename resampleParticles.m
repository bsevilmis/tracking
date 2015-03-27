function particles = resampleParticles(weights, propagatedParticles)
particles = zeros(size(propagatedParticles));
cumulativeWeights = cumsum(weights);
for i = 1:size(propagatedParticles,2)
    comparisonArray = cumulativeWeights;
    comparisonArray(comparisonArray < rand) = 1;
    [~, index] = min(comparisonArray);
    particles(:,i) = propagatedParticles(:,index);
end
end