#include <stdio.h>
#include <mpi.h>
#define MCW MPI_COMM_WORLD

void ErrorHandler(int error_code) 
{
	if (error_code != MPI_SUCCESS) 
	{
		char error_string[100];
		int reslen, error_class;
		MPI_Error_class(error_code, &error_class);
		MPI_Error_string(error_code, error_string, &reslen);
		printf("%d %s\n", error_code, error_string);
	}
}

int main() 
{
	int rank,size,fact=1,factsum,i,error_code;
	char error_string[100];
	MPI_Init(NULL,NULL);
	error_code = MPI_Comm_rank(MCW,&rank);
	ErrorHandler(error_code);
	error_code = MPI_Comm_size(MCW, &size);
	ErrorHandler(error_code);

	for(i=1;i<=rank+1;i++)
		fact *=i;
	
	printf("Process %d: fact: %d\n", rank, fact);
	error_code = MPI_Scan(&fact,&factsum,1,MPI_INT,MPI_SUM,MCW);
	ErrorHandler(error_code);
	if(rank==size-1)
		printf("Sum of all the factorial=%d\n",factsum);
	
	MPI_Finalize();
}