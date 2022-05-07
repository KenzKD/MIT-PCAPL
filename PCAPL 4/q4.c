#include <mpi.h>
#include <stdio.h>
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
	int rank, size, error_code;
	int matrix[4][4],recv[4],sum[4];
	MPI_Init(NULL,NULL);
	MPI_Errhandler_set(MCW, MPI_ERRORS_RETURN);
	MPI_Comm_rank(MCW, &rank);

	error_code = MPI_Comm_size(MCW, &size);
	ErrorHandler(error_code);

	if (rank == 0)
	{
		printf("Enter 4x4 values below:\n");
		for (int i=0;i<4;i++)
			for (int j=0;j<4;j++)
				scanf("%d",&matrix[i][j]);
		printf("-**-\n");
	}

	//dividing columns
	error_code = MPI_Scatter(matrix,4,MPI_INT,recv,4,MPI_INT,0,MCW);
	ErrorHandler(error_code);

	//sequentially adding the columns
	error_code = MPI_Scan(recv,sum,4,MPI_INT,MPI_SUM,MCW);
	ErrorHandler(error_code);

	for (int i=0;i<4;i++)
		printf("%d ",sum[i]);
	printf("\n");
	MPI_Finalize();
}