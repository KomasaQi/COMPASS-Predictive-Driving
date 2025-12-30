/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_trailer2_mei_api.c
 *
 * Code generation for function '_coder_trailer2_mei_api'
 *
 */

/* Include files */
#include "_coder_trailer2_mei_api.h"
#include "rt_nonfinite.h"
#include "trailer2_mei.h"
#include "trailer2_mei_data.h"

/* Function Declarations */
static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId);

static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static real_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *tf,
                               const char_T *identifier);

static const mxArray *emlrt_marshallOut(const real_T u);

/* Function Definitions */
static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = c_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  real_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "double", false, 0U,
                          (const void *)&dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *tf,
                               const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real_T y;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(tf), &thisId);
  emlrtDestroyArray(&tf);
  return y;
}

static const mxArray *emlrt_marshallOut(const real_T u)
{
  const mxArray *m;
  const mxArray *y;
  y = NULL;
  m = emlrtCreateDoubleScalar(u);
  emlrtAssign(&y, m);
  return y;
}

void trailer2_mei_api(const mxArray *const prhs[23], int32_T nlhs,
                      const mxArray *plhs[3])
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  real_T D_safe;
  real_T InDepth;
  real_T MEI;
  real_T TEM;
  real_T Ts;
  real_T ego_head;
  real_T ego_l;
  real_T ego_lb;
  real_T ego_trailer_gamma;
  real_T ego_trailer_l;
  real_T ego_trailer_w;
  real_T ego_v;
  real_T ego_w;
  real_T ego_x;
  real_T ego_y;
  real_T tf;
  real_T tractor_head;
  real_T tractor_l;
  real_T tractor_lb;
  real_T tractor_v;
  real_T tractor_w;
  real_T tractor_x;
  real_T tractor_y;
  real_T trailer_gamma;
  real_T trailer_l;
  real_T trailer_w;
  st.tls = emlrtRootTLSGlobal;
  /* Marshall function inputs */
  tf = emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "tf");
  Ts = emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "Ts");
  D_safe = emlrt_marshallIn(&st, emlrtAliasP(prhs[2]), "D_safe");
  ego_x = emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "ego_x");
  ego_y = emlrt_marshallIn(&st, emlrtAliasP(prhs[4]), "ego_y");
  ego_v = emlrt_marshallIn(&st, emlrtAliasP(prhs[5]), "ego_v");
  ego_head = emlrt_marshallIn(&st, emlrtAliasP(prhs[6]), "ego_head");
  ego_l = emlrt_marshallIn(&st, emlrtAliasP(prhs[7]), "ego_l");
  ego_w = emlrt_marshallIn(&st, emlrtAliasP(prhs[8]), "ego_w");
  ego_lb = emlrt_marshallIn(&st, emlrtAliasP(prhs[9]), "ego_lb");
  ego_trailer_gamma =
      emlrt_marshallIn(&st, emlrtAliasP(prhs[10]), "ego_trailer_gamma");
  ego_trailer_l = emlrt_marshallIn(&st, emlrtAliasP(prhs[11]), "ego_trailer_l");
  ego_trailer_w = emlrt_marshallIn(&st, emlrtAliasP(prhs[12]), "ego_trailer_w");
  tractor_x = emlrt_marshallIn(&st, emlrtAliasP(prhs[13]), "tractor_x");
  tractor_y = emlrt_marshallIn(&st, emlrtAliasP(prhs[14]), "tractor_y");
  tractor_v = emlrt_marshallIn(&st, emlrtAliasP(prhs[15]), "tractor_v");
  tractor_head = emlrt_marshallIn(&st, emlrtAliasP(prhs[16]), "tractor_head");
  tractor_l = emlrt_marshallIn(&st, emlrtAliasP(prhs[17]), "tractor_l");
  tractor_w = emlrt_marshallIn(&st, emlrtAliasP(prhs[18]), "tractor_w");
  tractor_lb = emlrt_marshallIn(&st, emlrtAliasP(prhs[19]), "tractor_lb");
  trailer_gamma = emlrt_marshallIn(&st, emlrtAliasP(prhs[20]), "trailer_gamma");
  trailer_l = emlrt_marshallIn(&st, emlrtAliasP(prhs[21]), "trailer_l");
  trailer_w = emlrt_marshallIn(&st, emlrtAliasP(prhs[22]), "trailer_w");
  /* Invoke the target function */
  trailer2_mei(&st, tf, Ts, D_safe, ego_x, ego_y, ego_v, ego_head, ego_l, ego_w,
               ego_lb, ego_trailer_gamma, ego_trailer_l, ego_trailer_w,
               tractor_x, tractor_y, tractor_v, tractor_head, tractor_l,
               tractor_w, tractor_lb, trailer_gamma, trailer_l, trailer_w, &MEI,
               &TEM, &InDepth);
  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(MEI);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(TEM);
  }
  if (nlhs > 2) {
    plhs[2] = emlrt_marshallOut(InDepth);
  }
}

/* End of code generation (_coder_trailer2_mei_api.c) */
