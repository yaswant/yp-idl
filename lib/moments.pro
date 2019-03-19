;+
; :NAME:
;     moments
;
; :PURPOSE:
;     The MOMENTS function computes the mean, variance, skewness, and kurtosis
;     of a sample population contained in an Array in any dimension. This is
;     an enhancement to IDL's native MOMENT function.
;
; :SYNTAX:
;     Result = MOMENTS( Array [,Dimension] [,MDEV=Variable] [,SDEV=Variable]
;                         [,/NaN] [,/DOUBLE] )
;
;
;  :PARAMS:
;     arr (IN:Array) An n-element, floating-point or double-precision array.
;     dim (IN:Value) Dimension over which statistical moments will be computed.
;
;
;  :KEYWORDS:
;     MDEV (OUT:Variable) Set this keyword to a named variable that will
;               contain the mean absolute deviation of arr.
;     SDEV (OUT:Variable) Set this keyword to a named variable that will
;               contain the standard deviation of arr.
;     _EXTRA    See  inherited keywords from MOMENT, total and average:
;       /NaN    Ignore nans in calculation
;       /DOUBLE Perform its computations in double precision arithmetic and
;               returns a double precision result. If this keyword is not set,
;               the computations and result depend upon the type of the input
;               data (integer and float data return float results,
;               while double data returns double results)
;
;
; :REQUIRES:
;     average.pro
;
; :EXAMPLES:
;     See "test_moms" procedure below
; Create a [4,2,3] array
; IDL> x=[ [[2.0,3.0,4.2,1.1],[1.2,7.2,0.5,8.1]], $
;          [[0.8,0.3,5.4,2.3],[1.0,4.0,2.0,1.0]], $
;          [[3.0,2.0,1.0,3.0],[2.0,3.0,4.0,7.0]] ]
;
; IDL> help, moments(x),/struct
;  Warning! Dim set to 0.
; ** Structure <>, 4 tags, length=16, data length=16, refs=1:
;    MEAN            FLOAT           2.87917
;    VARIANCE        FLOAT           4.79216
;    SKEWNESS        FLOAT          0.958398
;    KURTOSIS        FLOAT         -0.134541
;
; IDL> help, moments(x,1),/struct
; ** Structure <>, 4 tags, length=96, data length=96, refs=1:
;    MEAN            FLOAT     Array[2, 3]
;    VARIANCE        FLOAT     Array[2, 3]
;    SKEWNESS        FLOAT     Array[2, 3]
;    KURTOSIS        FLOAT     Array[2, 3]
;
; IDL> help, moments(x,2),/struct
; ** Structure <>, 4 tags, length=192, data length=192, refs=1:
;    MEAN            FLOAT     Array[4, 3]
;    VARIANCE        FLOAT     Array[4, 3]
;    SKEWNESS        FLOAT     Array[4, 3]
;    KURTOSIS        FLOAT     Array[4, 3]
;
; IDL> help, moments(x,3, SDEV=sd, MDEV=md, /NaN, /DOUBLE),/struct
; ** Structure <>, 4 tags, length=256, data length=256, refs=1:
;    MEAN            DOUBLE    Array[4, 2]
;    VARIANCE        DOUBLE    Array[4, 2]
;    SKEWNESS        DOUBLE    Array[4, 2]
;    KURTOSIS        DOUBLE    Array[4, 2]
;
; IDL> help,md,sd
;   MD              DOUBLE    = Array[4, 2]
;   SD              DOUBLE    = Array[4, 2]
;
;
; WARNING:
;   1.  This function is compatible with native IDL. Met Office users are
;       advised to SWITCH OFF WAVE mode if running on TIDL;
;   2.  Be aware of the memory issues when dealing with large data set.
;       MOMENTS function requires 6 times input array size + for array
;       operations (transpose). Within these limits, this function should
;       always perform better than loop approaches; See results below for
;       a huge (~75 million elements) floating point array:
; IDL> tic & x=randomn(seed,20,10,62,23,11,3,8) & toc
;       Elapsed time: 00:00:07.54
; IDL> tic & p=moments(x,1) & toc
;       Elapsed time: 00:00:10.08
;
; :CATEGORIES:
;   Statistics
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  19-Feb-2010 11:02:48 Created. Yaswant Pradhan.
;  09-Sep-2011 Code clean. YP
;
;-
FUNCTION  moments, arr, dim, $
          MDEV=mdev, SDEV=sdev, _EXTRA=ex


  ; Parse Inputs
  Syntax =' Result = MOMENTS( Array [,Dimension] [,MDEV=Variable]'+$
          ' [,SDEV=Variable] [,/NaN] [,/DOUBLE] )'

  if (n_params() lt 1) then message, Syntax
  if (size(arr,/TYPE) gt 5) then message,'Error! Incorrect data type.'

  ; Check if argument <dim> passed correctly:
  dim = (n_elements(dim) gt 0) ? (dim > 0) : 0

  ; If dimension argument is not present, then return moment of the
  ; whole array using IDL native moment function:
  if (dim eq 0) then begin
    print,' Warning! Dim set to 0.'
    m = moment(arr, MDEV=mdev, SDEV=sdev, _EXTRA=ex)
    return, {mean:m[0], variance:m[1], skewness:m[2], kurtosis:m[3]}
  endif


  ; Get Input array definition:
  ndim  = size(arr, /N_DIMENSIONS)
  dims  = size(arr, /DIMENSIONS)
  nel   = size(arr, /N_ELEMENTS)

  if (dim gt ndim) then $
  message,'Error! dim should be <= '+strtrim(ndim,2)

  ; Reform original data array to reduce dimensions:
  idx = lindgen(ndim)
  a   = where(idx eq dim-1,na, COMPLEMENT=b, NCOMPLEMENT=nb)

  tidx  = [a,b]                 ; new array index for transposition
  tarr  = transpose(arr, tidx)  ; transposed array to 2D
  d1    = dims[dim-1]           ; total elements over working dim
  d2    = nel/d1                ; total elements over other dim(s)
  rtarr = reform(tarr,d1,d2)    ; reform transposed array to 2D


  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; OUTPUTS:
  ;   - Get average of array over prescribed dim
  ;   - Transform average array to match transformed array
  ;   - Calculate Unbiased Sample variance.
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; [1] Average:
  avg   = average(arr, dim, _EXTRA=ex)
  ravg  = transpose( rebin(avg[*],d2,d1) )

  ; [2] Unbiased Sample Variance:
  vari  = total( (rtarr-ravg)^2., 1, _EXTRA=ex ) / $
                 (d1-1 > 1)

  rvari = transpose( rebin(vari[*],d2,d1) )

  ; [3] Standard Deviation:
  if arg_present(sdev) then $
  sdev  = reform( sqrt(vari), dims[b] )

  ; [4] Mean Absolute Deviation:
  if arg_present(mdev) then $
  mdev  = reform( total(abs(rtarr-ravg), 1, _EXTRA=ex ) / $
                  (d1 > 1), dims[b] )

  ; [5] Skewness:
  skew  = d1 gt 1 ? $
          reform( total( ((rtarr-ravg)/sqrt(rvari))^3., 1, $
                  _EXTRA=ex ) / (d1 > 1), dims[b] )      : $
          reform( make_array(d2, _EXTRA=ex), dims[b] )
  ;           reform( replicate(0,d2), dims[b] )
  ; Note: Using replicate() over make_array() could be ~10% faster
  ; but will ignore the output data type if dim = 1.

  ; [6] Kurtosis:
  kurto = d1 gt 1 ? $
          reform( (total( ((rtarr-ravg)/sqrt(rvari))^4., 1, $
                  _EXTRA=ex ) / (d1 > 1)) - 3., dims[b] ) : $
          reform( make_array(d2, _EXTRA=ex), dims[b] )
          ; reform( replicate(0,d2), dims[b] )


  return, { mean      : avg,  $
            variance  : reform(vari,dims[b]), $
            skewness  : skew, $
            kurtosis  : kurto }

END
;------------------------------------------------------------------------------

; How to call from a procedure?
; IDL> test_vari, [1|2|3|4]
pro test_moms, dim

  ;test=findgen(100,20,17,2)
  x=randomn(seed,3,2,1,3)
  helps,moments(x, dim)

end
