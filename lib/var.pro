FUNCTION  var, arr, dim, $
          MIN=mn, MAX=mx, AVG=avg, SUM=sum, $
          MDEV=mdev, SDEV=sdev, COUNT=cnt, $
          _EXTRA=ex, QUIET=quiet

;+
; NAME:
;       var
;
; PURPOSE:
;       Returns the floating-point or double-precision
;       statistical unbiased sample variance.
;
; SYNTAX:
;       Result = VAR( Array [,Dimension] [,MIN=Variable] [,MAX=Variable] [,SUM=Variable] [,MDEV=Variable] [,SDEV=Variable] [,/NaN] [,/DOUBLE] )
;
; ARGUMENTS:
;       arr (IN:Array) An n-element, floating-point or double-precision array.
;       dim (IN:Value) Dimension over which variance will be computed
;
; KEYWORDS:
;       MIN (OUT:Variable) - Set this keyword to a named variable that will
;               contain the minimum of arr in dim.
;       MAX (OUT:Variable) - Set this keyword to a named variable that will
;               contain the maximum of arr in dim.
;       SUM (OUT:Variable) - Set this keyword to a named variable that will
;               contain the total of arr in dim.
;       AVG (OUT:Variable) - Set this keyword to a named variable that will
;               contain the average of arr in dim.
;       MDEV (OUT:Variable) - Set this keyword to a named variable that will
;               contain the mean absolute deviation of arr in dim.
;       SDEV (OUT:Variable) - Set this keyword to a named variable that will
;               contain the standard deviation of arr in dim.
;       COUNT (OUT:Variable) - Set this keyword to a named variable that will
;               contain total number of finite values        
;   See inherited keywords from total and average
;       /NaN - Ignore nans in calculation
;       /DOUBLE - Perform its computations in double precision arithmetic and
;               returns a double precision result. If this keyword is not set,
;               the computations and result depend upon the type of the input
;               data (integer and float data return float results,
;               while double data returns double results)
;				/QUIET - Suppress all compiler errors
;
; EXAMPLE:
;       See example procedure below
;     Create a [4,2,3] array
; IDL> x=[ [[2.0,3.0,4.2,1.1],[1.2,7.2,0.5,8.1]], $
;          [[0.8,0.3,5.4,2.3],[1.0,4.0,2.0,1.0]], $
;          [[3.0,2.0,1.0,3.0],[2.0,3.0,4.0,7.0]] ]
; IDL> print,var(x)
;       4.79216
; IDL> print,var(x,1)
;       1.77583      15.6300
;       5.27333      2.00000
;      0.916667      4.66667
; IDL> print,var(x,2)
;      0.320000      8.82000      6.84500      24.5000
;     0.0200000      6.84500      5.78000     0.845000
;      0.500000     0.500000      4.50000      8.00000
; IDL> print,var(x,3)
;       1.21333      1.86333      5.17333     0.923333
;      0.280000      4.81333      3.08333      14.6033
;
; EXTERNAL ROUTINES:
;       None.
;
; WARNING:
;       This function if compatible with native IDL. Met Office users
;       are advised to SWITCH OFF WAVE mode if running on TIDL;
;       Ps: I have not checked if WAVEON causes any discrepancies.
;
; CATEGORY:
;       Statistics
; -------------------------------------------------------------------------
; $Id: var.pro,v0.1  2010-02-19 11:02:48 yaswant Exp $
; var.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification:
; 2010-02-22 18:29:26 Use temporary for memory efficiency. YP
; 2010-02-22 18:29:26 No external routine dependecies. YP
; 2010-02-22 18:29:26 Add MIN MAX SUM keywords. YP
; 2010-06-21 10:46:26 Bug fix for 1D array keyword variables. YP
;                     Added quiet keyword. YP
; 2010-07-02 17:16:26 Add COUNT keyword. YP 
; 2010-11-29 14:46:34 Bug Fix for Count in conjunction with NaN. YP                    
; -------------------------------------------------------------------------
;-

  def__quiet	= !QUIET
  if keyword_set(quiet) then !QUIET = 1

  Syntax = 'Result = VAR( Array [,Dimension] [,MIN=Variable] [,MAX=Variable] [,AVG=Variable] '+$
           '[,SUM=Variable] [,MDEV=Variable] [,SDEV=Variable] [,COUNT=Variable] [,/NaN] [,/DOUBLE] [,/QUIET])'
  if n_params() lt 1 then message, Syntax

  typ   = size(arr, /TYPE)
  if typ gt 5 then message,'Error! Incorrect data type.'

; Check if argument <dim> passed correctly
  dim = (n_elements(dim) gt 0) ? (dim > 0) : 0
  
  if dim eq 0 then begin
    if ~keyword_set(quiet) then print,' Warning! Dim set to 0.'
    mom = moment(arr, SDEV=sdev, MDEV=mdev, _EXTRA=ex)
		mn  = min(arr, MAX=mx, _EXTRA=ex)    
    sum	= total(arr, _EXTRA=ex)
    avg	= mom[0]
    cnt = long(total(finite(arr)))
    if keyword_set(quiet) then !QUIET = def__quiet
    return, mom[1]
  endif
; -------------------------------------------------------------------------


; Get Input array definition
  ndim  = size(arr, /N_DIMENSIONS)
  dims  = size(arr, /DIMENSIONS)
  nel   = size(arr, /N_ELEMENTS)


; Reform original data array to reduce dimensions
  idx = lindgen(ndim)
  a   = where(idx eq dim-1,na, COMPLEMENT=b, NCOMPLEMENT=nb)

  tidx  = [a,b]                           ; new array index for transposition
  tarr  = transpose(arr, tidx)            ; transposed array to 2D

  d1    = dims[dim-1]                     ; total elements over working dim
  d2    = nel/d1                          ; total elements over other dim(s)
  rtarr = reform(temporary(tarr),d1,d2)   ; reform transposed array to 2D


; Get average of array over prescribed dim
; Transform average array to match transformed array

  avg	= total(arr, dim, _EXTRA=ex) / $
         (total(finite(arr), dim)>1)

; Number of elements (Samples):
  cnt = long((total(finite(arr), dim)>0))

; Minimum value:  
  if arg_present(mn) then mn	= min(arr, DIM=dim, _EXTRA=ex)

; Maximum value:
  if arg_present(mx) then mx	= max(arr, DIM=dim, _EXTRA=ex)

; Total:
  if arg_present(sum) then sum	= total(arr, dim, _EXTRA=ex)

; Average value:
  ravg  = transpose( rebin(avg[*],d2,d1) )

; Mean Absolute Deviation:
  if arg_present(mdev) then $	
  mdev  = reform( total(abs(rtarr-ravg), 1, _EXTRA=ex ) / $
                  (d1 > 1), dims[b] )

; Unbiased Sample Variance:
  vari  = total( (temporary(rtarr)-temporary(ravg))^2., 1, _EXTRA=ex ) / $
          (d1-1 > 1)

; Unbiased Standard Deviation
  if arg_present(sdev) then sdev  = reform( sqrt(vari), dims[b] )

; Return variance
  if keyword_set(quiet) then !QUIET = def__quiet
  return, reform( vari, dims[b] )

END
; -------------------------------------------------------------------------




; How to call from a procedure?
; IDL> test_vari, [1|2|3|4]
pro test_vari, dim

  ;test=findgen(100,20,17,2)
  x=randomn(seed,3,2,1,3)
  print,var(x, dim, AVG=av, MIN=mn, MAX=mx, SDEV=sd, MDEV=md, SUM=tot,/NAN)

	help,av
	print,mn,mx,sd,av,md,tot
end
