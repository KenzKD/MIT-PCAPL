#include <stdio.h>
#include <mpi.h>
#include<math.h>
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

int main () 
{

    int rank, size,error_code;
    float x, y, area, pi1;

    MPI_Init(NULL,NULL);
    error_code = MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    ErrorHandler(error_code);
    error_code = MPI_Comm_size(MCW, &size);
    ErrorHandler(error_code);
    
    x = (float)(rank+1)/size;
    y = 4.f/(1+x*x);
    area = (1/(float)size)*y;

    error_code = MPI_Reduce(&area,&pi1,1,MPI_FLOAT,MPI_SUM, 0,MCW);
    ErrorHandler(error_code);

    if (rank == 0) 
        printf("Pi value found = %f\n",pi1);
    MPI_Finalize();
}