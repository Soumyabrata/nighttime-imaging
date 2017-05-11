function [binary_image]=local_th_novi(input_image)
% Image is divided into 16 sub-images. And Otsu threshold is applied on
% each of the sub-image.
% Yang et al. 2010 approach
   

   
   
   I=input_image;


   red=I(:,:,1);   green=I(:,:,2); blue=I(:,:,3);
   rb=red-blue;
   RB=showasImageNovi(rb);
   
   
   [rows,cols]=size(RB);
   
   
   rect_specs=cell(4,4);
   
   for i=1:4
      for j=1:4
         
          if (i==4)&&(j~=4)
              rect_specs{i,j}=[0+(i-1)*(floor(cols/4)),0+(j-1)*(floor(rows/4)),cols-3*floor(cols/4),floor(rows/4)];
          elseif (i~=4)&&(j==4)
              rect_specs{i,j}=[0+(i-1)*(floor(cols/4)),0+(j-1)*(floor(rows/4)),floor(cols/4),rows-3*floor(rows/4)];
          elseif (i==4)&&(j==4)
              rect_specs{i,j}=[0+(i-1)*(floor(cols/4)),0+(j-1)*(floor(rows/4)),cols-3*floor(cols/4),rows-3*floor(rows/4)];
          else
              
              rect_specs{i,j}=[0+(i-1)*(floor(cols/4)),0+(j-1)*(floor(rows/4)),floor(cols/4),floor(rows/4)];
          
          end
      end   
   end
   
    thresh_cell=cell(4,4);
    
    for p=1:4
      for q=1:4
         
          
          I_grid=imcrop(I,rect_specs{q,p});
          
          red=I_grid(:,:,1);   green=I_grid(:,:,2); blue=I_grid(:,:,3);
            
          rb=red./blue;
          RB=showasImageNovi(rb);          
          
          level = graythresh(RB);
          BW = im2bw(uint8(RB),level);
          
          thresh_cell{p,q}=double(BW);
          
      end
       
   end  
   
 
   A = cell2mat(thresh_cell);  
   B=imcrop(A,[0,0,cols,rows]);
   %figure; imshow(B);   
   
   
  
   %[precision,recall,fscore, error] = score(double(B),I_GT);
   

   

   binary_image=double(B);

end