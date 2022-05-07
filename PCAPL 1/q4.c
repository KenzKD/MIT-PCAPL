#include <stdio.h>
#include <mpi.h>
#include <ctype.h>

int main() 
{
	int rank;
	MPI_Init(NULL, NULL);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	char s[] = "Hello";
	if(islower(s[rank])) 
		s[rank] -= 32;
	else if(isupper(s[rank])) 
		s[rank] += 32;
	printf("Rank:%d char:%c\n", rank, s[rank]);
	MPI_Finalize();
}