# Nighttime sky/cloud image segmentation

With the spirit of reproducible research, this repository contains all the codes required to produce the results in the manuscript: S. Dev, F. M. Savoy, Y. H. Lee and S. Winkler, Nighttime sky/cloud image segmentation, *Proc. IEEE International Conference on Image Processing (ICIP)*, 2017. 

Please cite the above paper if you intend to use whole/part of the code. This code is only for academic and research purposes.

## Code Organization
The codes are written in python and MATLAB.

### Dataset
The nighttime image segmentation dataset can be downloaded from [this](http://vintage.winklerbros.net/swinseg.html) link. A few sample images can be found in the folder `./images`.

### Core functionality
* `color16Norm.m` Generates the 16 color channels in the form of a MATLAB struct. All values are normalized.
* `color16_struct.m` Generates the 16 color channels in the form of a MATLAB struct.
* `createSPImage.m` Generates the quantised- and binary- image of our proposed method.
* `createSPImageNumber.m` Generates the quantised- and binary- image of our proposed method, based on the number of superpixels.
* `gacal.m` Implements the Gacal approach.
* `global_th_novi.m` Implements the Yang et al. 2009 approach
* `internal_calibration.py` Implements the internal calibration of our sky camera.
* `local_th_novi.m` Implements the Yang et al. 2010 approach.
* `RGBPlane.m` Extracts the red-, green-, blue- plane of an input image.
* `score.m` Calculates precision, recall, fscore and error of a binary output image.
* `showasImageNovi.m` Normalizes the image to a range [0,255].
* `SPS_novi.m` Implements the Liu et al. approach.
* `undistort_WAHRSIS_imgs.py` Undistorts our sky camera images; needed during the creation of the dataset.

### Superpixel function
The various functions required in SLIC superpixel segmentation can be found in the folder `./SegmentationToolbox`. The core functions of SLIC are re-distributed under [GNU General Public License](https://en.wikipedia.org/wiki/GNU_General_Public_License) terms.

### Reproducibility 
In addition to all the related codes, we have also shared the generated results. These files are contained in the folder `./results`.

Please run the following to generate the various figures and tables in the paper.
* `Figure1.m` Demonstration of the proposed segmentation algorithm.
* `Figure3.m` Computes the cloud coverage of the sample images of the dataset. 
* `Figure6.m` Performance of the various color channels for nighttime image segmentation.
* `Statistics of SWINSEG dataset.ipynb` Computes the distribution of images in the image dataset.
* `Table2.m` Performance evaluation of various benchmarking algorithms. 
