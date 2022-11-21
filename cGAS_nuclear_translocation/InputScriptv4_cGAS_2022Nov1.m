clear
clc
close all

% Folder containing all raw and segmented channels
folders = {
"F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\WT"};
% All files should have the same base name.
cGASrawSuffix = "_cGAS.png";
cellMaskSuffix = "_merge_cp_masks.png";
nuclearMaskSuffix = "_nucleus_cp_masks.png";

% The output will include nuclear to cytoplasmic ratio as well as nuclear
% to perinuclear.

SE = strel('disk',15);





addpath 'C:\Users\MrBes\Documents\MATLAB\ImageProcessingPipelines\cGAS'
tic
mainScriptv4
toc
curDate = datetime;
save('F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\WT',...
    'meanCytoIntensity','meanNuclearIntensity','meanPeriNuclearIntensity',...
    'nucToCyto','nucToPerinuc', ...
    'curDate');

%%
folders = {
"F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\WT_mitoQ"};
tic
mainScriptv4
toc
curDate = datetime;
save('F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\WT_mitoQ',...
    'meanCytoIntensity','meanNuclearIntensity','meanPeriNuclearIntensity',...
    'nucToCyto','nucToPerinuc', ...
    'curDate');
%%

folders = {
"F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\PKD1_mitoQ"};
tic
mainScriptv4
toc
curDate = datetime;
save('F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\PKD1_mitoQ',...
    'meanCytoIntensity','meanNuclearIntensity','meanPeriNuclearIntensity',...
    'nucToCyto','nucToPerinuc', ...
    'curDate');
%%
folders = {
"F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\PKD1"};
tic
mainScriptv4
toc
curDate = datetime;
save('F:\PKD\WT CRE-mitoQ day3-cGAS cy3-091622\PKD1',...
    'meanCytoIntensity','meanNuclearIntensity','meanPeriNuclearIntensity',...
    'nucToCyto','nucToPerinuc', ...
    'curDate');

%%

