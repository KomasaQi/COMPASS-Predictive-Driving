/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * trailer2_mei.h
 *
 * Code generation for function 'trailer2_mei'
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
void trailer2_mei(const emlrtStack *sp, real_T tf, real_T Ts, real_T D_safe,
                  real_T ego_x, real_T ego_y, real_T ego_v, real_T ego_head,
                  real_T ego_l, real_T ego_w, real_T ego_lb,
                  real_T ego_trailer_gamma, real_T ego_trailer_l,
                  real_T ego_trailer_w, real_T tractor_x, real_T tractor_y,
                  real_T tractor_v, real_T tractor_head, real_T tractor_l,
                  real_T tractor_w, real_T tractor_lb, real_T trailer_gamma,
                  real_T trailer_l, real_T trailer_w, real_T *MEI, real_T *TEM,
                  real_T *InDepth);

/* End of code generation (trailer2_mei.h) */
