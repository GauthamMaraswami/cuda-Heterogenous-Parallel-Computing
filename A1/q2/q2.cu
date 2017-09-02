//Submitted by GAutham M 15co118 and yashwanth 15co154
#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include <time.h>
__global__ void func(float *da_in,float *db_in,float *d_out)
{
  int idx = blockIdx.x*100 + threadIdx.x;
   d_out[idx] = da_in[idx] + db_in[idx];
}

int main()
{
const int array_size = 16000;
const int array_bytes = array_size* sizeof(float);
float a_in[array_size],b_in[array_size];
for(int i=0;i<array_size;i++)
{
   a_in[i] = float(i);
   b_in[i]=float(i);
}
/*for(int i=0;i<array_size;i++)
{
   b_in[i]=rand()%16000;
}*/
float h_out[array_size];
float *da_in;
float *db_in;
float *d_out;
int temp=array_size;
int array_bytes1=array_bytes;
time_t t,t1;
srand((unsigned) time(&t));
 t1=clock();
while(temp>1)
{
//printf("abc");
if((temp)%2==1)
{
a_in[temp]=0;
//printf("con fail\n");
temp++;
array_bytes1+=8;
}
temp=temp/2;

array_bytes1/=2;
cudaMalloc((void **)&da_in,array_bytes1);
cudaMalloc((void **)&db_in,array_bytes1);
cudaMalloc((void **)&d_out,array_bytes1);

cudaMemcpy(da_in,a_in,array_bytes1,cudaMemcpyHostToDevice);
cudaMemcpy(db_in,a_in+(temp),array_bytes1,cudaMemcpyHostToDevice);
//kernel
func<<<dim3(160,1,1),dim3(100,1,1)>>>(da_in,db_in,d_out);

//copying back
cudaMemcpy(h_out,d_out,array_bytes1,cudaMemcpyDeviceToHost);

for(int i=0;i<temp;i++)
{
//      a_in[i]=h_out[i];
  // printf("%d=%f",i+1,h_out[i]);
  // printf(((i%4)!=3)? "\t":"\n");
  a_in[i]=h_out[i];
}
cudaFree(da_in);
cudaFree(d_out);
cudaFree(db_in);
//printf("\n");

}

 t1=clock()-t1;
double time_taken = ((double)t1)/CLOCKS_PER_SEC;
printf("parallel execution gave answer as%f- time taken as %f\n",a_in[0],time_taken);
}