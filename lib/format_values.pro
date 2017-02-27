function format_values, Array, DecimalPlace, AXISV=axisv
;+
; :NAME:
;    	format_values
;
; :PURPOSE:
;     The FORMAT_VALUES function converts a scalar/array of numeric values
;     into a scaler/array of string value(s).
;
; :SYNTAX:
;     Result = FORMAT_VALUES( Array [,DecimalPlace] [,/AXISV] )
;
;
;	 :PARAMS:
;    Array (IN:Array) A numeric array
;          
;    DecimalPlace (IN:Value) Corp to this decimal place. Rounding-off 
;             will take place only if /AXISV keyword is present. 
;
;
;  :KEYWORDS:
;    AXISV    Return a vector of formmated string values. Note: each elements
;             in the output array will have equal width in this case.
;             See help on intrinsic FORMAT_AXIS_VALUES function. 
;
; :REQUIRES:
;     is_defined.pro
;
; :EXAMPLES:
;   IDL> print, format_values( [1.2, 3, 2.09, 100.01, -20.02] )
;         1.2 3 2 100 -20
;   IDL> print, format_values( [1.2, 3, 2.09, 100.01, -20.02], 2 )
;         1.20 3 2.09 100.01 -20.02
;   IDL> print, format_values( [1.2, 3, 2.09, 100.01, -20.02], 3, /ax )
;         1.2 3.0 2.0 100 -20
;
;
; :CATEGORIES:
;     String manipulaion, Data formatting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  01-Sep-2009 18:28:03 Created. Yaswant Pradhan.
;  06-Oct-2011 Update header. YP.
;
;-

; Parse arguments:
  dp      = keyword_set(DecimalPlace) ? DecimalPlace : 1
  if keyword_set(axisv) then return, strmid(format_axis_values(Array),0,dp)
  
  base    = fix( Array )          ; integer part of the array
  nl      = n_elements(Array)     ; numer of elements in array
  flt     = Array mod 1           ; floating part of the array
  p       = where( flt ne 0, np ) ; perfect integer values in the array
  out     = strtrim(base,2)
  flt_str = strtrim(string(flt,format='(f13.6)'), 2)


; Fix negative zero values:
  nzero   = where( base eq 0 and Array lt 0., nnz )
  base    = strtrim( base,2 )
  if (nnz gt 0) then base[nzero] = '-'+base[nzero]


; Handle floating part of the elements:
  if ((np gt 0) and (dp ne 0)) then begin
    flt_str1 = strmid(flt_str, strpos(flt_str,'.')+1)

    for i=0,nl-1 do for j=0,nl-1 do if (i eq j) then $
    flt_str[j] = flt_str1[i,j]
      
    out[p]  = base[p]+'.'+strmid(flt_str[p],0,dp)
   
  ; Now fix the floating part of formmated strings only if 
  ; all values after the decimal place are zeros:
    out_flt = double(out) mod 1
    x = where( out_flt eq 0, nx )
   
    if (nx gt 0) then out[x] = strtrim(fix(out[x]), 2)

    return, out
  endif else return, base

end
