#include <stdio.h>
// #include <stdlib.h>
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
	int rank,error_code,count = 0,totalCount;
	MPI_Init(NULL, NULL);	
	error_code = MPI_Comm_rank(MCW, &rank);
	ErrorHandler(error_code);

	int mat[3][3],row[3],key;
	if(rank == 0)
	{
		printf("Enter 3*3 matrix\n");
		for(int i=0;i<3;i++)
			for(int j=0;j<3;j++)
				scanf("%d",&mat[i][j]);
		printf("Enter element to search for\n");
		scanf("%d", &key);
	}

	error_code = MPI_Bcast(&key, 1, MPI_INT, 0, MCW);// Broadcast key to search for
	ErrorHandler(error_code);

	error_code = MPI_Scatter(mat,3,MPI_INT,row,3,MPI_INT,0,MCW);
	ErrorHandler(error_code);

	for(int i=0; i<3; i++)
		if(row[i] == key)
			count++;

	error_code = MPI_Reduce(&count,&totalCount,1,MPI_INT,MPI_SUM,0,MCW);
	ErrorHandler(error_code);
	
	if(rank == 0)
		printf("Total count = %d\n", totalCount);
	MPI_Finalize();
}