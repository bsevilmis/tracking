% This script evaluates best Hoiem object proposals compared to a given GT
% segmentation.
% Author: Berk Sevilmis, Feb 21, 2015

% set tracking videos path
trackingVideoImagesDirectory = '/home/berksevilmis/Desktop/Research/SegTrackv2/JPEGImages/';
trackingVideoImagesFolder = dir(trackingVideoImagesDirectory);
trackingVideoGTDirectory = '/home/berksevilmis/Desktop/Research/SegTrackv2/GroundTruth/';
trackingVideoGTFolder = dir(trackingVideoGTDirectory);

% set proposals directory
proposalsDirectory = '/home/berksevilmis/workspace/trackingProject/Dataset/SegTrackv2/HoiemProposals/';

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
                
                videoProposalsDirectory = [proposalsDirectory trackingVideoGTFolder(i).name '/frame' num2str(j-2) '/'];
                videoProposalsFolder = dir(videoProposalsDirectory);
                jaccardIndexArray = zeros(length(videoProposalsFolder)-2,1);
                xorIndexArray = zeros(length(videoProposalsFolder)-2,1);
                for s = 3:length(videoProposalsFolder)
                    proposal = logical(imread([videoProposalsDirectory videoProposalsFolder(s).name]));
                    intersectionOverUnion = nnz(gt & proposal) / nnz(gt | proposal);
                    jaccardIndexArray(s-2) = intersectionOverUnion;
                    xorIndexArray(s-2) = nnz(xor(gt,proposal));
                end
                
                [value, index] = max(jaccardIndexArray);
                perFramePixelError(videoIndex) = perFramePixelError(videoIndex) + xorIndexArray(index);
            end
            perFramePixelError(videoIndex) = perFramePixelError(videoIndex) / (length(currentVideoGTFolder) - 2);
        end
    end
end

perFramePixelError