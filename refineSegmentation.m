function fineSegmentation = refineSegmentation(observedImage, superpixelSegments,locationPrior,...
        foregroundNBDistribution,backgroundNBDistribution, nbOfSuperpixelsInCol,foregroundProbability);

spaceScaleFactor = 1.1;

% obtain location prior
topLeftX = locationPrior(1);
topLeftY = locationPrior(2);
width = locationPrior(5)*locationPrior(7);
height = locationPrior(6)*locationPrior(7);
bottomRightX = topLeftX + width - 1;
bottomRightY = topLeftY + height - 1;

% update location prior with scale factor
topLeftX = topLeftX - ((sqrt(spaceScaleFactor)*width-width)/2);
topLeftY = topLeftY - ((sqrt(spaceScaleFactor)*height-height)/2);
bottomRightX = bottomRightX + ((sqrt(spaceScaleFactor)*width-width)/2);
bottomRightY = bottomRightY + ((sqrt(spaceScaleFactor)*height-height)/2);

% round to integers
topLeftX = round(topLeftX);
topLeftY = round(topLeftY);
bottomRightX = round(bottomRightX);
bottomRightY = round(bottomRightY);

% correct topleft corner
if(topLeftX <= 0)
    topLeftX = 1;
end
if(topLeftX > size(observedImage,2))
    topLeftX = size(observedImage,2);
end
if(topLeftY <= 0)
    topLeftY = 1;
end
if(topLeftY > size(observedImage,1))
    topLeftY = size(observedImage,1);
end

% correct bottomright corner
if(bottomRightX <= 0)
    bottomRightX = 1;
end
if(bottomRightX > size(observedImage,2))
    bottomRightX = size(observedImage,2);
end
if(bottomRightY <= 0)
    bottomRightY = 1;
end
if(bottomRightY > size(observedImage,1))
    bottomRightY = size(observedImage,1);
end

% % visually check enlarged search space
% figure(3), imshow(observedImage),rectangle('Position',[topLeftX topLeftY bottomRightX - topLeftX bottomRightY - topLeftY],'EdgeColor',[0.0,1,0.0]); 
% waitforbuttonpress

% locate superpixels to consider
superpixelSegmentsIndicesVector = [];
superpixelInclusionThreshold = 0;
for i = 1:max(max(superpixelSegments))
    currentSuperPixelSegment = (superpixelSegments == i);
    intersection = nnz(currentSuperPixelSegment(topLeftY:bottomRightY,topLeftX:bottomRightX));
    if ((double(intersection) / double(nnz(currentSuperPixelSegment))) > superpixelInclusionThreshold)
        superpixelSegmentsIndicesVector = [superpixelSegmentsIndicesVector i];
    end
end

% figure(4);
% for l = 1:length(superpixelSegmentsIndicesVector)
%     imshow(superpixelSegments == superpixelSegmentsIndicesVector(l)),hold on;
%     waitforbuttonpress
% end
% figure(3), imshow(observedImage),rectangle('Position',[topLeftX topLeftY bottomRightX - topLeftX bottomRightY - topLeftY],'EdgeColor',[0.0,1,0.0]); 
% waitforbuttonpress



