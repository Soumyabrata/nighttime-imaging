#include <math.h>
#include <matrix.h>
#include <mex.h>
#include "SLIC.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    /* Check for proper number of arguments. */
    if (nrhs != 3) {
        mexErrMsgTxt("Three inputs required (image, regionSize and regularizer).");
    }
    
    if (!mxIsClass(prhs[0], "uint8") || (mxGetNumberOfDimensions(prhs[0]) != 3)){
        mexErrMsgTxt("First input should be a 3D uint8 image");
    }
    
    int mrows1, ncols1;
    mrows1 = mxGetM(prhs[1]);
    ncols1 = mxGetN(prhs[1]);
    if (mxIsComplex(prhs[1]) || !(mrows1 == 1 && ncols1 == 1)) {
        mexErrMsgTxt("Second input should be a scalar");
    }
    
    int mrows2, ncols2;
    mrows2 = mxGetM(prhs[2]);
    ncols2 = mxGetN(prhs[2]);
    if (mxIsComplex(prhs[2]) || !(mrows2 == 1 && ncols2 == 1)) {
        mexErrMsgTxt("Third input should be a scalar");
    }
    
	int width(0), height(0);

	//figure out dimensions
	const mwSize *dims;
  	dims = mxGetDimensions(prhs[0]);
    
 	width = (int)dims[0]; height = (int)dims[1];

	unsigned char* imageRGB;
	imageRGB = (unsigned char*) mxGetData(prhs[0]);
    unsigned int* image = (unsigned int*) mxMalloc(height * width * sizeof(unsigned int));
    
    // Translate to the correct format
    for(int i = 0 ; i < width ; i++){
        for(int j = 0 ; j < height ; j++){
            
            image[i + j*width] = ((unsigned int) imageRGB[i + j*width]) * 65536;
            image[i + j*width] = image[i + j*width] + ((unsigned int) imageRGB[i + j*width + height*width]) * 256;
            image[i + j*width] = image[i + j*width] + (unsigned int) imageRGB[i + j*width + 2*height*width];
            
        }
    }
    
    int regionSize;
    regionSize = (int) mxGetScalar(prhs[1]);
    //char txt1[50];
    //sprintf(txt1, "regionSize : %d", regionSize);
    //mexWarnMsgTxt(txt1);
    
    double regularizer;
    regularizer = mxGetScalar(prhs[2]);
    //char txt2[50];
    //sprintf(txt2, "regularizer : %f", regularizer);
    //mexWarnMsgTxt(txt2);

	//double m = 1000;//Compactness factor. use a value ranging from 10 to 40 depending on your needs. Default is 10
	int* klabels = (int*) mxMalloc(height * width * sizeof(int));
	int numlabels(0);

	SLIC segment;
    //segment.DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels(image, 
    //        width, height, klabels, numlabels, nbSuperpixels, regularizer);
    segment.DoSuperpixelSegmentation_ForGivenSuperpixelSize(image, 
            width, height, klabels, numlabels, regionSize, regularizer);
    
    unsigned char* c;
    mwSize nd = 2;
    mwSize dimsOut[] = { width, height };
    plhs[0] = mxCreateNumericArray(nd, dimsOut, mxUINT8_CLASS, mxREAL);
    c = (unsigned char*) mxGetData(plhs[0]);
    
    for(int k=0 ; k < height*width ; ++k){
        c[k] = (unsigned char) klabels[k];
    }
	
    if(image) mxFree(image);
    if(klabels) mxFree(klabels);

}
