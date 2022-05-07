#include <stdio.h>
#include <mpi.h>

int main() 
{
	int rank, a=30, b=15;
	MPI_Init(NULL,NULL);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	if(rank== 0) 
		printf("%d+%d = %d\n", a ,b, (a+b));
	else if(rank == 1) 
		printf("%d-%d = %d\n", a ,b, (a-b));
	else if(rank == 2)
		printf("%d*%d = %d\n", a ,b, (a*b));
	else if(rank == 3) 
		printf("%d/%d = %d\n", a ,b, (a/b));
	MPI_Finalize();
}

