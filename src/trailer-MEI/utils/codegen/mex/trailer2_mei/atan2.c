/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * atan2.c
 *
 * Code generation for function 'atan2'
 *
 */

/* Include files */
#include "atan2.h"
#include "ixfun.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_emxutil.h"
#include "trailer2_mei_types.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo db_emlrtRSI = {
    13,      /* lineNo */
    "atan2", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\atan2.m" /* pathName
                                                                        */
};

static emlrtRSInfo eb_emlrtRSI = {
    57,      /* lineNo */
    "ixfun", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\ixfun.m" /* pathName
                                                                            */
};

static emlrtRSInfo fb_emlrtRSI = {
    102,                          /* lineNo */
    "binaryImplicitExpansionFun", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\ixfun.m" /* pathName
                                                                            */
};

static emlrtRTEInfo od_emlrtRTEI = {
    13,      /* lineNo */
    1,       /* colNo */
    "atan2", /* fName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\atan2.m" /* pName
                                                                        */
};

/* Function Definitions */
void b_atan2(const emlrtStack *sp, const emxArray_real_T *y,
             const emxArray_real_T *x, emxArray_real_T *r)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  const real_T *x_data;
  const real_T *y_data;
  real_T *r_data;
  int32_T i;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  x_data = x->data;
  y_data = y->data;
  st.site = &db_emlrtRSI;
  b_st.site = &eb_emlrtRSI;
  if (y->size[1] == x->size[1]) {
    int32_T loop_ub;
    i = r->size[0] * r->size[1];
    r->size[0] = 1;
    r->size[1] = y->size[1];
    emxEnsureCapacity_real_T(&b_st, r, i, &od_emlrtRTEI);
    r_data = r->data;
    loop_ub = y->size[1];
    for (i = 0; i < loop_ub; i++) {
      real_T varargin_1;
      real_T varargin_2;
      varargin_1 = y_data[i];
      varargin_2 = x_data[i];
      r_data[i] = muDoubleScalarAtan2(varargin_1, varargin_2);
    }
  } else {
    c_st.site = &fb_emlrtRSI;
    expand_atan2(&c_st, y, x, r);
  }
}

/* End of code generation (atan2.c) */
