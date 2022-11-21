% Iterate through the folders.

nFolders = length(folders);
% Initialize variables as cells so that parfor can be used.


meanCytoIntensity = [];
meanNuclearIntensity = [];
meanPeriNuclearIntensity = [];

saveNames = cell(nFolders,1);

for jFolder = 1:nFolders
    thisFolder = folders{jFolder};
    fileList = dir(thisFolder + "\*" + cellMaskSuffix);
    fileList = {fileList(:).name}';
    fileList = string(fileList);
    fileList = thisFolder + "\" + fileList;
    nFiles = length(fileList);


    for jFiles = 1:nFiles
        % String manipulations. I use uniform file names and suffixes for
        % different images : raw, mask, channnels.
        thisRaw = strrep(fileList(jFiles),cellMaskSuffix,cGASrawSuffix);
        thisRaw = imread(thisRaw);
        thisCellMask = imread(fileList(jFiles));
        thisNuclearMask = strrep(fileList(jFiles),cellMaskSuffix,nuclearMaskSuffix);
        thisNuclearMask = imread(thisNuclearMask);
        
        uniqueCellIds = unique(thisCellMask(:));
        uniqueCellIds(uniqueCellIds == 0) = []; % remove background id
        nCells = length(uniqueCellIds);


        % This for loop can be run in parallel with parfor.
        for jCells = 1:nCells
            % Iterate through each segmented cell.  
            thisCellId = uniqueCellIds(jCells);
            thisRegionMask = (thisCellMask == thisCellId);
            % do calculations on a small ROI to save memory.
            colsMask = find(max(thisRegionMask)); % find column mask first appears
            ndx1 = min(colsMask);
            ndx2 = max(colsMask);
            rowsMask = find(max(thisRegionMask'));
            ndx3 = min(rowsMask);
            ndx4 = max(rowsMask);
            thisRegionMask = thisCellMask(ndx3:ndx4,ndx1:ndx2);
            mask = thisRegionMask ~= thisCellId; % this is a mask for areas outside the current area of interest
            thisRegionMask(mask) = 0;
            thisRegionMask = logical(thisRegionMask);
            thisRegionNuclearMask = thisNuclearMask(ndx3:ndx4,ndx1:ndx2);
            thisRegionNuclearMask(mask) = 0;
            thisRegionNuclearMask = logical(thisRegionNuclearMask);
            thisRegionRaw = thisRaw(ndx3:ndx4,ndx1:ndx2);
            periNucMask = imdilate(thisRegionNuclearMask,SE);
            
            justCytoMask = logical(thisRegionMask - thisRegionNuclearMask);
            justPeriMask = logical(periNucMask - thisRegionNuclearMask - ~thisRegionMask);
            nucVals = thisRegionRaw(thisRegionNuclearMask);
            cytoVals = thisRegionRaw(justCytoMask);
            periNucVals = thisRegionRaw(justPeriMask);
            nucVals = single(nucVals);
            cytoVals = single(cytoVals);
            periNucVals = single(periNucVals);

            meanCytoIntensity = [mean(cytoVals); meanCytoIntensity];
            meanNuclearIntensity = [mean(nucVals); meanNuclearIntensity];
            meanPeriNuclearIntensity = [mean(periNucVals); meanPeriNuclearIntensity];

            if mean(nucVals) < 400
                3;
            end
    
        end
    end
end


nucToCyto = meanNuclearIntensity ./ meanCytoIntensity;
nucToPerinuc = meanNuclearIntensity ./ meanPeriNuclearIntensity;
toRemove = isnan(nucToCyto);

nucToCyto(toRemove) = [];
nucToPerinuc(toRemove) =[];
meanCytoIntensity(toRemove) =[];
meanNuclearIntensity(toRemove) =[];
meanPeriNuclearIntensity(toRemove) = [];