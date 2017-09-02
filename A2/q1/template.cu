#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include<stdio.h>
#include <stdlib.h>
#include<iostream>
int num;
float*  read_data(char c1[])
{
//printf("%s",c1);
FILE *file = fopen(c1, "r");
int i=0;
   // int num=0;
    fscanf(file, "%d", &num) ;
//        printf("%d",num);
  //      i++;
float * fobj=(float *)malloc(sizeof(float)*num);

float fint;
for( i=0;i<num;++i)
{
 fscanf(file, "%f", &fint) ;
	fobj[i]=fint;        
//printf("%f",fint);
       // i++;
}	
  
//for(int i=0;i<num;++i)
//printf("%f",fobj[i]);  
return fobj;



}
int main(int argc, char *argv[]) {

//  float *hostInput1 = nullptr;
 // float *hostInput2 = nullptr;
 // float *hostOutput = nullptr;
  
int inputLength;
int i;
std::cout<<num;
//return 0; 
float *input1=read_data(argv[3]);
float *input2=read_data(argv[2]);
float *expectedoutput=read_data(argv[1]);
/*for(int i=0;i<num;++i)
printf("%f",input1[i]);
*/ float *hostInput1 = input1;
float *hostInput2 = input2;
 float *hostOutput = NULL;

  /* parse the input arguments */

  //@@ Insert code here

  // Import host input data
thrust::host_vector<float> h_vec1(num);
for(int i=0;i<num;++i)
h_vec1[i]=input1[i];
thrust::host_vector<float> h_vec2(num);
for(int i=0;i<num;++i)
h_vec2[i]=input2[i];
thrust::host_vector<float> h_out(num);

/*for(int i = 0; i < num; i++)
 std::cout << "H[" << i << "] = " << h_vec1[i] << std::endl;
for(int i = 0; i < num; i++)
 std::cout << "H1[" << i << "] = " << h_vec2[i] << std::endl;*/
  //@@ Read data from the raw files here
  //@@ Insert code here
//  hostInput1 =
// hostInput2 =

  // Declare and allocate host output
  //@@ Insert code here
hostOutput=(float *)malloc(sizeof(float)*num);
  // Declare and allocate thrust device input and output vectors
  //@@ Insert code here

  // Copy to device
  //@@ Insert code here
thrust::device_vector<float> d_vec1 = h_vec1;
thrust::device_vector<float> d_vec2 = h_vec2;
thrust::device_vector<float>d_out(num);
  // Execute vector addition
  //@@ Insert Code here
thrust::transform(d_vec1.begin(),d_vec1.end(),d_vec2.begin(),d_out.begin(),thrust::plus<float>());
  /////////////////////////////////////////////////////////
h_out=d_out;

FILE *outp = fopen(argv[4], "w");
	fprintf(outp, "%d", num);
	for(int i = 0; i <num; ++i)
	{
	  fprintf(outp, "\n%.2f", h_out[i]);
	}






float *recievedoutput=read_data(argv[4]);
int matchflag=0;
for(long i = 0; i < 3987; i++)
 {
 // std::cout <<i<<"--"<<recievedoutput[i]<<"\t"; 
if(fabs(recievedoutput[i] - expectedoutput[i]) >= 0.001)
  {
	matchflag=i+1;
std::cout<<" xxxzzz"<<recievedoutput[i]<<"ccc"<<expectedoutput[i]<<"\n";
	break;
}
}
std::cout<<"xxxxxx"<<matchflag;
if(matchflag==0)
std::cout<<" matched";
else
 std::cout<<"not matched";
  // Copy data back to host
  //@@ Insert code here

  free(hostInput1);
  free(hostInput2);
  free(hostOutput);
  
return 0;
}

