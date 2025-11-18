/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * trailer2_mei_initialize.c
 *
 * Code generation for function 'trailer2_mei_initialize'
 *
 */

/* Include files */
#include "trailer2_mei_initialize.h"
#include "_coder_trailer2_mei_mex.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"

/* Function Declarations */
static void trailer2_mei_once(void);

/* Function Definitions */
static void trailer2_mei_once(void)
{
  mex_InitInfAndNan();
}

void trailer2_mei_initialize(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2022b(&st);
  emlrtClearAllocCountR2012b(&st, false, 0U, NULL);
  emlrtEnterRtStackR2012b(&st);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    trailer2_mei_once();
  }
}

/* End of code generation (trailer2_mei_initialize.c) */
