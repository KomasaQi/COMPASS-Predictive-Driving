/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * log.c
 *
 * Code generation for function 'log'
 *
 */

/* Include files */
#include "log.h"
#include "eml_int_forloop_overflow_check.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"
#include "trailer2_mei_types.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo x_emlrtRSI =
    {
        17,    /* lineNo */
        "log", /* fcnName */
        "D:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\log.m" /* pathName
                                                                          */
};

/* Function Definitions */
void b_log(const emlrtStack *sp, emxArray_real_T *x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T *x_data;
  int32_T k;
  int32_T nx;
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  x_data = x->data;
  p = false;
  nx = x->size[1];
  for (k = 0; k < nx; k++) {
    if (p || (x_data[k] < 0.0)) {
      p = true;
    }
  }
  if (p) {
    emlrtErrorWithMessageIdR2018a(
        sp, &h_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 3, "log");
  }
  st.site = &x_emlrtRSI;
  nx = x->size[1];
  b_st.site = &u_emlrtRSI;
  if (x->size[1] > 2147483646) {
    c_st.site = &s_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  for (k = 0; k < nx; k++) {
    x_data[k] = muDoubleScalarLog(x_data[k]);
  }
}

/* End of code generation (log.c) */
