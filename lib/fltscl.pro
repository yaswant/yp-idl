;+
; :NAME:
;     fltscl
;
; :PURPOSE:
;     The FLTSCL function scales all values in an Array that lie in the
;     range (Min <= x <= Max)  into the range (low <= x <= High).
;
; :SYNTAX:
;     Result = FLTSCL( Array [[,High=Value] [,LOW=Value]] [,/CLIP_LIMIT]
;                     [DELTA=Variable])
;
;  :PARAMS:
;    Array (IN:Array) Input array to be scaled.
;
;
;  :KEYWORDS:
;    HIGH (IN:Value) Set this keyword to the maximum value of the output
;                 scaled Array, default is 1.
;    LOW (IN:Value) Set this keyword to the maximum value of the output
;                 scaled Array, default is 0
;    /CLIP_LIMIT -Adds high and low values to the data series before scaling.
;    DELTA (OUT:Variable) Depricated. Think what can be stored an array of
;                 derivatives? A named variable to return the value of
;                 interval for regularly spaced Array.
;    /RELAX - When HIGH < LOW, using this keyword reverses the values and
;                 carry on scaling the data (assuming this as a human error).
;
; :REQUIRES:
;   is_defined.pro
;
; :EXAMPLES:
;   IDL> print,fltscl([1,2,3,4,5,6])
;   0.00000     0.200000     0.400000     0.600000     0.800000      1.00000
;
;   IDL> print,fltscl([1,2,3,4,5,6],/clip)
;   0.166667     0.333333     0.500000     0.666667     0.833333      1.00000
;   This is equivalent to fltscl([[0],1,2,3,4,5,6,[1]]) with 1st and last
;   element removed
;
;   IDL> print,fltscl([1,2,3,4,5,6],low=10,high=20)
;   10.0000      12.0000      14.0000      16.0000      18.0000      20.0000
;
;   IDL> print,fltscl([1,2,3,4,5,6],low=10,high=20,/clip)
;   10.0000      10.5263      11.0526      11.5789      12.1053      12.6316
;   This is equivalent to fltscl([[10],1,2,3,4,5,6,[20]]) with 1st and last
;   element removed
;
;
; :CATEGORIES:
;     Numerical scaling
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  07-Mar-2007 09:22:11 Created. Yaswant Pradhan. U Plymouth.
;  xx-Mar-2009 Added CLIP_LIMIT keyword. YP.
;  xx-Apr-2009 Added DELTA keyword. YP.
;  16-Feb-2010 Several bug fixes for 1-element and uniq array. YP.
;  13-Oct-2010 Added RELAX keyword. YP.
;
;-

FUNCTION fltscl,  Array, HIGH=high, LOW=low, CLIP_LIMIT=clip_limit, $
                  DELTA=delta, RELAX=relax

  ; Parse input:
  Syntax =' Result = FLTSCL( Array [[,HIGH=Value] [,LOW=Value]]' +$
          ' [,/CLIP_LIMIT] [,DELTA=Variable] [,/RELAX])'
  if(n_params() LT 1) then message, Syntax

  low     = is_defined(low)   ? low   : 0.
  high    = is_defined(high)  ? high  : 1.
  rev     = 0b

  if (low gt high) then begin
    if keyword_set(relax) then begin
      rev = 1b
      l1  = low
      h1  = high
      high= l1
      low = h1
    endif else message,'[FLTSCL] High < Low.'
  endif

  clip    = keyword_set(clip_limit)


  ; For scalar input return 0
  if n_elements(Array) eq 1 then begin
    if keyword_set(relax) then begin
      delta = 0
      return, mean([high,low],/NaN)
    endif else begin
      delta = 0
      return, 0.
    endelse
  endif


  Array   = clip ? [low, high, float(Array)] : float(Array)
  Range   = max(Array,/NaN) - min(Array,/NaN)   ; Input data range
  uRange  = (high gt low) ? (high-low) : low    ; User defined range

  if ((high eq low) and ~keyword_set(relax)) then $
     return, replicate(high,n_elements(Array))


  ; Scale input data between data Range
  x     = (n_elements(uniq(Array)) eq 1)  ? $
          replicate(0.,n_elements(Array)) : $
          (Array - min(Array,/NaN)) / Range

  x2    = clip ? (x*uRange)[2:*] : x * uRange
  Array = clip ? Array[2:*] : Array   ; Set back the original Array
  delta = x2[1] - x2[0]

  ; delta = clip ? (x2[3]-x2[2]) : (x2[1]-x2[0])
  ; return, clip ? [x2[2:*] + low ] : [x2 + low]
  return, rev ? reverse(x2 + low) : x2 + low

END
