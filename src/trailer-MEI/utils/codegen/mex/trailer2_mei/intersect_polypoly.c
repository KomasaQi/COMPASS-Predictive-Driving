/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * intersect_polypoly.c
 *
 * Code generation for function 'intersect_polypoly'
 *
 */

/* Include files */
#include "intersect_polypoly.h"
#include "intersect_lineline.h"
#include "rt_nonfinite.h"
#include "trailer2_mei_data.h"
#include <emmintrin.h>

/* Variable Definitions */
static emlrtRSInfo ub_emlrtRSI = {
    6,                    /* lineNo */
    "intersect_lineline", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\\xe8\x87\xaa\xe5\x8a\xa8\xe9"
    "\xa9\xbe\xe9\xa9\xb6\xe7\xac\xac\xe5\x9b\x9b\xe6\x9c\x9f"
    "\xe5\xad\xa6\xe4\xb9\xa0\\intersect_lineline.m" /* pathName */
};

static emlrtRSInfo vb_emlrtRSI = {
    5,                    /* lineNo */
    "intersect_lineline", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\\xe8\x87\xaa\xe5\x8a\xa8\xe9"
    "\xa9\xbe\xe9\xa9\xb6\xe7\xac\xac\xe5\x9b\x9b\xe6\x9c\x9f"
    "\xe5\xad\xa6\xe4\xb9\xa0\\intersect_lineline.m" /* pathName */
};

/* Function Definitions */
boolean_T intersect_polypoly(const emlrtStack *sp, const real_T poly1[10],
                             const real_T poly2[10])
{
  emlrtStack st;
  real_T A[2];
  real_T AB[2];
  real_T AC[2];
  real_T AD[2];
  real_T B[2];
  real_T C[2];
  real_T D[2];
  int32_T i;
  boolean_T exitg1;
  boolean_T flag;
  st.prev = sp;
  st.tls = sp->tls;
  /*  函数：intersect_polypoly*********** */
  /*  基于intersect_linepoly来判断两个多边形是否相交 */
  /*  也可以用来判断两组线段是否相交，但效率低 */
  /*  polygon为 n x 2的向量，是用点序列表示的多边形 */
  flag = false;
  i = 0;
  exitg1 = false;
  while ((!exitg1) && (i < 4)) {
    real_T b_line[4];
    int32_T b_i;
    boolean_T b_flag;
    boolean_T exitg2;
    b_line[0] = poly1[i];
    b_line[1] = poly1[i + 1];
    b_line[2] = poly1[i + 5];
    b_line[3] = poly1[i + 6];
    /*  函数：intersect_linepoly*********** */
    /*  基于intersect_lineline来判断一条线段是否和一个多边形相交 */
    /*  也可以用来判断一条线段是否和一组线段相交，但效率低 */
    /*  polygon为 n x 2的向量，是用点序列表示的多边形 */
    b_flag = false;
    b_i = 0;
    exitg2 = false;
    while ((!exitg2) && (b_i < 4)) {
      __m128d r;
      __m128d r1;
      real_T b_poly2[4];
      real_T d;
      real_T result1;
      real_T result2;
      real_T result3;
      real_T result4;
      boolean_T c_flag;
      /*  函数：intersect_lineline********** */
      /* 判断两条线段是否相交，返回逻辑值1或0 */
      c_flag = false;
      st.site = &vb_emlrtRSI;
      sortPoint(&st, b_line, A, B);
      b_poly2[0] = poly2[b_i];
      b_poly2[1] = poly2[b_i + 1];
      b_poly2[2] = poly2[b_i + 5];
      b_poly2[3] = poly2[b_i + 6];
      st.site = &ub_emlrtRSI;
      sortPoint(&st, b_poly2, C, D);
      /*  1-检测线段CD的两个断电是否位于线段AB两边 */
      r = _mm_loadu_pd(&B[0]);
      r1 = _mm_loadu_pd(&A[0]);
      _mm_storeu_pd(&AB[0], _mm_sub_pd(r, r1));
      r = _mm_loadu_pd(&C[0]);
      _mm_storeu_pd(&AC[0], _mm_sub_pd(r, r1));
      r = _mm_loadu_pd(&D[0]);
      _mm_storeu_pd(&AD[0], _mm_sub_pd(r, r1));
      /*  子函数： */
      result1 = AB[0] * AC[1] - AC[0] * AB[1];
      /*  子函数： */
      result2 = AB[0] * AD[1] - AD[0] * AB[1];
      /*  2-检测线段AB的两个端点是否位于线段CD两边 */
      r = _mm_loadu_pd(&D[0]);
      r1 = _mm_loadu_pd(&C[0]);
      _mm_storeu_pd(&AB[0], _mm_sub_pd(r, r1));
      r = _mm_loadu_pd(&B[0]);
      _mm_storeu_pd(&AD[0], _mm_sub_pd(r, r1));
      r = _mm_loadu_pd(&AC[0]);
      _mm_storeu_pd(&AC[0], _mm_mul_pd(r, _mm_set1_pd(-1.0)));
      /*  子函数： */
      result3 = AB[0] * AC[1] - AC[0] * AB[1];
      /*  子函数： */
      result4 = AB[0] * AD[1] - AD[0] * AB[1];
      /*  3-判断两条线段是否相交 */
      d = result1 * result2;
      if (((d < 0.0) && (result3 * result4 < 0.0)) ||
          ((d == 0.0) && (result3 * result4 < 0.0)) ||
          ((d < 0.0) && (result3 * result4 == 0.0))) {
        /* 若两条线为X型，或T型，则相交 */
        c_flag = true;
      } else if ((result1 == 0.0) && (result2 == 0.0) && (result3 == 0.0) &&
                 (result4 == 0.0) &&
                 ((C[0] < B[0]) || (D[0] < A[0]) || (C[1] < B[1]) ||
                  (D[1] < A[1]))) {
        /* 4个都为0，表明两条线段共线，但是否重合需要进一步判断 */
        /* 由于线段端点已经排序，只需要排除共线但不重合的情况即可 */
        /*  %x方向 */
        /* y方向 */
        c_flag = true;
      }
      if (c_flag) {
        b_flag = true;
        exitg2 = true;
      } else {
        b_i++;
        if (*emlrtBreakCheckR2012bFlagVar != 0) {
          emlrtBreakCheckR2012b((emlrtConstCTX)sp);
        }
      }
    }
    if (b_flag) {
      flag = true;
      exitg1 = true;
    } else {
      i++;
      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b((emlrtConstCTX)sp);
      }
    }
  }
  return flag;
}

/* End of code generation (intersect_polypoly.c) */
