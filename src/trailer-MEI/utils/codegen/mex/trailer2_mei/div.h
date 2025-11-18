/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * div.h
 *
 * Code generation for function 'div'
 *
 */

#pragma once

/* Include files */
#include "rtwtypes.h"
#include "trailer2_mei_types.h"
#include "emlrt.h"
#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function Declarations */
void b_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                        const emxArray_real_T *in2);

void e_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                        const emxArray_real_T *in2, const emxArray_real_T *in3);

/* End of code generation (div.h) */
