function histogramVector = calculateHistogramFromVectors(indices,binsPerEachColor,image)
histogramVector = zeros(binsPerEachColor,binsPerEachColor,binsPerEachColor);
binResolution = round(256/binsPerEachColor);

separatedRChannel = image(:,:,1);
separatedGChannel = image(:,:,2);
separatedBChannel = image(:,:,3);

redBins = floor(double(separatedRChannel(indices)) / binResolution) + 1;
greenBins = floor(double(separatedGChannel(indices)) / binResolution) + 1;
blueBins = floor(double(separatedBChannel(indices)) / binResolution) + 1;

linearIndices = (blueBins - 1)*binsPerEachColor*binsPerEachColor + ...
    (greenBins - 1)*binsPerEachColor + redBins;

for i = 1:length(linearIndices)
    histogramVector(linearIndices(i)) = histogramVector(linearIndices(i)) + 1;
end

%histogramVector(linearIndices) = histogramVector(linearIndices) + 1;
% for rowIndex = 1:length(rows)
%     for colIndex = 1:length(cols)
%         redBin = floor(image(rows(rowIndex),cols(colIndex),1) / binResolution) + 1;
%         histogramVector(redBin,1) = histogramVector(redBin,1) + 1;
%         greenBin = floor(image(rows(rowIndex),cols(colIndex),2) / binResolution) + 1;
%         histogramVector(greenBin,2) = histogramVector(greenBin,2) + 1;
%         blueBin = floor(image(rows(rowIndex),cols(colIndex),3) / binResolution) + 1;
%         histogramVector(redBin,greenBin,blueBin) = histogramVector(redBin,greenBin,blueBin) + 1;
%     end
% end
histogramVector = histogramVector ./ sum(sum(sum(histogramVector)));
end