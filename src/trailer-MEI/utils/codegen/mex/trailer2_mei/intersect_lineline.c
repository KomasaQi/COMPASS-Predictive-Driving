/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * intersect_lineline.c
 *
 * Code generation for function 'intersect_lineline'
 *
 */

/* Include files */
#include "intersect_lineline.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"

/* Function Definitions */
void sortPoint(const emlrtStack *sp, const real_T b_line[4], real_T p1[2],
               real_T p2[2])
{
  int32_T dim;
  boolean_T exitg1;
  /*  子函数:sortPoint****************** */
  /* 按照如下规则对线段的两个点进行排序： */
  /* 如果x坐标不相等，x坐标小的为p1 */
  /* 如果x坐标相等，y坐标小的为p1 */
  /* 以此类推，直到最后一个维度 */
  /* line形式为：2 x dim，2个点，dim为点的维度 */
  p1[0] = b_line[0];
  p2[0] = b_line[1];
  p1[1] = b_line[2];
  p2[1] = b_line[3];
  dim = 0;
  exitg1 = false;
  while ((!exitg1) && (dim < 2)) {
    real_T d;
    real_T d1;
    int32_T i;
    boolean_T guard1 = false;
    i = dim << 1;
    d = b_line[i];
    d1 = b_line[i + 1];
    guard1 = false;
    if (d == d1) {
      guard1 = true;
    } else if (d < d1) {
      exitg1 = true;
    } else {
      p1[0] = b_line[1];
      p2[0] = b_line[0];
      p1[1] = b_line[3];
      p2[1] = b_line[2];
      guard1 = true;
    }
    if (guard1) {
      dim++;
      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b((emlrtConstCTX)sp);
      }
    }
  }
}

/* End of code generation (intersect_lineline.c) */
