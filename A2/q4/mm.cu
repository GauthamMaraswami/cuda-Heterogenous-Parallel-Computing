#include<iostream>
#include<cuda.h>
#include<stdio.h>
using namespace std;


__global__  void matrixmul(int* d_a,int* d_b,int* d_c,int r1,int c2,int r2)
{
   int row = blockIdx.y*blockDim.y + threadIdx.y;
   int col = blockIdx.x*blockDim.x + threadIdx.x;
   
if(row<r1 && col <c2)
   {
      int sum = 0;
      for(int i=0; i<r2; i++)
     {
            sum  = sum +  d_a[row*r2+i]*d_b[i*c2+col];
      }
     d_c[row*c2 + col] = sum;
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
const dim3 blocksize(ceil(r1-1)/16 +1,ceil(c2-1)/16+1,1);
const dim3 gridsize(16,16,1);
//matrixmul<<<dim3(50,50),1>>>(d_a,d_b,d_c,r1,c2,r2);
matrixmul<<<blocksize,gridsize>>>(d_a,d_b,d_c,r1,c2,r2);

cudaMemcpy(c,d_c,sizeof(int)*r1*c2,cudaMemcpyDeviceToHost);

for(int i=0;i<r1;i++)
 { for(int j=0;j<c2;j++)
       { cout<<c[i*c2+j]<<" ";
}
 cout<<endl;}


cudaFree(d_a);
cudaFree(d_b);
cudaFree(d_c);
}
return 0;


}
   



