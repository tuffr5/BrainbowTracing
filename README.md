# BrainbowTracing
MATLAB code for neural tracing in Brainbow images

## Method
The method follows a segmentation-tracing pipeline.


## How to run?
#### Step 0
Run BM4D to denoise the image, code can be downloaded from [here](http://www.cs.tut.fi/~foi/GCF-BM3D/).
#### Step 1
Run mainScript.m in brainbowSegmentation folder to get the segmentation results. You can either use kernel k-means or GMM. Both the skeleton and segmentation will be saved in the directory specified.
#### Step 2
Run testMain.m in linkagebriding folder to precede the skeletons mat files and then generate the SWC files.


### Acknowledgements
Some codes are heavily borrowed from [Lorenzo Tortorella](https://www.mathworks.com/matlabcentral/fileexchange/45546-a-algorithm), [Philip Kollmannsberger](https://github.com/phi-max), [Mo Chen](https://github.com/PRML/PRMLT), and [Uygar Sümbül](https://github.com/uygarsumbul/brainbowSegmentation), especially for supervoxelization and skeletonization. Thanks for their wonderful implementations. 
