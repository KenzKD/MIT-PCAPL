#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

__global__ void vecAddKernel_1ab(int* A, int* B, int* C)
{
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	C[idx] = A[idx] + B[idx];
}

__global__ void vecAddKernel_1c(int* A, int* B, int* C, int n)
{
	int idx = threadIdx.x + blockIdx.x * blockDim.x;
	if (idx < n)
		C[idx] = A[idx] + B[idx];
}

void vecAdd(int* A, int* B, int* C, int n)
{
	int size = n*sizeof(int);
	
	int *d_A,*d_B,*d_C;
	
	cudaMalloc((void**) &d_A, size);
	cudaMalloc((void**) &d_B, size);
	cudaMalloc((void**) &d_C, size);
	
	cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);
	
	printf("A: ");
	for (int i = 0; i < n; i++)
		printf("%d ", A[i]);
	
	printf("\nB: ");
	for (int i = 0; i < n; i++)
		printf("%d ", B[i]);
	
	// 1a
	vecAddKernel_1ab<<<n, 1>>>(d_A, d_B, d_C);
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
	printf("\n\nA+B (1a): ");
	for (int i = 0; i < n ; i++)
		printf("%d ", C[i]);
	
	// 1b
	vecAddKernel_1ab<<<1, n>>>(d_A, d_B, d_C);
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
	printf("\nA+B (1b): ");
	for (int i = 0; i < n ; i++)
		printf("%d ", C[i]);	

	// 1c
	vecAddKernel_1c<<<ceil(n/256.0), n>>>(d_A, d_B, d_C, n);
	cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
	printf("\nA+B (1c): ");
	for (int i = 0; i < n ; i++)
		printf("%d ", C[i]);
	
	printf("\n");
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
}

int main()
{
	int *h_A, *h_B, *h_C;
	int n = 5;
	int size = n * sizeof(int);
	
	h_A = (int*) malloc(size);
	h_B = (int*) malloc(size);
	h_C = (int*) malloc(size);
	
	for (int i = 0; i < n; i++)
	{
		h_A[i] = i+1;
		h_B[i] = (i+1)*2;
	}

	vecAdd(h_A, h_B, h_C, n);
}