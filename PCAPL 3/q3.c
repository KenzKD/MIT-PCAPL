#include<mpi.h>
#include<stdio.h>
#include<string.h>
int main()
{
	int rank,size;
	MPI_Init(NULL,NULL);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	char str[100],rec[100];
	int n,total_count[100];
	if(rank==0)
	{
		printf("Enter a string:");
		fgets(str,100,stdin);//includes spaces
		n=strlen(str)/size;
	}
	MPI_Bcast(&n,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Scatter(str,n,MPI_CHAR,rec,n,MPI_CHAR,0,MPI_COMM_WORLD);
	int count=0;
	for(int i=0;i<n;i++)
	{
		if(rec[i]=='a'||rec[i]=='e'||rec[i]=='i'||rec[i]=='o'||rec[i]=='u')
			continue;
		count++;
	}
	MPI_Gather(&count,1,MPI_INT,total_count,1,MPI_INT,0,MPI_COMM_WORLD);
	if(rank==0)
	{
		int sum=0;
		for(int i=0;i<size;i++)
			sum+=total_count[i];
		printf("Total number of non-vowels: %d\n",sum);
	}
	MPI_Finalize();
}