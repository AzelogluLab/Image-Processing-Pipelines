clear
clc
close all

% Folder containing all raw and segmented channels
folders = {

};
% All files should have the same base name.
FArawSuffix = "_chan2.tif";
FAmaskSuffix = "_chan2_cp_masks.png";
cellSuffix = ".tif";
cellMaskSuffix = "_mask.png";


% If the cell mask was dilated, it will need to be eroded for coverage pct.
% calculation. Assumes structuring element is a disk.
amountDilated = 10;

% Sometimes bright regions on the PA channel will get segmented together.
% Set a limit on the maximum allowable FA size to remove segmentations that
% are obviously not a FA.
maxFA = 500000; %pixels^2

% Sometimes segmentation goes very wrong. Set a max coverage
maxCoverage = 60; % percent

% If you are using cell masks to get per cell information, you can set a
% minimum cell area to remove very small cells.
minCellArea = 500;



micronsPerPixel = .206;
addpath 'C:\Users\MrBes\Documents\MATLAB\ImageProcessingPipelines\FocalAdhesionAnalysis'
tic
mainScriptv4
toc

save('KOE_May13.mat','meanAreaFAsPerCell','numFAsPerCell','pctCoverage','saveNames','meanPerimetersPerCell', ...
    'meanFAeccPerCell','meanFAminorAxisLengthPerCell', ...
    'meanFAmajorAxisLengthPerCell','meanFAaspectRatioPerCell','meanFAcircPerCell');