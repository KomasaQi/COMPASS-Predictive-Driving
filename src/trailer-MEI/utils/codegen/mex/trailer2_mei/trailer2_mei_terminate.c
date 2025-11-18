/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * trailer2_mei_terminate.c
 *
 * Code generation for function 'trailer2_mei_terminate'
 *
 */

/* Include files */
#include "trailer2_mei_terminate.h"
#include "_coder_trailer2_mei_mex.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"

/* Function Definitions */
void trailer2_mei_atexit(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void trailer2_mei_terminate(void)
{
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (trailer2_mei_terminate.c) */
