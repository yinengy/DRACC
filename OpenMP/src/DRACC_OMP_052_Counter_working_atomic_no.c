/*
Concurrent access on an atomic counter. Inter and Intra Region.
*/
#include <stdio.h>
#define N 100000

int countervar = 0;


int count(){
    #pragma omp target map(tofrom:countervar) device(0)
    #pragma omp teams distribute parallel for
        for (int i=0; i<N; i++){
			#pragma omp atomic update
            countervar++;
        }
    return 0;
}


int main(){
    count();
    printf("counter: %i expected: 100000\n ",countervar);
    return 0;
}