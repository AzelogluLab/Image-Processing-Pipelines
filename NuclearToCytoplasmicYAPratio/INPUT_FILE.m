clear
clc
close all

rawYAP_Files = {"ch01.tif"};
nuclearMaskFiles = {"ch00_MASK_.png"};
cellMaskFiles = {"BLUR10PIXEL_MASK_.png"};
% Don't want to include cells at edge. For merged images, sometimes cells
% will be touching the boundary in their frame, but NOT in the overall
% merged image.
edgePixels = 40;

micronsPerPixel = 849.65/9429;

mainScript

save('example.mat','ratioYAP_vec')

