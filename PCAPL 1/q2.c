#include <stdio.h>
#include <mpi.h>
int main() 
{
	MPI_Init(NULL, NULL);
	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	if(rank%2 == 0) 
		printf("Rank: %d Message: Hello\n", rank);
	else
		printf("Rank: %d Message: World\n", rank);
	MPI_Finalize();
}