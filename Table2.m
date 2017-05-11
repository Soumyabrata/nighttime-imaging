% Performance evaluation of different benchmarking algorithms.
clear all; clc;

addpath(genpath('./SegmentationToolbox/'));
addpath(genpath('./scripts/'));

% For nighttime dataset
Files=dir('./nighttime/UNDISTORTED/*.jpg');



fileID = fopen(['./results/Liu2015-','c14','.txt'],'a');
%fileID = fopen(['./results/proposed-','c14','.txt'],'a');%
%fileID = fopen(['./results/Yang2010-','c14','.txt'],'a');
%fileID = fopen(['./results/Yang2009-','c14','.txt'],'a');
%fileID = fopen(['./results/gacal-','gray','.txt'],'a');

p_array = [];
r_array = [];
fs_array = [];
e_array = [];

fprintf(fileID,'FileNames \t Precision \t Recall \t F-Score \t Error \n');

for kot=1:length(Files)
%for kot=1:1

    FileNames=Files(kot).name;
    
    % For nighttime   
    I=imread(['./nighttime/UNDISTORTED/' FileNames]);

   
    % For nighttime
    GroundTruthName=FileNames;
    ind=length(GroundTruthName)-3:1:length(GroundTruthName);
    GroundTruthName(ind)=[];
    GroundTruthName=strcat(GroundTruthName,'-GT.jpg');
    GroundTruth=imread(['./nighttime/GT/' GroundTruthName]);
    I_GT=double(GroundTruth);
        
    
    [color_ch]=color16Norm(I);
    inputRatio = color_ch.c14;
    
    
 
    
    % SPS (Liu et al. 2015 approach)
    [binary_image]=SPS_novi(inputRatio);      
    
    
    % nightSLIC approach
    %[quantBlock, binary_image]=createSPImage(inputRatio);   
    
    
    % Local threshold (Yang et al. 2010 approach).
    %[binary_image]=local_th_novi(I);    
    
    
    % Global threshold (Yang et al. 2009 approach).
    %[binary_image]=global_th_novi(inputRatio);    
    
    
    % Gacal et al. 2016 approach
    %[binary_image]=gacal(I);    
    
    
    
    % Evaluation of binary image    
    [precision,recall,fscore, error] = score(binary_image,GroundTruth)   
        
    fprintf(fileID,'%s \t %f \t %f \t %f \t %f \n',FileNames,precision, recall, fscore,error);
    
    p_array=cat(1,p_array,precision);
    r_array=cat(1,r_array,recall);
    fs_array=cat(1,fs_array,fscore);
    e_array=cat(1,e_array,error);
    
    
    
    %%%figure; imshowpair(uint8(I),uint8(binary_image),'montage');
    %%%figure; imshowpair(uint8(I),uint8(showasImage(quantBlock)),'montage'); 
    close all;
    
end

disp ('Testing done');

Precision=nanmean(p_array)
Recall=nanmean(r_array)
FScore=nanmean(fs_array)
Error=nanmean(e_array)

disp(['Average error = ',num2str(Error)]);


% Closing the TXT file.
fclose(fileID);
        