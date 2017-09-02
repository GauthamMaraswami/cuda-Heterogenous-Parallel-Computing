//Submitted by GAutham M 15co118 and yashwanth 15co154
#include <stdio.h>

int main() {
  int nDevices;

  cudaGetDeviceCount(&nDevices);
  for (int i = 0; i < nDevices; i++) {
		cudaDeviceProp prop;
		cudaGetDeviceProperties(&prop, i);
		printf("Device Number: %d\n", i);
		printf("  Device name: %s\n", prop.name);
		printf("  Memory Clock Rate (KHz): %d\n",
			   prop.memoryClockRate);
		printf("  Memory Bus Width (bits): %d\n",
			   prop.memoryBusWidth);
		printf("  Peak Memory Bandwidth (GB/s): %f\n\n",
			   2.0*prop.memoryClockRate*(prop.memoryBusWidth/8)/1.0e6);
		printf("Total global memory:           %u\n",  prop.totalGlobalMem);
		printf("Total shared memory per block: %u\n",  prop.sharedMemPerBlock);
		printf("Total registers per block:     %d\n",  prop.regsPerBlock);
		printf("Warp size:                     %d\n",  prop.warpSize);
		printf("Maximum memory pitch:          %u\n",  prop.memPitch);
		printf("Maximum threads per block:     %d\n",  prop.maxThreadsPerBlock);
		for (int i = 0; i < 3; ++i)
	    printf("Maximum dimension %d of block:  %d\n", i, prop.maxThreadsDim[i]);
		for (int i = 0; i < 3; ++i)
		printf("Maximum dimension %d of grid:   %d\n", i, prop.maxGridSize[i]);
		printf("Total constant memory:         %u\n",  prop.totalConstMem);
		printf("Texture alignment:             %u\n",  prop.textureAlignment);
		printf("Concurrent copy and execution: %s\n",  (prop.deviceOverlap ? "Yes" : "No"));
		printf("Number of multiprocessors:     %d\n",  prop.multiProcessorCount);
		printf("Kernel execution timeout:      %s\n",  (prop.kernelExecTimeoutEnabled ? "Yes" : "No"));


}

}