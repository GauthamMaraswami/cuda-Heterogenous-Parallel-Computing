//15co154 Yeshwanth R
//15co118 Goutham M
#include<stdio.h>
#include<cuda.h>

__global__ void addition(int *da_in ,int *db_in ,int *d_out){


     int idx = blockIdx.x*5 + threadIdx.x;
     int idy = blockIdx.y*5 + threadIdx.y;
      int in = idx + idy*5;
        d_out[in] = da_in[in] + db_in[in];

}

int main()
{
int array_size = 10;
int array_bytes = 10*10*sizeof(int);
int a_in[array_size][array_size],b_in[array_size][array_size];
int h_out[array_size][array_size];
for(int i=0;i<array_size;i++)
for(int j=0;j<array_size;j++)
    a_in[i][j] = i;

for(int i=0;i<array_size;i++)
for(int j=0;j<array_size;j++)
    b_in[i][j] = j;

int *da_in;
int *db_in;
int *d_out;

cudaMalloc((void **)&da_in,array_bytes);
cudaMalloc((void **)&db_in,array_bytes);
cudaMalloc((void **)&d_out,array_bytes);


cudaMemcpy(da_in,a_in,array_bytes,cudaMemcpyHostToDevice);
cudaMemcpy(db_in,b_in,array_bytes,cudaMemcpyHostToDevice);

addition<<<dim3(2,2,1),dim3(5,5,1)>>>(da_in,db_in,d_out);


cudaMemcpy(h_out,d_out,array_bytes,cudaMemcpyDeviceToHost);

for(int i=0;i<array_size;i++)
{
for(int j=0;j<array_size;j++)

{
   printf("%d  ",h_out[i*10+j]);
  }
printf("\n");
}
cudaFree(da_in);
cudaFree(db_in);
cudaFree(d_out);
}