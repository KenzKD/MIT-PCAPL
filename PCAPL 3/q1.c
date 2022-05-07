#include <stdio.h>
#include <mpi.h>

int fact(int n) 
{
	if(n==1 || n==0) 
		return 1;
	return n*fact(n-1);
}

int main() 
{
	int rank, size, A[5], recv[5], c;
	MPI_Init(NULL, NULL);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	if(rank == 0) 
	{	int N=size;
		printf("Enter %d numbers:\n",N);
		for(int i = 0; i < N; i++) 
			scanf("%d", &A[i]);
	}
	MPI_Scatter(A,1,MPI_INT,&c,1,MPI_INT,0,MPI_COMM_WORLD);
	printf("I have received %d in process %d\n",c,rank);
	int f = fact(c);
	MPI_Gather(&f,1,MPI_INT,recv,1,MPI_INT,0,MPI_COMM_WORLD);
	if(rank==0) 
	{
		printf("The Result gathered in the root \n");
		int sum = 0;
		for(int i=0; i<N; i++)
			printf("%d \t",recv[i]);	
		printf("\n");
	}
	MPI_Finalize();
} 