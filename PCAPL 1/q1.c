#include <stdio.h>
#include <math.h>
#include <mpi.h>

int main() 
{
	int x = 2;
	MPI_Init(NULL,NULL);
	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	double p = pow(x,rank);
	printf(" %d^rank %d = %f\n", x, rank, p);
	MPI_Finalize();
}