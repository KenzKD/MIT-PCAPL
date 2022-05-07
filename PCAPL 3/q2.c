#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main() 
{
	int rank, size, sum=0;
	MPI_Init(NULL, NULL);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	int arr[100],row_avg[100],recv[100],M, N;

	if(rank == 0) 
	{
		N = size;
		printf("Enter M: ");
		scanf("%d", &M);
		printf("Enter the elements of the array:\n");
		for(int i = 0; i < N*M; i++)
			scanf("%d", &arr[i]);
	}

	MPI_Bcast(&M,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Scatter(arr, M, MPI_INT, recv, M, MPI_INT, 0, MPI_COMM_WORLD);
	for(int i = 0; i < M; i++)
		sum += recv[i];
	sum /= M;
	MPI_Gather(&sum, 1, MPI_INT, row_avg, 1, MPI_INT, 0, MPI_COMM_WORLD);
	
	if(rank==0) 
	{	
		printf("Average row wise:");
		int total_sum=0,total_avg=0;
		for(int i=0;i<N;i++)
		{
			printf("\nRow: %d, Avg: %d",i,row_avg[i]);
			total_sum+=row_avg[i];
		}
		total_avg=total_sum/N;
		printf("\nTotal total_avg=%d\n",total_avg);
	}
	MPI_Finalize();
}