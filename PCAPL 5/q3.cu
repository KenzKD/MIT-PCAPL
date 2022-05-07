#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

__global__ void oddEven(int* arr, int n)
{
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	if (idx%2==1 && idx+1<n)
		if (arr[idx]>arr[idx+1])
		{
			int temp = arr[idx];
			arr[idx] = arr[idx+1];
			arr[idx+1] = temp;
		}
}

__global__ void evenOdd(int* arr, int n)
{
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	if (idx%2==0 && idx+1<n)
		if (arr[idx]>arr[idx+1])
		{
			int temp = arr[idx];
			arr[idx] = arr[idx+1];
			arr[idx+1] = temp;
		}
}

void oddEvenTranspositionSort(int* arr, int n)
{
	int size = n*sizeof(int);
	int* d_arr;
	
	cudaMalloc((void**) &d_arr, size);
	cudaMemcpy(d_arr,arr,size,cudaMemcpyHostToDevice);
	for (int i=0;i<=n/2;i++)
	{
		oddEven<<<1,n>>>(d_arr,n);
		evenOdd<<<1,n>>>(d_arr,n);
	}
	cudaMemcpy(arr,d_arr,size,cudaMemcpyDeviceToHost);
	cudaFree(d_arr);
}

int main()
{
	int *h_arr;
	int n = 5;
	int size = n * sizeof(int);
	h_arr = (int*) malloc(size);
	
	printf("Unsorted Array: ");
	for (int i = 0; i < n; i++)
	{
		h_arr[i] = rand()%40;
		printf("%d ",h_arr[i]);
	}	
	
	oddEvenTranspositionSort(h_arr, n);
	
	printf("\nSorted Array: ");
	for (int i = 0; i < n; i++)
		printf("%d ", h_arr[i]);

	printf("\n");
}
