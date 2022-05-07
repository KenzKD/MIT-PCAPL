#include <stdio.h>
#include <mpi.h>
#include <string.h>
#include <ctype.h>

int main() 
{
	int rank;
	char str[10];
	MPI_Init(NULL, NULL);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Status status;
	if(rank==0)
	{
		printf("Enter a string in sender process:");
		scanf("%s",str);
		MPI_Ssend(str,10,MPI_CHAR,1,1,MPI_COMM_WORLD);
		printf("I have sent %s from process 0\n",str);
		MPI_Recv(str,10,MPI_CHAR,1,1,MPI_COMM_WORLD,&status);
		printf("Modified string is : %s\n", str);
	}
	else
	{
		MPI_Recv(str,10,MPI_CHAR,0,1,MPI_COMM_WORLD,&status);
		printf("I have received %s in process 1\n",str);
		for(int i = 0; i < strlen(str); i++) 
		{
			if(isupper(str[i])) 
				str[i] += 32;
			else 
				str[i] -= 32;
		}
		MPI_Ssend(str,10,MPI_CHAR,0,1,MPI_COMM_WORLD);
	}
	MPI_Finalize();
} 