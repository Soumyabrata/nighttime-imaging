% Selection of color channels for efficient nighttime cloud segmentation

clear all; clc; 
addpath(genpath('./scripts/'));

% For nighttime dataset
Files=dir('./nighttime/UNDISTORTED/*.jpg');
Files_GT=dir('./nighttime/GT/*.jpg');



IDX_array=[];   ind_array=[];   Z_array=[];

for t=1:length(Files)    
    
    FileNames=Files(t).name;

    disp (['Calculating for image = ',FileNames]);
    
    % For nighttime   
    I=imread(['./nighttime/UNDISTORTED/' FileNames]);

   
    % For nighttime
    GroundTruthName=FileNames;
    ind=length(GroundTruthName)-3:1:length(GroundTruthName);
    GroundTruthName(ind)=[];
    GroundTruthName=strcat(GroundTruthName,'-GT.jpg');
    GroundTruth=imread(['./nighttime/GT/' GroundTruthName]);
    I_GT=double(GroundTruth);


    
    [color_ch]=color16_struct(I);

    QAZ=cat(2,color_ch.c1(:),color_ch.c2(:),color_ch.c3(:),color_ch.c4(:),color_ch.c5(:),color_ch.c6(:),color_ch.c7(:),color_ch.c8(:),color_ch.c9(:),color_ch.c10(:),color_ch.c11(:),color_ch.c12(:),color_ch.c13(:),color_ch.c14(:),color_ch.c15(:),color_ch.c16(:));

    I_GT(I_GT<129)=0;
    I_GT(I_GT>128)=1;
    GH=I_GT(:);

    if (length(unique(GH(:)))==2)
        [IDX,Z] = rankfeatures(QAZ',GH','NumberOfIndices',16,'Criterion','roc');
        [~,ind]=sort(IDX);
    else
        IDX=[];
        Z=[];
        ind=[];
    end
    
    IDX_array=cat(2,IDX_array,IDX);
    ind_array=cat(2,ind_array,ind);
    Z_array=cat(2,Z_array,Z);

end

ind_m=mean(ind_array,2);

Z_m=mean(Z_array,2);

[~,final_rank2]=sort(Z_m)

%%

figure('Position', [400, 250, 450, 260]);
bar(Z_m,0.5);
Labels={'c_{1}','c_{2}','c_{3}','c_{4}','c_{5}','c_{6}','c_{7}','c_{8}','c_{9}','c_{10}','c_{11}','c_{12}','c_{13}','c_{14}','c_{15}','c_{16}'};
set(gca, 'XTick', 1:16, 'XTickLabel', []); %// no ticklabels
set(gca,'fontsize',12);
ylabel('Area under ROC curve','FontSize',12)
axis([0 17 0.2 0.5])
xlabelpoints = (1:numel(Z_m))-0.2;
text(xlabelpoints, 0.2-.02*ones(1,numel(Z_m)), Labels, 'interpreter', 'TeX');
grid on ;
%%


