/*
Matrix Vector multiplication with Matrix partially missing on Accelerator. Using the target enter data construct.
The enter data clause allocates to small memory for the implicit copy of the right size, resulting in an error.
*/
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#define C 512


int *a;
int *b;
int *c;


int init(){
    for(int i=0; i<C; i++){
        for(int j=0; j<C; j++){
            b[j+i*C]=1;
        }
        a[i]=1;
        c[i]=0;
    }
        return 0;
}


int Mult(){
    #pragma acc enter data copyin(a[0:C],b[0:C]) create(c[0:C])
    {
        #pragma acc parallel loop gang
        for(int i=0; i<C; i++){
            #pragma acc loop worker
            for(int j=0; j<C; j++){
                c[i]+=b[j+i*C]*a[j];
            }
        }
    }
    #pragma acc exit data copyout(c[0:C]) delete(a[0:C],b[0:C])
    return 0;
}

int check(){
    bool test = false;
    for(int i=0; i<C; i++){
        if(c[i]!=C){
            test = true;
        }
    }
    printf("Memory Access Issue visible: %s\n",test ? "true" : "false");
    return 0;
}

int main(){
    a = malloc(C*sizeof(int));
    b = malloc(C*C*sizeof(int));
    c = malloc(C*sizeof(int));
    init();
    Mult();
    check();
    free(a);
    free(b);
    free(c);
    return 0;
}