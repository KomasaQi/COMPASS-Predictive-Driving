/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * intersect_polypoly.h
 *
 * Code generation for function 'intersect_polypoly'
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
boolean_T intersect_polypoly(const emlrtStack *sp, const real_T poly1[10],
                             const real_T poly2[10]);

/* End of code generation (intersect_polypoly.h) */
