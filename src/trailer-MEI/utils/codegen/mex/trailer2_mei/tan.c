/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * tan.c
 *
 * Code generation for function 'tan'
 *
 */

/* Include files */
#include "tan.h"
#include "eml_int_forloop_overflow_check.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"
#include "trailer2_mei_types.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo w_emlrtRSI =
    {
        11,    /* lineNo */
        "tan", /* fcnName */
        "D:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\tan.m" /* pathName
                                                                          */
};

/* Function Definitions */
void b_tan(const emlrtStack *sp, emxArray_real_T *x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T *x_data;
  int32_T k;
  int32_T nx;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  x_data = x->data;
  st.site = &w_emlrtRSI;
  nx = x->size[1];
  b_st.site = &u_emlrtRSI;
  if (x->size[1] > 2147483646) {
    c_st.site = &s_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  for (k = 0; k < nx; k++) {
    x_data[k] = muDoubleScalarTan(x_data[k]);
  }
}

/* End of code generation (tan.c) */
