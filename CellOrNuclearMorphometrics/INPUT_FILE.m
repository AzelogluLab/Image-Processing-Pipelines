% JH, July 28, 2022
clear
clc
close all

rawFiles = {"F:\PKD\Cysts_2022_July\6_8_22\CRE5_Factin.tif"
"F:\PKD\Cysts_2022_July\6_8_22\CRE6_Factin.tif"
"F:\PKD\Cysts_2022_July\6_8_22\CRE7_Factin.tif"
"F:\PKD\Cysts_2022_July\6_8_22\CRE8_Factin.tif"
"F:\PKD\Cysts_2022_July\6_8_22\CRE1_Factin.tif"
"F:\PKD\Cysts_2022_July\6_8_22\CRE2_Factin.tif"
"F:\PKD\Cysts_2022_July\6_8_22\CRE3_Factin.tif"
"F:\PKD\Cysts_2022_July\6_8_22\CRE4_Factin.tif"};
maskFiles = {"F:\PKD\Cysts_2022_July\6_8_22\CRE5_Factin_cp_masks.png"
"F:\PKD\Cysts_2022_July\6_8_22\CRE6_Factin_cp_masks.png"
"F:\PKD\Cysts_2022_July\6_8_22\CRE7_Factin_cp_masks.png"
"F:\PKD\Cysts_2022_July\6_8_22\CRE8_Factin_cp_masks.png"
"F:\PKD\Cysts_2022_July\6_8_22\CRE1_Factin_cp_masks.png"
"F:\PKD\Cysts_2022_July\6_8_22\CRE2_Factin_cp_masks.png"
"F:\PKD\Cysts_2022_July\6_8_22\CRE3_Factin_cp_masks.png"
"F:\PKD\Cysts_2022_July\6_8_22\CRE4_Factin_cp_masks.png"};


% Don't want to include cells at edge. For merged images, sometimes cells
% will be touching the boundary in their frame, but NOT in the overall
% merged image.
edgePixels = 0;
minAreaMicrons = 0;

% Can either be a single value OR a vector of values.
micronsPerPixel = [141.70/512
    141.70/512
    607.28/512
    607.28/512
    607.28/512
    607.28/512
    607.28/512
    607.28/512];


addpath 'C:\Users\MrBes\Documents\MATLAB\ImageProcessingPipelines\CellArea'
mainScript_v2
save('F:\PKD\Cysts_2022_July\CRE_6_8_22.mat','areasVec','perimetersVec', ...
    'circVec','eccentricityVec','MAL_Vec','MIL_Vec','micronsPerPixel', ...
    'solidityVec', 'aspectRatioVec')
