/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_trailer2_mei_info.c
 *
 * Code generation for function 'trailer2_mei'
 *
 */

/* Include files */
#include "_coder_trailer2_mei_info.h"
#include "emlrt.h"
#include "tmwtypes.h"

/* Function Declarations */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo(void);

/* Function Definitions */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  const char_T *data[8] = {
      "789ced574b6fd340109ea042b900692528b75648884b4195fb140704a489086dd3aa4d68"
      "420271ba59276e1c3bd84eea500909a902a41e7a42483d7005f53720"
      "0e883fc0a187f2b823b8c395756ce761616ae4b2696856b267676777bff1ccec8c177ce1"
      "391f009c06a3b183063d65f27e931e83d66697fb4c7adcc6437dbca7",
      "659d25df32299244156baac1889922aeafcc4a455ecc886ab45ac2206345122a385b9370"
      "bc80a37c112f3533119d2b869a44754617e9fd401ea3c252b908725e"
      "6968283433757bf87dbfffde1e97f68839d8a3cfa43b264d4210ee91e72aa4a06f65a3f2"
      "14ff88a4e052824b724996f4d210d3bec78dfe6ee1eda6cea580db7a",
      "b2f50a4d2cbe58df1520fd6129457608c310791781180b72e42d02822a190b935e96f01a"
      "bcdffc19e945bdf914a8644e0678106ab32fc35c6dbd7d9c21e8fa7e"
      "3c5c21b4d53e9ac3f7bbb5cf5907fbf86df21c56d332466aba2409d534926411cb4a931e"
      "ac473d4e38ea6148b2527945c00dbc218f7171df01cf8a8b37263d5c",
      "71a1af5309a64c28aaf54a20915955d243a42793bdf4154a3d52f6f3cf1997f6b2d3c6fc"
      "93353ab0f0d947138f7d3eccd1c4b35abbf0bc9ef3730e787e9b3cba"
      "36cb8dc7a223a3a1dbd391a93c1360b47268baa1c7c23e38fbe9010e3cadfdbbf5e4cff5"
      "8475f8fe83cae348961485695fdd008ffe9f77c0b3fcffd2a487cbff",
      "887012a90a0af1bde1735a79ac9f725db8bef7ee0b4d3cab756a5d70fbffc794c2422237"
      "162be5427c613cfb3086aa521cba75e1a8d405af71d6ef601fbf4dce"
      "936ba8ac58170dfd69d583f5a8c7dfd68baf1ef16e3ae05971b161d2838a8b6f8f5f2f3e"
      "daae6c0faf7fba339833e6f3242254f35e60bf375894f67de1d9e21e",
      "d5ba00497c8d2a9ed93ab52eb8bd2fa8f31c3711bc5598e7f3f2ccc8ddc8ea5a22f320f8"
      "ffd485a37afee9e77b81177137dfff2b7f0bb551dcb67c7f71ef23dd"
      "7c7f7e7b932a9ed93a35dfbbbd072c27462b91389a9dca95183c1d5dbea169e20c74f37d"
      "a79ffff6e47bfd81163d588f7a74f37dabbf2d4a3bdf5fa09def77fa",
      "06a8e299ad53f3bddbff7b25c7886399b2ca6457d1e4c8643c119c53e540e7e7fb5f7e04"
      "795f",
      ""};
  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(&data[0], 8056U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties(void)
{
  mxArray *xEntryPoints;
  mxArray *xInputs;
  mxArray *xResult;
  const char_T *propFieldName[7] = {
      "Version",      "ResolvedFunctions", "Checksum",    "EntryPoints",
      "CoverageInfo", "IsPolymorphic",     "PropertyList"};
  const char_T *epFieldName[6] = {
      "Name",           "NumberOfInputs", "NumberOfOutputs",
      "ConstantInputs", "FullPath",       "TimeStamp"};
  xEntryPoints =
      emlrtCreateStructMatrix(1, 1, 6, (const char_T **)&epFieldName[0]);
  xInputs = emlrtCreateLogicalMatrix(1, 23);
  emlrtSetField(xEntryPoints, 0, "Name", emlrtMxCreateString("trailer2_mei"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs",
                emlrtMxCreateDoubleScalar(23.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs",
                emlrtMxCreateDoubleScalar(3.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 0, "FullPath",
      emlrtMxCreateString(
          "E:"
          "\\\xe6\x88\x91\xe7\x9a\x84\xe6\x96\x87\xe4\xbb\xb6\\\xe5\xa4\xa7\xe5"
          "\xad\xa6\xe5\xad\xa6\xe4\xb9\xa0\\_\xe7\xa1\x95\xe5\xa3\xab"
          "\xe5\xad\xa6\xe4\xb9\xa0\\\xe6\xaf\x95\xe8\xae\xbe\xe7\xa1\x95\xe5"
          "\xa3\xab\\\xe8\xbd\xa6\xe8\xbe\x86\xe6\x8e\xa7\xe5\x88\xb6\xe7"
          "\xae\x97\xe6\xb3\x95\xe5\xbc\x80\xe5\x8f\x91\\EI Emergency "
          "Index\xe8\xaf\x84\xe4\xbb\xb7\xe6\x8c\x87\xe6\xa0\x87\\trailer-"
          "MEI\\t"
          "railer2_mei.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp",
                emlrtMxCreateDoubleScalar(739930.46194444445));
  xResult =
      emlrtCreateStructMatrix(1, 1, 7, (const char_T **)&propFieldName[0]);
  emlrtSetField(xResult, 0, "Version",
                emlrtMxCreateString("9.14.0.2206163 (R2023a)"));
  emlrtSetField(xResult, 0, "ResolvedFunctions",
                (mxArray *)emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "Checksum",
                emlrtMxCreateString("ja6MMyr9jRFfEvUW6flzBB"));
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

/* End of code generation (_coder_trailer2_mei_info.c) */
