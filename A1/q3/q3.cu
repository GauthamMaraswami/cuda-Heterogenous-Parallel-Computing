//15co154 Yeshwanth R
//15co118 Goutham M


#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

__global__ void func(float *da_in,float *db_in,float *d_out)
{
  int idx = blockIdx.x*100 + threadIdx.x;
   d_out[idx] = da_in[idx] + db_in[idx];
}





int main()
{
float t1,t2;
const int array_size = 16000;
const int array_bytes = array_size* sizeof(float);
float a_in[array_size],b_in[array_size];

for(int i=0;i<array_size;i++)
{
   a_in[i] = float(i);
}
for(int i=0;i<array_size;i++)
{
   b_in[i]=rand()%16000;
}
float h_out[array_size];
float *da_in;
float *db_in;
float *d_out;
cudaMalloc((void **)&da_in,array_bytes);
cudaMalloc((void **)&db_in,array_bytes);
cudaMalloc((void **)&d_out,array_bytes);

cudaMemcpy(da_in,a_in,array_bytes,cudaMemcpyHostToDevice);
cudaMemcpy(db_in,b_in,array_bytes,cudaMemcpyHostToDevice);
//kernel
func<<<dim3(160,1,1),dim3(100,1,1)>>>(da_in,db_in,d_out);
float time;
//copying back
cudaMemcpy(h_out,d_out,array_bytes,cudaMemcpyDeviceToHost);
for(int i=0;i<array_size;i++)
{
   printf("%f",h_out[i]);
   printf(((i%12)!=3)? "\t":"\n");
}
cudaFree(da_in);
cudaFree(d_out);
cudaFree(db_in);
printf("\n\n\n\n");


}
