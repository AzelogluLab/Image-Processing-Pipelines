% Used to calculate nuclear to cytoplasmic YAP ratios. Note, that this will
% consider only cells with ONE nucleus.
tic
numFiles = length(rawYAP_Files);

% Initalize vectors.
sizeToAllocate = 10000;
ratioYAP_vec = zeros(sizeToAllocate,1);


currentVecNdx = 1; % This keeps track of the index to allocate things.
for j = 1:numFiles
    thisCellMask = imread(cellMaskFiles{j});
    thisNuclearMask = imread(nuclearMaskFiles{j});
    thisRawYAP = imread(rawYAP_Files{j});
    % Remove border cells, and relabel the regions so that they are
    % increasing with no skipped integers.
    % Remove from cell masks
    top = unique(thisCellMask(1:edgePixels,:));
    bottom = unique(thisCellMask(end-edgePixels+1:end,:));
    left = unique(thisCellMask(:,1:edgePixels));
    right = unique(thisCellMask(:,end-edgePixels+1:end));
    toRemove = [top; bottom; left; right];
    toRemove = unique(toRemove);
    for removej = 1:length(toRemove)
        thisCellMask(thisCellMask==toRemove(removej)) = 0;
    end
    % Remove from nuclear masks
    top = unique(thisNuclearMask(1:edgePixels,:));
    bottom = unique(thisNuclearMask(end-edgePixels+1:end,:));
    left = unique(thisNuclearMask(:,1:edgePixels));
    right = unique(thisNuclearMask(:,end-edgePixels+1:end));
    toRemove = [top; bottom; left; right];
    toRemove = unique(toRemove);
    for removej = 1:length(toRemove)
        thisNuclearMask(thisNuclearMask==toRemove(removej)) = 0;
    end

    % In order to speed up the computation of this script, I am going to
    % find the boundingbox of every region so that later calculations can
    % be done on a small subregion of the image, rather than the entire
    % image itself. For large merged images with sizes 10kx10k, this
    % drastically reduces run time + memory requirements.
    
    stats = regionprops(thisCellMask,thisCellMask,'BoundingBox','MeanIntensity');
    % Note here that the computed MeanIntensity will actually be the region
    % ID.
    BB = [stats.BoundingBox]';
    boundingBoxCellID = [stats.MeanIntensity]';

    boundBoxsVec = zeros(length(boundingBoxCellID),4);
    for boxj = 1:4
        boundBoxsVec(:,boxj) = BB(boxj:4:end);
    end

    % Iterate over cell masks.
    cellIDs = unique(thisCellMask);
    cellIDs(find(cellIDs==0)) = []; % Remove ID of 0. This is background.
    numCells = length(cellIDs);
    for cellj = 1:numCells
        % Find the index in the boundBoxsVec corresponding to the
        % boundingbox for the cell region in this current iteration.
        ndxBoundingBox = find(boundingBoxCellID == cellIDs(cellj));
        ndx1 = floor(boundBoxsVec(ndxBoundingBox,2));
        ndx2 = floor(boundBoxsVec(ndxBoundingBox,1));
        ndx3 = ndx1 + ceil(boundBoxsVec(ndxBoundingBox,4));
        ndx4 = ndx2 + ceil(boundBoxsVec(ndxBoundingBox,3));
        thisCellMaskSubRegion = thisCellMask(ndx1:ndx3,ndx2:ndx4);
        thisNuclearMaskSubRegion = thisNuclearMask(ndx1:ndx3,ndx2:ndx4);

        singleCellMask = thisCellMaskSubRegion == cellIDs(cellj);
        allNucIDsInCell = thisNuclearMaskSubRegion(singleCellMask);
        nucIDsInCell = unique(allNucIDsInCell);
        bgNdx = find(nucIDsInCell==0);
        if ~isempty(bgNdx)
            % if this is not empty, there is bg in the id list
            nucIDsInCell(bgNdx) = [];
        end

        % Check that there is ONE nucleus in the cell
        if length(nucIDsInCell) > 1
            % See if they are just small parts of nucleus. IE, if area <
            % say 25 pixels, just remove it.
            areas = zeros(length(nucIDsInCell),1);
            for jNucs = 1:length(nucIDsInCell)
                thisNucID = nucIDsInCell(jNucs);
                areas(jNucs) = sum(allNucIDsInCell == thisNucID);
            end
            % Remove these small nuclei from being considered in the
            % cytoplasm, as they will skew the results.
            nucNdxToRemove = [];
            for jAreas = 1:length(areas)
                if areas(jAreas) < 20*20
                    nucNdxToRemove = [nucNdxToRemove; jAreas];
                    singleCellMask = singleCellMask & ~(thisNuclearMaskSubRegion==nucIDsInCell(jAreas));
                end

            end
            nucIDsInCell(nucNdxToRemove) = [];

        end
        if length(nucIDsInCell) == 1
            singleNucMask = thisNuclearMaskSubRegion == nucIDsInCell;
            singleCellMask = singleCellMask & ~(thisNuclearMaskSubRegion==nucIDsInCell);
            thisRawYAP_subRegion = thisRawYAP(ndx1:ndx3,ndx2:ndx4);
            nucYAP = mean(thisRawYAP_subRegion(singleNucMask));
            cytoYAP = mean(thisRawYAP_subRegion(singleCellMask));
            ratioYAP_vec(currentVecNdx) = nucYAP ./ cytoYAP;
            currentVecNdx = currentVecNdx + 1;
        end
    end

end

ratioYAP_vec(currentVecNdx:end) = [];

toRemove = isnan(ratioYAP_vec) | ratioYAP_vec == 0 | isinf(ratioYAP_vec);
ratioYAP_vec(toRemove) = [];
toc

