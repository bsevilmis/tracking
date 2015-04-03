function [spSegmentation, spFeatures] = extractSuperPixelFeatures(frameNumber, observedImage, spFeatures, nbOfSuperPixels, locationPrior, binsPerEachColor,foregroundProbability)

observedImageLab = vl_xyz2lab(vl_rgb2xyz(observedImage));
superpixelSegments = vl_slic(single(observedImageLab),sqrt((size(observedImageLab,1)*size(observedImageLab,2))/nbOfSuperPixels),1000);
superpixelSegments = superpixelSegments + 1; %make sure indexing starts from 1




perim = true(size(observedImage,1), size(observedImage,2));
for k = 1 : max(superpixelSegments(:))
    regionK = superpixelSegments == k;
    perimK = bwperim(regionK, 8);
    perim(perimK) = false;
end

perim = uint8(cat(3,perim,perim,perim));
spSegmentation = observedImage .* perim;






nbOfSuperpixelsInCol = max(superpixelSegments(:,1));
nbOfSuperpixelsInRow = max(max(superpixelSegments)) / nbOfSuperpixelsInCol;


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


% obtain 8bit LAB image
imageLAB8Bit = (observedImageLab - min(min(min(observedImageLab)))) ./...
    (max(max(max(observedImageLab))) - min(min(min(observedImageLab))));
imageLAB8Bit = uint8(imageLAB8Bit.*255);

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

% extract features
for i = 1:length(superpixelSegmentsIndicesVector)
    [rowIndices,colIndices] = find(superpixelSegments == superpixelSegmentsIndicesVector(i));
    pixelIndices = sub2ind([size(observedImage,1),size(observedImage,2)],rowIndices,colIndices);
    superpixelHistogramRGB = calculateHistogramFromVectors(pixelIndices,binsPerEachColor,observedImage);
    superpixelHistogramLAB = calculateHistogramFromVectors(pixelIndices,binsPerEachColor,imageLAB8Bit);
    [meanX,meanY] = getSuperpixelCenter(rowIndices,colIndices);
    meanForegroundProbability = getMeanForegroundProbability(pixelIndices, foregroundProbability);
    % save features
    sp.frameNumber = frameNumber;
    sp.spNumber = superpixelSegmentsIndicesVector(i);
    sp.histogramRGB = superpixelHistogramRGB;
    sp.histogramLAB = superpixelHistogramLAB;
    sp.relativeCoordinates = [ (meanX - topLeftX) / (bottomRightX - topLeftX) (meanY - topLeftY) / (bottomRightY - topLeftY)];
    sp.fgProbability = meanForegroundProbability;
    sp.meanCoordinates = [meanY meanX];
    spFeatures = [spFeatures;sp];
end
end

function [meanX,meanY] = getSuperpixelCenter(rowIndices,colIndices)
    meanY = mean(rowIndices);
    meanX = mean(colIndices);
end

function meanForegroundProbability = getMeanForegroundProbability(pixelIndices, foregroundProbability)
    meanForegroundProbability = mean(foregroundProbability(pixelIndices));
end