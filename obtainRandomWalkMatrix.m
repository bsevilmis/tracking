function randomWalkMatrix = obtainRandomWalkMatrix(spFeatures,binsPerEachColor)

% set earth movers ground distance
saturationValue = 5;
d = zeros(binsPerEachColor^3,binsPerEachColor^3);
for i = 1:binsPerEachColor^3
    [currentBinR,currentBinG,currentBinB] = ind2sub([binsPerEachColor,binsPerEachColor,binsPerEachColor],i);
    for j = 1:binsPerEachColor^3
        [neighborBinR,neighborBinG,neighborBinB] = ind2sub([binsPerEachColor,binsPerEachColor,binsPerEachColor],j);
            d(i,j) = 1 - exp(-saturationValue*sum([abs(currentBinR-neighborBinR) abs(currentBinG-neighborBinG) abs(currentBinB-neighborBinB)])/(binsPerEachColor^3 - 1)) ;
    end
end
                
nbOfNodes = length(spFeatures);
randomWalkMatrix = zeros(nbOfNodes,nbOfNodes);


localWeights = [1/3 1/3 1/3];
for i = 1:50
    for j = i:nbOfNodes
        if (i == j)
            randomWalkMatrix(i,j) = 1;
        else
            [rgbEMDCost, ~] = emd_hat_mex(spFeatures(i).histogramRGB(:),spFeatures(j).histogramRGB(:),d,0,3);
            [labEMDCost, ~] = emd_hat_mex(spFeatures(i).histogramLAB(:),spFeatures(j).histogramLAB(:),d,0,3);
            spatialCost = sum(abs(spFeatures(i).relativeCoordinates - spFeatures(j).relativeCoordinates))/2;
            similarity = sum(localWeights.*[(1-rgbEMDCost) (1-labEMDCost) (1-spatialCost)]);
            randomWalkMatrix(i,j) = similarity;
        end
    end
    disp(['i: ' num2str(i) '..done']);
end
end
        

