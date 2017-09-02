#include<iostream>
#include<cuda.h>
#include<stdio.h>
using namespace std;
#define TILE_WIDTH 4
__global__ void MatrixMulKernel( int* A, int* B, int* C,int m, int n, int k)
{
	__shared__ int ds_A[TILE_WIDTH][TILE_WIDTH];
	__shared__ int ds_B[TILE_WIDTH][TILE_WIDTH];
	int bx = blockIdx.x; int by = blockIdx.y;
	int tx = threadIdx.x; int ty = threadIdx.y;
	int cx = blockIdx.x * blockDim.x; int cy = blockIdx.y * blockDim.y;
	int Cx = cx + tx; int Cy = cy + ty;
	int Row = by * blockDim.y + ty;
	int Col = bx * blockDim.x + tx;
	int Cvalue = 0;
	int total_tiles = (n + TILE_WIDTH - 1) / TILE_WIDTH;
	for (int t = 0; t <  total_tiles; ++t)
	 {
		int Ax = t * TILE_WIDTH + tx; int Ay = cy + ty;
		int Bx = cx + tx; int By = t * TILE_WIDTH + ty;
		
		if (Ax < n && Ay < m) {
      			ds_A[ty][tx] = A[Ay * n + Ax];
   		 }
   		 else {
      			ds_A[ty][tx] = 0;
   		 }
    		if (Bx < n && By < k) {
     			ds_B[ty][tx] = B[By * n + Bx];
    		}
   		 else {
     			 ds_B[ty][tx] = 0;
		}
		__syncthreads();
		for (int i = 0; i < TILE_WIDTH; i++) {
      			Cvalue+= ds_A[ty][i] * ds_B[i][tx];
		}
		__syncthreads();
	}
		 if (Cx < n && Cy < m) {
    			C[Cy * n + Cx] = Cvalue;
  			}
}

int main()
{
int r1=30,r2=30,c1=30,c2 = 30;
int *a= new int[r1*c1];
int *b= new int[r2*c2];
int *c= new int[r1*c2];
for(int i=0;i<r1;i++)
for(int j=0;j<c1;j++)

   { a[i*c1+j] = rand()%100;}

for(int i=0;i<r2;i++)
 { for(int j=0;j<c2;j++)
      { b[i*c2+j]= rand()%100;}}
if(r2!=c1)
{
cout<<"not possible";
return 0;
}
else
{    
int *d_a,*d_b,*d_c;
cudaMalloc((void**)&d_a,sizeof(int)*r1*c1);
cudaMalloc((void**)&d_b,sizeof(int)*r2*c2);
cudaMalloc((void**)&d_c,sizeof(int)*r1*c2);
cudaMemcpy(d_a,a,sizeof(int)*r1*c1,cudaMemcpyHostToDevice);
cudaMemcpy(d_b,b,sizeof(int)*r2*c2,cudaMemcpyHostToDevice);

const dim3 blocksize((c2/TILE_WIDTH) + 1, (r1/TILE_WIDTH) + 1, 1);//Number of Blocks required
const dim3 gridsize(TILE_WIDTH, TILE_WIDTH, 1);//Number of threads in each block


/*const dim3 blocksize(ceil(r1-1)/16 +1,ceil(c2-1)/16+1,1);
const dim3 gridsize(16,16,1);*/
//matrixmul<<<dim3(50,50),1>>>(d_a,d_b,d_c,r1,c2,r2);
MatrixMulKernel<<<blocksize,gridsize>>>(d_a,d_b,d_c,r1,c2,r2);

cudaMemcpy(c,d_c,sizeof(int)*r1*c2,cudaMemcpyDeviceToHost);

for(int i=0;i<r1;i++)
 { for(int j=0;j<c2;j++)
       { cout<<c[i*c2+j]<<" ";
}
 cout<<endl;}
 cout<<endl;

cudaFree(d_a);
cudaFree(d_b);
cudaFree(d_c);
}
return 0;


}
   




