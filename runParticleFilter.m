% This script implements particle filter on Hoiem proposals and tries to
% pick best proposal.
% Author: Berk Sevilmis, Feb 21, 2015
% state = [x y velocityX velocityY width height scale]

function bestProposalIndices = runParticleFilter(firstFrameGTImage, framesPath, proposalsPath, resultsPath)

%VLFeat setup
run('~/Desktop/Research/vlfeat-0.9.19/toolbox/vl_setup');

% add recursive path
addpath(genpath('/home/berksevilmis/workspace/trackingProject/Bk_matlab'));
BK_LoadLib;

% add recursive path
% addpath(genpath('/home/berksevilmis/workspace/trackingProject/gco-v3.0'));
% GCO_LoadLib;


% obtain frames folder
framesFolder = dir(framesPath);

% obtain logical ground truth image
if (nnz(size(firstFrameGTImage)) == 3)
    gt = rgb2gray(firstFrameGTImage);
end
gt = (gt >= 128);

%%%%%% particle filter parameters %%%%%%%%
N = 50;
binsPerEachColor = 4;
distanceVariance = 0.1;
stateUpdateNoiseVariances = [5;5;10;10;1;1;0.001]; %[5;5;10;10;1;1;0.005];
objectModelUpdateParameter = 0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% learn object model
initialFrameImage = imread([framesPath '/' framesFolder(3).name]);
[objectModel,objectInitialState] = learnObjectModel(gt, binsPerEachColor, initialFrameImage);
writeResult(gt, initialFrameImage, objectInitialState, 1,resultsPath, [],[]);
generationVariances = stateUpdateNoiseVariances;
particles = generateParticles(objectInitialState, N, generationVariances);

% read images
numberOfFrames = length(framesFolder)-2;
locationPriorsCell = cell(numberOfFrames,1);
predictedProposalsCell = cell(numberOfFrames,1);
predictedBackgroundProposalsCell = cell(numberOfFrames,1);
foregroundProbabilityCell = cell(numberOfFrames,1);
for frameNumber = 2:numberOfFrames
    % obtain observation
    observedImage = imread([framesPath '/' framesFolder(2+frameNumber).name]);
    % propagate particles
    propagatedParticles = updateStateModelOfParticles(particles, stateUpdateNoiseVariances);
    % update weights
    [weights, foregroundProbability] = updateWeights(propagatedParticles, objectModel, distanceVariance, binsPerEachColor, observedImage, proposalsPath, frameNumber, numberOfFrames);
    % obtain state estimation
    [predictedState, predictedProposal, predictedProposalModel, predictedBackgroundProposal] = estimateState(objectModel, weights, propagatedParticles,observedImage, proposalsPath, frameNumber, numberOfFrames, binsPerEachColor);
    % keep location priors and predicted proposals
    locationPriorsCell{frameNumber} = predictedState;
    predictedProposalsCell{frameNumber} = predictedProposal;
    predictedBackgroundProposalsCell{frameNumber} = predictedBackgroundProposal;
    foregroundProbabilityCell{frameNumber} = foregroundProbability;
    % write result
    writeResult(predictedProposal, observedImage, predictedState, frameNumber, resultsPath,foregroundProbability,predictedBackgroundProposal);
    % update object model
    objectModel = updateObjectModel(objectModel, predictedProposalModel, objectModelUpdateParameter);
    % update background model
    %backgroundModel = updateObjectModel(backgroundModel, predictedBackgroundProposalModel, objectModelUpdateParameter);
    % resample particles
    particles = resampleParticles(weights, propagatedParticles);
    disp(['Frame: ' num2str(frameNumber) ' done..']);
end

% learn naive bayesian color distribution with Dirichlet prior
load('./Results/SegTrackv2/HoiemResults/girlv3/currentWorkspace.mat')
foregroundNBDistribution = ones(1,256,3);
backgroundNBDistribution = ones(1,256,3);
for frameNumber = 2:numberOfFrames
    % obtain observation
    observedImage = imread([framesPath '/' framesFolder(2+frameNumber).name]);
    % update distribution
    foregroundNBDistribution = updateNBDistribution(foregroundNBDistribution, observedImage, predictedProposalsCell{frameNumber});
    backgroundNBDistribution = updateNBDistribution(backgroundNBDistribution, observedImage, predictedBackgroundProposalsCell{frameNumber});
end
foregroundNBDistribution = foregroundNBDistribution ./sum(sum(sum(foregroundNBDistribution)));
backgroundNBDistribution = backgroundNBDistribution ./sum(sum(sum(backgroundNBDistribution)));

% fine resegmentation
nbOfSuperPixels = 750;
for frameNumber = 2:numberOfFrames
    % obtain observation
    observedImage = imread([framesPath '/' framesFolder(2+frameNumber).name]);
    observedImageLab = vl_xyz2lab(vl_rgb2xyz(observedImage));
    superpixelSegments = vl_slic(single(observedImageLab),sqrt((size(observedImageLab,1)*size(observedImageLab,2))/nbOfSuperPixels),1000);
    superpixelSegments = superpixelSegments + 1; %make sure indexing starts from 1
    nbOfSuperpixelsInCol = max(superpixelSegments(:,1)); 
    nbOfSuperpixelsInRow = max(max(superpixelSegments)) / nbOfSuperpixelsInCol;
    % obtain location prior and predicted proposal
    locationPrior = locationPriorsCell{frameNumber};
    predictedProposal = predictedProposalsCell{frameNumber};
    foregroundProbability = foregroundProbabilityCell{frameNumber};
    % obtain graph cut based segmentation
    fineSegmentation = refineSegmentation(observedImage, superpixelSegments,locationPrior,...
        foregroundNBDistribution,backgroundNBDistribution, nbOfSuperpixelsInCol,foregroundProbability);
    imwrite(fineSegmentation, [resultsPath '/' num2str(frameNumber) 'GCResult.png']);
    
    perim = true(size(observedImage,1), size(observedImage,2));
    for k = 1 : max(superpixelSegments(:))
        regionK = superpixelSegments == k;
        perimK = bwperim(regionK, 8);
        perim(perimK) = false;
    end
    
    perim = uint8(cat(3,perim,perim,perim));
    finalImage = observedImage .* perim;
    imwrite(finalImage, [resultsPath '/' num2str(frameNumber) 'SPResult.png']);
%     
%     figure(1), imshow(finalImage);
%     waitforbuttonpress
%     close all;

end
end



















  



