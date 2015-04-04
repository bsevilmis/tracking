function randomWalkMatrix = obtainRandomWalkMatrix(spFeatures,binsPerEachColor)

% % set earth movers ground distance
% saturationValue = 5;
% d = zeros(binsPerEachColor^3,binsPerEachColor^3);
% for i = 1:binsPerEachColor^3
%     [currentBinR,currentBinG,currentBinB] = ind2sub([binsPerEachColor,binsPerEachColor,binsPerEachColor],i);
%     for j = 1:binsPerEachColor^3
%         [neighborBinR,neighborBinG,neighborBinB] = ind2sub([binsPerEachColor,binsPerEachColor,binsPerEachColor],j);
%             d(i,j) = 1 - exp(-saturationValue*sum([abs(currentBinR-neighborBinR) abs(currentBinG-neighborBinG) abs(currentBinB-neighborBinB)])/(binsPerEachColor^3 - 1)) ;
%     end
% end
%                 
nbOfNodes = length(spFeatures);
randomWalkMatrix = zeros(nbOfNodes,nbOfNodes);


localWeights = [1/2 1/2 0];
for i = 1:nbOfNodes
    for j = i:nbOfNodes
        if (i == j)
            randomWalkMatrix(i,j) = 1;
        else
            rgbColorCost = sum(abs((spFeatures(i).meanRGB - spFeatures(j).meanRGB)))/(3*255);
            labColorCost = sum(abs((spFeatures(i).meanLAB - spFeatures(j).meanLAB)))/(3*255);
            %[rgbEMDCost, ~] = emd_hat_mex(spFeatures(i).histogramRGB(:),spFeatures(j).histogramRGB(:),d,0,3);
            %[labEMDCost, ~] = emd_hat_mex(spFeatures(i).histogramLAB(:),spFeatures(j).histogramLAB(:),d,0,3);
            spatialCost = sum(abs(spFeatures(i).relativeCoordinates - spFeatures(j).relativeCoordinates))/2;
            %similarity = sum(localWeights.*[(1-rgbEMDCost) (1-labEMDCost) (1-spatialCost)]);
            similarity = sum(localWeights.*[(1-rgbColorCost) (1-labColorCost) (1-spatialCost)]);
            randomWalkMatrix(i,j) = similarity;
            randomWalkMatrix(j,i) = similarity;
        end
    end
    disp(['i: ' num2str(i) '..done']);
end
end
        

