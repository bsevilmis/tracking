function backgroundModel = learnBackgroundModel(backgroundGT, objectInitialState, binsPerEachColor, initialFrameImage)
topLeftX = objectInitialState(1);
topLeftY = objectInitialState(2);
width = objectInitialState(5)*objectInitialState(7);
height = objectInitialState(6)*objectInitialState(7);
bottomRightX = topLeftX + width - 1;
bottomRightY = topLeftY + height - 1;
pixelIndices = find(backgroundGT(topLeftY:bottomRightY,topLeftX:bottomRightX));
backgroundModel = calculateHistogramFromVectors(pixelIndices, binsPerEachColor, initialFrameImage);
end