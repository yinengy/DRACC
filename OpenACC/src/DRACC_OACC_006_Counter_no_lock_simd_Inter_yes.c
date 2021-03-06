/*
Concurrent access on a counter with no lock with simd. Atomicity Violation. Not using worker level parallelism (Inter Region). Data Race in line 26.
*/
#include <stdio.h>
#include <stdbool.h>
#define N 100000
#define C 64

int countervar[C];


int init(){
    for(int i=0; i<C; i++){
        countervar[i]=0;
    }
    return 0;
}



int count(){
    #pragma acc parallel loop gang
        for (int i=0; i<N; i++){
            #pragma acc loop vector
            for(int i=0; i<C; i++){
                countervar[i]++;
            }
        }
    return 0;
}

int check(){
    bool test = false;
    for(int i=0; i<C; i++){
        if(countervar[i]!=100000){
            test = true;
        }
    }
    printf("Memory Access Issue visible: %s\n",test ? "true" : "false");
    return 0;
}

int main(){
    init();
    count();
    check();
    return 0;
}