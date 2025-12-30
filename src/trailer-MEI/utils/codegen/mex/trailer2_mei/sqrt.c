/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sqrt.c
 *
 * Code generation for function 'sqrt'
 *
 */

/* Include files */
#include "sqrt.h"
#include "eml_int_forloop_overflow_check.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"
#include "trailer2_mei_types.h"
#include "mwmathutil.h"
#include <emmintrin.h>

/* Variable Definitions */
static emlrtRSInfo cb_emlrtRSI = {
    16,     /* lineNo */
    "sqrt", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\sqrt.m" /* pathName
                                                                       */
};

static emlrtRTEInfo i_emlrtRTEI = {
    13,     /* lineNo */
    9,      /* colNo */
    "sqrt", /* fName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\sqrt.m" /* pName
                                                                       */
};

/* Function Definitions */
void b_sqrt(const emlrtStack *sp, emxArray_real_T *x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T *x_data;
  int32_T k;
  int32_T nx;
  int32_T scalarLB;
  int32_T vectorUB;
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
        sp, &i_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 4, "sqrt");
  }
  st.site = &cb_emlrtRSI;
  nx = x->size[1];
  b_st.site = &u_emlrtRSI;
  if (x->size[1] > 2147483646) {
    c_st.site = &s_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  scalarLB = (nx / 2) << 1;
  vectorUB = scalarLB - 2;
  for (k = 0; k <= vectorUB; k += 2) {
    __m128d r;
    r = _mm_loadu_pd(&x_data[k]);
    _mm_storeu_pd(&x_data[k], _mm_sqrt_pd(r));
  }
  for (k = scalarLB; k < nx; k++) {
    x_data[k] = muDoubleScalarSqrt(x_data[k]);
  }
}

void c_sqrt(const emlrtStack *sp, emxArray_real_T *x)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T *x_data;
  int32_T k;
  int32_T nx;
  int32_T scalarLB;
  int32_T vectorUB;
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  x_data = x->data;
  p = false;
  nx = x->size[0];
  for (k = 0; k < nx; k++) {
    if (p || (x_data[k] < 0.0)) {
      p = true;
    }
  }
  if (p) {
    emlrtErrorWithMessageIdR2018a(
        sp, &i_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 4, "sqrt");
  }
  st.site = &cb_emlrtRSI;
  nx = x->size[0];
  b_st.site = &u_emlrtRSI;
  if (x->size[0] > 2147483646) {
    c_st.site = &s_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  scalarLB = (nx / 2) << 1;
  vectorUB = scalarLB - 2;
  for (k = 0; k <= vectorUB; k += 2) {
    __m128d r;
    r = _mm_loadu_pd(&x_data[k]);
    _mm_storeu_pd(&x_data[k], _mm_sqrt_pd(r));
  }
  for (k = scalarLB; k < nx; k++) {
    x_data[k] = muDoubleScalarSqrt(x_data[k]);
  }
}

/* End of code generation (sqrt.c) */
