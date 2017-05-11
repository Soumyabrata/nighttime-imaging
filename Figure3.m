% Calculating coverage values for a few sample images of the dataset.
clear all; clc;

I1 = double(imread('./images/GT/a2016-07-08-01-44-03-wahrsis3-undist-GT.jpg'));
count_zero1 = sum(I1(:) == 0);
cov_percentage1 = 100 - (count_zero1/(500*500))*100;
disp(['Coverage [in %] = ',num2str(cov_percentage1)]);


I2 = double(imread('./images/GT/b2016-09-27-03-10-04-wahrsis3-undist-GT.jpg'));
count_zero2 = sum(I2(:) == 0);
cov_percentage2 = 100 - (count_zero2/(500*500))*100;
disp(['Coverage [in %] = ',num2str(cov_percentage2)]);


I3 = double(imread('./images/GT/c2016-05-10-03-16-04-wahrsis3-undist-GT.jpg'));
count_zero3 = sum(I3(:) == 0);
cov_percentage3 = 100 - (count_zero3/(500*500))*100;
disp(['Coverage [in %] = ',num2str(cov_percentage3)]);


I4 = double(imread('./images/GT/d2016-03-25-03-38-03-wahrsis3-undist-GT.jpg'));
count_zero4 = sum(I4(:) == 0);
cov_percentage4 = 100 - (count_zero4/(500*500))*100;
disp(['Coverage [in %] = ',num2str(cov_percentage4)]);


