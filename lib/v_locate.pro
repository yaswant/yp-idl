;+
; NAME:
;   V_LOCATE
;   The V_LOCATE function finds the intervals within a given monotonic vector
;   that brackets a given set of one or more search values. This function is
;   useful for interpolation and table-lookup, and is an adaptation of the
;   value_locate() that uses the bisection method to locate the interval routine in IDL.
;
; PURPOSE:
;   To find closest indices in Vector1 (Vector) corresponding to Vector2 (Value).
;   Vector1 must be monotonically increasing or decreasing, otherwise a sort vector
;   should be passed.
;
; SYNTAX:
;   Result = V_LOCATE ( Vector, Value [,/SORT ] ) OR
;   Result = V_LOCATE ( Vector, Value [ SORT=variable ] )
;
; RETURN VALUE:
;   Each return value, Result [i], is an index, j, into Vector,
;   corresponding to the interval into which the given Value [i] falls.
;   The returned values are in the range 0 <= j <= N-1, where N is the number of elements in the input vector.
;
; ARGUMENTS:
; Vector - A vector of monotonically increasing or decreasing values.
;       Vector may be of type string, or any numeric type except complex,
;       and may not contain the value NaN (not-a-number).
; Value - The value for which the location of the intervals is to be computed.
;       Value may be either a scalar or an array. The return value will contain
;       the same number of elements as this parameter.
;
; KEYWORDS:
; SORT - Sort Vector before proceed
; TIDL - Set this Keyword for Met Office tidl compatibility
;         Note: tidl and idl handle the min() function's dimension keyword differently
; REQUIRES:
;   waveon_tidl.pro
;
; EXAMPLE:
;   Define a vector of values.
; IDL> vec = [2,5,8,10]
;   Compute location of other values within that vector.
; IDL> loc = V_LOCATE(vec, [0,3,5,6,12])
; IDL> PRINT, loc
;   IDL prints:
;   0   0   1   1   3

; $Id: V_LOCATE.pro,v 1.0 03/04/2008 09:53 yaswant Exp $
; V_LOCATE.pro Yaswant Pradhan
; Last modIFication: Apr 08
;-

function v_locate, vector, value, SORT=s, TIDL=tidl

  syntax  = 'Result = V_LOCATE( Vector,Value [,/SORT | SORT=Variable] )'

  ; Parse input and Resolve TIDL
  if n_params() lt 2 then message, syntax

  tidl  = keyword_set(tidl) ; or waveon_tidl()
  nf    = n_elements(value) ; Number of samples in vector2 (or value)
  srt   = keyword_set(s) || arg_present(s)

  ; Sort vector if required
  if srt && n_elements(s) ne n_elements(vector) then s=sort(vector)

  ; Use value_locate to get the nearest intigerised version of
  ; nearest location
  vl  = value_locate( srt ? vector[s] : vector, value )
  xb  = [[vl>0],[(vl+1)<(n_elements(vector)-1)]]

  ; See MetOffice TIDL MIN() function's dimension keyword parameter
  mn  = reform( min( $
        abs((srt ? vector[s[xb]] : vector[xb])-rebin([value],nf,2)), $
             DIMENSION=( tidl ? 1 : 2), pos ) )

  ;print,'MN, POS : ',mn,pos
  pos = vl > 0 + pos / nf

  return, srt ? s[pos] : pos

end
