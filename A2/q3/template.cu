#include "wb.h"
//@@ define error checking macro here.
#define errCheck(stmt)                                                     \
  do {                                                                    \
    cudaError_t err = stmt;                                               \
    if (err != cudaSuccess) {                                             \
      printErrorLog(ERROR, "Failed to run stmt ", #stmt);                         \
      printErrorLog(ERROR, "Got CUDA error ...  ", cudaGetErrorString(err));      \
      return -1;                                                          \
    }                                                                     \
  } while (0)

//@@ INSERT CODE HERE
__global__ void colorToGrayscale(float *inputImage, float *outputImage, int *imageHeight, int *imageWidth)
{
	int x = 3 * threadIdx.x;
	int y = 3 * blockIdx.x;
	float average = (inputImage[y * (*imageWidth) + x] * 0.21 + inputImage[y * (*imageWidth) + x + 1] * 0.71 + inputImage[y * (*imageWidth) + x + 2] * 0.07);
	outputImage[y / 3 * (*imageWidth) + x / 3] = average;
}
int main(int argc, char *argv[]) {

  int imageChannels;
  int imageWidth;
  int imageHeight;
  char *inputImageFile;
  wbImage_t inputImage;
  wbImage_t outputImage;
  float *hostInputImageData;
  float *hostOutputImageData;
  float *deviceInputImageData;
  float *deviceOutputImageData;
  int *deviceImageHeight;
  int *deviceImageWidth;

  /* parse the input arguments */
  //@@ Insert code here
  if(argc != 3)
  {
	printf("Invalid arguments, format should be: \ninput.ppm expected.ppm");
    return 0;	
  }
  wbArg_t args = wbArg_read(argc, argv);

  inputImageFile = wbArg_getInputFile(args, 0);

  inputImage = wbImport(inputImageFile);

  imageWidth  = wbImage_getWidth(inputImage);
  imageHeight = wbImage_getHeight(inputImage);
  // For this lab the value is always 3
  imageChannels = wbImage_getChannels(inputImage);

  // Since the image is monochromatic, it only contains one channel
  outputImage = wbImage_new(imageWidth, imageHeight, 1);

  hostInputImageData  = wbImage_getData(inputImage);
  hostOutputImageData = wbImage_getData(outputImage);

  wbTime_start(GPU, "Doing GPU Computation (memory + compute)");

  wbTime_start(GPU, "Doing GPU memory allocation");
  cudaMalloc((void **)&deviceInputImageData,
             imageWidth * imageHeight * imageChannels * sizeof(float));
  cudaMalloc((void **)&deviceOutputImageData,
             imageWidth * imageHeight * sizeof(float));
  wbTime_stop(GPU, "Doing GPU memory allocation");

  wbTime_start(Copy, "Copying data to the GPU");
  cudaMemcpy(deviceInputImageData, hostInputImageData,
             imageWidth * imageHeight * imageChannels * sizeof(float),
             cudaMemcpyHostToDevice);
  wbTime_stop(Copy, "Copying data to the GPU");

  ///////////////////////////////////////////////////////
  wbTime_start(Compute, "Doing the computation on the GPU");
  //@@ INSERT CODE HERE
  cudaMalloc((void **)&deviceImageHeight, sizeof(int));
  cudaMalloc((void **)&deviceImageWidth, sizeof(int));
  cudaMemcpy(deviceImageHeight, &imageHeight, sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(deviceImageWidth, &imageWidth, sizeof(int), cudaMemcpyHostToDevice);
  colorToGrayscale<<<imageHeight, imageWidth>>>(deviceInputImageData, deviceOutputImageData, deviceImageHeight, deviceImageWidth);
  wbTime_stop(Compute, "Doing the computation on the GPU");

  ///////////////////////////////////////////////////////
  wbTime_start(Copy, "Copying data from the GPU");
  cudaMemcpy(hostOutputImageData, deviceOutputImageData,
             imageWidth * imageHeight * sizeof(float),
             cudaMemcpyDeviceToHost);
  wbTime_stop(Copy, "Copying data from the GPU");

  wbTime_stop(GPU, "Doing GPU Computation (memory + compute)");

  wbSolution(args, outputImage);

  cudaFree(deviceInputImageData);
  cudaFree(deviceOutputImageData);

  wbImage_delete(outputImage);
  wbImage_delete(inputImage);

  return 0;
}
