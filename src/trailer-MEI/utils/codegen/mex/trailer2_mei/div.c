/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * div.c
 *
 * Code generation for function 'div'
 *
 */

/* Include files */
#include "div.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"
#include "trailer2_mei_emxutil.h"
#include "trailer2_mei_types.h"

/* Function Definitions */
void b_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                        const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T i1;
  int32_T in2_idx_0;
  int32_T loop_ub;
  int32_T stride_0_0;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  in2_idx_0 = in2->size[0];
  emxInit_real_T(sp, &b_in1, 2, &dd_emlrtRTEI);
  if (in2_idx_0 == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2_idx_0;
  }
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = loop_ub;
  b_in1->size[1] = 2;
  emxEnsureCapacity_real_T(sp, b_in1, i, &dd_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  in2_idx_0 = (in2_idx_0 != 1);
  for (i = 0; i < 2; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          in1_data[i1 * stride_0_0 + in1->size[0] * i] /
          in2_data[i1 * in2_idx_0];
    }
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = 2;
  emxEnsureCapacity_real_T(sp, in1, i, &dd_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[0];
  for (i = 0; i < 2; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in1_data[i1 + b_in1->size[0] * i];
    }
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

void e_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                        const emxArray_real_T *in2, const emxArray_real_T *in3)
{
  const real_T *in2_data;
  const real_T *in3_data;
  real_T *in1_data;
  int32_T i;
  int32_T i1;
  int32_T in3_idx_0;
  int32_T loop_ub;
  int32_T stride_0_0;
  in3_data = in3->data;
  in2_data = in2->data;
  in3_idx_0 = in3->size[0];
  if (in3_idx_0 == 1) {
    loop_ub = in2->size[0];
  } else {
    loop_ub = in3_idx_0;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = loop_ub;
  in1->size[1] = 2;
  emxEnsureCapacity_real_T(sp, in1, i, &tc_emlrtRTEI);
  in1_data = in1->data;
  stride_0_0 = (in2->size[0] != 1);
  in3_idx_0 = (in3_idx_0 != 1);
  for (i = 0; i < 2; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] =
          in2_data[i1 * stride_0_0 + in2->size[0] * i] /
          in3_data[i1 * in3_idx_0];
    }
  }
}

/* End of code generation (div.c) */
