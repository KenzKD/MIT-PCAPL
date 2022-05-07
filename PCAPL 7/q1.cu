#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

#define MASK_WIDTH 5
#define WIDTH 10

/* 
do 1D conv
1 - with mask in global memory
2 - with mask in shared memory(tiled)
3 - with mask in constant memory
*/

__constant__ int d_Mc[MASK_WIDTH];

__global__ void conv_global_(int *A, int *M, int *R)
{
	
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	float val = 0;
	int start = i-(MASK_WIDTH/2);
    
	for(int j=0; j<MASK_WIDTH;j++)
		if(start+j>=0 && start+j<WIDTH)
			val+= A[start+j]*M[j];
	R[i]=val;
}

__global__ void conv_shared_(int *A, int *M, int *R)
{
    __shared__ int d_Ms[MASK_WIDTH];
    for(int i=0;i<MASK_WIDTH;i++)
        d_Ms[i] = M[i];
    
    int i = blockIdx.x*blockDim.x+threadIdx.x;
	float val = 0;
	int start = i-(MASK_WIDTH/2);
    
	for(int j =0; j<MASK_WIDTH;j++)
		if(start+j>=0 && start+j<WIDTH)
			val+= A[start+j]*d_Ms[j];
	R[i]=val;
}

__global__ void conv_constant_(int *A, int *R)
{
    int i = blockIdx.x*blockDim.x+threadIdx.x;
	float val = 0;
	int start = i-(MASK_WIDTH/2);
    
	for(int j =0; j<MASK_WIDTH;j++)
        if(start+j>=0 && start+j<WIDTH)
            val+= A[start+j]*d_Mc[j];
	R[i]=val;
}

int main()
{
    int A[WIDTH], M[MASK_WIDTH], R[WIDTH];
    int *d_A, *d_M, *d_R;

    for(int i=0; i<WIDTH; i++)
    {
        A[i] = rand() % 10;
        R[i] = 0;

        if(i < MASK_WIDTH)
            M[i] = rand() % 10;
    }

    printf("Input Matrix : ");
    for(int i=0; i<WIDTH; i++)
        printf("%d ", A[i]);

    printf("\nMask Matrix : ");
    for(int i=0; i<MASK_WIDTH; i++)
        printf("%d ", M[i]);

    cudaMalloc((void**)&d_A, WIDTH*sizeof(int));
    cudaMalloc((void**)&d_M, MASK_WIDTH*sizeof(int));
    cudaMalloc((void**)&d_R, WIDTH*sizeof(int));

    cudaMemcpy(d_A, A, WIDTH*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, M, MASK_WIDTH*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_R, R, WIDTH*sizeof(int), cudaMemcpyHostToDevice);

    // Q1a
    conv_global_<<<1, WIDTH>>>(d_A, d_M, d_R);
    cudaMemcpy(R, d_R, WIDTH*sizeof(int), cudaMemcpyDeviceToHost);
    printf("\n\nResultant Matrix after Basic conv : ");
    for(int i=0; i<WIDTH; i++)
        printf("%d ", R[i]);

    // Q1b
    conv_shared_<<<1, WIDTH>>>(d_A, d_M, d_R);
    cudaMemcpy(R, d_R, WIDTH*sizeof(int), cudaMemcpyDeviceToHost);
    printf("\nResultant Matrix after Tiled conv : ");
    for(int i=0; i<WIDTH; i++)
        printf("%d ", R[i]);

    // Q1c
    cudaMemcpyToSymbol(d_Mc, M, MASK_WIDTH*sizeof(int));
    conv_constant_<<<1, WIDTH>>>(d_A, d_R);
    cudaMemcpy(R, d_R, WIDTH*sizeof(int), cudaMemcpyDeviceToHost);
    printf("\nResultant Matrix after constant conv : ");
    for(int i=0; i<WIDTH; i++)
        printf("%d ", R[i]);

    printf("\n");

    cudaFree(d_A);
    cudaFree(d_M);
    cudaFree(d_R);
    return 0;
}