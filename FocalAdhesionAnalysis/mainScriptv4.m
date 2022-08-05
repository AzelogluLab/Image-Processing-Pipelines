% Iterate through the folders.

nFolders = length(folders);
% Initialize variables as cells so that parfor can be used.
numFAsPerCell = cell(nFolders,1);
meanAreaFAsPerCell = cell(nFolders,1);
pctCoverage = cell(nFolders,1);
meanPerimetersPerCell = cell(nFolders,1);
meanFAeccPerCell = cell(nFolders,1);
meanFAminorAxisLengthPerCell = cell(nFolders,1);
meanFAmajorAxisLengthPerCell = cell(nFolders,1);
meanFAaspectRatioPerCell = cell(nFolders,1);
meanFAcircPerCell = cell(nFolders,1);
saveNames = cell(nFolders,1);

for jFolder = 1:nFolders
    thisFolder = folders{jFolder};
    fileList = dir(thisFolder + "\*" + FAmaskSuffix);
    fileList = {fileList(:).name}';
    fileList = string(fileList);
    fileList = thisFolder + "\" + fileList;
    nCells = length(fileList);
    
    % Initializations 
    thisNumFAsPerCell = zeros(nCells,1);
    thisMeanAreaFAsPerCell = zeros(nCells,1);
    thisMeanPerimetersPerCell = zeros(nCells,1);
    thisMeanFAeccPerCell = zeros(nCells,1);
    thisMeanFAminorAxisLengthPerCell = zeros(nCells,1);
    thisMeanFAmajorAxisLengthPerCell = zeros(nCells,1);
    thisMeanFAaspectRatioPerCell = zeros(nCells,1);
    thisMeanFAcircPerCell = zeros(nCells,1);
    thisPctCoverage = zeros(nCells,1);
    thisSaveNames = cell(nCells,1);
    
    

    % This for loop can be run in parallel with parfor.
    parfor jCells = 1:nCells
        % Read in the files
        thisFArawFH = strrep(fileList(jCells),FAmaskSuffix,FArawSuffix);
        thisCellMaskFH = strrep(fileList(jCells),FAmaskSuffix,cellMaskSuffix);
        thisFAmask = imread(fileList(jCells));
        thisFAraw = imread(thisFArawFH);
        thisCellMask = imread(thisCellMaskFH);

        % We only care about focal adhesions within the cell. Use cell mask
        % to remove regions outside the cell.
        outsideCell = thisCellMask <1;
        thisFAraw(outsideCell) = 0;
        thisFAmask(outsideCell) = 0;
        % Create an overlayed segmentation 
        A = imadjust(thisFAraw);
        C = labeloverlay(A,thisFAmask,'Transparency',.8);
        thisBWperim = bwperim(thisCellMask);
        thisBWperim = imdilate(thisBWperim,strel('disk',1));
        C = labeloverlay(C,thisBWperim,'Colormap',[1 0 0]);
        overlayFH = strrep(fileList(jCells),FAmaskSuffix,"_final.png");
        imshow(C)
        saveas(gcf,overlayFH)

        % Calculate region properties
        stats = regionprops(thisFAmask,'Area','Perimeter','Eccentricity','MajorAxisLength','MinorAxisLength');
        areas = [stats(:).Area]';
        perimeters = [stats(:).Perimeter]';
        ecc = [stats(:).Eccentricity]';
        majorAxisLen = [stats(:).MajorAxisLength]';
        minorAxisLen = [stats(:).MinorAxisLength]';

        toRemove = isnan(areas) | areas == 0 | perimeters == 0;
        areas(toRemove) = [];
        perimeters(toRemove) = [];
        ecc(toRemove) = [];
        majorAxisLen(toRemove) = [];
        minorAxisLen(toRemove) = [];

        thisCirc = (4.*pi.*areas) ./ (perimeters.^2);
        thisAR = majorAxisLen ./ minorAxisLen;
        thisCellMaskEroded = imerode(thisCellMask,strel('disk',amountDilated));
        thisFAmaskBinary = thisFAmask;
        thisFAmaskBinary(thisFAmask>=1) = 1;

        thisNumFAsPerCell(jCells) = length(areas);
        thisMeanAreaFAsPerCell(jCells) = mean(areas);
        thisPctCoverage(jCells) = 100*(sum(single(thisFAmaskBinary(:))) ./ sum(single(thisCellMaskEroded(:)))) ;
        thisSaveNames{jCells} = overlayFH;
        thisMeanPerimetersPerCell(jCells) = mean(perimeters);
        thisMeanFAeccPerCell(jCells) = mean(ecc);
        thisMeanFAminorAxisLengthPerCell(jCells) = mean(minorAxisLen);
        thisMeanFAmajorAxisLengthPerCell(jCells) = mean(majorAxisLen);
        thisMeanFAaspectRatioPerCell(jCells) = mean(thisAR);
        thisMeanFAcircPerCell(jCells) = mean(thisCirc);
    end
    numFAsPerCell{jFolder} = thisNumFAsPerCell;
    meanAreaFAsPerCell{jFolder} = thisMeanAreaFAsPerCell;
    pctCoverage{jFolder} = thisPctCoverage;
    saveNames{jFolder} = thisSaveNames;
    meanPerimetersPerCell{jFolder} = thisMeanPerimetersPerCell;
    meanFAeccPerCell{jFolder} = thisMeanFAeccPerCell;
    meanFAminorAxisLengthPerCell{jFolder} = thisMeanFAminorAxisLengthPerCell;
    meanFAmajorAxisLengthPerCell{jFolder} = thisMeanFAmajorAxisLengthPerCell;
    meanFAaspectRatioPerCell{jFolder} = thisMeanFAaspectRatioPerCell;
    meanFAcircPerCell{jFolder} = thisMeanFAcircPerCell;
end
numFAsPerCell = vertcat(numFAsPerCell{:});
meanAreaFAsPerCell = vertcat(meanAreaFAsPerCell{:});
pctCoverage = vertcat(pctCoverage{:});
meanPerimetersPerCell = vertcat(meanPerimetersPerCell{:});
meanFAeccPerCell = vertcat(meanFAeccPerCell{:});
meanFAminorAxisLengthPerCell = vertcat(meanFAminorAxisLengthPerCell{:});
meanFAmajorAxisLengthPerCell = vertcat(meanFAmajorAxisLengthPerCell{:});
meanFAaspectRatioPerCell = vertcat(meanFAaspectRatioPerCell{:});
meanFAcircPerCell = vertcat(meanFAcircPerCell{:});
saveNames = vertcat(saveNames{:});
saveNames = vertcat(saveNames{:});

meanAreaFAsPerCell = meanAreaFAsPerCell .* micronsPerPixel^2;
meanPerimetersPerCell = meanPerimetersPerCell .* micronsPerPixel;
meanFAminorAxisLengthPerCell = meanFAminorAxisLengthPerCell .* micronsPerPixel;
meanFAmajorAxisLengthPerCell = meanFAmajorAxisLengthPerCell .* micronsPerPixel;
