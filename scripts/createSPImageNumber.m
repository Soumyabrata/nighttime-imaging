%I = imread('./images/2016-11-20-20-24-03-wahrsis3.jpg');
%inputRatio = I(:,:,1);


function [quantBlock, binary_image]=createSPImageNumber(inputRatio,noOfSups)
 
   inputSLIC = cat(3,inputRatio,inputRatio,inputRatio);  

    %-------------
    % Initial setup
    dispBorders = true;
    dispLabels = true;
    divideBy = noOfSups;
    compactness = 10;
    applyLabelChange = false;
    selectedLabel = 1;
    initSegm = NaN;

    % This is correct!
    handles.computation = currentComputation(uint8(inputSLIC), divideBy, compactness, ...
    dispBorders, dispLabels, applyLabelChange, selectedLabel, initSegm, '');  
    %-------------
    
    
    
    SP_labels=double(handles.computation.segmentations);
    
    [rows,cols]=size(SP_labels);    
    SP_labels_st=SP_labels(:);
    inputRatio_st = inputRatio(:);
    

    X_feature=cell(1,1+max(SP_labels_st));    
    

    for t=0:max(SP_labels_st)
        
        ind=find(SP_labels_st==t);        
        X_array=double(inputRatio_st(ind,:));
        X_feature{1,1+t}=mean(X_array);
       
    end

    X_matrix = cell2mat(X_feature(:)); 
    
    
    quantBlock=zeros(rows,cols);
    for i=1:rows
       for j=1:cols
           quantBlock(i,j)= X_matrix(SP_labels(i,j)+1,1);           
       end        
    end
    
    %figure; imshow(uint8(showasImage(quantBlock)));    
    %figure; imshowpair(uint8(I),uint8(showasImage(quantBlock)),'montage');
    %imwrite(uint8(showasImage(BR_block)),'./BR_block.png');
    
    
    

    % K-means clustering
    idx = kmeans(X_matrix,2);    
    binary_image=SP_labels;

    for t=0:max(SP_labels_st)
        binary_image(binary_image==t)=idx(1+t,1);

    end
    




    % For c15 channel.
    mean1=mean(X_matrix(idx==1,1));
    mean2=mean(X_matrix(idx==2,1)); 
    
   if mean1 < mean2   % For "some" color channel.
        binary_image(binary_image==1)=0;
        binary_image(binary_image==2)=1;
    else
        binary_image(binary_image==2)=0;

   end   
    
    
   %figure; imshowpair(uint8(I),uint8(binary_image),'montage');

    
    

end