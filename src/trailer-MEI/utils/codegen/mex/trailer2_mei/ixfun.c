/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ixfun.c
 *
 * Code generation for function 'ixfun'
 *
 */

/* Include files */
#include "ixfun.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_emxutil.h"
#include "trailer2_mei_types.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRTEInfo e_emlrtRTEI = {
    225,            /* lineNo */
    23,             /* colNo */
    "expand_atan2", /* fName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\ixfun.m" /* pName
                                                                            */
};

static emlrtRTEInfo pd_emlrtRTEI = {
    234,     /* lineNo */
    20,      /* colNo */
    "ixfun", /* fName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\ixfun.m" /* pName
                                                                            */
};

/* Function Definitions */
void expand_atan2(const emlrtStack *sp, const emxArray_real_T *a,
                  const emxArray_real_T *b, emxArray_real_T *c)
{
  const real_T *a_data;
  const real_T *b_data;
  real_T *c_data;
  int32_T sak;
  int32_T sbk;
  b_data = b->data;
  a_data = a->data;
  sak = a->size[1];
  sbk = b->size[1];
  if (b->size[1] == 1) {
    sak = a->size[1];
  } else if (a->size[1] == 1) {
    sak = b->size[1];
  } else {
    sak = muIntScalarMin_sint32(sak, sbk);
    if (a->size[1] != b->size[1]) {
      emlrtErrorWithMessageIdR2018a(sp, &e_emlrtRTEI,
                                    "MATLAB:sizeDimensionsMustMatch",
                                    "MATLAB:sizeDimensionsMustMatch", 0);
    }
  }
  sbk = c->size[0] * c->size[1];
  c->size[0] = 1;
  c->size[1] = sak;
  emxEnsureCapacity_real_T(sp, c, sbk, &pd_emlrtRTEI);
  c_data = c->data;
  if (sak != 0) {
    boolean_T b1;
    boolean_T b_b;
    b_b = (a->size[1] != 1);
    b1 = (b->size[1] != 1);
    sbk = sak - 1;
    for (sak = 0; sak <= sbk; sak++) {
      c_data[sak] = muDoubleScalarAtan2(a_data[b_b * sak], b_data[b1 * sak]);
    }
  }
}

/* End of code generation (ixfun.c) */
