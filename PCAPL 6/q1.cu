#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__global__ void word_count_kernel(char* str, char* key, int* word_indices, int* result, int* key_len)
{
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	int si = word_indices[idx];
	int ei = word_indices[idx+1];
	char word[100];
	int i = 0;
	int corr_count=0;

	for (i = 0; i < (ei-si-1); i++)
	{
		word[i] = str[si+1+i];
	}

	word[i] = '\0';

	int i1 = 0;
	int i2 = 0;
	int is_equal = 0;

	while (word[i1] != '\0' && key[i2] != '\0')
	{
		if (word[i1] == key[i2])
		{
			i1++;
			i2++;
			corr_count++;
		}
		else
		{
			is_equal = 0;
			break;
		}
	}

	if(corr_count==(*key_len))
	{
		is_equal=1;
	}

	if (is_equal == 1)
	{
		atomicAdd(result, 1);
	}
}

int main()
{
	char str[100] = " apple banana mango apple laptop apple mango banana laptop confuse ";
	char key[100] = "apple";

	int str_len = strlen(str);
	int key_len = strlen(key);
	int word_count = 0;

	for (int i = 0; i < str_len; i++)
	{
		if (str[i] == ' ')
		{
			word_count++;
		}
	}

	int* word_indices;
	int wi = -1;

	word_indices = (int*) (malloc(word_count * sizeof(int)));

	for (int i = 0; i < str_len; i++)
	{
		if (str[i] == ' ')
		{
			word_indices[++wi] = i;
		}
	}

	int result = 0;

	char* d_str;
	char* d_key;
	int* d_word_indices;
	int* d_result;
	int* d_keylen;

	cudaMalloc((void**)&d_str, str_len * sizeof(char));
	cudaMalloc((void**)&d_key, key_len * sizeof(char));
	cudaMalloc((void**)&d_word_indices, (word_count+1) * sizeof(int));
	cudaMalloc((void**)&d_result, sizeof(int));
	cudaMalloc((void**)&d_keylen, sizeof(int));

	cudaMemcpy(d_str, str, str_len * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_key, key, key_len * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_word_indices, word_indices, (word_count+1) * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_result, &result, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_keylen, &key_len, sizeof(int), cudaMemcpyHostToDevice);


	word_count_kernel<<<1, word_count>>>(d_str, d_key, d_word_indices, d_result,d_keylen);

	cudaMemcpy(&result, d_result, sizeof(int), cudaMemcpyDeviceToHost);

	printf("Input String: %s\n", str);
	printf("Key: %s\n", key);
	if(result!=1)
	{
		printf("Total occurrences of %s is %d\n", key, result);
	}
	else
	{
		printf("Total occurrences of %s is %d\n", key, result);
	}

	cudaFree(d_str);
	cudaFree(d_key);
	cudaFree(d_result);

	return 0;
}