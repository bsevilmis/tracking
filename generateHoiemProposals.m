% This script generates Hoiem object proposals for a given video sequence
% Author: Berk Sevilmis, Feb 21, 2015

% add recursive path
addpath(genpath('/home/berksevilmis/Documents/PapersWithCodes/HoiemProposalsECCV2010/proposals'));

% set output directory
outputDirectory = '/home/berksevilmis/workspace/trackingProject/Dataset/SegTrackv2/HoiemProposals/';

% set dataset path
trackingVideoImagesDirectory = '/home/berksevilmis/Desktop/Research/SegTrackv2/JPEGImages/';
trackingVideoImagesFolder = dir(trackingVideoImagesDirectory);

% set subset of videos(others have more than 1 object of interest)
% subsetVideos = {'birdfall','bird_of_paradise','frog','girl',...
%     'parachute','monkey','worm','soldier'};
subsetVideos = {'disk'};

% generate object proposals
for i = 3:length(trackingVideoImagesFolder)
    if(~isempty(find(strcmp(subsetVideos,trackingVideoImagesFolder(i).name))))
        
        if(isdir([trackingVideoImagesDirectory trackingVideoImagesFolder(i).name]))
            newDirectoryName = [outputDirectory trackingVideoImagesFolder(i).name];
            if(exist(newDirectoryName,'file') ~= 7)
                mkdir(newDirectoryName);
                currentVideoImagesDirectory = [trackingVideoImagesDirectory trackingVideoImagesFolder(i).name];
                currentVideoImagesFolder = dir(currentVideoImagesDirectory);
                for j = 3:length(currentVideoImagesFolder)
                    image = imread([currentVideoImagesDirectory '/' currentVideoImagesFolder(j).name]);
                    
                    %run Hoiem on image
                    [proposals, superpixels] = generate_proposals([currentVideoImagesDirectory '/' currentVideoImagesFolder(j).name]);
                    masks1 = logical(zeros(size(image,1),size(image,2),length(proposals)));
                    for t = 1:length(proposals)
                        currentProposal = proposals{t};
                        masks1(:,:,t) = logical(ismember(superpixels,currentProposal));
                    end
                        
                    %write region
                    newFolderName = [newDirectoryName '/frame' num2str(j-2)];
                    mkdir(newFolderName);
                    for m = 1:size(masks1,3)
                        imwrite(masks1(:,:,m),[newFolderName '/' num2str(m) '.png']); 
                    end
                end
            end
        end
    
    
    end
    
end
