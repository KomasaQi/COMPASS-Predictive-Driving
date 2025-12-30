/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * trailer2_mei.c
 *
 * Code generation for function 'trailer2_mei'
 *
 */

/* Include files */
#include "trailer2_mei.h"
#include "assertCompatibleDims.h"
#include "atan.h"
#include "atan2.h"
#include "colon.h"
#include "cos.h"
#include "div.h"
#include "eml_int_forloop_overflow_check.h"
#include "exp.h"
#include "get_rect_poly_corners.h"
#include "intersect_polypoly.h"
#include "log.h"
#include "rt_nonfinite.h"
#include "sin.h"
#include "sqrt.h"
#include "tan.h"
#include "trailer2_mei_data.h"
#include "trailer2_mei_emxutil.h"
#include "trailer2_mei_types.h"
#include "mwmathutil.h"
#include <emmintrin.h>

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = {
    6,              /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo b_emlrtRSI = {
    17,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo c_emlrtRSI = {
    23,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo d_emlrtRSI = {
    24,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo e_emlrtRSI = {
    26,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo f_emlrtRSI = {
    41,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo g_emlrtRSI = {
    42,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo h_emlrtRSI = {
    47,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo i_emlrtRSI = {
    48,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo j_emlrtRSI = {
    56,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo k_emlrtRSI = {
    57,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo l_emlrtRSI = {
    58,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo m_emlrtRSI = {
    60,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo n_emlrtRSI = {
    64,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo o_emlrtRSI = {
    105,            /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo p_emlrtRSI =
    {
        125,     /* lineNo */
        "colon", /* fcnName */
        "D:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m" /* pathName
                                                                          */
};

static emlrtRSInfo bb_emlrtRSI =
    {
        71,      /* lineNo */
        "power", /* fcnName */
        "D:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\power.m" /* pathName
                                                                          */
};

static emlrtRSInfo gb_emlrtRSI = {
    39,    /* lineNo */
    "cat", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m" /* pathName
                                                                          */
};

static emlrtRSInfo hb_emlrtRSI = {
    113,        /* lineNo */
    "cat_impl", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m" /* pathName
                                                                          */
};

static emlrtRSInfo ib_emlrtRSI = {
    34,               /* lineNo */
    "rdivide_helper", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\rdivide_"
    "helper.m" /* pathName */
};

static emlrtRSInfo jb_emlrtRSI = {
    51,    /* lineNo */
    "div", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\div.m" /* pathName
                                                                          */
};

static emlrtRSInfo kb_emlrtRSI = {
    15,    /* lineNo */
    "max", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\max.m" /* pathName
                                                                        */
};

static emlrtRSInfo lb_emlrtRSI =
    {
        44,         /* lineNo */
        "minOrMax", /* fcnName */
        "D:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax."
        "m" /* pathName */
};

static emlrtRSInfo mb_emlrtRSI =
    {
        79,        /* lineNo */
        "maximum", /* fcnName */
        "D:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\minOrMax."
        "m" /* pathName */
};

static emlrtRSInfo nb_emlrtRSI = {
    190,             /* lineNo */
    "unaryMinOrMax", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\unaryMinOrMax.m" /* pathName */
};

static emlrtRSInfo ob_emlrtRSI = {
    901,                    /* lineNo */
    "maxRealVectorOmitNaN", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\unaryMinOrMax.m" /* pathName */
};

static emlrtRSInfo pb_emlrtRSI = {
    72,                      /* lineNo */
    "vectorMinOrMaxInPlace", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\vectorMinOrMaxInPlace.m" /* pathName */
};

static emlrtRSInfo qb_emlrtRSI = {
    64,                      /* lineNo */
    "vectorMinOrMaxInPlace", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\vectorMinOrMaxInPlace.m" /* pathName */
};

static emlrtRSInfo rb_emlrtRSI = {
    113,         /* lineNo */
    "findFirst", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\vectorMinOrMaxInPlace.m" /* pathName */
};

static emlrtRSInfo sb_emlrtRSI = {
    130,                        /* lineNo */
    "minOrMaxRealVectorKernel", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\vectorMinOrMaxInPlace.m" /* pathName */
};

static emlrtECInfo emlrtECI = {
    2,              /* nDims */
    23,             /* lineNo */
    37,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo b_emlrtECI = {
    2,              /* nDims */
    34,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo c_emlrtECI = {
    2,              /* nDims */
    35,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo d_emlrtECI = {
    2,              /* nDims */
    38,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo e_emlrtECI = {
    2,              /* nDims */
    39,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo f_emlrtECI = {
    2,              /* nDims */
    47,             /* lineNo */
    24,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo g_emlrtECI = {
    2,              /* nDims */
    48,             /* lineNo */
    28,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo h_emlrtECI = {
    2,              /* nDims */
    52,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo i_emlrtECI = {
    2,              /* nDims */
    53,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo j_emlrtECI = {
    2,              /* nDims */
    54,             /* lineNo */
    25,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo k_emlrtECI = {
    2,              /* nDims */
    55,             /* lineNo */
    25,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo l_emlrtECI = {
    2,              /* nDims */
    56,             /* lineNo */
    28,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo m_emlrtECI = {
    2,              /* nDims */
    56,             /* lineNo */
    54,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo n_emlrtECI = {
    2,              /* nDims */
    57,             /* lineNo */
    22,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo o_emlrtECI = {
    2,              /* nDims */
    57,             /* lineNo */
    66,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo p_emlrtECI = {
    1,              /* nDims */
    58,             /* lineNo */
    40,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo q_emlrtECI = {
    2,              /* nDims */
    60,             /* lineNo */
    26,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo r_emlrtECI = {
    2,              /* nDims */
    60,             /* lineNo */
    74,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo s_emlrtECI = {
    1,              /* nDims */
    63,             /* lineNo */
    12,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo t_emlrtECI = {
    1,              /* nDims */
    64,             /* lineNo */
    24,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtBCInfo emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    81,             /* lineNo */
    102,            /* colNo */
    "thr_s",        /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo b_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    82,             /* lineNo */
    95,             /* colNo */
    "thr_s",        /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo c_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    83,             /* lineNo */
    120,            /* colNo */
    "thr_s",        /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo d_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    84,             /* lineNo */
    113,            /* colNo */
    "thr_s",        /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo e_emlrtBCI = {
    -1,              /* iFirst */
    -1,              /* iLast */
    85,              /* lineNo */
    140,             /* colNo */
    "trailer_thr_s", /* aName */
    "trailer2_mei",  /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtECInfo u_emlrtECI = {
    1,              /* nDims */
    105,            /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtECInfo v_emlrtECI = {
    1,              /* nDims */
    105,            /* lineNo */
    19,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo emlrtRTEI = {
    288,                   /* lineNo */
    27,                    /* colNo */
    "check_non_axis_size", /* fName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m" /* pName
                                                                          */
};

static emlrtRTEInfo c_emlrtRTEI = {
    134,             /* lineNo */
    27,              /* colNo */
    "unaryMinOrMax", /* fName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\unaryMinOrMax.m" /* pName */
};

static emlrtBCInfo f_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    19,             /* lineNo */
    25,             /* colNo */
    "th",           /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo g_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    19,             /* lineNo */
    5,              /* colNo */
    "th",           /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo h_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    21,             /* lineNo */
    25,             /* colNo */
    "th",           /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo i_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    21,             /* lineNo */
    5,              /* colNo */
    "th",           /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo j_emlrtBCI = {
    -1,               /* iFirst */
    -1,               /* iLast */
    28,               /* lineNo */
    49,               /* colNo */
    "ego_trailer_th", /* aName */
    "trailer2_mei",   /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo k_emlrtBCI = {
    -1,               /* iFirst */
    -1,               /* iLast */
    28,               /* lineNo */
    5,                /* colNo */
    "ego_trailer_th", /* aName */
    "trailer2_mei",   /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo l_emlrtBCI = {
    -1,               /* iFirst */
    -1,               /* iLast */
    30,               /* lineNo */
    49,               /* colNo */
    "ego_trailer_th", /* aName */
    "trailer2_mei",   /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo m_emlrtBCI = {
    -1,               /* iFirst */
    -1,               /* iLast */
    30,               /* lineNo */
    5,                /* colNo */
    "ego_trailer_th", /* aName */
    "trailer2_mei",   /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo n_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    78,                 /* lineNo */
    66,                 /* colNo */
    "trailer_center_x", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo o_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    78,                 /* lineNo */
    86,                 /* colNo */
    "trailer_center_y", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo p_emlrtBCI = {
    -1,               /* iFirst */
    -1,               /* iLast */
    78,               /* lineNo */
    104,              /* colNo */
    "trailer_head_s", /* aName */
    "trailer2_mei",   /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo q_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    79,                        /* lineNo */
    77,                        /* colNo */
    "ego_trailer_center_xr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo r_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    79,                        /* lineNo */
    104,                       /* colNo */
    "ego_trailer_center_yr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo s_emlrtBCI = {
    -1,               /* iFirst */
    -1,               /* iLast */
    79,               /* lineNo */
    122,              /* colNo */
    "ego_trailer_th", /* aName */
    "trailer2_mei",   /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo t_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    81,                 /* lineNo */
    72,                 /* colNo */
    "trailer_center_x", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo u_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    81,                 /* lineNo */
    92,                 /* colNo */
    "trailer_center_y", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo v_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    82,                 /* lineNo */
    65,                 /* colNo */
    "trailer_center_x", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo w_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    82,                 /* lineNo */
    85,                 /* colNo */
    "trailer_center_y", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo x_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    81,             /* lineNo */
    16,             /* colNo */
    "res_dA",       /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo y_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    83,                        /* lineNo */
    83,                        /* colNo */
    "ego_trailer_center_xr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo ab_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    83,                        /* lineNo */
    110,                       /* colNo */
    "ego_trailer_center_yr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo bb_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    84,                        /* lineNo */
    76,                        /* colNo */
    "ego_trailer_center_xr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo cb_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    84,                        /* lineNo */
    103,                       /* colNo */
    "ego_trailer_center_yr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo db_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    83,             /* lineNo */
    16,             /* colNo */
    "res_dB",       /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo eb_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    85,                 /* lineNo */
    29,                 /* colNo */
    "trailer_center_x", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo fb_emlrtBCI = {
    -1,                 /* iFirst */
    -1,                 /* iLast */
    85,                 /* lineNo */
    49,                 /* colNo */
    "trailer_center_y", /* aName */
    "trailer2_mei",     /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo gb_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    85,                        /* lineNo */
    71,                        /* colNo */
    "ego_trailer_center_xr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo hb_emlrtBCI = {
    -1,                        /* iFirst */
    -1,                        /* iLast */
    85,                        /* lineNo */
    98,                        /* colNo */
    "ego_trailer_center_yr_s", /* aName */
    "trailer2_mei",            /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo ib_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    85,             /* lineNo */
    16,             /* colNo */
    "res_Dc",       /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo jb_emlrtBCI = {
    -1,              /* iFirst */
    -1,              /* iLast */
    87,              /* lineNo */
    23,              /* colNo */
    "res_collision", /* aName */
    "trailer2_mei",  /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtBCInfo kb_emlrtBCI = {
    -1,             /* iFirst */
    -1,             /* iLast */
    95,             /* lineNo */
    29,             /* colNo */
    "t",            /* aName */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m", /* pName */
    0                /* checkKind */
};

static emlrtRTEInfo j_emlrtRTEI = {
    6,              /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo k_emlrtRTEI = {
    17,             /* lineNo */
    46,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo l_emlrtRTEI = {
    17,             /* lineNo */
    15,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo m_emlrtRTEI = {
    17,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo n_emlrtRTEI = {
    1,              /* lineNo */
    32,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo o_emlrtRTEI = {
    19,             /* lineNo */
    22,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo p_emlrtRTEI = {
    21,             /* lineNo */
    22,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo q_emlrtRTEI = {
    23,             /* lineNo */
    41,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo r_emlrtRTEI = {
    23,             /* lineNo */
    52,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo s_emlrtRTEI = {
    23,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo t_emlrtRTEI = {
    24,             /* lineNo */
    36,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo u_emlrtRTEI = {
    24,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo v_emlrtRTEI = {
    26,             /* lineNo */
    62,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo w_emlrtRTEI = {
    26,             /* lineNo */
    27,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo x_emlrtRTEI = {
    26,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo y_emlrtRTEI = {
    28,             /* lineNo */
    34,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ab_emlrtRTEI = {
    30,             /* lineNo */
    34,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo bb_emlrtRTEI = {
    34,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo cb_emlrtRTEI = {
    34,             /* lineNo */
    58,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo db_emlrtRTEI = {
    34,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo eb_emlrtRTEI = {
    35,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo fb_emlrtRTEI = {
    35,             /* lineNo */
    58,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo gb_emlrtRTEI = {
    35,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo hb_emlrtRTEI = {
    36,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ib_emlrtRTEI = {
    37,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo jb_emlrtRTEI = {
    38,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo kb_emlrtRTEI = {
    38,             /* lineNo */
    58,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo lb_emlrtRTEI = {
    38,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo mb_emlrtRTEI = {
    39,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo nb_emlrtRTEI = {
    39,             /* lineNo */
    58,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ob_emlrtRTEI = {
    39,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo pb_emlrtRTEI = {
    41,             /* lineNo */
    25,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo qb_emlrtRTEI = {
    41,             /* lineNo */
    24,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo rb_emlrtRTEI = {
    42,             /* lineNo */
    25,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo sb_emlrtRTEI = {
    42,             /* lineNo */
    24,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo tb_emlrtRTEI = {
    43,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ub_emlrtRTEI = {
    44,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo vb_emlrtRTEI = {
    47,             /* lineNo */
    35,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo wb_emlrtRTEI = {
    47,             /* lineNo */
    24,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo xb_emlrtRTEI = {
    47,             /* lineNo */
    60,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo yb_emlrtRTEI = {
    47,             /* lineNo */
    49,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ac_emlrtRTEI = {
    47,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo bc_emlrtRTEI = {
    48,             /* lineNo */
    35,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo cc_emlrtRTEI = {
    48,             /* lineNo */
    28,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo dc_emlrtRTEI = {
    48,             /* lineNo */
    49,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ec_emlrtRTEI = {
    48,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo fc_emlrtRTEI = {
    51,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo gc_emlrtRTEI = {
    52,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo hc_emlrtRTEI = {
    53,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ic_emlrtRTEI = {
    54,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo jc_emlrtRTEI = {
    55,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo kc_emlrtRTEI = {
    56,             /* lineNo */
    28,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo lc_emlrtRTEI = {
    57,             /* lineNo */
    35,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo mc_emlrtRTEI = {
    56,             /* lineNo */
    54,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo nc_emlrtRTEI = {
    57,             /* lineNo */
    79,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo oc_emlrtRTEI = {
    57,             /* lineNo */
    21,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo pc_emlrtRTEI = {
    57,             /* lineNo */
    65,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo qc_emlrtRTEI = {
    57,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo rc_emlrtRTEI = {
    58,             /* lineNo */
    40,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo sc_emlrtRTEI = {
    58,             /* lineNo */
    81,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo uc_emlrtRTEI = {
    60,             /* lineNo */
    43,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo vc_emlrtRTEI = {
    60,             /* lineNo */
    91,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo wc_emlrtRTEI = {
    60,             /* lineNo */
    25,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo xc_emlrtRTEI = {
    60,             /* lineNo */
    73,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo yc_emlrtRTEI = {
    60,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ad_emlrtRTEI = {
    63,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo bd_emlrtRTEI = {
    64,             /* lineNo */
    24,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo cd_emlrtRTEI = {
    64,             /* lineNo */
    49,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ed_emlrtRTEI = {
    67,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo fd_emlrtRTEI = {
    64,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo gd_emlrtRTEI = {
    68,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo hd_emlrtRTEI = {
    69,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo id_emlrtRTEI = {
    70,             /* lineNo */
    5,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo jd_emlrtRTEI = {
    19,             /* lineNo */
    8,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo kd_emlrtRTEI = {
    21,             /* lineNo */
    8,              /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ld_emlrtRTEI = {
    28,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo md_emlrtRTEI = {
    30,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo qd_emlrtRTEI = {
    105,            /* lineNo */
    19,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo rd_emlrtRTEI = {
    105,            /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo sd_emlrtRTEI = {
    63,             /* lineNo */
    12,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo td_emlrtRTEI = {
    53,             /* lineNo */
    20,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRTEInfo ud_emlrtRTEI = {
    23,             /* lineNo */
    24,             /* colNo */
    "trailer2_mei", /* fName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pName */
};

static emlrtRSInfo tb_emlrtRSI = {
    86,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo wb_emlrtRSI = {
    52,    /* lineNo */
    "div", /* fcnName */
    "D:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\div.m" /* pathName
                                                                          */
};

static emlrtRSInfo xb_emlrtRSI = {
    63,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo yb_emlrtRSI = {
    52,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo ac_emlrtRSI = {
    53,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo bc_emlrtRSI = {
    35,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo cc_emlrtRSI = {
    39,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo dc_emlrtRSI = {
    34,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo ec_emlrtRSI = {
    38,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo fc_emlrtRSI = {
    54,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

static emlrtRSInfo gc_emlrtRSI = {
    55,             /* lineNo */
    "trailer2_mei", /* fcnName */
    "E:"
    "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5\xad"
    "\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
    "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5\xa3\xab"
    "\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
    "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
    "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-MEI\\t"
    "railer2_mei.m" /* pathName */
};

/* Function Declarations */
static void b_minus(const emlrtStack *sp, emxArray_real_T *in1,
                    const emxArray_real_T *in2);

static void b_plus(const emlrtStack *sp, emxArray_real_T *in1,
                   const emxArray_real_T *in2);

static void binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                             real_T in2, const emxArray_boolean_T *in3);

static void c_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2,
                               const emxArray_real_T *in3);

static void c_minus(const emlrtStack *sp, emxArray_real_T *in1,
                    const emxArray_real_T *in2);

static void d_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2,
                               const emxArray_real_T *in3, real_T in4);

static void f_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emlrtRSInfo in2,
                               const emxArray_real_T *in3,
                               const emxArray_real_T *in4,
                               const emxArray_real_T *in5,
                               const emxArray_real_T *in6);

static void g_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2,
                               const emxArray_real_T *in3);

static void h_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2, real_T in3);

static void i_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2, real_T in3);

static void j_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               real_T in2, const emxArray_real_T *in3,
                               real_T in4);

static void minus(const emlrtStack *sp, emxArray_real_T *in1,
                  const emxArray_real_T *in2);

static void plus(const emlrtStack *sp, emxArray_real_T *in1,
                 const emxArray_real_T *in2);

/* Function Definitions */
static void b_minus(const emlrtStack *sp, emxArray_real_T *in1,
                    const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_1_0;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &sd_emlrtRTEI);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = loop_ub;
  b_in1->size[1] = 2;
  emxEnsureCapacity_real_T(sp, b_in1, i, &sd_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_1_0 = (in2->size[0] != 1);
  for (i = 0; i < 2; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          in1_data[i1 * stride_0_0 + in1->size[0] * i] -
          in2_data[i1 * stride_1_0 + in2->size[0] * i];
    }
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = 2;
  emxEnsureCapacity_real_T(sp, in1, i, &sd_emlrtRTEI);
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

static void b_plus(const emlrtStack *sp, emxArray_real_T *in1,
                   const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &cc_emlrtRTEI);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 1;
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  b_in1->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &cc_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = in1_data[i * stride_0_1] + in2_data[i * stride_1_1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &cc_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                             real_T in2, const emxArray_boolean_T *in3)
{
  emxArray_real_T *b_in1;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_1_0;
  const boolean_T *in3_data;
  in3_data = in3->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 1, &qd_emlrtRTEI);
  if (in3->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in3->size[0];
  }
  i = b_in1->size[0];
  b_in1->size[0] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &qd_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_1_0 = (in3->size[0] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] =
        (in1_data[i * stride_0_0] + in2) * (real_T)in3_data[i * stride_1_0];
  }
  i = in1->size[0];
  in1->size[0] = b_in1->size[0];
  emxEnsureCapacity_real_T(sp, in1, i, &qd_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[0];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void c_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2,
                               const emxArray_real_T *in3)
{
  const real_T *in2_data;
  const real_T *in3_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_1_0;
  in3_data = in3->data;
  in2_data = in2->data;
  if (in3->size[1] == 1) {
    loop_ub = in2->size[0];
  } else {
    loop_ub = in3->size[1];
  }
  i = in1->size[0];
  in1->size[0] = loop_ub;
  emxEnsureCapacity_real_T(sp, in1, i, &xc_emlrtRTEI);
  in1_data = in1->data;
  stride_0_0 = (in2->size[0] != 1);
  stride_1_0 = (in3->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i * stride_0_0] * in3_data[i * stride_1_0];
  }
}

static void c_minus(const emlrtStack *sp, emxArray_real_T *in1,
                    const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &td_emlrtRTEI);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 1;
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  b_in1->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &td_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = in1_data[i * stride_0_1] - in2_data[i * stride_1_1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &td_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void d_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2,
                               const emxArray_real_T *in3, real_T in4)
{
  const real_T *in2_data;
  const real_T *in3_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_1_0;
  in3_data = in3->data;
  in2_data = in2->data;
  if (in3->size[1] == 1) {
    loop_ub = in2->size[0];
  } else {
    loop_ub = in3->size[1];
  }
  i = in1->size[0];
  in1->size[0] = loop_ub;
  emxEnsureCapacity_real_T(sp, in1, i, &wc_emlrtRTEI);
  in1_data = in1->data;
  stride_0_0 = (in2->size[0] != 1);
  stride_1_0 = (in3->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i * stride_0_0] * in3_data[i * stride_1_0] - in4;
  }
}

static void f_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emlrtRSInfo in2,
                               const emxArray_real_T *in3,
                               const emxArray_real_T *in4,
                               const emxArray_real_T *in5,
                               const emxArray_real_T *in6)
{
  emlrtStack st;
  emxArray_real_T *b_in3;
  emxArray_real_T *b_in5;
  const real_T *in3_data;
  const real_T *in4_data;
  const real_T *in5_data;
  const real_T *in6_data;
  real_T *b_in3_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  st.prev = sp;
  st.tls = sp->tls;
  in6_data = in6->data;
  in5_data = in5->data;
  in4_data = in4->data;
  in3_data = in3->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in3, 2, &kc_emlrtRTEI);
  i = b_in3->size[0] * b_in3->size[1];
  b_in3->size[0] = 1;
  if (in4->size[1] == 1) {
    loop_ub = in3->size[1];
  } else {
    loop_ub = in4->size[1];
  }
  b_in3->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in3, i, &kc_emlrtRTEI);
  b_in3_data = b_in3->data;
  stride_0_1 = (in3->size[1] != 1);
  stride_1_1 = (in4->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in3_data[i] = in3_data[i * stride_0_1] - in4_data[i * stride_1_1];
  }
  emxInit_real_T(sp, &b_in5, 2, &mc_emlrtRTEI);
  i = b_in5->size[0] * b_in5->size[1];
  b_in5->size[0] = 1;
  if (in6->size[1] == 1) {
    loop_ub = in5->size[1];
  } else {
    loop_ub = in6->size[1];
  }
  b_in5->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in5, i, &mc_emlrtRTEI);
  b_in3_data = b_in5->data;
  stride_0_1 = (in5->size[1] != 1);
  stride_1_1 = (in6->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in3_data[i] = in5_data[i * stride_0_1] - in6_data[i * stride_1_1];
  }
  st.site = (emlrtRSInfo *)&in2;
  b_atan2(&st, b_in3, b_in5, in1);
  emxFree_real_T(sp, &b_in5);
  emxFree_real_T(sp, &b_in3);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void g_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2,
                               const emxArray_real_T *in3)
{
  const real_T *in2_data;
  const real_T *in3_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  emxEnsureCapacity_real_T(sp, in1, i, &jc_emlrtRTEI);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, in1, i, &jc_emlrtRTEI);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = (in2_data[i * stride_0_1] + in3_data[i * stride_1_1]) / 2.0;
  }
}

static void h_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2, real_T in3)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &mb_emlrtRTEI);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 1;
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  b_in1->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &mb_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = (in1_data[i * stride_0_1] + in2_data[i * stride_1_1]) + in3;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &mb_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void i_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2, real_T in3)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &jb_emlrtRTEI);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 1;
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  b_in1->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &jb_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = (in1_data[i * stride_0_1] - in2_data[i * stride_1_1]) + in3;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &jb_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void j_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               real_T in2, const emxArray_real_T *in3,
                               real_T in4)
{
  emxArray_real_T *c_in2;
  const real_T *in3_data;
  real_T b_in2;
  real_T *in1_data;
  real_T *in2_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_1;
  int32_T stride_1_1;
  in3_data = in3->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  b_in2 = in2 * in4;
  emxInit_real_T(sp, &c_in2, 2, &ud_emlrtRTEI);
  i = c_in2->size[0] * c_in2->size[1];
  c_in2->size[0] = 1;
  if (in3->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  c_in2->size[1] = loop_ub;
  emxEnsureCapacity_real_T(sp, c_in2, i, &ud_emlrtRTEI);
  in2_data = c_in2->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  for (i = 0; i < loop_ub; i++) {
    in2_data[i] =
        -(in2 * (in1_data[i * stride_0_1] + in3_data[i * stride_1_1]) - b_in2);
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = c_in2->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &ud_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = c_in2->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i];
  }
  emxFree_real_T(sp, &c_in2);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void minus(const emlrtStack *sp, emxArray_real_T *in1,
                  const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_1_0;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 1, &rd_emlrtRTEI);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  i = b_in1->size[0];
  b_in1->size[0] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &rd_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_1_0 = (in2->size[0] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = in1_data[i * stride_0_0] - in2_data[i * stride_1_0];
  }
  i = in1->size[0];
  in1->size[0] = b_in1->size[0];
  emxEnsureCapacity_real_T(sp, in1, i, &rd_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[0];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void plus(const emlrtStack *sp, emxArray_real_T *in1,
                 const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T i;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_1_0;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 1, &rd_emlrtRTEI);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  i = b_in1->size[0];
  b_in1->size[0] = loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &rd_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_1_0 = (in2->size[0] != 1);
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = in1_data[i * stride_0_0] + in2_data[i * stride_1_0];
  }
  i = in1->size[0];
  in1->size[0] = b_in1->size[0];
  emxEnsureCapacity_real_T(sp, in1, i, &rd_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[0];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

void trailer2_mei(const emlrtStack *sp, real_T tf, real_T Ts, real_T D_safe,
                  real_T ego_x, real_T ego_y, real_T ego_v, real_T ego_head,
                  real_T ego_l, real_T ego_w, real_T ego_lb,
                  real_T ego_trailer_gamma, real_T ego_trailer_l,
                  real_T ego_trailer_w, real_T tractor_x, real_T tractor_y,
                  real_T tractor_v, real_T tractor_head, real_T tractor_l,
                  real_T tractor_w, real_T tractor_lb, real_T trailer_gamma,
                  real_T trailer_l, real_T trailer_w, real_T *MEI, real_T *TEM,
                  real_T *InDepth)
{
  __m128d r;
  __m128d r4;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
  emlrtStack st;
  emxArray_boolean_T *res_collision;
  emxArray_int32_T *r1;
  emxArray_int32_T *r3;
  emxArray_int32_T *r5;
  emxArray_int32_T *r6;
  emxArray_real_T *b_tractor_x_self_s;
  emxArray_real_T *ego_trailer_center_xr_s;
  emxArray_real_T *ego_trailer_center_yr_s;
  emxArray_real_T *ego_trailer_th;
  emxArray_real_T *ego_trailer_v_s;
  emxArray_real_T *ego_trailer_vr_s;
  emxArray_real_T *res_Dc;
  emxArray_real_T *res_dA;
  emxArray_real_T *res_dB;
  emxArray_real_T *t;
  emxArray_real_T *th;
  emxArray_real_T *tractor_x_self_s;
  emxArray_real_T *tractor_xr_s;
  emxArray_real_T *trailer_center_x;
  emxArray_real_T *trailer_center_y;
  emxArray_real_T *trailer_thr_s;
  emxArray_real_T *trailer_v_s;
  emxArray_real_T *trailer_vr_s;
  emxArray_real_T *trailer_x_self_s;
  emxArray_real_T *trailer_xr_s;
  emxArray_real_T *trailer_y_self_s;
  real_T b_trailer_center_x[2];
  real_T x[2];
  real_T b_tractor_xg0_r_tmp;
  real_T b_tractor_xr0_tmp;
  real_T d;
  real_T tractor_xg0_r;
  real_T tractor_xg0_r_tmp;
  real_T tractor_xr0_tmp;
  real_T tractor_xr0_trans;
  real_T tractor_yg0_r_tmp;
  real_T tractor_yr0_trans;
  real_T *b_tractor_x_self_s_data;
  real_T *ego_trailer_center_xr_s_data;
  real_T *ego_trailer_center_yr_s_data;
  real_T *ego_trailer_th_data;
  real_T *ego_trailer_v_s_data;
  real_T *res_dA_data;
  real_T *t_data;
  real_T *th_data;
  real_T *tractor_x_self_s_data;
  real_T *tractor_xr_s_data;
  real_T *trailer_center_x_data;
  real_T *trailer_center_y_data;
  real_T *trailer_v_s_data;
  real_T *trailer_x_self_s_data;
  real_T *trailer_y_self_s_data;
  int32_T b_i;
  int32_T b_scalarLB_tmp;
  int32_T b_vectorUB_tmp;
  int32_T c_vectorUB_tmp;
  int32_T i;
  int32_T idx;
  int32_T last;
  int32_T loop_ub;
  int32_T scalarLB_tmp;
  int32_T vectorUB_tmp;
  int32_T *r2;
  boolean_T has_collide;
  boolean_T *res_collision_data;
  (void)ego_l;
  (void)ego_w;
  (void)tractor_l;
  (void)tractor_w;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  i_st.prev = &h_st;
  i_st.tls = h_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  /*  仿真参数设置 */
  st.site = &emlrtRSI;
  emxInit_real_T(&st, &t, 2, &j_emlrtRTEI);
  t_data = t->data;
  if (muDoubleScalarIsNaN(Ts) || muDoubleScalarIsNaN(tf)) {
    i = t->size[0] * t->size[1];
    t->size[0] = 1;
    t->size[1] = 1;
    emxEnsureCapacity_real_T(&st, t, i, &j_emlrtRTEI);
    t_data = t->data;
    t_data[0] = rtNaN;
  } else if ((Ts == 0.0) || ((tf > 0.0) && (Ts < 0.0)) ||
             ((tf < 0.0) && (Ts > 0.0))) {
    t->size[0] = 1;
    t->size[1] = 0;
  } else if (muDoubleScalarIsInf(tf) && muDoubleScalarIsInf(Ts)) {
    i = t->size[0] * t->size[1];
    t->size[0] = 1;
    t->size[1] = 1;
    emxEnsureCapacity_real_T(&st, t, i, &j_emlrtRTEI);
    t_data = t->data;
    t_data[0] = rtNaN;
  } else if (muDoubleScalarIsInf(Ts)) {
    i = t->size[0] * t->size[1];
    t->size[0] = 1;
    t->size[1] = 1;
    emxEnsureCapacity_real_T(&st, t, i, &j_emlrtRTEI);
    t_data = t->data;
    t_data[0] = 0.0;
  } else if (muDoubleScalarFloor(Ts) == Ts) {
    i = t->size[0] * t->size[1];
    t->size[0] = 1;
    loop_ub = (int32_T)(tf / Ts);
    t->size[1] = loop_ub + 1;
    emxEnsureCapacity_real_T(&st, t, i, &j_emlrtRTEI);
    t_data = t->data;
    for (i = 0; i <= loop_ub; i++) {
      t_data[i] = Ts * (real_T)i;
    }
  } else {
    b_st.site = &p_emlrtRSI;
    eml_float_colon(&b_st, Ts, tf, t);
    t_data = t->data;
  }
  /*     %% 轨迹解析解与坐标转换 */
  /*  转换牵引车/挂车位置到自车坐标系 */
  tractor_xr0_trans = tractor_x - ego_x;
  tractor_yr0_trans = tractor_y - ego_y;
  tractor_xr0_tmp = muDoubleScalarSin(-ego_head);
  b_tractor_xr0_tmp = muDoubleScalarCos(-ego_head);
  tractor_xg0_r_tmp = tractor_head - ego_head;
  b_tractor_xg0_r_tmp = muDoubleScalarCos(tractor_xg0_r_tmp);
  tractor_xg0_r = (tractor_xr0_trans * b_tractor_xr0_tmp -
                   tractor_yr0_trans * tractor_xr0_tmp) -
                  tractor_lb * b_tractor_xg0_r_tmp;
  tractor_yg0_r_tmp = muDoubleScalarSin(tractor_xg0_r_tmp);
  tractor_yr0_trans = (tractor_xr0_trans * tractor_xr0_tmp +
                       tractor_yr0_trans * b_tractor_xr0_tmp) -
                      tractor_lb * tractor_yg0_r_tmp;
  /*  计算牵引车、挂车轨迹解析解（曳物线） */
  tractor_xg0_r_tmp = tractor_v / trailer_l;
  tractor_xr0_trans =
      muDoubleScalarTan((trailer_gamma + 3.1415926535897931) / 2.0);
  emxInit_real_T(sp, &th, 2, &m_emlrtRTEI);
  i = th->size[0] * th->size[1];
  th->size[0] = 1;
  th->size[1] = t->size[1];
  emxEnsureCapacity_real_T(sp, th, i, &k_emlrtRTEI);
  th_data = th->data;
  loop_ub = t->size[1];
  scalarLB_tmp = (t->size[1] / 2) << 1;
  vectorUB_tmp = scalarLB_tmp - 2;
  for (i = 0; i <= vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&t_data[i]);
    _mm_storeu_pd(&th_data[i], _mm_mul_pd(_mm_set1_pd(tractor_xg0_r_tmp), r));
  }
  for (i = scalarLB_tmp; i < loop_ub; i++) {
    th_data[i] = tractor_xg0_r_tmp * t_data[i];
  }
  st.site = &b_emlrtRSI;
  b_exp(&st, th);
  i = th->size[0] * th->size[1];
  th->size[0] = 1;
  emxEnsureCapacity_real_T(sp, th, i, &l_emlrtRTEI);
  th_data = th->data;
  loop_ub = th->size[1] - 1;
  last = (th->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&th_data[i]);
    _mm_storeu_pd(&th_data[i], _mm_mul_pd(_mm_set1_pd(tractor_xr0_trans), r));
  }
  for (i = last; i <= loop_ub; i++) {
    th_data[i] *= tractor_xr0_trans;
  }
  st.site = &b_emlrtRSI;
  b_atan(&st, th);
  i = th->size[0] * th->size[1];
  th->size[0] = 1;
  emxEnsureCapacity_real_T(sp, th, i, &m_emlrtRTEI);
  th_data = th->data;
  loop_ub = th->size[1] - 1;
  last = (th->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&th_data[i]);
    _mm_storeu_pd(&th_data[i], _mm_sub_pd(_mm_set1_pd(3.1415926535897931),
                                          _mm_mul_pd(_mm_set1_pd(2.0), r)));
  }
  for (i = last; i <= loop_ub; i++) {
    th_data[i] = 3.1415926535897931 - 2.0 * th_data[i];
  }
  idx = th->size[1] - 1;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (th_data[b_i] > 3.1415926535897931) {
      last++;
    }
  }
  emxInit_int32_T(sp, &r1, &jd_emlrtRTEI);
  i = r1->size[0] * r1->size[1];
  r1->size[0] = 1;
  r1->size[1] = last;
  emxEnsureCapacity_int32_T(sp, r1, i, &n_emlrtRTEI);
  r2 = r1->data;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (th_data[b_i] > 3.1415926535897931) {
      r2[last] = b_i;
      last++;
    }
  }
  loop_ub = r1->size[1];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > idx) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, idx, &f_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
  }
  loop_ub = r1->size[1];
  emxInit_real_T(sp, &res_dA, 1, &ed_emlrtRTEI);
  i = res_dA->size[0];
  res_dA->size[0] = r1->size[1];
  emxEnsureCapacity_real_T(sp, res_dA, i, &o_emlrtRTEI);
  res_dA_data = res_dA->data;
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = th_data[r2[i]] - 6.2831853071795862;
  }
  loop_ub = res_dA->size[0];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > th->size[1] - 1) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, th->size[1] - 1, &g_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    th_data[r2[i]] = res_dA_data[i];
  }
  emxFree_int32_T(sp, &r1);
  idx = th->size[1] - 1;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (th_data[b_i] < -3.1415926535897931) {
      last++;
    }
  }
  emxInit_int32_T(sp, &r3, &kd_emlrtRTEI);
  i = r3->size[0] * r3->size[1];
  r3->size[0] = 1;
  r3->size[1] = last;
  emxEnsureCapacity_int32_T(sp, r3, i, &n_emlrtRTEI);
  r2 = r3->data;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (th_data[b_i] < -3.1415926535897931) {
      r2[last] = b_i;
      last++;
    }
  }
  loop_ub = r3->size[1];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > idx) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, idx, &h_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
  }
  loop_ub = r3->size[1];
  i = res_dA->size[0];
  res_dA->size[0] = r3->size[1];
  emxEnsureCapacity_real_T(sp, res_dA, i, &p_emlrtRTEI);
  res_dA_data = res_dA->data;
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = th_data[r2[i]] + 6.2831853071795862;
  }
  loop_ub = res_dA->size[0];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > th->size[1] - 1) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, th->size[1] - 1, &i_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    th_data[r2[i]] = res_dA_data[i];
  }
  emxFree_int32_T(sp, &r3);
  emxInit_real_T(sp, &trailer_x_self_s, 2, &s_emlrtRTEI);
  i = trailer_x_self_s->size[0] * trailer_x_self_s->size[1];
  trailer_x_self_s->size[0] = 1;
  trailer_x_self_s->size[1] = th->size[1];
  emxEnsureCapacity_real_T(sp, trailer_x_self_s, i, &q_emlrtRTEI);
  trailer_x_self_s_data = trailer_x_self_s->data;
  loop_ub = th->size[1];
  last = (th->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&th_data[i]);
    _mm_storeu_pd(&trailer_x_self_s_data[i], _mm_div_pd(r, _mm_set1_pd(2.0)));
  }
  for (i = last; i < loop_ub; i++) {
    trailer_x_self_s_data[i] = th_data[i] / 2.0;
  }
  st.site = &c_emlrtRSI;
  b_tan(&st, trailer_x_self_s);
  st.site = &c_emlrtRSI;
  b_log(&st, trailer_x_self_s);
  emxInit_real_T(sp, &tractor_x_self_s, 2, &kc_emlrtRTEI);
  i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
  tractor_x_self_s->size[0] = 1;
  tractor_x_self_s->size[1] = th->size[1];
  emxEnsureCapacity_real_T(sp, tractor_x_self_s, i, &r_emlrtRTEI);
  tractor_x_self_s_data = tractor_x_self_s->data;
  loop_ub = th->size[1];
  for (i = 0; i < loop_ub; i++) {
    tractor_x_self_s_data[i] = th_data[i];
  }
  st.site = &c_emlrtRSI;
  b_cos(&st, tractor_x_self_s);
  tractor_x_self_s_data = tractor_x_self_s->data;
  if ((trailer_x_self_s->size[1] != tractor_x_self_s->size[1]) &&
      ((trailer_x_self_s->size[1] != 1) && (tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_x_self_s->size[1],
                                tractor_x_self_s->size[1], &emlrtECI,
                                (emlrtConstCTX)sp);
  }
  d = muDoubleScalarTan(-trailer_gamma / 2.0);
  st.site = &c_emlrtRSI;
  if (d < 0.0) {
    emlrtErrorWithMessageIdR2018a(
        &st, &h_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 3, "log");
  }
  d = muDoubleScalarLog(d);
  if (trailer_x_self_s->size[1] == tractor_x_self_s->size[1]) {
    tractor_xg0_r_tmp = trailer_l * d;
    loop_ub = trailer_x_self_s->size[1] - 1;
    i = trailer_x_self_s->size[0] * trailer_x_self_s->size[1];
    trailer_x_self_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, trailer_x_self_s, i, &s_emlrtRTEI);
    trailer_x_self_s_data = trailer_x_self_s->data;
    last = (trailer_x_self_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&trailer_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&tractor_x_self_s_data[i]);
      _mm_storeu_pd(&trailer_x_self_s_data[i],
                    _mm_mul_pd(_mm_sub_pd(_mm_mul_pd(_mm_set1_pd(trailer_l),
                                                     _mm_add_pd(r, r4)),
                                          _mm_set1_pd(tractor_xg0_r_tmp)),
                               _mm_set1_pd(-1.0)));
    }
    for (i = last; i <= loop_ub; i++) {
      trailer_x_self_s_data[i] =
          -(trailer_l * (trailer_x_self_s_data[i] + tractor_x_self_s_data[i]) -
            tractor_xg0_r_tmp);
    }
  } else {
    st.site = &c_emlrtRSI;
    j_binary_expand_op(&st, trailer_x_self_s, trailer_l, tractor_x_self_s, d);
    trailer_x_self_s_data = trailer_x_self_s->data;
  }
  emxInit_real_T(sp, &trailer_y_self_s, 2, &u_emlrtRTEI);
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  trailer_y_self_s->size[1] = th->size[1];
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &t_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = th->size[1];
  for (i = 0; i < loop_ub; i++) {
    trailer_y_self_s_data[i] = th_data[i];
  }
  st.site = &d_emlrtRSI;
  b_sin(&st, trailer_y_self_s);
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &u_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = trailer_y_self_s->size[1] - 1;
  last = (trailer_y_self_s->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&trailer_y_self_s_data[i]);
    _mm_storeu_pd(
        &trailer_y_self_s_data[i],
        _mm_mul_pd(_mm_mul_pd(_mm_set1_pd(trailer_l), r), _mm_set1_pd(-1.0)));
  }
  for (i = last; i <= loop_ub; i++) {
    trailer_y_self_s_data[i] = -(trailer_l * trailer_y_self_s_data[i]);
  }
  /*  计算自车挂车转向角度解析解（曳物线） */
  tractor_xg0_r_tmp = ego_v / ego_trailer_l;
  tractor_xr0_trans =
      muDoubleScalarTan((ego_trailer_gamma + 3.1415926535897931) / 2.0);
  emxInit_real_T(sp, &ego_trailer_th, 2, &x_emlrtRTEI);
  i = ego_trailer_th->size[0] * ego_trailer_th->size[1];
  ego_trailer_th->size[0] = 1;
  ego_trailer_th->size[1] = t->size[1];
  emxEnsureCapacity_real_T(sp, ego_trailer_th, i, &v_emlrtRTEI);
  ego_trailer_th_data = ego_trailer_th->data;
  loop_ub = t->size[1];
  for (i = 0; i <= vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&t_data[i]);
    _mm_storeu_pd(&ego_trailer_th_data[i],
                  _mm_mul_pd(_mm_set1_pd(tractor_xg0_r_tmp), r));
  }
  for (i = scalarLB_tmp; i < loop_ub; i++) {
    ego_trailer_th_data[i] = tractor_xg0_r_tmp * t_data[i];
  }
  st.site = &e_emlrtRSI;
  b_exp(&st, ego_trailer_th);
  i = ego_trailer_th->size[0] * ego_trailer_th->size[1];
  ego_trailer_th->size[0] = 1;
  emxEnsureCapacity_real_T(sp, ego_trailer_th, i, &w_emlrtRTEI);
  ego_trailer_th_data = ego_trailer_th->data;
  loop_ub = ego_trailer_th->size[1] - 1;
  last = (ego_trailer_th->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&ego_trailer_th_data[i]);
    _mm_storeu_pd(&ego_trailer_th_data[i],
                  _mm_mul_pd(_mm_set1_pd(tractor_xr0_trans), r));
  }
  for (i = last; i <= loop_ub; i++) {
    ego_trailer_th_data[i] *= tractor_xr0_trans;
  }
  st.site = &e_emlrtRSI;
  b_atan(&st, ego_trailer_th);
  i = ego_trailer_th->size[0] * ego_trailer_th->size[1];
  ego_trailer_th->size[0] = 1;
  emxEnsureCapacity_real_T(sp, ego_trailer_th, i, &x_emlrtRTEI);
  ego_trailer_th_data = ego_trailer_th->data;
  loop_ub = ego_trailer_th->size[1] - 1;
  last = (ego_trailer_th->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&ego_trailer_th_data[i]);
    _mm_storeu_pd(&ego_trailer_th_data[i],
                  _mm_sub_pd(_mm_set1_pd(3.1415926535897931),
                             _mm_mul_pd(_mm_set1_pd(2.0), r)));
  }
  for (i = last; i <= loop_ub; i++) {
    ego_trailer_th_data[i] = 3.1415926535897931 - 2.0 * ego_trailer_th_data[i];
  }
  idx = ego_trailer_th->size[1] - 1;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (ego_trailer_th_data[b_i] > 3.1415926535897931) {
      last++;
    }
  }
  emxInit_int32_T(sp, &r5, &ld_emlrtRTEI);
  i = r5->size[0] * r5->size[1];
  r5->size[0] = 1;
  r5->size[1] = last;
  emxEnsureCapacity_int32_T(sp, r5, i, &n_emlrtRTEI);
  r2 = r5->data;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (ego_trailer_th_data[b_i] > 3.1415926535897931) {
      r2[last] = b_i;
      last++;
    }
  }
  loop_ub = r5->size[1];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > idx) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, idx, &j_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
  }
  loop_ub = r5->size[1];
  i = res_dA->size[0];
  res_dA->size[0] = r5->size[1];
  emxEnsureCapacity_real_T(sp, res_dA, i, &y_emlrtRTEI);
  res_dA_data = res_dA->data;
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = ego_trailer_th_data[r2[i]] - 6.2831853071795862;
  }
  loop_ub = res_dA->size[0];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > ego_trailer_th->size[1] - 1) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, ego_trailer_th->size[1] - 1,
                                    &k_emlrtBCI, (emlrtConstCTX)sp);
    }
    ego_trailer_th_data[r2[i]] = res_dA_data[i];
  }
  emxFree_int32_T(sp, &r5);
  idx = ego_trailer_th->size[1] - 1;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (ego_trailer_th_data[b_i] < -3.1415926535897931) {
      last++;
    }
  }
  emxInit_int32_T(sp, &r6, &md_emlrtRTEI);
  i = r6->size[0] * r6->size[1];
  r6->size[0] = 1;
  r6->size[1] = last;
  emxEnsureCapacity_int32_T(sp, r6, i, &n_emlrtRTEI);
  r2 = r6->data;
  last = 0;
  for (b_i = 0; b_i <= idx; b_i++) {
    if (ego_trailer_th_data[b_i] < -3.1415926535897931) {
      r2[last] = b_i;
      last++;
    }
  }
  loop_ub = r6->size[1];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > idx) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, idx, &l_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
  }
  loop_ub = r6->size[1];
  i = res_dA->size[0];
  res_dA->size[0] = r6->size[1];
  emxEnsureCapacity_real_T(sp, res_dA, i, &ab_emlrtRTEI);
  res_dA_data = res_dA->data;
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = ego_trailer_th_data[r2[i]] + 6.2831853071795862;
  }
  loop_ub = res_dA->size[0];
  for (i = 0; i < loop_ub; i++) {
    if (r2[i] > ego_trailer_th->size[1] - 1) {
      emlrtDynamicBoundsCheckR2012b(r2[i], 0, ego_trailer_th->size[1] - 1,
                                    &m_emlrtBCI, (emlrtConstCTX)sp);
    }
    ego_trailer_th_data[r2[i]] = res_dA_data[i];
  }
  emxFree_int32_T(sp, &r6);
  /*  将解析解旋转+平移到自车坐标系下 */
  emxInit_real_T(sp, &trailer_xr_s, 2, &db_emlrtRTEI);
  i = trailer_xr_s->size[0] * trailer_xr_s->size[1];
  trailer_xr_s->size[0] = 1;
  trailer_xr_s->size[1] = trailer_x_self_s->size[1];
  emxEnsureCapacity_real_T(sp, trailer_xr_s, i, &bb_emlrtRTEI);
  res_dA_data = trailer_xr_s->data;
  loop_ub = trailer_x_self_s->size[1];
  b_i = (trailer_x_self_s->size[1] / 2) << 1;
  b_vectorUB_tmp = b_i - 2;
  for (i = 0; i <= b_vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&trailer_x_self_s_data[i]);
    _mm_storeu_pd(&res_dA_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(b_tractor_xg0_r_tmp)));
  }
  for (i = b_i; i < loop_ub; i++) {
    res_dA_data[i] = trailer_x_self_s_data[i] * b_tractor_xg0_r_tmp;
  }
  i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
  tractor_x_self_s->size[0] = 1;
  tractor_x_self_s->size[1] = trailer_y_self_s->size[1];
  emxEnsureCapacity_real_T(sp, tractor_x_self_s, i, &cb_emlrtRTEI);
  tractor_x_self_s_data = tractor_x_self_s->data;
  loop_ub = trailer_y_self_s->size[1];
  b_scalarLB_tmp = (trailer_y_self_s->size[1] / 2) << 1;
  c_vectorUB_tmp = b_scalarLB_tmp - 2;
  for (i = 0; i <= c_vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&trailer_y_self_s_data[i]);
    _mm_storeu_pd(&tractor_x_self_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(tractor_yg0_r_tmp)));
  }
  for (i = b_scalarLB_tmp; i < loop_ub; i++) {
    tractor_x_self_s_data[i] = trailer_y_self_s_data[i] * tractor_yg0_r_tmp;
  }
  if ((trailer_xr_s->size[1] != tractor_x_self_s->size[1]) &&
      ((trailer_xr_s->size[1] != 1) && (tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_xr_s->size[1],
                                tractor_x_self_s->size[1], &b_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (trailer_xr_s->size[1] == tractor_x_self_s->size[1]) {
    loop_ub = trailer_xr_s->size[1] - 1;
    i = trailer_xr_s->size[0] * trailer_xr_s->size[1];
    trailer_xr_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, trailer_xr_s, i, &db_emlrtRTEI);
    res_dA_data = trailer_xr_s->data;
    last = (trailer_xr_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&tractor_x_self_s_data[i]);
      _mm_storeu_pd(&res_dA_data[i],
                    _mm_add_pd(_mm_sub_pd(r, r4), _mm_set1_pd(tractor_xg0_r)));
    }
    for (i = last; i <= loop_ub; i++) {
      res_dA_data[i] =
          (res_dA_data[i] - tractor_x_self_s_data[i]) + tractor_xg0_r;
    }
  } else {
    st.site = &dc_emlrtRSI;
    i_binary_expand_op(&st, trailer_xr_s, tractor_x_self_s, tractor_xg0_r);
  }
  i = trailer_x_self_s->size[0] * trailer_x_self_s->size[1];
  trailer_x_self_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, trailer_x_self_s, i, &eb_emlrtRTEI);
  trailer_x_self_s_data = trailer_x_self_s->data;
  loop_ub = trailer_x_self_s->size[1] - 1;
  for (i = 0; i <= b_vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&trailer_x_self_s_data[i]);
    _mm_storeu_pd(&trailer_x_self_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(tractor_yg0_r_tmp)));
  }
  for (i = b_i; i <= loop_ub; i++) {
    trailer_x_self_s_data[i] *= tractor_yg0_r_tmp;
  }
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &fb_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = trailer_y_self_s->size[1] - 1;
  for (i = 0; i <= c_vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&trailer_y_self_s_data[i]);
    _mm_storeu_pd(&trailer_y_self_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(b_tractor_xg0_r_tmp)));
  }
  for (i = b_scalarLB_tmp; i <= loop_ub; i++) {
    trailer_y_self_s_data[i] *= b_tractor_xg0_r_tmp;
  }
  if ((trailer_x_self_s->size[1] != trailer_y_self_s->size[1]) &&
      ((trailer_x_self_s->size[1] != 1) && (trailer_y_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_x_self_s->size[1],
                                trailer_y_self_s->size[1], &c_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (trailer_x_self_s->size[1] == trailer_y_self_s->size[1]) {
    loop_ub = trailer_x_self_s->size[1] - 1;
    i = trailer_x_self_s->size[0] * trailer_x_self_s->size[1];
    trailer_x_self_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, trailer_x_self_s, i, &gb_emlrtRTEI);
    trailer_x_self_s_data = trailer_x_self_s->data;
    last = (trailer_x_self_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&trailer_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&trailer_y_self_s_data[i]);
      _mm_storeu_pd(
          &trailer_x_self_s_data[i],
          _mm_add_pd(_mm_add_pd(r, r4), _mm_set1_pd(tractor_yr0_trans)));
    }
    for (i = last; i <= loop_ub; i++) {
      trailer_x_self_s_data[i] =
          (trailer_x_self_s_data[i] + trailer_y_self_s_data[i]) +
          tractor_yr0_trans;
    }
  } else {
    st.site = &bc_emlrtRSI;
    h_binary_expand_op(&st, trailer_x_self_s, trailer_y_self_s,
                       tractor_yr0_trans);
    trailer_x_self_s_data = trailer_x_self_s->data;
  }
  emxInit_real_T(sp, &b_tractor_x_self_s, 2, &hb_emlrtRTEI);
  i = b_tractor_x_self_s->size[0] * b_tractor_x_self_s->size[1];
  b_tractor_x_self_s->size[0] = 1;
  b_tractor_x_self_s->size[1] = t->size[1];
  emxEnsureCapacity_real_T(sp, b_tractor_x_self_s, i, &hb_emlrtRTEI);
  b_tractor_x_self_s_data = b_tractor_x_self_s->data;
  loop_ub = t->size[1];
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  trailer_y_self_s->size[1] = t->size[1];
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &ib_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  for (i = 0; i <= vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&t_data[i]);
    _mm_storeu_pd(&b_tractor_x_self_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(tractor_v)));
    _mm_storeu_pd(&trailer_y_self_s_data[i], _mm_mul_pd(_mm_set1_pd(0.0), r));
  }
  for (i = scalarLB_tmp; i < loop_ub; i++) {
    d = t_data[i];
    b_tractor_x_self_s_data[i] = d * tractor_v;
    trailer_y_self_s_data[i] = 0.0 * d;
  }
  emxInit_real_T(sp, &tractor_xr_s, 2, &lb_emlrtRTEI);
  i = tractor_xr_s->size[0] * tractor_xr_s->size[1];
  tractor_xr_s->size[0] = 1;
  tractor_xr_s->size[1] = b_tractor_x_self_s->size[1];
  emxEnsureCapacity_real_T(sp, tractor_xr_s, i, &jb_emlrtRTEI);
  tractor_xr_s_data = tractor_xr_s->data;
  loop_ub = b_tractor_x_self_s->size[1];
  i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
  tractor_x_self_s->size[0] = 1;
  tractor_x_self_s->size[1] = trailer_y_self_s->size[1];
  emxEnsureCapacity_real_T(sp, tractor_x_self_s, i, &kb_emlrtRTEI);
  tractor_x_self_s_data = tractor_x_self_s->data;
  b_i = (b_tractor_x_self_s->size[1] / 2) << 1;
  b_vectorUB_tmp = b_i - 2;
  for (i = 0; i <= b_vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
    _mm_storeu_pd(&tractor_xr_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(b_tractor_xg0_r_tmp)));
    r = _mm_loadu_pd(&trailer_y_self_s_data[i]);
    _mm_storeu_pd(&tractor_x_self_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(tractor_yg0_r_tmp)));
  }
  for (i = b_i; i < loop_ub; i++) {
    tractor_xr_s_data[i] = b_tractor_x_self_s_data[i] * b_tractor_xg0_r_tmp;
    tractor_x_self_s_data[i] = trailer_y_self_s_data[i] * tractor_yg0_r_tmp;
  }
  if ((tractor_xr_s->size[1] != tractor_x_self_s->size[1]) &&
      ((tractor_xr_s->size[1] != 1) && (tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(tractor_xr_s->size[1],
                                tractor_x_self_s->size[1], &d_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (tractor_xr_s->size[1] == tractor_x_self_s->size[1]) {
    loop_ub = tractor_xr_s->size[1] - 1;
    i = tractor_xr_s->size[0] * tractor_xr_s->size[1];
    tractor_xr_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, tractor_xr_s, i, &lb_emlrtRTEI);
    tractor_xr_s_data = tractor_xr_s->data;
    last = (tractor_xr_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&tractor_xr_s_data[i]);
      r4 = _mm_loadu_pd(&tractor_x_self_s_data[i]);
      _mm_storeu_pd(&tractor_xr_s_data[i],
                    _mm_add_pd(_mm_sub_pd(r, r4), _mm_set1_pd(tractor_xg0_r)));
    }
    for (i = last; i <= loop_ub; i++) {
      tractor_xr_s_data[i] =
          (tractor_xr_s_data[i] - tractor_x_self_s_data[i]) + tractor_xg0_r;
    }
  } else {
    st.site = &ec_emlrtRSI;
    i_binary_expand_op(&st, tractor_xr_s, tractor_x_self_s, tractor_xg0_r);
  }
  i = b_tractor_x_self_s->size[0] * b_tractor_x_self_s->size[1];
  b_tractor_x_self_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, b_tractor_x_self_s, i, &mb_emlrtRTEI);
  b_tractor_x_self_s_data = b_tractor_x_self_s->data;
  loop_ub = b_tractor_x_self_s->size[1] - 1;
  for (i = 0; i <= b_vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
    _mm_storeu_pd(&b_tractor_x_self_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(tractor_yg0_r_tmp)));
  }
  for (i = b_i; i <= loop_ub; i++) {
    b_tractor_x_self_s_data[i] *= tractor_yg0_r_tmp;
  }
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &nb_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = trailer_y_self_s->size[1] - 1;
  last = (trailer_y_self_s->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&trailer_y_self_s_data[i]);
    _mm_storeu_pd(&trailer_y_self_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(b_tractor_xg0_r_tmp)));
  }
  for (i = last; i <= loop_ub; i++) {
    trailer_y_self_s_data[i] *= b_tractor_xg0_r_tmp;
  }
  if ((b_tractor_x_self_s->size[1] != trailer_y_self_s->size[1]) &&
      ((b_tractor_x_self_s->size[1] != 1) &&
       (trailer_y_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(b_tractor_x_self_s->size[1],
                                trailer_y_self_s->size[1], &e_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (b_tractor_x_self_s->size[1] == trailer_y_self_s->size[1]) {
    loop_ub = b_tractor_x_self_s->size[1] - 1;
    i = b_tractor_x_self_s->size[0] * b_tractor_x_self_s->size[1];
    b_tractor_x_self_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, b_tractor_x_self_s, i, &ob_emlrtRTEI);
    b_tractor_x_self_s_data = b_tractor_x_self_s->data;
    last = (b_tractor_x_self_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&trailer_y_self_s_data[i]);
      _mm_storeu_pd(
          &b_tractor_x_self_s_data[i],
          _mm_add_pd(_mm_add_pd(r, r4), _mm_set1_pd(tractor_yr0_trans)));
    }
    for (i = last; i <= loop_ub; i++) {
      b_tractor_x_self_s_data[i] =
          (b_tractor_x_self_s_data[i] + trailer_y_self_s_data[i]) +
          tractor_yr0_trans;
    }
  } else {
    st.site = &cc_emlrtRSI;
    h_binary_expand_op(&st, b_tractor_x_self_s, trailer_y_self_s,
                       tractor_yr0_trans);
    b_tractor_x_self_s_data = b_tractor_x_self_s->data;
  }
  emxInit_real_T(sp, &ego_trailer_center_xr_s, 2, &tb_emlrtRTEI);
  i = ego_trailer_center_xr_s->size[0] * ego_trailer_center_xr_s->size[1];
  ego_trailer_center_xr_s->size[0] = 1;
  ego_trailer_center_xr_s->size[1] = ego_trailer_th->size[1];
  emxEnsureCapacity_real_T(sp, ego_trailer_center_xr_s, i, &pb_emlrtRTEI);
  ego_trailer_center_xr_s_data = ego_trailer_center_xr_s->data;
  loop_ub = ego_trailer_th->size[1];
  for (i = 0; i < loop_ub; i++) {
    ego_trailer_center_xr_s_data[i] = ego_trailer_th_data[i];
  }
  st.site = &f_emlrtRSI;
  b_cos(&st, ego_trailer_center_xr_s);
  i = ego_trailer_center_xr_s->size[0] * ego_trailer_center_xr_s->size[1];
  ego_trailer_center_xr_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, ego_trailer_center_xr_s, i, &qb_emlrtRTEI);
  ego_trailer_center_xr_s_data = ego_trailer_center_xr_s->data;
  loop_ub = ego_trailer_center_xr_s->size[1] - 1;
  last = (ego_trailer_center_xr_s->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&ego_trailer_center_xr_s_data[i]);
    _mm_storeu_pd(&ego_trailer_center_xr_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(-1.0)));
  }
  for (i = last; i <= loop_ub; i++) {
    ego_trailer_center_xr_s_data[i] = -ego_trailer_center_xr_s_data[i];
  }
  emxInit_real_T(sp, &ego_trailer_center_yr_s, 2, &ub_emlrtRTEI);
  i = ego_trailer_center_yr_s->size[0] * ego_trailer_center_yr_s->size[1];
  ego_trailer_center_yr_s->size[0] = 1;
  ego_trailer_center_yr_s->size[1] = ego_trailer_th->size[1];
  emxEnsureCapacity_real_T(sp, ego_trailer_center_yr_s, i, &rb_emlrtRTEI);
  ego_trailer_center_yr_s_data = ego_trailer_center_yr_s->data;
  loop_ub = ego_trailer_th->size[1];
  for (i = 0; i < loop_ub; i++) {
    ego_trailer_center_yr_s_data[i] = ego_trailer_th_data[i];
  }
  st.site = &g_emlrtRSI;
  b_sin(&st, ego_trailer_center_yr_s);
  i = ego_trailer_center_yr_s->size[0] * ego_trailer_center_yr_s->size[1];
  ego_trailer_center_yr_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, ego_trailer_center_yr_s, i, &sb_emlrtRTEI);
  ego_trailer_center_yr_s_data = ego_trailer_center_yr_s->data;
  loop_ub = ego_trailer_center_yr_s->size[1] - 1;
  last = (ego_trailer_center_yr_s->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&ego_trailer_center_yr_s_data[i]);
    _mm_storeu_pd(&ego_trailer_center_yr_s_data[i],
                  _mm_mul_pd(r, _mm_set1_pd(-1.0)));
  }
  for (i = last; i <= loop_ub; i++) {
    ego_trailer_center_yr_s_data[i] = -ego_trailer_center_yr_s_data[i];
  }
  i = ego_trailer_center_xr_s->size[0] * ego_trailer_center_xr_s->size[1];
  ego_trailer_center_xr_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, ego_trailer_center_xr_s, i, &tb_emlrtRTEI);
  ego_trailer_center_xr_s_data = ego_trailer_center_xr_s->data;
  tractor_xg0_r_tmp = ego_lb / 2.0;
  loop_ub = ego_trailer_center_xr_s->size[1] - 1;
  last = (ego_trailer_center_xr_s->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&ego_trailer_center_xr_s_data[i]);
    _mm_storeu_pd(
        &ego_trailer_center_xr_s_data[i],
        _mm_sub_pd(
            _mm_div_pd(_mm_sub_pd(_mm_mul_pd(r, _mm_set1_pd(ego_trailer_l)),
                                  _mm_set1_pd(ego_lb)),
                       _mm_set1_pd(2.0)),
            _mm_set1_pd(tractor_xg0_r_tmp)));
  }
  for (i = last; i <= loop_ub; i++) {
    ego_trailer_center_xr_s_data[i] =
        (ego_trailer_center_xr_s_data[i] * ego_trailer_l - ego_lb) / 2.0 -
        tractor_xg0_r_tmp;
  }
  i = ego_trailer_center_yr_s->size[0] * ego_trailer_center_yr_s->size[1];
  ego_trailer_center_yr_s->size[0] = 1;
  emxEnsureCapacity_real_T(sp, ego_trailer_center_yr_s, i, &ub_emlrtRTEI);
  ego_trailer_center_yr_s_data = ego_trailer_center_yr_s->data;
  loop_ub = ego_trailer_center_yr_s->size[1] - 1;
  last = (ego_trailer_center_yr_s->size[1] / 2) << 1;
  idx = last - 2;
  for (i = 0; i <= idx; i += 2) {
    r = _mm_loadu_pd(&ego_trailer_center_yr_s_data[i]);
    _mm_storeu_pd(&ego_trailer_center_yr_s_data[i],
                  _mm_div_pd(_mm_mul_pd(r, _mm_set1_pd(ego_trailer_l)),
                             _mm_set1_pd(2.0)));
  }
  for (i = last; i <= loop_ub; i++) {
    ego_trailer_center_yr_s_data[i] =
        ego_trailer_center_yr_s_data[i] * ego_trailer_l / 2.0;
  }
  /*  计算挂车速度幅值序列 */
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  trailer_y_self_s->size[1] = th->size[1];
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &vb_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = th->size[1];
  for (i = 0; i < loop_ub; i++) {
    trailer_y_self_s_data[i] = th_data[i];
  }
  st.site = &h_emlrtRSI;
  b_cos(&st, trailer_y_self_s);
  trailer_y_self_s_data = trailer_y_self_s->data;
  st.site = &h_emlrtRSI;
  b_st.site = &bb_emlrtRSI;
  emxInit_real_T(&b_st, &trailer_v_s, 2, &ac_emlrtRTEI);
  i = trailer_v_s->size[0] * trailer_v_s->size[1];
  trailer_v_s->size[0] = 1;
  trailer_v_s->size[1] = trailer_y_self_s->size[1];
  emxEnsureCapacity_real_T(&b_st, trailer_v_s, i, &wb_emlrtRTEI);
  trailer_v_s_data = trailer_v_s->data;
  loop_ub = trailer_y_self_s->size[1];
  for (i = 0; i < loop_ub; i++) {
    tractor_xg0_r_tmp = tractor_v * trailer_y_self_s_data[i];
    trailer_v_s_data[i] = tractor_xg0_r_tmp * tractor_xg0_r_tmp;
  }
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  trailer_y_self_s->size[1] = th->size[1];
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &xb_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = th->size[1];
  for (i = 0; i < loop_ub; i++) {
    trailer_y_self_s_data[i] = th_data[i];
  }
  st.site = &h_emlrtRSI;
  b_sin(&st, trailer_y_self_s);
  trailer_y_self_s_data = trailer_y_self_s->data;
  st.site = &h_emlrtRSI;
  b_st.site = &bb_emlrtRSI;
  i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
  tractor_x_self_s->size[0] = 1;
  tractor_x_self_s->size[1] = trailer_y_self_s->size[1];
  emxEnsureCapacity_real_T(&b_st, tractor_x_self_s, i, &yb_emlrtRTEI);
  tractor_x_self_s_data = tractor_x_self_s->data;
  loop_ub = trailer_y_self_s->size[1];
  for (i = 0; i < loop_ub; i++) {
    tractor_xg0_r_tmp = tractor_v * trailer_y_self_s_data[i] / 2.0;
    tractor_x_self_s_data[i] = tractor_xg0_r_tmp * tractor_xg0_r_tmp;
  }
  if ((trailer_v_s->size[1] != tractor_x_self_s->size[1]) &&
      ((trailer_v_s->size[1] != 1) && (tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_v_s->size[1], tractor_x_self_s->size[1],
                                &f_emlrtECI, (emlrtConstCTX)sp);
  }
  if (trailer_v_s->size[1] == tractor_x_self_s->size[1]) {
    loop_ub = trailer_v_s->size[1] - 1;
    i = trailer_v_s->size[0] * trailer_v_s->size[1];
    trailer_v_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, trailer_v_s, i, &ac_emlrtRTEI);
    trailer_v_s_data = trailer_v_s->data;
    last = (trailer_v_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&trailer_v_s_data[i]);
      r4 = _mm_loadu_pd(&tractor_x_self_s_data[i]);
      _mm_storeu_pd(&trailer_v_s_data[i], _mm_add_pd(r, r4));
    }
    for (i = last; i <= loop_ub; i++) {
      trailer_v_s_data[i] += tractor_x_self_s_data[i];
    }
  } else {
    b_plus(sp, trailer_v_s, tractor_x_self_s);
  }
  st.site = &h_emlrtRSI;
  b_sqrt(&st, trailer_v_s);
  trailer_v_s_data = trailer_v_s->data;
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  trailer_y_self_s->size[1] = th->size[1];
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &bc_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = th->size[1];
  for (i = 0; i < loop_ub; i++) {
    trailer_y_self_s_data[i] = th_data[i];
  }
  st.site = &i_emlrtRSI;
  b_cos(&st, trailer_y_self_s);
  trailer_y_self_s_data = trailer_y_self_s->data;
  st.site = &i_emlrtRSI;
  b_st.site = &bb_emlrtRSI;
  emxInit_real_T(&b_st, &ego_trailer_v_s, 2, &ec_emlrtRTEI);
  i = ego_trailer_v_s->size[0] * ego_trailer_v_s->size[1];
  ego_trailer_v_s->size[0] = 1;
  ego_trailer_v_s->size[1] = trailer_y_self_s->size[1];
  emxEnsureCapacity_real_T(&b_st, ego_trailer_v_s, i, &cc_emlrtRTEI);
  ego_trailer_v_s_data = ego_trailer_v_s->data;
  loop_ub = trailer_y_self_s->size[1];
  for (i = 0; i < loop_ub; i++) {
    tractor_xg0_r_tmp = ego_v * trailer_y_self_s_data[i];
    ego_trailer_v_s_data[i] = tractor_xg0_r_tmp * tractor_xg0_r_tmp;
  }
  st.site = &i_emlrtRSI;
  b_sin(&st, th);
  th_data = th->data;
  st.site = &i_emlrtRSI;
  b_st.site = &bb_emlrtRSI;
  i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
  tractor_x_self_s->size[0] = 1;
  tractor_x_self_s->size[1] = th->size[1];
  emxEnsureCapacity_real_T(&b_st, tractor_x_self_s, i, &dc_emlrtRTEI);
  tractor_x_self_s_data = tractor_x_self_s->data;
  loop_ub = th->size[1];
  for (i = 0; i < loop_ub; i++) {
    tractor_xg0_r_tmp = ego_v * th_data[i] / 2.0;
    tractor_x_self_s_data[i] = tractor_xg0_r_tmp * tractor_xg0_r_tmp;
  }
  if ((ego_trailer_v_s->size[1] != tractor_x_self_s->size[1]) &&
      ((ego_trailer_v_s->size[1] != 1) && (tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ego_trailer_v_s->size[1],
                                tractor_x_self_s->size[1], &g_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (ego_trailer_v_s->size[1] == tractor_x_self_s->size[1]) {
    loop_ub = ego_trailer_v_s->size[1] - 1;
    i = ego_trailer_v_s->size[0] * ego_trailer_v_s->size[1];
    ego_trailer_v_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, ego_trailer_v_s, i, &ec_emlrtRTEI);
    ego_trailer_v_s_data = ego_trailer_v_s->data;
    last = (ego_trailer_v_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&ego_trailer_v_s_data[i]);
      r4 = _mm_loadu_pd(&tractor_x_self_s_data[i]);
      _mm_storeu_pd(&ego_trailer_v_s_data[i], _mm_add_pd(r, r4));
    }
    for (i = last; i <= loop_ub; i++) {
      ego_trailer_v_s_data[i] += tractor_x_self_s_data[i];
    }
  } else {
    b_plus(sp, ego_trailer_v_s, tractor_x_self_s);
  }
  st.site = &i_emlrtRSI;
  b_sqrt(&st, ego_trailer_v_s);
  ego_trailer_v_s_data = ego_trailer_v_s->data;
  /*  将牵引车挂车坐标时空投影到自车坐标 */
  i = trailer_y_self_s->size[0] * trailer_y_self_s->size[1];
  trailer_y_self_s->size[0] = 1;
  trailer_y_self_s->size[1] = t->size[1];
  emxEnsureCapacity_real_T(sp, trailer_y_self_s, i, &fc_emlrtRTEI);
  trailer_y_self_s_data = trailer_y_self_s->data;
  loop_ub = t->size[1];
  for (i = 0; i <= vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&t_data[i]);
    _mm_storeu_pd(&trailer_y_self_s_data[i], _mm_mul_pd(_mm_set1_pd(ego_v), r));
  }
  for (i = scalarLB_tmp; i < loop_ub; i++) {
    trailer_y_self_s_data[i] = ego_v * t_data[i];
  }
  if ((trailer_xr_s->size[1] != trailer_y_self_s->size[1]) &&
      ((trailer_xr_s->size[1] != 1) && (trailer_y_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_xr_s->size[1],
                                trailer_y_self_s->size[1], &h_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (trailer_xr_s->size[1] == trailer_y_self_s->size[1]) {
    loop_ub = trailer_xr_s->size[1] - 1;
    i = trailer_xr_s->size[0] * trailer_xr_s->size[1];
    trailer_xr_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, trailer_xr_s, i, &gc_emlrtRTEI);
    res_dA_data = trailer_xr_s->data;
    last = (trailer_xr_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&trailer_y_self_s_data[i]);
      _mm_storeu_pd(&res_dA_data[i], _mm_sub_pd(r, r4));
    }
    for (i = last; i <= loop_ub; i++) {
      res_dA_data[i] -= trailer_y_self_s_data[i];
    }
  } else {
    st.site = &yb_emlrtRSI;
    c_minus(&st, trailer_xr_s, trailer_y_self_s);
    res_dA_data = trailer_xr_s->data;
  }
  if ((tractor_xr_s->size[1] != trailer_y_self_s->size[1]) &&
      ((tractor_xr_s->size[1] != 1) && (trailer_y_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(tractor_xr_s->size[1],
                                trailer_y_self_s->size[1], &i_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (tractor_xr_s->size[1] == trailer_y_self_s->size[1]) {
    loop_ub = tractor_xr_s->size[1] - 1;
    i = tractor_xr_s->size[0] * tractor_xr_s->size[1];
    tractor_xr_s->size[0] = 1;
    emxEnsureCapacity_real_T(sp, tractor_xr_s, i, &hc_emlrtRTEI);
    tractor_xr_s_data = tractor_xr_s->data;
    last = (tractor_xr_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&tractor_xr_s_data[i]);
      r4 = _mm_loadu_pd(&trailer_y_self_s_data[i]);
      _mm_storeu_pd(&tractor_xr_s_data[i], _mm_sub_pd(r, r4));
    }
    for (i = last; i <= loop_ub; i++) {
      tractor_xr_s_data[i] -= trailer_y_self_s_data[i];
    }
  } else {
    st.site = &ac_emlrtRSI;
    c_minus(&st, tractor_xr_s, trailer_y_self_s);
    tractor_xr_s_data = tractor_xr_s->data;
  }
  if ((trailer_xr_s->size[1] != tractor_xr_s->size[1]) &&
      ((trailer_xr_s->size[1] != 1) && (tractor_xr_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_xr_s->size[1], tractor_xr_s->size[1],
                                &j_emlrtECI, (emlrtConstCTX)sp);
  }
  emxInit_real_T(sp, &trailer_center_x, 2, &ic_emlrtRTEI);
  if (trailer_xr_s->size[1] == tractor_xr_s->size[1]) {
    i = trailer_center_x->size[0] * trailer_center_x->size[1];
    trailer_center_x->size[0] = 1;
    trailer_center_x->size[1] = trailer_xr_s->size[1];
    emxEnsureCapacity_real_T(sp, trailer_center_x, i, &ic_emlrtRTEI);
    trailer_center_x_data = trailer_center_x->data;
    loop_ub = trailer_xr_s->size[1];
    last = (trailer_xr_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&tractor_xr_s_data[i]);
      _mm_storeu_pd(&trailer_center_x_data[i],
                    _mm_div_pd(_mm_add_pd(r, r4), _mm_set1_pd(2.0)));
    }
    for (i = last; i < loop_ub; i++) {
      trailer_center_x_data[i] = (res_dA_data[i] + tractor_xr_s_data[i]) / 2.0;
    }
  } else {
    st.site = &fc_emlrtRSI;
    g_binary_expand_op(&st, trailer_center_x, trailer_xr_s, tractor_xr_s);
    trailer_center_x_data = trailer_center_x->data;
  }
  if ((trailer_x_self_s->size[1] != b_tractor_x_self_s->size[1]) &&
      ((trailer_x_self_s->size[1] != 1) &&
       (b_tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_x_self_s->size[1],
                                b_tractor_x_self_s->size[1], &k_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  emxInit_real_T(sp, &trailer_center_y, 2, &jc_emlrtRTEI);
  if (trailer_x_self_s->size[1] == b_tractor_x_self_s->size[1]) {
    i = trailer_center_y->size[0] * trailer_center_y->size[1];
    trailer_center_y->size[0] = 1;
    trailer_center_y->size[1] = trailer_x_self_s->size[1];
    emxEnsureCapacity_real_T(sp, trailer_center_y, i, &jc_emlrtRTEI);
    trailer_center_y_data = trailer_center_y->data;
    loop_ub = trailer_x_self_s->size[1];
    last = (trailer_x_self_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&trailer_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
      _mm_storeu_pd(&trailer_center_y_data[i],
                    _mm_div_pd(_mm_add_pd(r, r4), _mm_set1_pd(2.0)));
    }
    for (i = last; i < loop_ub; i++) {
      trailer_center_y_data[i] =
          (trailer_x_self_s_data[i] + b_tractor_x_self_s_data[i]) / 2.0;
    }
  } else {
    st.site = &gc_emlrtRSI;
    g_binary_expand_op(&st, trailer_center_y, trailer_x_self_s,
                       b_tractor_x_self_s);
    trailer_center_y_data = trailer_center_y->data;
  }
  if ((b_tractor_x_self_s->size[1] != trailer_x_self_s->size[1]) &&
      ((b_tractor_x_self_s->size[1] != 1) &&
       (trailer_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(b_tractor_x_self_s->size[1],
                                trailer_x_self_s->size[1], &l_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((tractor_xr_s->size[1] != trailer_xr_s->size[1]) &&
      ((tractor_xr_s->size[1] != 1) && (trailer_xr_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(tractor_xr_s->size[1], trailer_xr_s->size[1],
                                &m_emlrtECI, (emlrtConstCTX)sp);
  }
  if ((b_tractor_x_self_s->size[1] == trailer_x_self_s->size[1]) &&
      (tractor_xr_s->size[1] == trailer_xr_s->size[1])) {
    i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
    tractor_x_self_s->size[0] = 1;
    tractor_x_self_s->size[1] = b_tractor_x_self_s->size[1];
    emxEnsureCapacity_real_T(sp, tractor_x_self_s, i, &kc_emlrtRTEI);
    tractor_x_self_s_data = tractor_x_self_s->data;
    loop_ub = b_tractor_x_self_s->size[1];
    last = (b_tractor_x_self_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&trailer_x_self_s_data[i]);
      _mm_storeu_pd(&tractor_x_self_s_data[i], _mm_sub_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      tractor_x_self_s_data[i] =
          b_tractor_x_self_s_data[i] - trailer_x_self_s_data[i];
    }
    i = th->size[0] * th->size[1];
    th->size[0] = 1;
    th->size[1] = tractor_xr_s->size[1];
    emxEnsureCapacity_real_T(sp, th, i, &mc_emlrtRTEI);
    th_data = th->data;
    loop_ub = tractor_xr_s->size[1];
    last = (tractor_xr_s->size[1] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&tractor_xr_s_data[i]);
      r4 = _mm_loadu_pd(&res_dA_data[i]);
      _mm_storeu_pd(&th_data[i], _mm_sub_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      th_data[i] = tractor_xr_s_data[i] - res_dA_data[i];
    }
    st.site = &j_emlrtRSI;
    b_atan2(&st, tractor_x_self_s, th, trailer_y_self_s);
    trailer_y_self_s_data = trailer_y_self_s->data;
  } else {
    st.site = &j_emlrtRSI;
    f_binary_expand_op(&st, trailer_y_self_s, j_emlrtRSI, b_tractor_x_self_s,
                       trailer_x_self_s, tractor_xr_s, trailer_xr_s);
    trailer_y_self_s_data = trailer_y_self_s->data;
  }
  emxFree_real_T(sp, &tractor_xr_s);
  emxFree_real_T(sp, &b_tractor_x_self_s);
  emxFree_real_T(sp, &trailer_xr_s);
  emxFree_real_T(sp, &trailer_x_self_s);
  i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
  tractor_x_self_s->size[0] = 1;
  tractor_x_self_s->size[1] = trailer_y_self_s->size[1];
  emxEnsureCapacity_real_T(sp, tractor_x_self_s, i, &lc_emlrtRTEI);
  tractor_x_self_s_data = tractor_x_self_s->data;
  loop_ub = trailer_y_self_s->size[1];
  for (i = 0; i < loop_ub; i++) {
    tractor_x_self_s_data[i] = trailer_y_self_s_data[i];
  }
  st.site = &k_emlrtRSI;
  b_cos(&st, tractor_x_self_s);
  tractor_x_self_s_data = tractor_x_self_s->data;
  if ((trailer_v_s->size[1] != tractor_x_self_s->size[1]) &&
      ((trailer_v_s->size[1] != 1) && (tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_v_s->size[1], tractor_x_self_s->size[1],
                                &n_emlrtECI, (emlrtConstCTX)sp);
  }
  i = th->size[0] * th->size[1];
  th->size[0] = 1;
  th->size[1] = trailer_y_self_s->size[1];
  emxEnsureCapacity_real_T(sp, th, i, &nc_emlrtRTEI);
  th_data = th->data;
  loop_ub = trailer_y_self_s->size[1];
  for (i = 0; i < loop_ub; i++) {
    th_data[i] = trailer_y_self_s_data[i];
  }
  st.site = &k_emlrtRSI;
  b_sin(&st, th);
  th_data = th->data;
  if ((trailer_v_s->size[1] != th->size[1]) &&
      ((trailer_v_s->size[1] != 1) && (th->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_v_s->size[1], th->size[1], &o_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  st.site = &k_emlrtRSI;
  i = res_dA->size[0];
  res_dA->size[0] = trailer_v_s->size[1];
  emxEnsureCapacity_real_T(&st, res_dA, i, &oc_emlrtRTEI);
  res_dA_data = res_dA->data;
  loop_ub = trailer_v_s->size[1];
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = trailer_v_s_data[i];
  }
  emxFree_real_T(&st, &trailer_v_s);
  emxInit_real_T(&st, &res_dB, 1, &gd_emlrtRTEI);
  if (res_dA->size[0] == tractor_x_self_s->size[1]) {
    i = res_dB->size[0];
    res_dB->size[0] = res_dA->size[0];
    emxEnsureCapacity_real_T(&st, res_dB, i, &oc_emlrtRTEI);
    trailer_x_self_s_data = res_dB->data;
    loop_ub = res_dA->size[0];
    last = (res_dA->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&tractor_x_self_s_data[i]);
      _mm_storeu_pd(&trailer_x_self_s_data[i],
                    _mm_sub_pd(_mm_mul_pd(r, r4), _mm_set1_pd(ego_v)));
    }
    for (i = last; i < loop_ub; i++) {
      trailer_x_self_s_data[i] =
          res_dA_data[i] * tractor_x_self_s_data[i] - ego_v;
    }
  } else {
    b_st.site = &k_emlrtRSI;
    d_binary_expand_op(&b_st, res_dB, res_dA, tractor_x_self_s, ego_v);
    trailer_x_self_s_data = res_dB->data;
  }
  emxInit_real_T(&st, &res_Dc, 1, &hd_emlrtRTEI);
  if (res_dA->size[0] == th->size[1]) {
    i = res_Dc->size[0];
    res_Dc->size[0] = res_dA->size[0];
    emxEnsureCapacity_real_T(&st, res_Dc, i, &pc_emlrtRTEI);
    tractor_xr_s_data = res_Dc->data;
    loop_ub = res_dA->size[0];
    last = (res_dA->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&th_data[i]);
      _mm_storeu_pd(&tractor_xr_s_data[i], _mm_mul_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      tractor_xr_s_data[i] = res_dA_data[i] * th_data[i];
    }
  } else {
    b_st.site = &k_emlrtRSI;
    c_binary_expand_op(&b_st, res_Dc, res_dA, th);
    tractor_xr_s_data = res_Dc->data;
  }
  b_st.site = &gb_emlrtRSI;
  c_st.site = &hb_emlrtRSI;
  if (res_Dc->size[0] != res_dB->size[0]) {
    emlrtErrorWithMessageIdR2018a(&c_st, &emlrtRTEI,
                                  "MATLAB:catenate:matrixDimensionMismatch",
                                  "MATLAB:catenate:matrixDimensionMismatch", 0);
  }
  emxInit_real_T(&b_st, &trailer_vr_s, 2, &qc_emlrtRTEI);
  i = trailer_vr_s->size[0] * trailer_vr_s->size[1];
  trailer_vr_s->size[0] = res_dB->size[0];
  trailer_vr_s->size[1] = 2;
  emxEnsureCapacity_real_T(&b_st, trailer_vr_s, i, &qc_emlrtRTEI);
  b_tractor_x_self_s_data = trailer_vr_s->data;
  loop_ub = res_dB->size[0];
  for (i = 0; i < loop_ub; i++) {
    b_tractor_x_self_s_data[i] = trailer_x_self_s_data[i];
  }
  loop_ub = res_Dc->size[0];
  for (i = 0; i < loop_ub; i++) {
    b_tractor_x_self_s_data[i + trailer_vr_s->size[0]] = tractor_xr_s_data[i];
  }
  i = res_dB->size[0];
  res_dB->size[0] = trailer_vr_s->size[0];
  emxEnsureCapacity_real_T(sp, res_dB, i, &rc_emlrtRTEI);
  trailer_x_self_s_data = res_dB->data;
  loop_ub = trailer_vr_s->size[0];
  i = res_dA->size[0];
  res_dA->size[0] = trailer_vr_s->size[0];
  emxEnsureCapacity_real_T(sp, res_dA, i, &sc_emlrtRTEI);
  res_dA_data = res_dA->data;
  scalarLB_tmp = (trailer_vr_s->size[0] / 2) << 1;
  vectorUB_tmp = scalarLB_tmp - 2;
  for (i = 0; i <= vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
    _mm_storeu_pd(&trailer_x_self_s_data[i], _mm_mul_pd(r, r));
    r = _mm_loadu_pd(&b_tractor_x_self_s_data[i + trailer_vr_s->size[0]]);
    _mm_storeu_pd(&res_dA_data[i], _mm_mul_pd(r, r));
  }
  for (i = scalarLB_tmp; i < loop_ub; i++) {
    d = b_tractor_x_self_s_data[i];
    trailer_x_self_s_data[i] = d * d;
    d = b_tractor_x_self_s_data[i + trailer_vr_s->size[0]];
    res_dA_data[i] = d * d;
  }
  if ((res_dB->size[0] != res_dA->size[0]) &&
      ((res_dB->size[0] != 1) && (res_dA->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(res_dB->size[0], res_dA->size[0], &p_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  st.site = &l_emlrtRSI;
  if (res_dB->size[0] == res_dA->size[0]) {
    loop_ub = res_dB->size[0];
    last = (res_dB->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&trailer_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&res_dA_data[i]);
      _mm_storeu_pd(&trailer_x_self_s_data[i], _mm_add_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      trailer_x_self_s_data[i] += res_dA_data[i];
    }
  } else {
    plus(&st, res_dB, res_dA);
  }
  b_st.site = &l_emlrtRSI;
  c_sqrt(&b_st, res_dB);
  trailer_x_self_s_data = res_dB->data;
  b_st.site = &ib_emlrtRSI;
  c_st.site = &jb_emlrtRSI;
  assertCompatibleDims(&c_st, trailer_vr_s, res_dB);
  emxInit_real_T(&b_st, &trailer_thr_s, 2, &tc_emlrtRTEI);
  if (trailer_vr_s->size[0] == res_dB->size[0]) {
    i = trailer_thr_s->size[0] * trailer_thr_s->size[1];
    trailer_thr_s->size[0] = trailer_vr_s->size[0];
    trailer_thr_s->size[1] = 2;
    emxEnsureCapacity_real_T(&b_st, trailer_thr_s, i, &tc_emlrtRTEI);
    trailer_v_s_data = trailer_thr_s->data;
    loop_ub = trailer_vr_s->size[0];
    for (i = 0; i < 2; i++) {
      for (last = 0; last <= vectorUB_tmp; last += 2) {
        r = _mm_loadu_pd(
            &b_tractor_x_self_s_data[last + trailer_vr_s->size[0] * i]);
        r4 = _mm_loadu_pd(&trailer_x_self_s_data[last]);
        _mm_storeu_pd(&trailer_v_s_data[last + trailer_thr_s->size[0] * i],
                      _mm_div_pd(r, r4));
      }
      for (last = scalarLB_tmp; last < loop_ub; last++) {
        trailer_v_s_data[last + trailer_thr_s->size[0] * i] =
            b_tractor_x_self_s_data[last + trailer_vr_s->size[0] * i] /
            trailer_x_self_s_data[last];
      }
    }
  } else {
    c_st.site = &wb_emlrtRSI;
    e_binary_expand_op(&c_st, trailer_thr_s, trailer_vr_s, res_dB);
    trailer_v_s_data = trailer_thr_s->data;
  }
  i = tractor_x_self_s->size[0] * tractor_x_self_s->size[1];
  tractor_x_self_s->size[0] = 1;
  tractor_x_self_s->size[1] = ego_trailer_th->size[1];
  emxEnsureCapacity_real_T(sp, tractor_x_self_s, i, &uc_emlrtRTEI);
  tractor_x_self_s_data = tractor_x_self_s->data;
  loop_ub = ego_trailer_th->size[1];
  for (i = 0; i < loop_ub; i++) {
    tractor_x_self_s_data[i] = ego_trailer_th_data[i];
  }
  st.site = &m_emlrtRSI;
  b_cos(&st, tractor_x_self_s);
  tractor_x_self_s_data = tractor_x_self_s->data;
  if ((ego_trailer_v_s->size[1] != tractor_x_self_s->size[1]) &&
      ((ego_trailer_v_s->size[1] != 1) && (tractor_x_self_s->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ego_trailer_v_s->size[1],
                                tractor_x_self_s->size[1], &q_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  i = th->size[0] * th->size[1];
  th->size[0] = 1;
  th->size[1] = ego_trailer_th->size[1];
  emxEnsureCapacity_real_T(sp, th, i, &vc_emlrtRTEI);
  th_data = th->data;
  loop_ub = ego_trailer_th->size[1];
  for (i = 0; i < loop_ub; i++) {
    th_data[i] = ego_trailer_th_data[i];
  }
  st.site = &m_emlrtRSI;
  b_sin(&st, th);
  th_data = th->data;
  if ((ego_trailer_v_s->size[1] != th->size[1]) &&
      ((ego_trailer_v_s->size[1] != 1) && (th->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ego_trailer_v_s->size[1], th->size[1],
                                &r_emlrtECI, (emlrtConstCTX)sp);
  }
  st.site = &m_emlrtRSI;
  i = res_dA->size[0];
  res_dA->size[0] = ego_trailer_v_s->size[1];
  emxEnsureCapacity_real_T(&st, res_dA, i, &wc_emlrtRTEI);
  res_dA_data = res_dA->data;
  loop_ub = ego_trailer_v_s->size[1];
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = ego_trailer_v_s_data[i];
  }
  emxFree_real_T(&st, &ego_trailer_v_s);
  if (res_dA->size[0] == tractor_x_self_s->size[1]) {
    i = res_dB->size[0];
    res_dB->size[0] = res_dA->size[0];
    emxEnsureCapacity_real_T(&st, res_dB, i, &wc_emlrtRTEI);
    trailer_x_self_s_data = res_dB->data;
    loop_ub = res_dA->size[0];
    last = (res_dA->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&tractor_x_self_s_data[i]);
      _mm_storeu_pd(&trailer_x_self_s_data[i],
                    _mm_sub_pd(_mm_mul_pd(r, r4), _mm_set1_pd(ego_v)));
    }
    for (i = last; i < loop_ub; i++) {
      trailer_x_self_s_data[i] =
          res_dA_data[i] * tractor_x_self_s_data[i] - ego_v;
    }
  } else {
    b_st.site = &m_emlrtRSI;
    d_binary_expand_op(&b_st, res_dB, res_dA, tractor_x_self_s, ego_v);
    trailer_x_self_s_data = res_dB->data;
  }
  emxFree_real_T(&st, &tractor_x_self_s);
  if (res_dA->size[0] == th->size[1]) {
    i = res_Dc->size[0];
    res_Dc->size[0] = res_dA->size[0];
    emxEnsureCapacity_real_T(&st, res_Dc, i, &xc_emlrtRTEI);
    tractor_xr_s_data = res_Dc->data;
    loop_ub = res_dA->size[0];
    last = (res_dA->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&th_data[i]);
      _mm_storeu_pd(&tractor_xr_s_data[i], _mm_mul_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      tractor_xr_s_data[i] = res_dA_data[i] * th_data[i];
    }
  } else {
    b_st.site = &m_emlrtRSI;
    c_binary_expand_op(&b_st, res_Dc, res_dA, th);
    tractor_xr_s_data = res_Dc->data;
  }
  emxFree_real_T(&st, &th);
  b_st.site = &gb_emlrtRSI;
  c_st.site = &hb_emlrtRSI;
  if (res_Dc->size[0] != res_dB->size[0]) {
    emlrtErrorWithMessageIdR2018a(&c_st, &emlrtRTEI,
                                  "MATLAB:catenate:matrixDimensionMismatch",
                                  "MATLAB:catenate:matrixDimensionMismatch", 0);
  }
  emxInit_real_T(&b_st, &ego_trailer_vr_s, 2, &yc_emlrtRTEI);
  i = ego_trailer_vr_s->size[0] * ego_trailer_vr_s->size[1];
  ego_trailer_vr_s->size[0] = res_dB->size[0];
  ego_trailer_vr_s->size[1] = 2;
  emxEnsureCapacity_real_T(&b_st, ego_trailer_vr_s, i, &yc_emlrtRTEI);
  res_dA_data = ego_trailer_vr_s->data;
  loop_ub = res_dB->size[0];
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = trailer_x_self_s_data[i];
  }
  loop_ub = res_Dc->size[0];
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i + ego_trailer_vr_s->size[0]] = tractor_xr_s_data[i];
  }
  /*  ego_trailer_thr_s =
   * ego_trailer_v_s./sqrt((ego_trailer_v_s(:,1)).*ego_trailer_v_s(:,1) +
   * (ego_trailer_v_s(:,2)).*ego_trailer_v_s(:,2)); */
  if ((trailer_vr_s->size[0] != ego_trailer_vr_s->size[0]) &&
      ((trailer_vr_s->size[0] != 1) && (ego_trailer_vr_s->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(trailer_vr_s->size[0],
                                ego_trailer_vr_s->size[0], &s_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (trailer_vr_s->size[0] == ego_trailer_vr_s->size[0]) {
    loop_ub = trailer_vr_s->size[0] << 1;
    i = trailer_vr_s->size[0] * trailer_vr_s->size[1];
    trailer_vr_s->size[1] = 2;
    emxEnsureCapacity_real_T(sp, trailer_vr_s, i, &ad_emlrtRTEI);
    b_tractor_x_self_s_data = trailer_vr_s->data;
    last = (loop_ub / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&res_dA_data[i]);
      _mm_storeu_pd(&b_tractor_x_self_s_data[i], _mm_sub_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      b_tractor_x_self_s_data[i] -= res_dA_data[i];
    }
  } else {
    st.site = &xb_emlrtRSI;
    b_minus(&st, trailer_vr_s, ego_trailer_vr_s);
    b_tractor_x_self_s_data = trailer_vr_s->data;
  }
  i = res_dB->size[0];
  res_dB->size[0] = trailer_vr_s->size[0];
  emxEnsureCapacity_real_T(sp, res_dB, i, &bd_emlrtRTEI);
  trailer_x_self_s_data = res_dB->data;
  loop_ub = trailer_vr_s->size[0];
  i = res_dA->size[0];
  res_dA->size[0] = trailer_vr_s->size[0];
  emxEnsureCapacity_real_T(sp, res_dA, i, &cd_emlrtRTEI);
  res_dA_data = res_dA->data;
  scalarLB_tmp = (trailer_vr_s->size[0] / 2) << 1;
  vectorUB_tmp = scalarLB_tmp - 2;
  for (i = 0; i <= vectorUB_tmp; i += 2) {
    r = _mm_loadu_pd(&b_tractor_x_self_s_data[i]);
    _mm_storeu_pd(&trailer_x_self_s_data[i], _mm_mul_pd(r, r));
    r = _mm_loadu_pd(&b_tractor_x_self_s_data[i + trailer_vr_s->size[0]]);
    _mm_storeu_pd(&res_dA_data[i], _mm_mul_pd(r, r));
  }
  for (i = scalarLB_tmp; i < loop_ub; i++) {
    d = b_tractor_x_self_s_data[i];
    trailer_x_self_s_data[i] = d * d;
    d = b_tractor_x_self_s_data[i + trailer_vr_s->size[0]];
    res_dA_data[i] = d * d;
  }
  if ((res_dB->size[0] != res_dA->size[0]) &&
      ((res_dB->size[0] != 1) && (res_dA->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(res_dB->size[0], res_dA->size[0], &t_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  st.site = &n_emlrtRSI;
  if (res_dB->size[0] == res_dA->size[0]) {
    loop_ub = res_dB->size[0];
    last = (res_dB->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&trailer_x_self_s_data[i]);
      r4 = _mm_loadu_pd(&res_dA_data[i]);
      _mm_storeu_pd(&trailer_x_self_s_data[i], _mm_add_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      trailer_x_self_s_data[i] += res_dA_data[i];
    }
  } else {
    plus(&st, res_dB, res_dA);
  }
  b_st.site = &n_emlrtRSI;
  c_sqrt(&b_st, res_dB);
  trailer_x_self_s_data = res_dB->data;
  b_st.site = &ib_emlrtRSI;
  c_st.site = &jb_emlrtRSI;
  assertCompatibleDims(&c_st, trailer_vr_s, res_dB);
  if (trailer_vr_s->size[0] == res_dB->size[0]) {
    i = ego_trailer_vr_s->size[0] * ego_trailer_vr_s->size[1];
    ego_trailer_vr_s->size[0] = trailer_vr_s->size[0];
    ego_trailer_vr_s->size[1] = 2;
    emxEnsureCapacity_real_T(&b_st, ego_trailer_vr_s, i, &dd_emlrtRTEI);
    res_dA_data = ego_trailer_vr_s->data;
    loop_ub = trailer_vr_s->size[0];
    for (i = 0; i < 2; i++) {
      for (last = 0; last <= vectorUB_tmp; last += 2) {
        r = _mm_loadu_pd(
            &b_tractor_x_self_s_data[last + trailer_vr_s->size[0] * i]);
        r4 = _mm_loadu_pd(&trailer_x_self_s_data[last]);
        _mm_storeu_pd(&res_dA_data[last + ego_trailer_vr_s->size[0] * i],
                      _mm_div_pd(r, r4));
      }
      for (last = scalarLB_tmp; last < loop_ub; last++) {
        res_dA_data[last + ego_trailer_vr_s->size[0] * i] =
            b_tractor_x_self_s_data[last + trailer_vr_s->size[0] * i] /
            trailer_x_self_s_data[last];
      }
    }
    i = trailer_vr_s->size[0] * trailer_vr_s->size[1];
    trailer_vr_s->size[0] = ego_trailer_vr_s->size[0];
    trailer_vr_s->size[1] = 2;
    emxEnsureCapacity_real_T(&b_st, trailer_vr_s, i, &fd_emlrtRTEI);
    b_tractor_x_self_s_data = trailer_vr_s->data;
    loop_ub = ego_trailer_vr_s->size[0] << 1;
    for (i = 0; i < loop_ub; i++) {
      b_tractor_x_self_s_data[i] = res_dA_data[i];
    }
  } else {
    c_st.site = &wb_emlrtRSI;
    b_binary_expand_op(&c_st, trailer_vr_s, res_dB);
    b_tractor_x_self_s_data = trailer_vr_s->data;
  }
  emxFree_real_T(&b_st, &ego_trailer_vr_s);
  /*     %% 计算替代安全指标 */
  /*  预分配存储空间 */
  i = res_dA->size[0];
  res_dA->size[0] = t->size[1];
  emxEnsureCapacity_real_T(sp, res_dA, i, &ed_emlrtRTEI);
  res_dA_data = res_dA->data;
  loop_ub = t->size[1];
  i = res_dB->size[0];
  res_dB->size[0] = t->size[1];
  emxEnsureCapacity_real_T(sp, res_dB, i, &gd_emlrtRTEI);
  trailer_x_self_s_data = res_dB->data;
  i = res_Dc->size[0];
  res_Dc->size[0] = t->size[1];
  emxEnsureCapacity_real_T(sp, res_Dc, i, &hd_emlrtRTEI);
  tractor_xr_s_data = res_Dc->data;
  emxInit_boolean_T(sp, &res_collision, &id_emlrtRTEI);
  i = res_collision->size[0];
  res_collision->size[0] = t->size[1];
  emxEnsureCapacity_boolean_T(sp, res_collision, i, &id_emlrtRTEI);
  res_collision_data = res_collision->data;
  for (i = 0; i < loop_ub; i++) {
    res_dA_data[i] = 0.0;
    trailer_x_self_s_data[i] = 0.0;
    tractor_xr_s_data[i] = 0.0;
    res_collision_data[i] = false;
  }
  /*  ego_corners = get_rect_poly_corners(0,0,0,ego_l,ego_w); */
  *TEM = rtInf;
  has_collide = false;
  i = t->size[1];
  for (b_i = 0; b_i < i; b_i++) {
    real_T ego_trailer_corners[10];
    real_T trailer_corners[10];
    boolean_T collision_res;
    if (b_i + 1 > trailer_center_x->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_x->size[1],
                                    &n_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_center_y->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_y->size[1],
                                    &o_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_y_self_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_y_self_s->size[1],
                                    &p_emlrtBCI, (emlrtConstCTX)sp);
    }
    tractor_xr0_trans = trailer_center_x_data[b_i];
    tractor_xg0_r_tmp = trailer_center_y_data[b_i];
    get_rect_poly_corners(tractor_xr0_trans, tractor_xg0_r_tmp,
                          trailer_y_self_s_data[b_i], trailer_l, trailer_w,
                          trailer_corners);
    if (b_i + 1 > ego_trailer_center_xr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_xr_s->size[1],
                                    &q_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > ego_trailer_center_yr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_yr_s->size[1],
                                    &r_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > ego_trailer_th->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, ego_trailer_th->size[1],
                                    &s_emlrtBCI, (emlrtConstCTX)sp);
    }
    tractor_yr0_trans = ego_trailer_center_xr_s_data[b_i];
    tractor_xr0_tmp = ego_trailer_center_yr_s_data[b_i];
    get_rect_poly_corners(tractor_yr0_trans, tractor_xr0_tmp,
                          ego_trailer_th_data[b_i], ego_trailer_l,
                          ego_trailer_w, ego_trailer_corners);
    if (b_i + 1 > trailer_center_x->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_x->size[1],
                                    &t_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_center_y->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_y->size[1],
                                    &u_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_vr_s->size[0]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_vr_s->size[0],
                                    &emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_center_x->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_x->size[1],
                                    &v_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_center_y->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_y->size[1],
                                    &w_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_vr_s->size[0]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_vr_s->size[0],
                                    &b_emlrtBCI, (emlrtConstCTX)sp);
    }
    d = muDoubleScalarAbs(
        (trailer_corners[0] - trailer_center_x_data[b_i]) *
            b_tractor_x_self_s_data[b_i + trailer_vr_s->size[0]] -
        b_tractor_x_self_s_data[b_i] *
            (trailer_corners[5] - trailer_center_y_data[b_i]));
    b_tractor_xr0_tmp = muDoubleScalarAbs(
        (trailer_corners[1] - trailer_center_x_data[b_i]) *
            b_tractor_x_self_s_data[b_i + trailer_vr_s->size[0]] -
        b_tractor_x_self_s_data[b_i] *
            (trailer_corners[6] - trailer_center_y_data[b_i]));
    if ((d < b_tractor_xr0_tmp) ||
        (muDoubleScalarIsNaN(d) && (!muDoubleScalarIsNaN(b_tractor_xr0_tmp)))) {
      if (b_i + 1 > res_dA->size[0]) {
        emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, res_dA->size[0], &x_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      res_dA_data[b_i] = b_tractor_xr0_tmp;
    } else {
      if (b_i + 1 > res_dA->size[0]) {
        emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, res_dA->size[0], &x_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      res_dA_data[b_i] = d;
    }
    if (b_i + 1 > ego_trailer_center_xr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_xr_s->size[1],
                                    &y_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > ego_trailer_center_yr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_yr_s->size[1],
                                    &ab_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_vr_s->size[0]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_vr_s->size[0],
                                    &c_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > ego_trailer_center_xr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_xr_s->size[1],
                                    &bb_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > ego_trailer_center_yr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_yr_s->size[1],
                                    &cb_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > trailer_vr_s->size[0]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_vr_s->size[0],
                                    &d_emlrtBCI, (emlrtConstCTX)sp);
    }
    d = muDoubleScalarAbs(
        (ego_trailer_corners[0] - ego_trailer_center_xr_s_data[b_i]) *
            b_tractor_x_self_s_data[b_i + trailer_vr_s->size[0]] -
        b_tractor_x_self_s_data[b_i] *
            (ego_trailer_corners[5] - ego_trailer_center_yr_s_data[b_i]));
    b_tractor_xr0_tmp = muDoubleScalarAbs(
        (ego_trailer_corners[1] - ego_trailer_center_xr_s_data[b_i]) *
            b_tractor_x_self_s_data[b_i + trailer_vr_s->size[0]] -
        b_tractor_x_self_s_data[b_i] *
            (ego_trailer_corners[6] - ego_trailer_center_yr_s_data[b_i]));
    if ((d < b_tractor_xr0_tmp) ||
        (muDoubleScalarIsNaN(d) && (!muDoubleScalarIsNaN(b_tractor_xr0_tmp)))) {
      if (b_i + 1 > res_dB->size[0]) {
        emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, res_dB->size[0], &db_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      trailer_x_self_s_data[b_i] = b_tractor_xr0_tmp;
    } else {
      if (b_i + 1 > res_dB->size[0]) {
        emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, res_dB->size[0], &db_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      trailer_x_self_s_data[b_i] = d;
    }
    if (b_i + 1 > trailer_center_x->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_x->size[1],
                                    &eb_emlrtBCI, (emlrtConstCTX)sp);
    }
    b_trailer_center_x[0] = tractor_xr0_trans;
    if (b_i + 1 > trailer_center_y->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_center_y->size[1],
                                    &fb_emlrtBCI, (emlrtConstCTX)sp);
    }
    b_trailer_center_x[1] = tractor_xg0_r_tmp;
    if (b_i + 1 > ego_trailer_center_xr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_xr_s->size[1],
                                    &gb_emlrtBCI, (emlrtConstCTX)sp);
    }
    x[0] = tractor_yr0_trans;
    if (b_i + 1 > ego_trailer_center_yr_s->size[1]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1,
                                    ego_trailer_center_yr_s->size[1],
                                    &hb_emlrtBCI, (emlrtConstCTX)sp);
    }
    x[1] = tractor_xr0_tmp;
    r = _mm_loadu_pd(&b_trailer_center_x[0]);
    r4 = _mm_loadu_pd(&x[0]);
    _mm_storeu_pd(&b_trailer_center_x[0], _mm_sub_pd(r, r4));
    if (b_i + 1 > trailer_thr_s->size[0]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, trailer_thr_s->size[0],
                                    &e_emlrtBCI, (emlrtConstCTX)sp);
    }
    if (b_i + 1 > res_Dc->size[0]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, res_Dc->size[0], &ib_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    tractor_xr_s_data[b_i] = muDoubleScalarAbs(
        b_trailer_center_x[0] * trailer_v_s_data[b_i + trailer_thr_s->size[0]] -
        trailer_v_s_data[b_i] * b_trailer_center_x[1]);
    st.site = &tb_emlrtRSI;
    collision_res =
        intersect_polypoly(&st, ego_trailer_corners, trailer_corners);
    if (b_i + 1 > res_collision->size[0]) {
      emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, res_collision->size[0],
                                    &jb_emlrtBCI, (emlrtConstCTX)sp);
    }
    res_collision_data[b_i] = collision_res;
    if (collision_res && (!has_collide)) {
      /*  disp(['第' num2str(i) '时刻发生相交' ]) */
      has_collide = true;
      if (b_i + 1 == 1) {
        *TEM = 1.0E-5;
      } else {
        if (b_i + 1 > t->size[1]) {
          emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, t->size[1], &kb_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        *TEM = t_data[b_i];
      }
    }
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b((emlrtConstCTX)sp);
    }
  }
  emxFree_real_T(sp, &trailer_thr_s);
  emxFree_real_T(sp, &trailer_vr_s);
  emxFree_real_T(sp, &trailer_center_y);
  emxFree_real_T(sp, &trailer_center_x);
  emxFree_real_T(sp, &ego_trailer_center_yr_s);
  emxFree_real_T(sp, &ego_trailer_center_xr_s);
  emxFree_real_T(sp, &ego_trailer_th);
  emxFree_real_T(sp, &trailer_y_self_s);
  emxFree_real_T(sp, &t);
  if ((res_dA->size[0] != res_dB->size[0]) &&
      ((res_dA->size[0] != 1) && (res_dB->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(res_dA->size[0], res_dB->size[0], &u_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (res_dA->size[0] == res_dB->size[0]) {
    loop_ub = res_dA->size[0];
    last = (res_dA->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&trailer_x_self_s_data[i]);
      _mm_storeu_pd(&res_dA_data[i], _mm_add_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      res_dA_data[i] += trailer_x_self_s_data[i];
    }
  } else {
    st.site = &o_emlrtRSI;
    plus(&st, res_dA, res_dB);
    res_dA_data = res_dA->data;
  }
  emxFree_real_T(sp, &res_dB);
  if ((res_dA->size[0] != res_Dc->size[0]) &&
      ((res_dA->size[0] != 1) && (res_Dc->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(res_dA->size[0], res_Dc->size[0], &u_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if (res_dA->size[0] == res_Dc->size[0]) {
    loop_ub = res_dA->size[0];
    last = (res_dA->size[0] / 2) << 1;
    idx = last - 2;
    for (i = 0; i <= idx; i += 2) {
      r = _mm_loadu_pd(&res_dA_data[i]);
      r4 = _mm_loadu_pd(&tractor_xr_s_data[i]);
      _mm_storeu_pd(&res_dA_data[i], _mm_sub_pd(r, r4));
    }
    for (i = last; i < loop_ub; i++) {
      res_dA_data[i] -= tractor_xr_s_data[i];
    }
  } else {
    st.site = &o_emlrtRSI;
    minus(&st, res_dA, res_Dc);
    res_dA_data = res_dA->data;
  }
  emxFree_real_T(sp, &res_Dc);
  if ((res_dA->size[0] != res_collision->size[0]) &&
      ((res_dA->size[0] != 1) && (res_collision->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(res_dA->size[0], res_collision->size[0],
                                &v_emlrtECI, (emlrtConstCTX)sp);
  }
  st.site = &o_emlrtRSI;
  if (res_dA->size[0] == res_collision->size[0]) {
    loop_ub = res_dA->size[0];
    for (i = 0; i < loop_ub; i++) {
      res_dA_data[i] =
          (res_dA_data[i] + D_safe) * (real_T)res_collision_data[i];
    }
  } else {
    b_st.site = &o_emlrtRSI;
    binary_expand_op(&b_st, res_dA, D_safe, res_collision);
    res_dA_data = res_dA->data;
  }
  emxFree_boolean_T(&st, &res_collision);
  b_st.site = &kb_emlrtRSI;
  c_st.site = &lb_emlrtRSI;
  d_st.site = &mb_emlrtRSI;
  if (res_dA->size[0] < 1) {
    emlrtErrorWithMessageIdR2018a(&d_st, &c_emlrtRTEI,
                                  "Coder:toolbox:eml_min_or_max_varDimZero",
                                  "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }
  e_st.site = &nb_emlrtRSI;
  f_st.site = &ob_emlrtRSI;
  last = res_dA->size[0];
  if (res_dA->size[0] <= 2) {
    if (res_dA->size[0] == 1) {
      *InDepth = res_dA_data[0];
    } else if ((res_dA_data[0] < res_dA_data[1]) ||
               (muDoubleScalarIsNaN(res_dA_data[0]) &&
                (!muDoubleScalarIsNaN(res_dA_data[1])))) {
      *InDepth = res_dA_data[1];
    } else {
      *InDepth = res_dA_data[0];
    }
  } else {
    g_st.site = &qb_emlrtRSI;
    if (!muDoubleScalarIsNaN(res_dA_data[0])) {
      idx = 1;
    } else {
      boolean_T exitg1;
      idx = 0;
      h_st.site = &rb_emlrtRSI;
      if (res_dA->size[0] > 2147483646) {
        i_st.site = &s_emlrtRSI;
        check_forloop_overflow_error(&i_st);
      }
      b_vectorUB_tmp = 2;
      exitg1 = false;
      while ((!exitg1) && (b_vectorUB_tmp <= last)) {
        if (!muDoubleScalarIsNaN(res_dA_data[b_vectorUB_tmp - 1])) {
          idx = b_vectorUB_tmp;
          exitg1 = true;
        } else {
          b_vectorUB_tmp++;
        }
      }
    }
    if (idx == 0) {
      *InDepth = res_dA_data[0];
    } else {
      g_st.site = &pb_emlrtRSI;
      *InDepth = res_dA_data[idx - 1];
      b_i = idx + 1;
      h_st.site = &sb_emlrtRSI;
      if ((idx + 1 <= res_dA->size[0]) && (res_dA->size[0] > 2147483646)) {
        i_st.site = &s_emlrtRSI;
        check_forloop_overflow_error(&i_st);
      }
      for (b_vectorUB_tmp = b_i; b_vectorUB_tmp <= last; b_vectorUB_tmp++) {
        d = res_dA_data[b_vectorUB_tmp - 1];
        if (*InDepth < d) {
          *InDepth = d;
        }
      }
    }
  }
  emxFree_real_T(&f_st, &res_dA);
  /*  InDepth = max((res_dA + res_dB - res_Dc + D_safe)); */
  *MEI = *InDepth / *TEM;
  if (muDoubleScalarIsInf(*TEM)) {
    *TEM = rtNaN;
    *MEI = rtNaN;
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

/* End of code generation (trailer2_mei.c) */
