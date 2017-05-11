function [binary_image]=SPS_novi(input_ratio)
% This function implements the Liu et al. superpixel segentation paper in Geoscience letters.

    addpath(genpath('/home/soumya/Dropbox/MATLAB/SegmentationToolbox/'));
    
    % Implementing the Liu et al. superpixel segmentation paper.
    

    RB = input_ratio ;

    level = graythresh(RB);
    Tg=level*255;

    W_max=max(RB(:));   W_min=min(RB(:));
    % -------------------------------------

 
    %imageName='168img';
    %image = uint8(I);
    %image=imread('B1.jpg');
    
    image = cat(3,uint8(RB),uint8(RB),uint8(RB));

    % Initial setup
    dispBorders = true;
    dispLabels = true;
    divideBy = 20;   % This is the parameter used in Lie et al.
    compactness = 10;
    applyLabelChange = false;
    selectedLabel = 1;

    initSegm = NaN;



    handles.computation = currentComputation(image, divideBy, compactness, ...
    dispBorders, dispLabels, applyLabelChange, selectedLabel, initSegm, '');

  
    SP_labels=double(handles.computation.segmentations);
    [rows,cols]=size(SP_labels);

    SP_labels_st=SP_labels(:);

    
  
    RB_st=RB(:);
    local_thresh=cell(1,1+max(SP_labels_st));

    for t=0:max(SP_labels_st)
        ind=find(SP_labels_st==t);
        RB_array=RB_st(ind,:);
        level = graythresh(uint8(RB_array));

        s_l=min(RB_array)+level*(max(RB_array)-min(RB_array));

        l_min=min(RB_array);
        l_max=max(RB_array);

        if l_max<Tg
           T_l=l_max;

        elseif (l_min<Tg)
            T_l=l_min;

        else
            T_l=(s_l)/2 + (Tg)/2 ;

        end

        local_thresh{1,t+1}=T_l;


    end

    thresh_map1=SP_labels;
    neg_value=repmat(max(SP_labels_st),rows,cols);

    thresh_map2=thresh_map1-neg_value;

    for t=0:max(SP_labels_st)
        
        thresh_map2(thresh_map2==(t-max(SP_labels_st)))=local_thresh{1,1+t};

    end

    %figure; imshowpair(image,thresh_map2,'montage');
    threshold_matrix=thresh_map2;
    %figure; imshow(uint8(threshold_matrix))

    diff_image=thresh_map2-RB;
    binary_image=diff_image;

    binary_image(binary_image<0)=-99999;
    binary_image(binary_image==0)=-99999;
    binary_image(binary_image>0)=0;
    binary_image(binary_image==(-99999))=1;
    %figure; imshow(binary_image);

    figure; imshowpair(image,binary_image,'montage');
    
    %[precision,recall,fscore, error] = score(binary_image,I_GT);

    %%

end