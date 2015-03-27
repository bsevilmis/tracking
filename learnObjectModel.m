function [objectModel, objectInitialState] = learnObjectModel(gt, binsPerEachColor, initialFrameImage)
stats = regionprops(gt, 'BoundingBox');
boundingBox = stats.BoundingBox;
topX = boundingBox(1);
topY = boundingBox(2);
width = boundingBox(3);
height = boundingBox(4);
velocityX = 0;
velocityY = 0;
scale = 1;
objectInitialState = [round(topX);round(topY);velocityX;velocityY;...
    width;height;scale];
pixelIndices = find(gt);
objectModel = calculateHistogramFromVectors(pixelIndices,binsPerEachColor, initialFrameImage);
end