function [weights, foregroundProbability] = updateWeights(propagatedParticles, objectModel, distanceVariance, binsPerEachColor, observedImage, proposalsPath, currentFrameNumber, numberOfFrames)

if(currentFrameNumber < numberOfFrames)
    proposalsFolderCell = cell(3,1);
    indexArrayCells = cell(3,1);
    proposalsFolderCell{1} = [proposalsPath '/frame' num2str(currentFrameNumber)]; 
    proposalsFolderCell{2} = [proposalsPath '/frame' ...
        num2str(currentFrameNumber-1) 'to' num2str(currentFrameNumber)];
    proposalsFolderCell{3} = [proposalsPath '/frame' ...
        num2str(currentFrameNumber+1) 'to' num2str(currentFrameNumber)];
elseif(currentFrameNumber == numberOfFrames)
    proposalsFolderCell = cell(2,1);
    indexArrayCells = cell(2,1);
    proposalsFolderCell{1} = [proposalsPath '/frame' num2str(currentFrameNumber)]; 
    proposalsFolderCell{2} = [proposalsPath '/frame' ...
        num2str(currentFrameNumber-1) 'to' num2str(currentFrameNumber)];
end

weights = zeros(size(propagatedParticles,2),1);
foregroundProbability = ones(size(observedImage,1),size(observedImage,2));

for i = 1:size(propagatedParticles,2)
    
    currentParticle = propagatedParticles(:,i);
   
    % obtain state information from particle
    topLeftX = currentParticle(1);
    topLeftY = currentParticle(2);
    width = currentParticle(5)*currentParticle(7);
    height = currentParticle(6)*currentParticle(7);
    bottomRightX = topLeftX + width - 1;
    bottomRightY = topLeftY + height - 1;
        
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
    
    
%     topLeftX
%     topLeftY
%     width
%     height
%     bottomRightX
%     bottomRightY
    
    regionInclusionEpsilon = 0;

    for m = 1:length(proposalsFolderCell)
        numberOfProposals = length(dir(proposalsFolderCell{m}))-2;
        indexArrayCells{m} = [];
        currentProposalsDirectory = dir(proposalsFolderCell{m}); 
        for j = 1:numberOfProposals
            currentProposalName = currentProposalsDirectory(j+2).name;
            currentProposalExtension = currentProposalName(end-3:end);
            currentProposalNumber = currentProposalName(1:end-4);
            currentProposal = imread([proposalsFolderCell{m} '/' currentProposalName]);
            intersection = nnz(currentProposal(topLeftY:bottomRightY,topLeftX:bottomRightX));
            if ((double(intersection) / double(nnz(currentProposal))) >= (1-regionInclusionEpsilon))
                indexArrayCells{m} = [indexArrayCells{m} str2num(currentProposalNumber)];
            end
        end        
    end
    
    bestDistance = Inf;
    for m = 1:length(indexArrayCells)
        currentIndexArrayCell = indexArrayCells{m};
        for j = 1:length(currentIndexArrayCell)
            currentProposal = imread([proposalsFolderCell{m} '/' num2str(currentIndexArrayCell(j)) currentProposalExtension]);
            pixelIndices = find(currentProposal);
            currentProposalHistogramVector = ...
                calculateHistogramFromVectors(pixelIndices,binsPerEachColor,observedImage);
             distanceBetweenProposalAndModel = calculateBhattacharyaDistance(currentProposalHistogramVector, objectModel);
             tempWeight = (1/sqrt(2*pi*distanceVariance)) * exp(-distanceBetweenProposalAndModel.^2 / (2 * distanceVariance));
             foregroundProbability = foregroundProbability + tempWeight * double(currentProposal);
             if(distanceBetweenProposalAndModel < bestDistance)
                 bestDistance = distanceBetweenProposalAndModel;
                 bestDistanceProposalPathName = [proposalsFolderCell{m} '/' num2str(currentIndexArrayCell(j)) currentProposalExtension];
             end
        end
    end
    weights(i) = (1/sqrt(2*pi*distanceVariance)) * exp(-bestDistance.^2 / (2 * distanceVariance));
    %foregroundProbability = foregroundProbability + weights(i) * double(imread(bestDistanceProposalPathName));
    disp(['Particle: ' num2str(i) ' ..done']);
          
%     numberOfProposals = length(proposalsFolder)-2;
%     jaccardIndexArray = zeros(numberOfProposals,1);
%     for j = 1:numberOfProposals
%         currentProposal = imread([proposalsPath '/frame' num2str(currentFrameNumber) '/' proposalsFolder(j+2).name]);
%         intersection = nnz(currentProposal(topLeftY:bottomRightY,topLeftX:bottomRightX));
%         union = (bottomRightY - topLeftY + 1)*(bottomRightX - topLeftX + 1) + nnz(currentProposal) - intersection;
%         jaccardIndexArray(j) = intersection / union;
%     end
%     [~, index] = max(jaccardIndexArray);
%     bestProposal = imread([proposalsPath '/frame' num2str(currentFrameNumber) '/' proposalsFolder(index+2).name]);

%     figure(1), imshow(observedImage),rectangle('Position',[topLeftX topLeftY round(width) round(height)],'EdgeColor',[0.0,1,0.0]); 
%     waitforbuttonpress
%     figure(2), imshow(imread(bestDistanceProposalPathName));
%     waitforbuttonpress
%     close all;
    
%     pixelIndices = find(bestProposal);
%     bestProposalHistogramVector = calculateHistogramFromVectors(pixelIndices,binsPerEachColor,observedImage);
%     distanceBetweenProposalAndModel = calculateBhattacharyaDistance(bestProposalHistogramVector, objectModel);
%     weights(i) = (1/sqrt(2*pi*distanceVariance)) * exp(-distanceBetweenProposalAndModel.^2 / (2 * distanceVariance));
end
weights = weights ./ sum(weights);
foregroundProbability = foregroundProbability ./ sum(sum(foregroundProbability));
end