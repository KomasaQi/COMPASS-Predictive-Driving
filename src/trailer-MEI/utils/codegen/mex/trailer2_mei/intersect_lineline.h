/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * intersect_lineline.h
 *
 * Code generation for function 'intersect_lineline'
 *
 */

#pragma once

/* Include files */
#include "rtwtypes.h"
#include "emlrt.h"
#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function Declarations */
void sortPoint(const emlrtStack *sp, const real_T b_line[4], real_T p1[2],
               real_T p2[2]);

/* End of code generation (intersect_lineline.h) */
