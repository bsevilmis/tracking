
function [predictedState, predictedProposal, predictedProposalModel, predictedBackgroundProposal] = estimateState(objectModel, weights, propagatedParticles, observedImage, proposalsPath, currentFrameNumber, numberOfFrames, binsPerEachColor)
predictedState = propagatedParticles*weights;

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

%proposalsFolder = dir([proposalsPath '/frame' num2str(currentFrameNumber)]);

% obtain state information from particle
topLeftX = predictedState(1);
topLeftY = predictedState(2);
width = predictedState(5)*predictedState(7);
height = predictedState(6)*predictedState(7);
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


regionInclusionEpsilon = 0.1;

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
        if(distanceBetweenProposalAndModel < bestDistance)
            bestDistance = distanceBetweenProposalAndModel;
            bestDistanceProposalPathName = [proposalsFolderCell{m} '/' num2str(currentIndexArrayCell(j)) currentProposalExtension];
        end
    end
end
predictedProposal = imread(bestDistanceProposalPathName);
pixelIndices = find(predictedProposal);
predictedProposalModel = calculateHistogramFromVectors(pixelIndices,binsPerEachColor,observedImage);

% obtain background proposal
se = strel('disk',7);
predictedBackgroundProposal = ~imdilate(predictedProposal, se);
mask = false(size(observedImage,1),size(observedImage,2));
mask(topLeftY:bottomRightY, topLeftX:bottomRightX) = true;
predictedBackgroundProposal = predictedBackgroundProposal .* mask;
%backgroundPixelIndices = find(predictedBackgroundProposal(topLeftY:bottomRightY,topLeftX:bottomRightX));
%predictedBackgroundProposalModel = calculateHistogramFromVectors(backgroundPixelIndices,binsPerEachColor,observedImage);


% numberOfProposals = length(proposalsFolder)-2;
% jaccardIndexArray = zeros(numberOfProposals,1);
% for j = 1:numberOfProposals
%     currentProposal = imread([proposalsPath '/frame' num2str(currentFrameNumber) '/' proposalsFolder(j+2).name]);
%     intersection = nnz(currentProposal(topLeftY:bottomRightY,topLeftX:bottomRightX));
%     union = (bottomRightY - topLeftY + 1)*(bottomRightX - topLeftX + 1) + nnz(currentProposal) - intersection;
%     jaccardIndexArray(j) = intersection / union;
% end
% [~, index] = max(jaccardIndexArray);
% predictedProposal = imread([proposalsPath '/frame' num2str(currentFrameNumber) '/' proposalsFolder(index+2).name]);
% pixelIndices = find(predictedProposal);
% predictedProposalModel = calculateHistogramFromVectors(pixelIndices,binsPerEachColor,observedImage);
end