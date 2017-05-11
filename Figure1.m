% Demonstration of proposed segmentation approach.

clear all; clc;

addpath(genpath('./SegmentationToolbox/'));
addpath(genpath('./scripts/'));

I = imread('./images/undist/2016-05-10-02-02-04-wahrsis3-undist.jpg');
figure('Position', [400, 250, 200, 200]);
imshow(I);

[color_ch]=color16Norm(I);
inputRatio = color_ch.c14;
figure('Position', [400, 250, 200, 200]);
imshow(uint8(inputRatio));

[quantBlock, binary_image]=createSPImage(inputRatio);

figure('Position', [400, 250, 200, 200]);
imshow(uint8(quantBlock));


figure('Position', [400, 250, 200, 200]);
imshow(binary_image);