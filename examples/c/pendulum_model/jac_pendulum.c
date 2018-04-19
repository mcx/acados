/* This file was automatically generated by CasADi.
   The CasADi copyright holders make no ownership claim of its contents. */
#ifdef __cplusplus
extern "C" {
#endif

/* How to prefix internal symbols */
#ifdef CODEGEN_PREFIX
  #define NAMESPACE_CONCAT(NS, ID) _NAMESPACE_CONCAT(NS, ID)
  #define _NAMESPACE_CONCAT(NS, ID) NS ## ID
  #define CASADI_PREFIX(ID) NAMESPACE_CONCAT(CODEGEN_PREFIX, ID)
#else
  #define CASADI_PREFIX(ID) jac_pendulum_ ## ID
#endif

#include <math.h>

#ifndef casadi_real
#define casadi_real double
#endif

#ifndef casadi_int
#define casadi_int int
#endif

/* Add prefix to internal symbols */
#define casadi_f0 CASADI_PREFIX(f0)
#define casadi_s0 CASADI_PREFIX(s0)
#define casadi_s1 CASADI_PREFIX(s1)
#define casadi_s2 CASADI_PREFIX(s2)

static const casadi_int casadi_s0[8] = {4, 1, 0, 4, 0, 1, 2, 3};
static const casadi_int casadi_s1[5] = {1, 1, 0, 1, 0};
static const casadi_int casadi_s2[23] = {4, 4, 0, 4, 8, 12, 16, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3};

/* jacFun:(i0[4],i1)->(o0[4],o1[4x4]) */
static int casadi_f0(const casadi_real** arg, casadi_real** res, casadi_int* iw, casadi_real* w, void* mem) {
  casadi_real a0, a1, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a2, a20, a21, a22, a23, a24, a25, a3, a4, a5, a6, a7, a8, a9;
  a0=arg[0] ? arg[0][1] : 0;
  if (res[0]!=0) res[0][0]=a0;
  a0=-8.0000000000000016e-02;
  a1=arg[0] ? arg[0][2] : 0;
  a2=sin(a1);
  a2=(a0*a2);
  a3=arg[0] ? arg[0][3] : 0;
  a4=(a2*a3);
  a5=(a4*a3);
  a6=9.8100000000000009e-01;
  a7=cos(a1);
  a7=(a6*a7);
  a8=sin(a1);
  a9=(a7*a8);
  a5=(a5+a9);
  a9=arg[1] ? arg[1][0] : 0;
  a5=(a5+a9);
  a10=1.1000000000000001e+00;
  a11=1.0000000000000001e-01;
  a12=cos(a1);
  a12=(a11*a12);
  a13=cos(a1);
  a14=(a12*a13);
  a10=(a10-a14);
  a5=(a5/a10);
  if (res[0]!=0) res[0][1]=a5;
  if (res[0]!=0) res[0][2]=a3;
  a14=cos(a1);
  a14=(a0*a14);
  a15=sin(a1);
  a16=(a14*a15);
  a17=(a16*a3);
  a18=(a17*a3);
  a19=cos(a1);
  a19=(a9*a19);
  a18=(a18+a19);
  a19=1.0791000000000002e+01;
  a20=sin(a1);
  a20=(a19*a20);
  a18=(a18+a20);
  a20=8.0000000000000004e-01;
  a21=(a20*a10);
  a18=(a18/a21);
  if (res[0]!=0) res[0][3]=a18;
  a22=0.;
  if (res[1]!=0) res[1][0]=a22;
  if (res[1]!=0) res[1][1]=a22;
  if (res[1]!=0) res[1][2]=a22;
  if (res[1]!=0) res[1][3]=a22;
  a23=1.;
  if (res[1]!=0) res[1][4]=a23;
  if (res[1]!=0) res[1][5]=a22;
  if (res[1]!=0) res[1][6]=a22;
  if (res[1]!=0) res[1][7]=a22;
  if (res[1]!=0) res[1][8]=a22;
  a24=cos(a1);
  a24=(a0*a24);
  a24=(a3*a24);
  a24=(a3*a24);
  a25=cos(a1);
  a7=(a7*a25);
  a25=sin(a1);
  a6=(a6*a25);
  a8=(a8*a6);
  a7=(a7-a8);
  a24=(a24+a7);
  a24=(a24/a10);
  a5=(a5/a10);
  a7=sin(a1);
  a11=(a11*a7);
  a13=(a13*a11);
  a11=sin(a1);
  a12=(a12*a11);
  a13=(a13+a12);
  a5=(a5*a13);
  a24=(a24-a5);
  if (res[1]!=0) res[1][9]=a24;
  if (res[1]!=0) res[1][10]=a22;
  a24=cos(a1);
  a14=(a14*a24);
  a24=sin(a1);
  a0=(a0*a24);
  a15=(a15*a0);
  a14=(a14-a15);
  a14=(a3*a14);
  a14=(a3*a14);
  a15=sin(a1);
  a9=(a9*a15);
  a14=(a14-a9);
  a1=cos(a1);
  a19=(a19*a1);
  a14=(a14+a19);
  a14=(a14/a21);
  a18=(a18/a21);
  a20=(a20*a13);
  a18=(a18*a20);
  a14=(a14-a18);
  if (res[1]!=0) res[1][11]=a14;
  if (res[1]!=0) res[1][12]=a22;
  a2=(a3*a2);
  a2=(a2+a4);
  a2=(a2/a10);
  if (res[1]!=0) res[1][13]=a2;
  if (res[1]!=0) res[1][14]=a23;
  a3=(a3*a16);
  a3=(a3+a17);
  a3=(a3/a21);
  if (res[1]!=0) res[1][15]=a3;
  return 0;
}

int jacFun(const casadi_real** arg, casadi_real** res, casadi_int* iw, casadi_real* w, void* mem){
  return casadi_f0(arg, res, iw, w, mem);
}

void jacFun_incref(void) {
}

void jacFun_decref(void) {
}

casadi_int jacFun_n_in(void) { return 2;}

casadi_int jacFun_n_out(void) { return 2;}

const char* jacFun_name_in(casadi_int i){
  switch (i) {
    case 0: return "i0";
    case 1: return "i1";
    default: return 0;
  }
}

const char* jacFun_name_out(casadi_int i){
  switch (i) {
    case 0: return "o0";
    case 1: return "o1";
    default: return 0;
  }
}

const casadi_int* jacFun_sparsity_in(casadi_int i) {
  switch (i) {
    case 0: return casadi_s0;
    case 1: return casadi_s1;
    default: return 0;
  }
}

const casadi_int* jacFun_sparsity_out(casadi_int i) {
  switch (i) {
    case 0: return casadi_s0;
    case 1: return casadi_s2;
    default: return 0;
  }
}

int jacFun_work(casadi_int *sz_arg, casadi_int* sz_res, casadi_int *sz_iw, casadi_int *sz_w) {
  if (sz_arg) *sz_arg = 2;
  if (sz_res) *sz_res = 2;
  if (sz_iw) *sz_iw = 0;
  if (sz_w) *sz_w = 0;
  return 0;
}


#ifdef __cplusplus
} /* extern "C" */
#endif
