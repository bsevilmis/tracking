% This script evaluates results compared to a given GT
% segmentation.
% Author: Berk Sevilmis, Feb 22, 2015

% set tracking videos path
trackingVideoImagesDirectory = '/home/berksevilmis/Desktop/Research/SegTrackv2/JPEGImages/';
trackingVideoImagesFolder = dir(trackingVideoImagesDirectory);
trackingVideoGTDirectory = '/home/berksevilmis/Desktop/Research/SegTrackv2/GroundTruth/';
trackingVideoGTFolder = dir(trackingVideoGTDirectory);

% set results directory
resultsDirectory = '/home/berksevilmis/workspace/trackingProject/Results/SegTrackv2/HoiemResults/';

% set subset of videos
subsetVideos = {'girl'};
perFramePixelError = zeros(length(subsetVideos),1);
videoIndex = 0;

% evaluate proposals
for i = 3:length(trackingVideoGTFolder)
    if(~isempty(find(strcmp(subsetVideos,trackingVideoGTFolder(i).name))))
        if(isdir([trackingVideoGTDirectory trackingVideoGTFolder(i).name]))
            videoIndex = videoIndex + 1;
            currentVideoGTDirectory = [trackingVideoGTDirectory trackingVideoGTFolder(i).name];
            currentVideoGTFolder = dir(currentVideoGTDirectory);
            for j = 3:length(currentVideoGTFolder)
                gt = imread([currentVideoGTDirectory '/' currentVideoGTFolder(j).name]);
                if( nnz(size(gt)) == 3 )
                    gt = rgb2gray(gt);
                end
                gt = (gt >= 128);
                
                resultImage = imread([resultsDirectory trackingVideoGTFolder(i).name '/' num2str(j-2) '.png']);
                xorValue = nnz(xor(gt,resultImage));
                
                perFramePixelError(videoIndex) = perFramePixelError(videoIndex) + xorValue;
            end
            perFramePixelError(videoIndex) = perFramePixelError(videoIndex) / (length(currentVideoGTFolder) - 2);
        end
    end
end

perFramePixelError