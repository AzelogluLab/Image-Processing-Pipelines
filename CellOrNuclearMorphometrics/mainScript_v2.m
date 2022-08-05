% Used to calculate cell area. Add other morphometric stuff later.


numFiles = length(rawFiles);

% Check if all the images have the same resolution. 
allImagesSameResolution = length(micronsPerPixel) == 1;
if allImagesSameResolution
    micronsPerPixel = repmat(micronsPerPixel,numFiles,1);
else % otherwise, check that that the vector is the right size.
    if length(micronsPerPixel) ~= numFiles
        error(['The number of values for micronsPerPixel is different', ...
            ' than the number of files.'])
    end
end

% Initalize vectors.
sizeToAllocate = 10000;
areasVec = zeros(sizeToAllocate,1);
perimetersVec = zeros(sizeToAllocate,1);
%circVec = zeros(sizeToAllocate,1);
eccentricityVec = zeros(sizeToAllocate,1);
MAL_Vec = zeros(sizeToAllocate,1); % Major Axis Length
MIL_Vec = zeros(sizeToAllocate,1); % Minor Axis Length
solidityVec = zeros(sizeToAllocate,1);
meanIntensityVec = zeros(sizeToAllocate,1);
boundBoxsVec = zeros(sizeToAllocate,4);

currentVecNdx = 1; % This keeps track of the index to allocate things.
for j = 1:numFiles
    thisMask = imread(maskFiles{j});
    thisRaw = imread(rawFiles{j});
    % Remove border cells, and relabel the regions so that they are
    % increasing with no skipped integers.
    top = unique(thisMask(1:edgePixels,:));
    bottom = unique(thisMask(end-edgePixels+1:end,:));
    left = unique(thisMask(:,1:edgePixels));
    right = unique(thisMask(:,end-edgePixels+1:end));
    toRemove = [top; bottom; left; right];
    toRemove = unique(toRemove);
    for removej = 1:length(toRemove)
    thisMask(thisMask==toRemove(removej)) = 0;
    end


    stats = regionprops(thisMask,thisRaw,'Area','Perimeter','Circularity', ...
        'Eccentricity','MajorAxisLength','MinorAxisLength', ...
        'BoundingBox','Solidity','MeanIntensity');
    numCells = length(stats);
    
    stopNdx = currentVecNdx + numCells - 1;

    areasVec(currentVecNdx:stopNdx) = [stats(:).Area]';
    perimetersVec(currentVecNdx:stopNdx) = [stats(:).Perimeter]';
    %circVec(currentVecNdx:stopNdx) = [stats(:).Circularity]';
    eccentricityVec(currentVecNdx:stopNdx) = [stats(:).Eccentricity]';
    MAL_Vec(currentVecNdx:stopNdx) = [stats(:).MajorAxisLength]';
    MIL_Vec(currentVecNdx:stopNdx) = [stats(:).MinorAxisLength]';
    solidityVec(currentVecNdx:stopNdx) = [stats(:).Solidity]';
    meanIntensityVec(currentVecNdx:stopNdx) = [stats(:).MeanIntensity]';

    % Convert from pixels to microns. I am purposefully doing this in two
    % parts, instead of including it in the code above for purposes of
    % debugging. It is easier to work in terms of pixels.
    areasVec(currentVecNdx:stopNdx) = areasVec(currentVecNdx:stopNdx) .* micronsPerPixel(j).^2;
    perimetersVec(currentVecNdx:stopNdx) = perimetersVec(currentVecNdx:stopNdx) .* micronsPerPixel(j);
    MAL_Vec(currentVecNdx:stopNdx) = MAL_Vec(currentVecNdx:stopNdx) .* micronsPerPixel(j);
    MIL_Vec(currentVecNdx:stopNdx) = MIL_Vec(currentVecNdx:stopNdx) .* micronsPerPixel(j);
    

    % Bounding Box assignment is a little bit more involved because it's a
    % 4x1 vector instead of just a scalar. Basically, assign it one column
    % at a time.
    BB = [stats.BoundingBox]';
    for boxj = 1:4
        boundBoxsVec(currentVecNdx:stopNdx,boxj) = BB(boxj:4:end);
    end
    
    currentVecNdx = currentVecNdx + numCells;
end

areasVec(currentVecNdx:end) = [];
perimetersVec(currentVecNdx:end) = [];
%circVec(currentVecNdx:end) = [];
eccentricityVec(currentVecNdx:end) = [];
MAL_Vec(currentVecNdx:end) = [];
MIL_Vec(currentVecNdx:end) = [];
boundBoxsVec(currentVecNdx:end,:) = [];
solidityVec(currentVecNdx:end) = [];
meanIntensityVec(currentVecNdx:end) = [];

% Because regionprops assumes regions will be labelled sequentially with no
% skipped integers, it will give 0s and NaN for skipped numbers. Need to
% remove those.

% In the line below, remember to convert area from microns^2 to pixels^2.
toRemove = isnan(areasVec) | areasVec <= minAreaMicrons;

areasVec(toRemove) = [];
perimetersVec(toRemove) = [];
%circVec(toRemove) = [];
eccentricityVec(toRemove) = [];
MAL_Vec(toRemove) = [];
MIL_Vec(toRemove) = [];
boundBoxsVec(toRemove) = [];
solidityVec(toRemove) = [];
% sometimes calculating perimeter fails and calculates zero.
perimetersVec(perimetersVec == 0) = nan;
circVec = (4.*pi.*areasVec) ./ (perimetersVec.^2);
aspectRatioVec = MAL_Vec ./ MIL_Vec;



