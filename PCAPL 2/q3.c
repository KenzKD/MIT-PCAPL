#include <stdio.h>
#include <mpi.h>

int main()
{
	int rank,size,x[10],buffer[100],s=100;
	MPI_Init(NULL,NULL);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Buffer_attach(&buffer,s);
	MPI_Status status;
	if(rank==0)
	{
		printf("Enter the array elements:\n");
		for(int i=0; i<size-1;i++)
		{
			scanf("%d",&x[i]);
			MPI_Bsend(&x[i],1,MPI_INT,i+1,1,MPI_COMM_WORLD);
		}
	}
	else
	{	
		int i;
		MPI_Recv(&i,1,MPI_INT,0,1,MPI_COMM_WORLD,&status);
		if(rank%2==0)
			printf("Rank %d:%d\n",rank,i*i);
		else
			printf("Rank %d:%d\n",rank,i*i*i);
	}
	MPI_Buffer_detach(&buffer,&s);
	MPI_Finalize();
}