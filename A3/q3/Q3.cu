#include <iostream>
#include <stdio.h>
#include <stdlib.h>

#include <thrust/adjacent_difference.h>
#include <thrust/binary_search.h>
#include <thrust/device_free.h>
#include <thrust/device_malloc.h>
#include <thrust/device_ptr.h>
#include <thrust/sort.h>
#include <thrust/transform.h>

#define NUM_BINS 32

struct saturate_to_127
{
    typedef int argument_type;

    typedef int result_type;

    __host__ __device__ int operator()(const int &x) const
    {
        if (x > 127)
        {
            return 127;
        }
        else
        {
            return x;
        }
    }
};

int *get_data_from_file(FILE *file, int n) 
{
    int i;
    int *data;

    data = (int *)malloc(n * sizeof(int));

    for (i = 0; i < n; i++)
    {
        fscanf(file, "%d", &data[i]);
    }

    return data;
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

    int *h_array_in = NULL;
    int *h_array_out = NULL;
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
           

            if (fscanf(input_file, "%d", &n) == -1)
            {
                break;
            }

            h_array_in = get_data_from_file(input_file, n);

            if (fscanf(expected_file, "%d", &num_bins) == -1)
            {
                break;
            }

            expectedOutput = get_data_from_file(expected_file, num_bins);

            
            thrust::device_ptr<int> d_array_in = thrust::device_malloc<int>(n);
            thrust::device_ptr<int> d_array_out = thrust::device_malloc<int>(NUM_BINS);

          
            thrust::copy(h_array_in, h_array_in + n, d_array_in);

         
            thrust::sort(d_array_in, d_array_in + n);

           
            thrust::upper_bound(d_array_in, d_array_in + n, thrust::make_counting_iterator(0), thrust::make_counting_iterator(NUM_BINS), d_array_out);

            
            thrust::adjacent_difference(d_array_out, d_array_out + NUM_BINS, d_array_out);

           
            thrust::transform(d_array_out, d_array_out + NUM_BINS, d_array_out, saturate_to_127());

            h_array_out = (int *)malloc(NUM_BINS * sizeof(int));

           
            thrust::copy(d_array_out, d_array_out + NUM_BINS, h_array_out);

            
            if (output_check)
            {
                fprintf(output_file, "%d", NUM_BINS);

                for (i = 0; i < NUM_BINS; i++)
                {
                    fprintf(output_file, "\n%d", h_array_out[i]);
                }

                fprintf(output_file, "\n");

                fflush(output_file);
            }

            
            output_pass = true;
            for (i = 0; i < NUM_BINS; i++)
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

           
            thrust::device_free(d_array_in);
            thrust::device_free(d_array_out);

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