%%%%%%%%%%%%%%%%%%%--MULTILABEL--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % set foreground seed
% se = strel('disk',5);
% erodedPredictedProposal = imerode(predictedProposal, se);
% 
% % locate foreground seeds to consider
% foregroundSegmentSeedIndicesVector = [];
% superpixelInclusionThreshold = 0.75;
% for i = 1:max(max(superpixelSegments))
%     currentSuperPixelSegment = (superpixelSegments == i);
%     intersection = nnz(currentSuperPixelSegment & erodedPredictedProposal);
%     if ((intersection / nnz(currentSuperPixelSegment)) >= superpixelInclusionThreshold)
%         foregroundSegmentSeedIndicesVector = [foregroundSegmentSeedIndicesVector i];
%     end
% end
% % set graph
% nbOfNodes = length(superpixelSegmentsIndicesVector);
% graphHandle = GCO_Create(nbOfNodes, 2);
% %graphHandle = BK_Create(nbOfNodes, 2*nbOfNodes);
% priorLabels = ones(1,nbOfNodes);
% pairwiseCosts = zeros(nbOfNodes, nbOfNodes);
% unaryCostMatrix = zeros(2,nbOfNodes);
% smoothnessPenaltyFactor = 1;
% smoothnessCost = smoothnessPenaltyFactor * (ones(2) - eye(2));
% 
% % set unary costs & pairwise costs
% logDivisionByZero = 6;
% for i = 1:length(superpixelSegmentsIndicesVector)
%     pixelIndices = find(superpixelSegments == superpixelSegmentsIndicesVector(i));
%     currentSuperpixelSegmentHistogramVector = calculateHistogramFromVectors(pixelIndices,binsPerEachColor,observedImage);
%     
%     % set unary cost
%     foregroundClassNegativeLogLikelihood = getNegativeLogLikelihood(pixelIndices, observedImage, binsPerEachColor, objectModel);
%     backgroundClassNegativeLogLikelihood = getNegativeLogLikelihood(pixelIndices, observedImage, binsPerEachColor, backgroundModel);
%     unaryCostMatrix(1,i) = backgroundClassNegativeLogLikelihood;
%     unaryCostMatrix(2,i) = foregroundClassNegativeLogLikelihood;
%     
%     %     % set unary cost
%     %     distanceBetweenSuperpixelAndFGModel = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, objectModel);
%     %     distanceBetweenSuperpixelAndBGModel = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, backgroundModel);
%     %     unaryCostMatrix(1,i) = 1 - exp(-distanceBetweenSuperpixelAndBGModel.^2 / (2 * distanceVariance));
%     %     unaryCostMatrix(2,i) = 1 - exp(-distanceBetweenSuperpixelAndFGModel.^2 / (2 * distanceVariance));
%     
%     % set pairwise cost
%     currentNodeIndex = superpixelSegmentsIndicesVector(i);
%     
%     currentNodeColIndex = ceil(double(currentNodeIndex) / double(nbOfSuperpixelsInCol));
%     currentNodeRowIndex = currentNodeIndex - (currentNodeColIndex -1)*nbOfSuperpixelsInCol;
%     
%     lowerNeighborNodeIndex = currentNodeIndex + 1;
%     nextNeighborNodeIndex = currentNodeColIndex*nbOfSuperpixelsInCol + currentNodeRowIndex;
%     
%     [~,LNNI] = find(superpixelSegmentsIndicesVector == lowerNeighborNodeIndex);
%     [~,NNNI] = find(superpixelSegmentsIndicesVector == nextNeighborNodeIndex);
%     
%     if(~isempty(LNNI))
%         lowerNeighborNodePixelIndices = find(superpixelSegments == lowerNeighborNodeIndex);
%         lowerNeighborSuperpixelSegmentHistogramVector = calculateHistogramFromVectors(lowerNeighborNodePixelIndices,binsPerEachColor,observedImage);
%         
%         neighborCost = getSymmetricKLDivergence(currentSuperpixelSegmentHistogramVector, lowerNeighborSuperpixelSegmentHistogramVector);
%         %         neighborCost = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, lowerNeighborSuperpixelSegmentHistogramVector);
%         %         neighborCost = exp(-neighborCost.^2 / (2 * distanceVariance));
%         pairwiseCosts(i,LNNI) = (logDivisionByZero - neighborCost);
%         
%         if(pairwiseCosts(i,LNNI) < 0)
%             error('Negative pairwise cost obtained..');
%         end
%         
%     end
%     
%     if(~isempty(NNNI))
%         nextNeighborNodePixelIndices = find(superpixelSegments == nextNeighborNodeIndex);
%         nextNeighborSuperpixelSegmentHistogramVector = calculateHistogramFromVectors(nextNeighborNodePixelIndices,binsPerEachColor,observedImage);
%         
%         neighborCost = getSymmetricKLDivergence(currentSuperpixelSegmentHistogramVector, nextNeighborSuperpixelSegmentHistogramVector);
%         %         neighborCost = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, nextNeighborSuperpixelSegmentHistogramVector);
%         %         neighborCost = exp(-neighborCost.^2 / (2 * distanceVariance));
%         pairwiseCosts(i,NNNI) = (logDivisionByZero - neighborCost);
%         
%         if(pairwiseCosts(i,NNNI) < 0)
%             error('Negative pairwise cost obtained..');
%         end
%         
%     end    
% end
% 
% % set foreground seed & background labeling
% for i = 1:length(foregroundSegmentSeedIndicesVector)
%     [~,indexOnGraph] =  find(superpixelSegmentsIndicesVector == foregroundSegmentSeedIndicesVector(i));
%     priorLabels(1,indexOnGraph) = 2;
% end
%     
% % convert costs to int32
% unaryCostMatrix = int32(100 * unaryCostMatrix);
% smoothnessCost = int32(smoothnessCost);
% pairwiseCosts = double(int32(10 * pairwiseCosts));
% 
% GCO_SetDataCost(graphHandle,unaryCostMatrix);
% GCO_SetSmoothCost(graphHandle,smoothnessCost);
% GCO_SetNeighbors(graphHandle, pairwiseCosts);
% GCO_SetLabeling(graphHandle, priorLabels);
% 
% GCO_Expansion(graphHandle);
% fineSegmentationLabels = GCO_GetLabeling(graphHandle);
% 
% % obtain fine segmentation
% fineSegmentation = uint8(zeros(size(observedImage,1),size(observedImage,2)));
% for i = 1:length(fineSegmentationLabels)
%     if (fineSegmentationLabels(i) == 2) %foreground
%         fineSegmentation(superpixelSegments == superpixelSegmentsIndicesVector(i)) = 255;
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--BINARY--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set graph
nbOfNodes = length(superpixelSegmentsIndicesVector);
graphHandle = BK_Create(nbOfNodes);
pairwiseCosts = zeros(nbOfNodes, nbOfNodes);
unaryCostMatrix = zeros(2,nbOfNodes);
smoothnessPenaltyFactor = 0;
blendFactor = 1;

