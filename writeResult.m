function [] = writeResult(predictedProposal, observedImage, predictedState, frameNumber, resultsPath, foregroundProbability, predictedBackgroundProposal)
    %copy observedImage
    observedImageCopy = observedImage;
    
    imwrite(predictedProposal, [resultsPath '/' num2str(frameNumber) '.png']);
    topLeftY = predictedState(2);
    topLeftX = predictedState(1);
    width = predictedState(5)*predictedState(7);
    height = predictedState(6)*predictedState(7);
    %left edge
    observedImage(round(topLeftY):round(topLeftY + height-1),...
        round(topLeftX),1) = 0;
    observedImage(round(topLeftY):round(topLeftY + height-1),...
        round(topLeftX),2) = 255;
    observedImage(round(topLeftY):round(topLeftY + height-1),...
        round(topLeftX),3) = 0;
    %right edge
    observedImage(round(topLeftY):round(topLeftY + height-1),...
        round(topLeftX + width - 1),1) = 0;
    observedImage(round(topLeftY):round(topLeftY + height-1),...
        round(topLeftX + width - 1),2) = 255;
    observedImage(round(topLeftY):round(topLeftY + height-1),...
        round(topLeftX + width - 1),3) = 0;
    %upper edge
    observedImage(round(topLeftY),round(topLeftX):...
        round(topLeftX + width - 1),1) = 0;
    observedImage(round(topLeftY),round(topLeftX):...
        round(topLeftX + width - 1),2) = 255;
    observedImage(round(topLeftY),round(topLeftX):...
        round(topLeftX + width - 1),3) = 0;
    %lower edge
    observedImage(round(topLeftY + height - 1),round(topLeftX):...
        round(topLeftX + width - 1),1) = 0;
    observedImage(round(topLeftY + height - 1),round(topLeftX):...
        round(topLeftX + width - 1),2) = 255;
    observedImage(round(topLeftY + height - 1),round(topLeftX):...
        round(topLeftX + width - 1),3) = 0;
    imwrite(observedImage, [resultsPath '/' num2str(frameNumber) 'R.png']);
    
    %write segmented image
    B = bwboundaries(predictedProposal);
    for k = 1:length(B)
        boundary = B{k};
        linearIndices = sub2ind(size(predictedProposal),boundary(:,1),boundary(:,2));
        
        observedImageCopyRChannel = observedImageCopy(:,:,1);
        observedImageCopyGChannel = observedImageCopy(:,:,2);
        observedImageCopyBChannel = observedImageCopy(:,:,3);
        
        observedImageCopyRChannel(linearIndices) = 255;
        observedImageCopyGChannel(linearIndices) = 0;
        observedImageCopyBChannel(linearIndices) = 0;
        
        observedImageCopy(:,:,1) = observedImageCopyRChannel;
        observedImageCopy(:,:,2) = observedImageCopyGChannel;
        observedImageCopy(:,:,3) = observedImageCopyBChannel;
        
        imwrite(observedImageCopy, [resultsPath '/' num2str(frameNumber) 'S.png']);
    end
    
    % write foreground probability
    if(~isempty(foregroundProbability))
        imwrite(imadjust(uint16(65535*foregroundProbability)), [resultsPath '/' num2str(frameNumber) 'Prob.png']);
    end
    % write background proposals model
    if(~isempty(predictedBackgroundProposal))
        imwrite(predictedBackgroundProposal, [resultsPath '/' num2str(frameNumber) 'BR.png']);
    end
    
end