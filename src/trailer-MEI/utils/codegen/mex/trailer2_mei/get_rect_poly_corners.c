/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * get_rect_poly_corners.c
 *
 * Code generation for function 'get_rect_poly_corners'
 *
 */

/* Include files */
#include "get_rect_poly_corners.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"

/* Function Definitions */
void get_rect_poly_corners(real_T x, real_T y, real_T h, real_T l, real_T w,
                           real_T corners[10])
{
  real_T b_corners_tmp_idx_0_tmp;
  real_T b_corners_tmp_idx_1_tmp;
  real_T c_corners_tmp_idx_0_tmp;
  real_T corners_tmp_idx_0;
  real_T corners_tmp_idx_0_tmp;
  real_T corners_tmp_idx_1;
  real_T corners_tmp_idx_1_tmp;
  real_T cos_h;
  real_T sin_h;
  /*  计算矩形车辆的四个角点（全局坐标） */
  cos_h = muDoubleScalarCos(h);
  sin_h = muDoubleScalarSin(h);
  corners_tmp_idx_0_tmp = l / 2.0 * cos_h;
  b_corners_tmp_idx_0_tmp = w / 2.0 * sin_h;
  c_corners_tmp_idx_0_tmp = x - corners_tmp_idx_0_tmp;
  corners_tmp_idx_0 = c_corners_tmp_idx_0_tmp - b_corners_tmp_idx_0_tmp;
  sin_h *= l / 2.0;
  corners_tmp_idx_1_tmp = w / 2.0 * cos_h;
  b_corners_tmp_idx_1_tmp = y - sin_h;
  corners_tmp_idx_1 = b_corners_tmp_idx_1_tmp + corners_tmp_idx_1_tmp;
  cos_h = x + corners_tmp_idx_0_tmp;
  corners[1] = cos_h - b_corners_tmp_idx_0_tmp;
  sin_h += y;
  corners[6] = sin_h + corners_tmp_idx_1_tmp;
  corners[2] = cos_h + b_corners_tmp_idx_0_tmp;
  corners[7] = sin_h - corners_tmp_idx_1_tmp;
  corners[3] = c_corners_tmp_idx_0_tmp + b_corners_tmp_idx_0_tmp;
  corners[8] = b_corners_tmp_idx_1_tmp - corners_tmp_idx_1_tmp;
  corners[0] = corners_tmp_idx_0;
  corners[4] = corners_tmp_idx_0;
  corners[5] = corners_tmp_idx_1;
  corners[9] = corners_tmp_idx_1;
}

/* End of code generation (get_rect_poly_corners.c) */
