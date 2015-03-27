% This script expands proposal sets for a given video sequence using
% optical flow
% Author: Berk Sevilmis, Mar 14, 2015

% add recursive path
addpath(genpath('/home/berksevilmis/Documents/PapersWithCodes/HoiemProposalsECCV2010/proposals'));
addpath(genpath('/home/berksevilmis/Desktop/Research/analysis'));

%set imwarp alias
originalimwarp = str2func('imwarp');

% set output directory
outputDirectory = '/home/berksevilmis/workspace/trackingProject/Dataset/SegTrackv2/HoiemProposals/';

% set dataset path
trackingVideoImagesDirectory = '/home/berksevilmis/Desktop/Research/SegTrackv2/JPEGImages/';
trackingVideoImagesFolder = dir(trackingVideoImagesDirectory);

% set subset of videos(others have more than 1 object of interest)
% subsetVideos = {'birdfall','bird_of_paradise','frog','girl',...
%     'parachute','monkey','worm','soldier'};
subsetVideos = {'girl'};

% generate object proposals
for i = 3:length(trackingVideoImagesFolder)
    if(~isempty(find(strcmp(subsetVideos,trackingVideoImagesFolder(i).name))))
        
        if(isdir([trackingVideoImagesDirectory trackingVideoImagesFolder(i).name]))
            newDirectoryName = [outputDirectory trackingVideoImagesFolder(i).name];
            currentVideoImagesDirectory = [trackingVideoImagesDirectory trackingVideoImagesFolder(i).name];
            currentVideoImagesFolder = dir(currentVideoImagesDirectory);
            for j = 3:length(currentVideoImagesFolder)
                image = imread([currentVideoImagesDirectory '/' currentVideoImagesFolder(j).name]);

                %estimate forward flow interface
                masks = dir([newDirectoryName '/frame' num2str(j-2)]);
                if(j ~= length(currentVideoImagesFolder))
                    newFolderName2 = [newDirectoryName '/frame' num2str(j-2) 'to' num2str(j-1)];
                    mkdir(newFolderName2);
                    nextImage = imread([currentVideoImagesDirectory '/' currentVideoImagesFolder(j+1).name]);
                    uv = estimate_flow_interface(image, nextImage, 'classic+nl-fast');
                    for m = 3:length(masks)
                        warpedSegment = originalimwarp(...
                            imread([newDirectoryName '/frame' num2str(j-2) '/' masks(m).name]),-uv(:,:,1),-uv(:,:,2),true);
                        warpedSegment = logical(warpedSegment >= 0.5);
                        imwrite(warpedSegment,[newFolderName2 '/' masks(m).name]);
                    end
                end
                
                %estimate backward flow interface
                if(j ~= length(currentVideoImagesFolder))
                    masks = dir([newDirectoryName '/frame' num2str(j-1)]);
                    newFolderName2 = [newDirectoryName '/frame' num2str(j-1) 'to' num2str(j-2)];
                    mkdir(newFolderName2);
                    nextImage = imread([currentVideoImagesDirectory '/' currentVideoImagesFolder(j+1).name]);
                    uv = estimate_flow_interface(nextImage, image, 'classic+nl-fast');
                    for m = 3:length(masks)
                        warpedSegment = originalimwarp(...
                            imread([newDirectoryName '/frame' num2str(j-1) '/' masks(m).name]),-uv(:,:,1),-uv(:,:,2),true);
                        warpedSegment = logical(warpedSegment >= 0.5);
                        imwrite(warpedSegment,[newFolderName2 '/' masks(m).name]);
                    end
                end
            end
        end
    end
end
    

