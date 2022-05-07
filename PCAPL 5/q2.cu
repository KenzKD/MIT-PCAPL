#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

__global__ void selectionSortKernel(int* unsorted, int* sorted, int n)
{
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	int key = unsorted[idx];
	int pos = 0;
	
	for (int i=0;i<n;i++)
		if (unsorted[i]<key || (unsorted[i]==key && i<idx))
			pos++;

	sorted[pos] = key;
}

void selectionSort(int* unsorted, int* sorted, int n)
{
	int size = n*sizeof(int);
	int *d_unsorted,*d_sorted;
	
	cudaMalloc((void**)&d_unsorted,size);
	cudaMalloc((void**)&d_sorted,size);

	cudaMemcpy(d_unsorted,unsorted,size,cudaMemcpyHostToDevice);
	
	selectionSortKernel<<<1,n>>>(d_unsorted,d_sorted,n);
	
	cudaMemcpy(sorted,d_sorted,size,cudaMemcpyDeviceToHost);
	
	cudaFree(d_unsorted);
	cudaFree(d_sorted);
}

int main()
{
	int *h_unsorted,*h_sorted;
	int n = 5;
	int size = n*sizeof(int);
	
	h_unsorted = (int*)malloc(size);
	h_sorted = (int*)malloc(size);
	
	for (int i=0;i<5;i++)
		h_unsorted[i] = rand()%50;
	
	selectionSort(h_unsorted,h_sorted,n);
	
	printf("Unsorted Array: ");
	for (int i=0;i<n;i++)
		printf("%d ",h_unsorted[i]);
	
	printf("\nSorted Array: ");
	for (int i=0;i<n;i++)
		printf("%d ",h_sorted[i]);
	
	printf("\n");
}
