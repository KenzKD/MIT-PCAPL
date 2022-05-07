#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__host__ __device__ void printMatrix(const char * string, int * A, int width) 
{
  printf("%s\n", string);
  for (int i = 0; i < width; i++) 
  {
    for (int j = 0; j < width; j++)
      printf("%d,\t ", A[i * width + j]);
    printf("\n");
  }
  printf("\n");
}

__host__ void clearMatrix(int * A, int width) 
{
  for (int i = 0; i < width; i++)
    for (int j = 0; j < width; j++)
      A[i * width + j] = 0;
}

__global__ void MatMulti_2a(int * A, int * B, int * C, int width) 
{
  int row = threadIdx.y;
  int k = 0;
  for (int i = 0; i < width; i++) 
  {
    k = 0;
    for (int j = 0; j < width; j++)
      k += A[row * width + j] * B[i + width * j];
    C[row * width + i] = k;
  }
}

__global__ void MatMulti_2b(int * A, int * B, int * C, int width) 
{
  int col = threadIdx.x;
  int k = 0;
  for (int i = 0; i < width; i++) 
  {
    k = 0;
    for (int j = 0; j < width; j++)
      k += A[i * width + j] * B[col + j * width];
    C[i * width + col] = k;
  }
}

__global__ void MatMulti_2c(int * A, int * B, int * C, int width) 
{
  int col = threadIdx.x;
  int row = threadIdx.y;
  int k = 0;
  for (int i = 0; i < width; i++)
    k += A[row * width + i] * B[col + i * width];
  C[row * width + col] = k;
}

__global__ void MatMulti_2d(int * A, int * B, int * C, int width) 
{
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  C[row * width + col] = 0;
  //calculating one element
  for (int k = 0; k < width; k++)
    C[row*width+ col] += A[row * width + k] * B[k * width + col];
}

void MatMulti(int * h_A, int * h_B, int * h_C, int width) 
{
  int * d_A, * d_B, * d_C;
  int size = width*width*sizeof(int);
  
  cudaMalloc((void ** ) & d_A, size);
  cudaMalloc((void ** ) & d_B, size);
  cudaMalloc((void ** ) & d_C, size);
  cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice);
  
  dim3 dimBlock(1, 1, 1);
  dim3 dimGrid(1, 1, 1);
  
  dimBlock.x = 1;
  dimBlock.y = width;
  dimBlock.z = 1;
  MatMulti_2a <<< dimGrid, dimBlock >>> (d_A, d_B, d_C, width);
  cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
  printMatrix("A*B: (from 2a kernel): ", h_C, width);
  clearMatrix(h_C, width);
  cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice);

  dimBlock.x = width;
  dimBlock.y = 1;
  dimBlock.z = 1;
  MatMulti_2b <<< dimGrid, dimBlock >>> (d_A, d_B, d_C, width);
  cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
  printMatrix("A*B: (from 2b kernel): ", h_C, width);
  clearMatrix(h_C, width);
  cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice);

  dimBlock.x = width;
  dimBlock.y = width;
  dimBlock.z = 1;
  MatMulti_2c <<< dimGrid, dimBlock >>> (d_A, d_B, d_C, width);
  cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
  printMatrix("A*B: (from 2c kernel): ", h_C, width);

  dimBlock.x = 2;
  dimBlock.y = 2;
  dimBlock.z = 1;
  dimGrid.x = 2;
  dimGrid.y = 2;
  dimGrid.z = 1;
  MatMulti_2d <<< dimGrid, dimBlock >>> (d_A, d_B, d_C, width);
  cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
  printMatrix("A*B: (from 2d kernel): ", h_C, width);

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);
}

int main() 
{
  int * A, * B, * C, width = 3;
  A = (int * ) calloc(width * width, sizeof(int));
  B = (int * ) calloc(width * width, sizeof(int));
  C = (int * ) calloc(width * width, sizeof(int));
  
  for (int i = 0; i < width; i++) 
  {
    for (int j = 0; j < width; j++) 
    {
      A[i * width + j] = rand() % 10;
      B[i * width + j] = rand() % 11;
    }
  }
  printMatrix("A:", A, width);
  printMatrix("B:", B, width);
  MatMulti(A, B, C, width);
  return 0;
}