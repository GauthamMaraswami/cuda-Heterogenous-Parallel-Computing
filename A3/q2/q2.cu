#include <iostream>
#include <stdio.h>
#include <stdlib.h>

#define BLOCK_WIDTH 256

__global__ void histogram(char *d_array_in, int *d_array_out, int n)
{
    __shared__ int shared_bin[128];

    int i, index, blocks, iterations;

    blocks = (n - 1) / BLOCK_WIDTH + 1; 
    iterations = 127 / (blocks * BLOCK_WIDTH) + 1;

    for (i = 0; i < iterations; i++) 
    {
        index = (blockIdx.x + i * blocks) * blockDim.x + threadIdx.x;

        if (index < 128)
        {
            d_array_out[index] = 0; 
        }
    }

    iterations = 127 / BLOCK_WIDTH + 1; 

    for (i = 0; i < iterations; i++)
    {
        index = i * blockDim.x + threadIdx.x;

        if (index < 128)
        {
            shared_bin[index] = 0; 
        }

        __syncthreads(); 
    }

    index = blockIdx.x * blockDim.x + threadIdx.x; 

    if (index < n)
    {
        atomicAdd(&shared_bin[d_array_in[index]], 1); 
    }

    __syncthreads();

    for (i = 0; i < iterations; i++) 
    {
        index = i * blockDim.x + threadIdx.x;

        if (index < 128)
        {
            atomicAdd(&d_array_out[index], shared_bin[index]); 
        }

        __syncthreads(); 
    }

    return;
}

int main(int argc, char *argv[])
{
    bool input_check = false;
    bool expected_check = false;
    bool output_check = false;
    bool error_present = false;
    bool expect_output = false;
    bool output_pass;

    char input_file_name[256];
    char expected_file_name[256];
    char output_file_name[256];

    FILE *input_file = NULL;
    FILE *expected_file = NULL;
    FILE *output_file = NULL;

    char *h_array_in = NULL;
    int *h_array_out = NULL;
    char *d_array_in = NULL;
    int *d_array_out = NULL;
    int *expectedOutput = NULL;

    int i, n, num_bins, dataset_no;

 

    for (i = 1; i < argc; i++)
    {
        if (strcmp(argv[i], "-i") == 0 && argc > i + 1)
        {
            if (argv[i + 1][0] != '-')
            {
                input_check = true;

                strcpy(input_file_name, argv[i + 1]);
            }
        }

        if (strcmp(argv[i], "-e") == 0 && argc > i + 1)
        {
            if (argv[i + 1][0] != '-')
            {
                expected_check = true;

                strcpy(expected_file_name, argv[i + 1]);
            }
        }

        if (strcmp(argv[i], "-o") == 0)
        {
            expect_output = true;

            if (argc > i + 1)
            {
                if (argv[i + 1][0] != '-')
                {
                    output_check = true;

                    strcpy(output_file_name, argv[i + 1]);
                }
            }
        }
    }

    if (!input_check)
    {
        std::cout << "Execution command syntax error: \"Input\" filename required" << std::endl;

        error_present = true;
    }
    else
    {
        input_file = fopen(input_file_name, "r");

        if (!input_file)
        {
            std::cout << "Error: File " << input_file_name << " does not exist" << std::endl;

            error_present = true;
        }
    }

    if (!expected_check)
    {
        std::cout << "Execution command syntax error: \"Expected Output\" filename required" << std::endl;

        error_present = true;
    }
    else
    {
        expected_file = fopen(expected_file_name, "r");

        if (!expected_file)
        {
            std::cout << "Error: File " << expected_file_name << " does not exist" << std::endl;

            error_present = true;
        }
    }

    if (!output_check && expect_output)
    {
        std::cout << "Execution Command Syntax Warning: \"Output\" filename expected" << std::endl;
    }
    else if (output_check)
    {
        output_file = fopen(output_file_name, "w");
    }

    if (error_present)
    {
        std::cout << "Use the following command to run the program:\n\n"
                     "./<program> ­-e <expected> -­i <input> ­-o <output>\n\n"
                     "Where <expected> is the expected output file, <input> is the input dataset files, and <output> is an optional path to store the results"
                  << std::endl;
    }
    else
    {
        dataset_no = 0;

        while (true)
        {
          
            h_array_in = (char *)malloc(1024 * sizeof(char));

            if (fgets(h_array_in, 1024, input_file) == NULL)
            {
                break;
            }

            for (n = 0; h_array_in[n] != '\n'; n++)
            {
                continue;
            }

            h_array_in[n] = '\0';

            if (fscanf(expected_file, "%d", &num_bins) == -1)
            {
                break;
            }

            expectedOutput = (int *)malloc(num_bins * sizeof(int));

            for (i = 0; i < num_bins; i++)
            {
                fscanf(expected_file, "%d", &expectedOutput[i]);
            }

            h_array_out = (int *)malloc(128 * sizeof(int));

            
            cudaMalloc((void **)&d_array_in, n * sizeof(char));
            cudaMalloc((void **)&d_array_out, 128 * sizeof(int));

            
            cudaMemcpy(d_array_in, h_array_in, n * sizeof(char), cudaMemcpyHostToDevice);

            
            dim3 blocks((n - 1) / BLOCK_WIDTH + 1);
            dim3 threads_per_block(BLOCK_WIDTH); 

            
            histogram<<<blocks, threads_per_block>>>(d_array_in, d_array_out, n);

           
            cudaMemcpy(h_array_out, d_array_out, 128 * sizeof(int), cudaMemcpyDeviceToHost);

            
            if (output_check)
            {
                fprintf(output_file, "%d", 128);

                for (i = 0; i < num_bins; i++)
                {
                    fprintf(output_file, "\n%d", h_array_out[i]);
                }

                fprintf(output_file, "\n");

                fflush(output_file);
            }

           
            output_pass = true;
            for (i = 0; i < 128; i++)
            {
                if (expectedOutput[i] != h_array_out[i])
                {
                    output_pass = false;
                }
            }

            if (output_pass)
            {
                std::cout << "Dataset " << dataset_no << " PASSED" << std::endl;
            }
            else
            {
                std::cout << "Dataset " << dataset_no << " FAILED" << std::endl;
            }

            dataset_no++;

          
            cudaFree(d_array_in);
            cudaFree(d_array_out);

            free(h_array_in);
            free(h_array_out);
            free(expectedOutput);
        }

        if (output_check)
        {
            std::cout << "Results stored in " << output_file_name << std::endl;
        }

        fclose(input_file);
        fclose(expected_file);

        if (output_check)
        {
            fclose(output_file);
        }
    }

    return 0;
}
