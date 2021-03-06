/*
Matrix addition with to large matrices for the device memory, without utilizng streams.
*/
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// Grid size
#define B 100

// Block size
#define T 512

// Matrix dimension
#define C 51200L

// Macro for checking errors in CUDA API calls
#define cudaErrorCheck(call)                                                              \
do{                                                                                       \
    cudaError_t cuErr = call;                                                             \
    if(cudaSuccess != cuErr){                                                             \
      printf("CUDA Error - %s:%d: '%s'\n", __FILE__, __LINE__, cudaGetErrorString(cuErr));\
      exit(0);                                                                            \
    }                                                                                     \
}while(0)

int size = sizeof(int64_t);

// Host point64_ter
int64_t *a;
int64_t *b;
int64_t *c;

// Device point64_ter
int64_t *d_a;
int64_t *d_b;
int64_t *d_c;

// Host initialisation and matrix allocation
int init(){
    a = (int64_t *) malloc(C*C*size);
    b = (int64_t *) malloc(C*C*size);
    c = (int64_t *) malloc(C*C*size);
    for(int64_t i=0; i<C; i++){
        for(int64_t j=0; j<C; j++){
            b[j+i*C]=1;
            a[j+i*C]=1;
            c[j+i*C]=0;
        }
        
    }
        return 0;
}

// Kernel
__global__ void Mult(int64_t* d_a, int64_t* d_b, int64_t* d_c){
    int64_t tid = blockDim.x * blockIdx.x + threadIdx.x;
    d_c[tid] = d_a[tid] + d_b[tid];
    
}

// Verifying results
int check(){
    bool test = false;
    for(int64_t i=0; i<C*C; i++){
        if(c[i]!=2){
            test = true;
        }
    }
    printf("Memory Access Issue visible: %s\n",test ? "true\n" : "false\n");
    return 0;
    
    
}

// Allocating device memory and copying matrices a and b from the host to d_a and d_b on the device
void initcuda(){
    
    cudaErrorCheck( cudaMalloc(&d_a, C*C*size));
    cudaErrorCheck( cudaMalloc(&d_b, C*C*size));
    cudaErrorCheck( cudaMalloc(&d_c, C*C*size));
    cudaErrorCheck( cudaMemcpy(d_a,a,C*C*size,cudaMemcpyHostToDevice));
    cudaErrorCheck( cudaMemcpy(d_b,b,C*C*size,cudaMemcpyHostToDevice));
    
}

// Main program
int main(){
    // Initialisation
    init();
    initcuda();
    
    //Launch Kernel
    Mult<<<B,T>>>(d_a,d_b,d_c);
    
     // Check for errors in kernel launch (e.g. invalid execution configuration paramters)
    cudaErrorCheck( cudaGetLastError());

    // Check for errors on the GPU after control is returned to CPU
    cudaErrorCheck( cudaDeviceSynchronize());
    
    // Copying back the result d_c from the device to c on the host
    cudaErrorCheck( cudaMemcpy(c,d_c,C*C*size,cudaMemcpyHostToDevice));
    
    // Verifying results
    check();
    
    // Freeing device memory
    cudaErrorCheck( cudaFree(d_a));
    cudaErrorCheck( cudaFree(d_b));
    cudaErrorCheck( cudaFree(d_c));
    
    // Freeing host memory
    free(a);
    free(b);
    free(c);
    return 0;
}