% set unary costs & pairwise costs
for i = 1:length(superpixelSegmentsIndicesVector)
    pixelIndices = find(superpixelSegments == superpixelSegmentsIndicesVector(i));
    
    % set unary cost
    foregroundClassNegativeLogLikelihood = getNegativeLogLikelihood(pixelIndices, observedImage, foregroundNBDistribution);
    backgroundClassNegativeLogLikelihood = getNegativeLogLikelihood(pixelIndices, observedImage, backgroundNBDistribution);
    
    foregroundClassNegativeLogLikelihoodLocation = getNegativeLogLikelihoodLocation(pixelIndices, foregroundProbability);
    
    unaryCostMatrix(1,i) = backgroundClassNegativeLogLikelihood;
    unaryCostMatrix(2,i) = blendFactor * foregroundClassNegativeLogLikelihood + (1-blendFactor)*foregroundClassNegativeLogLikelihoodLocation;
    
    
    
    
    
    
    %     % set unary cost
    %     distanceBetweenSuperpixelAndFGModel = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, objectModel);
    %     distanceBetweenSuperpixelAndBGModel = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, backgroundModel);
    %     unaryCostMatrix(1,i) = 1 - exp(-distanceBetweenSuperpixelAndBGModel.^2 / (2 * distanceVariance));
    %     unaryCostMatrix(2,i) = 1 - exp(-distanceBetweenSuperpixelAndFGModel.^2 / (2 * distanceVariance));
    
    % set pairwise cost
    currentNodeIndex = superpixelSegmentsIndicesVector(i);
    
    currentNodeColIndex = ceil(double(currentNodeIndex) / double(nbOfSuperpixelsInCol));
    currentNodeRowIndex = currentNodeIndex - (currentNodeColIndex -1)*nbOfSuperpixelsInCol;
    
    lowerNeighborNodeIndex = currentNodeIndex + 1;
    nextNeighborNodeIndex = currentNodeColIndex*nbOfSuperpixelsInCol + currentNodeRowIndex;
    
    [~,LNNI] = find(superpixelSegmentsIndicesVector == lowerNeighborNodeIndex);
    [~,NNNI] = find(superpixelSegmentsIndicesVector == nextNeighborNodeIndex);
    
    if(~isempty(LNNI))
        %lowerNeighborNodePixelIndices = find(superpixelSegments == lowerNeighborNodeIndex);
        %lowerNeighborSuperpixelSegmentHistogramVector = calculateHistogramFromVectors(lowerNeighborNodePixelIndices,binsPerEachColor,observedImage);
        
        %neighborCost = getSymmetricKLDivergence(currentSuperpixelSegmentHistogramVector, lowerNeighborSuperpixelSegmentHistogramVector);
        %         neighborCost = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, lowerNeighborSuperpixelSegmentHistogramVector);
        %         neighborCost = exp(-neighborCost.^2 / (2 * distanceVariance));
        %pairwiseCosts(i,LNNI) = (logDivisionByZero - neighborCost);
        
        pairwiseCosts(i,LNNI) = smoothnessPenaltyFactor;
        
        if(pairwiseCosts(i,LNNI) < 0)
            error('Negative pairwise cost obtained..');
        end
        
    end
    
    if(~isempty(NNNI))
        %nextNeighborNodePixelIndices = find(superpixelSegments == nextNeighborNodeIndex);
        %nextNeighborSuperpixelSegmentHistogramVector = calculateHistogramFromVectors(nextNeighborNodePixelIndices,binsPerEachColor,observedImage);
        
        %neighborCost = getSymmetricKLDivergence(currentSuperpixelSegmentHistogramVector, nextNeighborSuperpixelSegmentHistogramVector);
        %         neighborCost = calculateBhattacharyaDistance(currentSuperpixelSegmentHistogramVector, nextNeighborSuperpixelSegmentHistogramVector);
        %         neighborCost = exp(-neighborCost.^2 / (2 * distanceVariance));
        %pairwiseCosts(i,NNNI) = (logDivisionByZero - neighborCost);
        
        pairwiseCosts(i,NNNI) = smoothnessPenaltyFactor;
        
        if(pairwiseCosts(i,NNNI) < 0)
            error('Negative pairwise cost obtained..');
        end
        
    end    
end
    
%pairwiseCosts(pairwiseCosts>0) = 1;
%pairwiseCosts = smoothnessPenaltyFactor * pairwiseCosts;

BK_SetUnary(graphHandle, unaryCostMatrix);
% BK_SetNeighbors(graphHandle, pairwiseCosts);

energyFinal = BK_Minimize(graphHandle);
fineSegmentationLabels = BK_GetLabeling(graphHandle);

% obtain fine segmentation
fineSegmentation = uint8(zeros(size(observedImage,1),size(observedImage,2)));
for i = 1:length(fineSegmentationLabels)
    if (fineSegmentationLabels(i) == 2) %foreground
        fineSegmentation(superpixelSegments == superpixelSegmentsIndicesVector(i)) = 255;
    end
end
    
end