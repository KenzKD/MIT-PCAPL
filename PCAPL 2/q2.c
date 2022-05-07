#include <stdio.h>
#include <mpi.h>

int main() 
{
	int rank,size,x;
	MPI_Init(NULL, NULL);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Status status;
	if(rank==0)
		for(int i=1;i<size;i++) 
			MPI_Send(&i,1,MPI_INT,i,1,MPI_COMM_WORLD);
	else
	{
		MPI_Recv(&x,1,MPI_INT,0,1,MPI_COMM_WORLD,&status);
		printf("Received %d in process %d\n",x,rank);
	}
	MPI_Finalize();
} 