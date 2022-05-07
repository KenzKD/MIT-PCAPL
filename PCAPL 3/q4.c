#include<mpi.h>
#include<stdio.h>
#include<string.h>
int main()
{
	int rank,size;
	MPI_Init(NULL,NULL);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	char str[100],rec[100],str2[100],rec2[100],rec3[100];
	int n,n2;
	if(rank==0)
	{
		printf("Enter 1st string\n");
		fgets(str,100,stdin);
		n=strlen(str)/size;
		printf("Enter 2nd string\n");
		fgets(str2,100,stdin);
		n2=strlen(str2)/size;
	}
	MPI_Bcast(&n,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Bcast(&n2,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Scatter(str,n,MPI_CHAR,rec,n,MPI_CHAR,0,MPI_COMM_WORLD);
	MPI_Scatter(str2,n2,MPI_CHAR,rec2,n2,MPI_CHAR,0,MPI_COMM_WORLD);
	char sent[100];
	int n3=n+n2;
	for(int i=0,j=0;i<n3;i++,j++)
	{
		sent[i]=rec[j];
		sent[++i]=rec2[j];
	}
	MPI_Gather(sent,n3,MPI_CHAR,rec3,n3,MPI_CHAR,0,MPI_COMM_WORLD);
	if(rank==0)
		printf("Combined string: %s\n",rec3);
	MPI_Finalize();
}