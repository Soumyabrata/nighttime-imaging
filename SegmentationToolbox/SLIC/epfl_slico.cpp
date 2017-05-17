#include <math.h>
#include <matrix.h>
#include <mex.h>
#include "SLICO.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    /* Check for proper number of arguments. */
    if (nrhs != 2) {
        mexErrMsgTxt("Two inputs required (image and nb of superpixels).");
    }
    
    if (!mxIsClass(prhs[0], "uint8") || (mxGetNumberOfDimensions(prhs[0]) != 3)){
        mexErrMsgTxt("First input should be a 3D uint8 image");
    }
    
    int mrows, ncols;
    mrows = mxGetM(prhs[1]);
    ncols = mxGetN(prhs[1]);
    if (mxIsComplex(prhs[1]) || !(mrows == 1 && ncols == 1)) {
        mexErrMsgTxt("Second input should be a scalar");
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
            
            //char txt[50];
            //sprintf(txt, "R channel : %d, G channel : %d, B channel : %d", ((unsigned int) imageRGB[i + j*width]) << 16, ((unsigned int) imageRGB[i + j*width + height*width]) << 8, (unsigned int) imageRGB[i + j*width + 2*height*width]);
            //mexWarnMsgTxt(txt);
            image[i + j*width] = ((unsigned int) imageRGB[i + j*width]) * 65536;
            image[i + j*width] = image[i + j*width] + ((unsigned int) imageRGB[i + j*width + height*width]) * 256;
            image[i + j*width] = image[i + j*width] + (unsigned int) imageRGB[i + j*width + 2*height*width];
        }
    }
    
    int nbSuperpixels;
    nbSuperpixels = (int) mxGetScalar(prhs[1]);

	double m = 1000;//Compactness factor. use a value ranging from 10 to 40 depending on your needs. Default is 10
	int* klabels = (int*) mxMalloc(height * width * sizeof(int));
	int numlabels(0);

	SLICO segment;
	segment.PerformSLICO_ForGivenK(image, width, height, klabels, numlabels, nbSuperpixels, m);
    
    unsigned char* c;
    mwSize nd = 2;
    mwSize dimsOut[] = { width, height };
    plhs[0] = mxCreateNumericArray(nd, dimsOut, mxUINT8_CLASS, mxREAL);
    c = (unsigned char*) mxGetData(plhs[0]);
    
    for(int k=0 ; k < height*width ; ++k){
        c[k] = (unsigned char) klabels[k];
    }
	
    mxFree(image);
    mxFree(klabels);

}
