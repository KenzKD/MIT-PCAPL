#include <stdio.h>
#include <mpi.h>

int main() 
{
	int rank,size,x,nxtrank;
	MPI_Init(NULL, NULL);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Status status;
	if(rank==0)
	{
		printf("Enter a number in root process:");
		scanf("%d",&x);
		x++;
		MPI_Send(&x,1,MPI_INT,1,1,MPI_COMM_WORLD);
		MPI_Recv(&x,1,MPI_INT,size-1,1,MPI_COMM_WORLD,&status);
		printf("Process: %d\tData: %d\n",rank,x);
		return 0;
	}
	else
	{
		MPI_Recv(&x,1,MPI_INT,rank-1,1,MPI_COMM_WORLD,&status);
		printf("Process: %d\tData: %d\n", rank, x);
		x++;
		if(++rank>size-1) 
			rank = 0;
		MPI_Send(&x,1,MPI_INT,rank,1,MPI_COMM_WORLD);
	}
	MPI_Finalize();
}   