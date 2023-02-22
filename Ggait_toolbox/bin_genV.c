#include "mex.h"
#include "matrix.h"

// would call [temp c_C] = bin_genV(t,bin_length,c_C,spikeTimes);

void bin_genV(int col, double b_time, double b_size);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
const mxArray *prhs[]);

double *time, *binSize, *prevStartTimes, *spikeTimes, *bin, *postStartTimes;
int H, depth, cols;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
const mxArray *prhs[])
{
    // local program variables //   
    int i;
    double b_time, b_size;
    
    // input variables, returns are all pointers (except H) //
    time = mxGetPr(prhs[0]);            // time to calculate bins at
    binSize = mxGetPr(prhs[1]);         // window size
    prevStartTimes = mxGetPr(prhs[2]);  // should be 500x1
    spikeTimes = mxGetPr(prhs[3]);      // SHOULD BE 180925x(# of cells), this would just be ch. 1
    
    H = mxGetM(prhs[3]);                // number of rows in spikeTimes
    cols = mxGetN(prhs[3]);             // number of columns in spikeTimes

    depth = (int) (1000 / *binSize);
    
    // output variables //
    plhs[0] = mxCreateDoubleMatrix(1,(depth*cols), mxREAL); // want to return two 50x1 arrays
    plhs[1] = mxCreateDoubleMatrix(1,(depth*cols), mxREAL);
    
    bin = mxGetPr(plhs[0]);
    postStartTimes = mxGetPr(plhs[1]);
    
    b_time = *time;
    b_size = *binSize;
    
    //Main code //
    for(i = 0; i < cols; i++)
        bin_genV(i, b_time, b_size);

    return;
}

void bin_genV(int col, double b_time, double b_size)
{
    double **pWindow;
    int *binCount, *startTimes;
    int i, d_cnt;
    
    binCount = mxCalloc(depth, sizeof(int));  
    startTimes = mxCalloc(depth, sizeof(int));  
    pWindow = mxCalloc(depth, sizeof(double *));  

    // startTimes, binCount, and windowPointers overwrite after each channel
            
    for(i = 0; i<depth;i++)
        pWindow[i] = &spikeTimes[0+col*H]; // pWindow is an array of addresses
    
    for(i = 0; i < depth; i++)    //finds the correct start times   // checked against binGen 2/23/06 - working
    {         
        startTimes[i] = prevStartTimes[i+ col*depth]; 
        
        while( spikeTimes[startTimes[i]+col*H] < (b_time - (i+1)* b_size))
        {
            startTimes[i]++;
        }
        
        postStartTimes[i + depth*col] = startTimes[i];
        pWindow[i] += (int)startTimes[i]; //pointers are in the right location in the signal
    }
    
    // NEED TO ADD oversearch protection here - now is handled in .m file with infs 2/4/10
    for(d_cnt = 0; d_cnt < depth; d_cnt++)
        while((*pWindow[d_cnt] > (b_time - (d_cnt+1) * b_size)) && (*pWindow[d_cnt] < (b_time  - d_cnt * b_size)))  // spike occurred
		{
			binCount[d_cnt]++;
			pWindow[d_cnt]++;
		}   
	    
	for(i = 0; i < depth; i++)
		bin[i+depth*col] = binCount[i];
   
    mxFree(binCount);
    mxFree(startTimes);
    mxFree(pWindow);
    return;
}
