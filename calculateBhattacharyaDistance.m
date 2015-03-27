function distance = calculateBhattacharyaDistance(proposalHistogramVector, objectModel)
distance = sqrt(1-sum(sum(sum(sqrt(proposalHistogramVector.*objectModel)))));
end