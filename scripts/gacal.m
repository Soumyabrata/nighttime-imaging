function [binary_image]=gacal(input_image)

   
   
   
   I_gray = rgb2gray(input_image);
   I_gray = double(I_gray);
   
   binary_image=I_gray;
   binary_image(binary_image<17)=0;
   binary_image(binary_image==17)=0;
   binary_image(binary_image>17)=1;
   
  
   %figure; imshow(binary_image);   
   

end