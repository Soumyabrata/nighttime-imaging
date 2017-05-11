function [binary_image]=global_th_novi(input_ratio)
% This approach is Otsu's threshold approach.
% Yang et al. 2009 approach
   

   RB = input_ratio;
   
   level = graythresh(RB);
   BW = im2bw(uint8(RB),level);

   binary_image=double(BW);

end