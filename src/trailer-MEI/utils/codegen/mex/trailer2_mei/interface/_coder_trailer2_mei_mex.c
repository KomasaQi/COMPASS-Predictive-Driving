/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_trailer2_mei_mex.c
 *
 * Code generation for function '_coder_trailer2_mei_mex'
 *
 */

/* Include files */
#include "_coder_trailer2_mei_mex.h"
#include "_coder_trailer2_mei_api.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"
#include "trailer2_mei_initialize.h"
#include "trailer2_mei_terminate.h"

/* Function Definitions */
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  mexAtExit(&trailer2_mei_atexit);
  /* Module initialization. */
  trailer2_mei_initialize();
  /* Dispatch the entry-point. */
  trailer2_mei_mexFunction(nlhs, plhs, nrhs, prhs);
  /* Module termination. */
  trailer2_mei_terminate();
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLSR2022a(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1,
                           NULL, "GBK", true);
  return emlrtRootTLSGlobal;
}

void trailer2_mei_mexFunction(int32_T nlhs, mxArray *plhs[3], int32_T nrhs,
                              const mxArray *prhs[23])
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  const mxArray *outputs[3];
  int32_T i;
  st.tls = emlrtRootTLSGlobal;
  /* Check for proper number of arguments. */
  if (nrhs != 23) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 23, 4,
                        12, "trailer2_mei");
  }
  if (nlhs > 3) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 12,
                        "trailer2_mei");
  }
  /* Call the function. */
  trailer2_mei_api(prhs, nlhs, outputs);
  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    i = 1;
  } else {
    i = nlhs;
  }
  emlrtReturnArrays(i, &plhs[0], &outputs[0]);
}

/* End of code generation (_coder_trailer2_mei_mex.c) */
