FUNCTION scale2interval, array, intervals, POSITION=pos, PDF=pdf
;+
; :NAME:
;     scale2interval
;
; :PURPOSE:
;     Scales an input array to monotonically increasing interval values.
;     Optionally returns the array positions mapped on to the intervals.
;
; :SYNTAX:
;     Result = SCALE2INTERVAL( Array, intervals [,POSITION=Variable] [,PDF=Variable])
;
;  :PARAMS:
;    array (IN: Array) Input array to rescale to given intervals    
;    intervals (IN: Array) Interval array to which the Array will be mapped
;
;
;  :KEYWORDS:
;    POSITION (OUT: Variable) A named variable to store the positions of Array
;             values in the interval table.
;    PDF (OUT:  Variable) A named variable to store the probability distribution
;             of scaled array.
;
; :REQUIRES:
;     None
;
; :EXAMPLES:
; IDL> data = [ 1., 2.3, 4.9, 5., 0.6, 9.7, 3.4]
; IDL> interval = [ 2., 4., 6., 8. ]
; IDL> print, scale2interval( data, interval, POS=p)
;       2.00000 2.00000  4.00000  4.00000 2.00000 8.00000 4.00000
; IDL> print,p
;       0 0 1 1 0 3 1
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  19-Jun-2009 12:38:40 Created. Yaswant Pradhan.
;
;-

  if( N_PARAMS() LT 2 ) then $
  message,' Syntax: Result = SCALE2INTERVAL( Array, Intervals [,POSITION=Variable] [,PDF=Variable] )'
    
  pos = VALUE_LOCATE( intervals, array )  
  scaled_data = intervals[pos]
  
  if ARG_PRESENT(pdf) then begin    
    pdf = MAKE_ARRAY(N_ELEMENTS(intervals))
    for i=0,N_ELEMENTS(intervals)-1 do begin
      doit = WHERE(scaled_data eq intervals[i], n)
      pdf[i] = n
    endfor
  endif
  
  return, scaled_data
  
END
